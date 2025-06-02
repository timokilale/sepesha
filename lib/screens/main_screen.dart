import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/secret_variables.dart';
import 'package:sepesha_app/models/direction_model.dart';
import 'package:sepesha_app/models/predicted_places.dart';
import 'package:sepesha_app/screens/info_handler/app_info.dart';
import 'package:sepesha_app/service/request_assistance.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late AppInfo _appInfo;
  final loc.Location location = loc.Location();
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Position? _userCurrentPosition;
  final Geolocator _geoLocator = Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  List<PredictedPlaces> _pickupPredictedPlaces = [];
  List<PredictedPlaces> _dropoffPredictedPlaces = [];
  bool _showPickupSuggestions = false;
  bool _showDropoffSuggestions = false;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  FocusNode _pickupFocusNode = FocusNode();
  FocusNode _dropoffFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _appInfo = Provider.of<AppInfo>(context, listen: false);
    _setupFocusNodes();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _checkLocationPermission();
    await _locateUserPosition();
    await _setCurrentLocationAsDefault();
  }

  void _setupFocusNodes() {
    _pickupFocusNode.addListener(() {
      if (!_pickupFocusNode.hasFocus) {
        setState(() => _showPickupSuggestions = false);
      }
    });

    _dropoffFocusNode.addListener(() {
      if (!_dropoffFocusNode.hasFocus) {
        setState(() => _showDropoffSuggestions = false);
      }
    });
  }

  Future<void> _checkLocationPermission() async {
    _locationPermission = await Geolocator.checkPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
      if (_locationPermission != LocationPermission.whileInUse &&
          _locationPermission != LocationPermission.always) {
        return;
      }
    }
  }

  Future<void> _locateUserPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    Position cPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _userCurrentPosition = cPosition;

    if (newGoogleMapController != null) {
      newGoogleMapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(cPosition.latitude, cPosition.longitude)),
      );
    }
  }

  Future<void> _setCurrentLocationAsDefault() async {
    if (_userCurrentPosition != null) {
      try {
        List<geocoding.Placemark> placemarks = await geocoding
            .placemarkFromCoordinates(
              _userCurrentPosition!.latitude,
              _userCurrentPosition!.longitude,
            );

        String address =
            placemarks.isNotEmpty
                ? "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}"
                : "Current Location";

        _pickupController.text = address;
        _updatePickupLocation(
          LatLng(
            _userCurrentPosition!.latitude,
            _userCurrentPosition!.longitude,
          ),
          address,
        );
      } catch (e) {
        print("Error getting address: $e");
        _pickupController.text = "Current Location";
        _updatePickupLocation(
          LatLng(
            _userCurrentPosition!.latitude,
            _userCurrentPosition!.longitude,
          ),
          "Current Location",
        );
      }
    }
  }

  Future<void> _findPlaceAutoCompleteSearch(
    String inputText,
    bool isPickup,
  ) async {
    if (inputText.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:TZ';

      var response = await RequestAssistance.receiveRequest(url);

      if (response == 'Error occurred. Failed to receive request.') return;

      if (response["status"] == "OK") {
        var predictions = response["predictions"];
        var placesList =
            (predictions as List)
                .map((e) => PredictedPlaces.fromJson(e))
                .toList();

        setState(() {
          if (isPickup) {
            _pickupPredictedPlaces = placesList;
            _showPickupSuggestions = true;
          } else {
            _dropoffPredictedPlaces = placesList;
            _showDropoffSuggestions = true;
          }
        });
      }
    }
  }

  Future<void> _getPlaceDirectionDetails(String placeId, bool isPickup) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';

    var response = await RequestAssistance.receiveRequest(url);

    if (response == 'Error occurred. Failed to receive request.') return;

    if (response["status"] == "OK") {
      DirectionModel directionModel = DirectionModel();
      directionModel.locationName = response["result"]["name"];
      directionModel.locationId = placeId;
      directionModel.locationLatitude =
          response["result"]["geometry"]["location"]["lat"];
      directionModel.locationLongitude =
          response["result"]["geometry"]["location"]["lng"];

      LatLng latLng = LatLng(
        directionModel.locationLatitude!,
        directionModel.locationLongitude!,
      );

      if (isPickup) {
        _updatePickupLocation(latLng, directionModel.locationName!);
        _pickupController.text = directionModel.locationName!;
      } else {
        _updateDropoffLocation(latLng, directionModel.locationName!);
        _dropoffController.text = directionModel.locationName!;
      }

      if (_appInfo.userPickUpLocation != null &&
          _appInfo.UserDropOffLocation != null) {
        await _drawRoute();
      }

      setState(() {
        if (isPickup) {
          _showPickupSuggestions = false;
        } else {
          _showDropoffSuggestions = false;
        }
      });
    }
  }

  void _updatePickupLocation(LatLng latLng, String locationName) {
    DirectionModel pickupLocation = DirectionModel();
    pickupLocation.locationName = locationName;
    pickupLocation.locationLatitude = latLng.latitude;
    pickupLocation.locationLongitude = latLng.longitude;
    _appInfo.updatePickupLocationAddress(pickupLocation);

    _addMarker(
      latLng,
      "Pickup",
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
  }

  void _updateDropoffLocation(LatLng latLng, String locationName) {
    DirectionModel dropoffLocation = DirectionModel();
    dropoffLocation.locationName = locationName;
    dropoffLocation.locationLatitude = latLng.latitude;
    dropoffLocation.locationLongitude = latLng.longitude;
    _appInfo.updateDropOffLocationAddress(dropoffLocation);

    _addMarker(
      latLng,
      "Dropoff",
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }

  void _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == id);
      _markers.add(
        Marker(
          markerId: MarkerId(id),
          position: position,
          icon: descriptor,
          infoWindow: InfoWindow(title: id),
        ),
      );
    });
  }

  Future<void> _drawRoute() async {
    if (_appInfo.userPickUpLocation == null ||
        _appInfo.UserDropOffLocation == null) {
      return;
    }

    LatLng origin = LatLng(
      _appInfo.userPickUpLocation!.locationLatitude!,
      _appInfo.userPickUpLocation!.locationLongitude!,
    );
    LatLng destination = LatLng(
      _appInfo.UserDropOffLocation!.locationLatitude!,
      _appInfo.UserDropOffLocation!.locationLongitude!,
    );

    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$mapKey';

    var response = await RequestAssistance.receiveRequest(url);

    if (response == 'Error occurred. Failed to receive request.') return;

    if (response["status"] == "OK") {
      polylineCoordinates.clear();

      String encodedPoints =
          response["routes"][0]["overview_polyline"]["points"];
      polylineCoordinates = _convertToLatLngList(_decodePoly(encodedPoints));

      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        );
      });

      LatLngBounds bounds = _boundsFromLatLngList([origin, destination]);

      GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  List<LatLng> _convertToLatLngList(List<Point> points) {
    return points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  List<Point> _decodePoly(String encoded) {
    List<Point> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(Point(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: _polylines,
            markers: _markers,
            circles: _circles,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              newGoogleMapController = controller;
              setState(() => bottomPaddingOfMap = 300);
              _locateUserPosition().then((_) => _setCurrentLocationAsDefault());
            },
          ),

          // Align(
          //   alignment: Alignment.center,
          //   child: Padding(
          //     padding: const EdgeInsets.only(bottom: 25),
          //     child: Icon(Icons.location_pin, color: Colors.red, size: 32),
          //   ),
          // ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                _buildLocationField(
                  controller: _pickupController,
                  focusNode: _pickupFocusNode,
                  label: "From",
                  isPickup: true,
                ),
                const SizedBox(height: 10),
                _buildLocationField(
                  controller: _dropoffController,
                  focusNode: _dropoffFocusNode,
                  label: "To",
                  isPickup: false,
                ),
              ],
            ),
          ),

          if (_showPickupSuggestions)
            Positioned(
              top: 220,
              left: 20,
              right: 20,
              child: _buildSuggestionsList(_pickupPredictedPlaces, true),
            ),

          if (_showDropoffSuggestions)
            Positioned(
              top: 220,
              left: 20,
              right: 20,
              child: _buildSuggestionsList(_dropoffPredictedPlaces, false),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required bool isPickup,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Enter ${label.toLowerCase()} location',
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    setState(() {
                      if (isPickup) {
                        _showPickupSuggestions = false;
                        _pickupPredictedPlaces.clear();
                      } else {
                        _showDropoffSuggestions = false;
                        _dropoffPredictedPlaces.clear();
                      }
                    });
                  },
                ),
              ),
              onChanged:
                  (value) => _findPlaceAutoCompleteSearch(value, isPickup),
              onTap: () {
                setState(() {
                  if (isPickup) {
                    _showPickupSuggestions = true;
                    _showDropoffSuggestions = false;
                  } else {
                    _showDropoffSuggestions = true;
                    _showPickupSuggestions = false;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(List<PredictedPlaces> places, bool isPickup) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 200),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: places.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.location_on),
              title: Text(places[index].mainText ?? ""),
              subtitle: Text(places[index].secondaryText ?? ""),
              onTap: () {
                _getPlaceDirectionDetails(places[index].placeId!, isPickup);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pickupFocusNode.dispose();
    _dropoffFocusNode.dispose();
    super.dispose();
  }
}

class Point {
  final double latitude;
  final double longitude;

  Point(this.latitude, this.longitude);
}
