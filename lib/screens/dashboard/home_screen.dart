import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:sepesha_app/Utilities/app_color.dart';
import 'dart:convert';
import 'package:sepesha_app/Utilities/secret_variables.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/provider/ride_provider.dart';
import 'package:sepesha_app/screens/dashboard/widgets/state_specific_sheet.dart';
import 'package:sepesha_app/services/session_manager.dart';

// Point class for polyline decoding
class Point {
  final double latitude;
  final double longitude;

  Point(this.latitude, this.longitude);
}

// Utility class for API requests
class RequestAssistance {
  static Future<dynamic> receiveRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return 'Error occurred. Failed to receive request.';
      }
    } catch (e) {
      return 'Error occurred. Failed to receive request.';
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late RideProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<RideProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.setLoadingController(this);
      _initializeLocationAndAddress();
    });
  }

  Future<void> _initializeLocationAndAddress() async {
    await _provider.initializeLocation();
    if (_provider.currentLocation != null) {
      final origin = await _getAddressFromLatLng(_provider.currentLocation!);
      _provider.setPickupLocation(_provider.currentLocation!, origin);
      if (_provider.mapController.isCompleted) {
        try {
          final controller = await _provider.mapController.future;
          await controller.animateCamera(
            CameraUpdate.newLatLngZoom(_provider.currentLocation!, 14.5),
          );
        } catch (e) {
          debugPrint('Error moving camera to current location: $e');
        }
      }
    }
  }

  Future<String> _getAddressFromLatLng(LatLng location) async {
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$mapKey';
    var response = await RequestAssistance.receiveRequest(url);

    if (response == 'Error occurred. Failed to receive request.' ||
        response["status"] != "OK") {
      return "Current Location";
    }

    return response["results"][0]["formatted_address"] ?? "Current Location";
  }

  @override
  void dispose() {
    _provider.disposeResources();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RideProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              _buildMap(provider),
              const _AppBar(),
              if (provider.currentState == RideFlowState.idle)
                const _DestinationCard(),
              StateSpecificSheet(provider: provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap(RideProvider provider) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: provider.currentLocation ?? const LatLng(-6.7924, 39.2083),
        zoom: 14.5,
      ),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) async {
        if (!provider.mapController.isCompleted) {
          provider.mapController.complete(controller);
        }
        await Future.delayed(const Duration(milliseconds: 500));

        if (provider.currentLocation != null) {
          try {
            controller.animateCamera(
              CameraUpdate.newLatLngZoom(provider.currentLocation!, 14.5),
            );
          } catch (e) {
            debugPrint('Error animating camera: $e');
          }
        }
      },
      markers: _buildMapMarkers(provider),
      polylines: _buildPolylines(provider),
    );
  }

  Set<Marker> _buildMapMarkers(RideProvider provider) {
    final markers = <Marker>{};

    if (provider.pickupLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: provider.pickupLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    if (provider.destinationLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: provider.destinationLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    if ((provider.currentState == RideFlowState.driverAssigned ||
            provider.currentState == RideFlowState.arrived) &&
        provider.pickupLocation != null) {
      final progress = 1 - (provider.secondsToArrival / 180);
      final driverLocation = LatLng(
        provider.pickupLocation!.latitude - 0.002 * progress,
        provider.pickupLocation!.longitude - 0.002 * progress,
      );

      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: driverLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines(RideProvider provider) {
    final polylines = <Polyline>{};

    if (provider.polylineCoordinates.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: provider.polylineCoordinates,
          color: Colors.blue,
          width: 4,
        ),
      );
    }

    return polylines;
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RideProvider>(context);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Row(
        children: [
          if (provider.currentState == RideFlowState.idle)
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.grey),
            ),
          if (provider.currentState != RideFlowState.idle)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: provider.resetToInitialState,
            ),
        ],
      ),
    );
  }
}

class _DestinationCard extends StatefulWidget {
  const _DestinationCard();

  @override
  State<_DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<_DestinationCard> {

  Future<void> _getPlaceDirectionDetails(String placeId, bool isPickup) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';
    var response = await RequestAssistance.receiveRequest(url);

    if (response == 'Error occurred. Failed to receive request.') {
      return;
    }

    if (response["status"] == "OK") {
      if (mounted) {
        final provider = Provider.of<RideProvider>(context, listen: false);
        final navigator = Navigator.of(context);
        String locationName = response["result"]["name"];
        double latitude = response["result"]["geometry"]["location"]["lat"];
        double longitude = response["result"]["geometry"]["location"]["lng"];
        LatLng location = LatLng(latitude, longitude);

        if (isPickup) {
          provider.setPickupLocation(location, locationName);
        } else {
          provider.setDestination(location, locationName);
        }

        if (provider.pickupLocation != null &&
            provider.destinationLocation != null) {
          await _updateRoute(provider);
        }

        navigator.pop();
      }
    }
  }

  Future<void> _updateRoute(RideProvider provider) async {
    if (provider.pickupLocation == null ||
        provider.destinationLocation == null) {
      return;
    }

    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${provider.pickupLocation!.latitude},${provider.pickupLocation!.longitude}&destination=${provider.destinationLocation!.latitude},${provider.destinationLocation!.longitude}&key=$mapKey';

    var response = await RequestAssistance.receiveRequest(url);

    if (response == 'Error occurred. Failed to receive request.') {
      return;
    }

    if (response["status"] == "OK") {
      String encodedPoints =
          response["routes"][0]["overview_polyline"]["points"];
      List<LatLng> polylineCoordinates = _convertToLatLngList(
        _decodePoly(encodedPoints),
      );
      provider.updatePolylines(polylineCoordinates);

      LatLngBounds bounds = _boundsFromLatLngList([
        provider.pickupLocation!,
        provider.destinationLocation!,
      ]);
      final controller = await provider.mapController.future;
      try {
        controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
      } catch (e) {
        debugPrint('Error animating camera in updateRoute: $e');
      }
    }
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

  // socketManager(){
  //   SocketManager _socketManager = SocketManager.instance;
  //   _socketManager  .connect(url, onConnected)
  // }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RideProvider>(context);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildLocationInput(
                icon: Icons.gps_fixed,
                hint: provider.pickupAddress,
                iconColor: AppColor.primary,
                hasBorder: true,
                onTap: () => _showLocationSearch(context, isPickup: true),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              _buildLocationInput(
                icon: Icons.location_on,
                hint: provider.destinationAddress,
                iconColor: Colors.black,
                hasBorder: false,
                onTap: () => _showLocationSearch(context, isPickup: false),
              ),
              const SizedBox(height: 12),
              ContinueButton(
                isLoading: provider.isLoading,
                text: "Confirm Location",
                onPressed:
                    provider.destinationLocation == null
                        ? () {}
                        : () async {
                          provider.setIsLOading();
                          // Calculate and store distance using provider method
                          final distance = await provider
                              .calculateDistanceCovered(mapKey);
                          SessionManager.instance.setDistanceCovered(distance);
                          await Future.delayed(const Duration(seconds: 3));
                          provider.setIsLOading();
                          provider.changeAppState(RideFlowState.loadedLocation);
                          provider.changeAppState(RideFlowState.loadedLocation);
                          await provider.fetchCategories();
                        },
                backgroundColor:
                    provider.destinationLocation == null
                        ? Colors.grey
                        : Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInput({
    required IconData icon,
    required String hint,
    required Color iconColor,
    required bool hasBorder,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasBorder ? Colors.transparent : iconColor,
              border: hasBorder ? Border.all(color: iconColor, width: 2) : null,
            ),
            child: Icon(
              icon,
              size: 18,
              color: hasBorder ? iconColor : Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              hint.isEmpty ? "Current Location" : hint,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationSearch(BuildContext context, {required bool isPickup}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return LocationSearchModal(
          isPickup: isPickup,
          onLocationSelected: (placeId) {
            _getPlaceDirectionDetails(placeId, isPickup);
          },
        );
      },
    );
  }
}

// Separate StatefulWidget for location search modal
class LocationSearchModal extends StatefulWidget {
  final bool isPickup;
  final Function(String) onLocationSelected;

  const LocationSearchModal({
    super.key,
    required this.isPickup,
    required this.onLocationSelected,
  });

  @override
  State<LocationSearchModal> createState() => _LocationSearchModalState();
}

class _LocationSearchModalState extends State<LocationSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _placePredictions = [];
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _findPlaceAutoCompleteSearch(String inputText) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (inputText.isEmpty) {
      setState(() {
        _placePredictions = [];
      });
      return;
    }

    // Reduce debounce time for more responsive feel
    _debounceTimer = Timer(const Duration(milliseconds: 150), () async {
      if (inputText.length >= 2) { // Ensure minimum 2 characters for better API results
        String url =
            'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:TZ';
        var response = await RequestAssistance.receiveRequest(url);

        if (response == 'Error occurred. Failed to receive request.') {
          return;
        }

        if (response["status"] == "OK") {
          if (mounted) {
            setState(() {
              _placePredictions = response["predictions"];
            });
          }
        }
      } else if (inputText.length == 1) {
        // Clear predictions if only 1 character to avoid poor results
        setState(() {
          _placePredictions = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Search Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.isPickup ? 'Set Pickup Location' : 'Set Destination',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search TextField
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search location',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _placePredictions = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                _findPlaceAutoCompleteSearch(value);
                setState(() {}); // Update UI for clear button
              },
            ),
            const SizedBox(height: 16),

            // Results List
            Expanded(
              child: _placePredictions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_searching,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Start typing to search for locations'
                                : _searchController.text.length < 2
                                    ? 'Type at least 2 characters'
                                    : 'No locations found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _placePredictions.length,
                      itemBuilder: (context, index) {
                        final place = _placePredictions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColor.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: AppColor.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              place['structured_formatting']['main_text'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              place['structured_formatting']['secondary_text'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            onTap: () {
                              widget.onLocationSelected(place['place_id']);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
