import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_images.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/Utilities/secret_variables.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/provider/ride_provider.dart';
import 'package:sepesha_app/screens/ride/ride_selection_screen.dart';

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
      final address = await _getAddressFromLatLng(_provider.currentLocation!);
      _provider.setPickupLocation(_provider.currentLocation!, address);
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
              _StateSpecificSheet(provider: provider),
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
        target: provider.currentLocation ?? const LatLng(51.507, -0.099),
        zoom: 14.5,
      ),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        provider.mapController.complete(controller);
        if (provider.currentLocation != null) {
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(provider.currentLocation!, 14.5),
          );
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
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _placePredictions = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:TZ';
      var response = await RequestAssistance.receiveRequest(url);

      if (response == 'Error occurred. Failed to receive request.') {
        return;
      }

      if (response["status"] == "OK") {
        setState(() {
          _placePredictions = response["predictions"];
        });
      }
    } else {
      setState(() {
        _placePredictions = [];
      });
    }
  }

  Future<void> _getPlaceDirectionDetails(String placeId, bool isPickup) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';
    var response = await RequestAssistance.receiveRequest(url);

    if (response == 'Error occurred. Failed to receive request.') {
      return;
    }

    if (response["status"] == "OK") {
      final provider = Provider.of<RideProvider>(context, listen: false);
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

      Navigator.pop(context);
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
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
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
              const _Divider(),
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
                          await Future.delayed(const Duration(seconds: 3));
                          provider.setIsLOading();
                          provider.changeAppState(RideFlowState.loadedLocation);
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
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search location',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: _findPlaceAutoCompleteSearch,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _placePredictions.length,
                    itemBuilder: (context, index) {
                      final place = _placePredictions[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(
                          place['structured_formatting']['main_text'] ?? '',
                        ),
                        subtitle: Text(
                          place['structured_formatting']['secondary_text'] ??
                              '',
                        ),
                        onTap: () {
                          _getPlaceDirectionDetails(
                            place['place_id'],
                            isPickup,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StateSpecificSheet extends StatelessWidget {
  final RideProvider provider;

  const _StateSpecificSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    switch (provider.currentState) {
      case RideFlowState.idle:
        return const SizedBox.shrink();
      case RideFlowState.loadedLocation:
        return _DraggableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 1,
          child: _RideSelectionContent(provider: provider),
        );
      case RideFlowState.searching:
        return _DraggableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.15,
          maxChildSize: 0.6,
          child: _SearchingContent(provider: provider),
        );
      case RideFlowState.driverAssigned:
        return _DraggableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          child: _DriverAssignedContent(provider: provider),
        );
      case RideFlowState.arrived:
        return _DraggableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.7,
          child: _DriverArrivedContent(provider: provider),
        );
      case RideFlowState.onTrip:
        return _DraggableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.15,
          maxChildSize: 0.6,
          child: _TripInProgressContent(provider: provider),
        );
    }
  }
}

class _DraggableSheet extends StatelessWidget {
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final Widget child;

  const _DraggableSheet({
    required this.initialChildSize,
    required this.minChildSize,
    required this.maxChildSize,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final snapSizes = [minChildSize, initialChildSize, maxChildSize]..sort();

    return Positioned.fill(
      bottom: 0,
      child: DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        snap: true,
        snapSizes: snapSizes,
        builder: (context, scrollController) {
          return Material(
            elevation: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _RideSelectionContent extends StatelessWidget {
  final RideProvider provider;

  const _RideSelectionContent({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: _SheetHandle()),
          const SizedBox(height: 16),
          const Text(
            'Choose Your Ride',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildVehicleTypeFilter(),
          const SizedBox(height: 16),
          ...provider.filteredRideOptions.map(
            (option) => _buildRideOptionCard(option, provider),
          ),
          const SizedBox(height: 16),
          _buildLuggageOption(),
          const SizedBox(height: 16),
          _buildDiscountSection(context),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFilterChip('2 Wheeler', Icons.motorcycle),
          _buildFilterChip('4 Wheeler', Icons.directions_car),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String type, IconData icon) {
    final isSelected = provider.filterType == type;
    return GestureDetector(
      onTap: () => provider.filterRideType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.red : Colors.grey),
            const SizedBox(width: 6),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.red : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideOptionCard(RideOption option, RideProvider provider) {
    final isSelected = provider.selectedRideType == option.name;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => provider.selectRideType(option.name!),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? option.color!.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? option.color! : Colors.grey[200]!,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: option.color!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    _getVehicleImage(option.name!),
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        const SizedBox(width: 8),
                        Icon(Icons.people, color: Colors.grey[400], size: 14),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    option.price!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getVehicleImage(String name) {
    switch (name.toLowerCase()) {
      case 'rideway':
        return 'assets/images/bike.png';
      case 'rideway suv':
        return 'assets/images/bike.png';
      case 'rideway bike':
        return 'assets/images/bike.png';
      case 'rideway bike suv':
        return 'assets/images/bike.png';
      default:
        return 'assets/images/bike.png';
    }
  }

  Widget _buildLuggageOption() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.luggage, color: Colors.grey[600]),
              const SizedBox(width: 8),
              const Text(
                'Add Luggage Space',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Switch.adaptive(
            value: false,
            onChanged: (value) {},
            activeColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Have a promo code?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter promo code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ContinueButton(
                onPressed: () {},
                backgroundColor: AppColor.black,
                isLoading: false,
                text: 'Apply',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ContinueButton(
          isLoading: false,
          text: "Continue",
          onPressed: () => provider.startSearching(),
        ),
      ],
    );
  }
}

class _SearchingContent extends StatelessWidget {
  final RideProvider provider;

  const _SearchingContent({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 20),
          SizedBox(
            width: 40,
            height: 40,
            child: RotationTransition(
              turns: provider.loadingController!,
              child: const CircularProgressIndicator(
                color: AppColor.primary,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Looking for a driver',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re finding the best driver for you',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ContinueButton(
            isLoading: false,
            text: "Cancel",
            onPressed: provider.resetToInitialState,
            backgroundColor: Colors.red[50],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DriverAssignedContent extends StatelessWidget {
  final RideProvider provider;

  const _DriverAssignedContent({required this.provider});

  @override
  Widget build(BuildContext context) {
    final minutes = provider.secondsToArrival ~/ 60;
    final seconds = provider.secondsToArrival % 60;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 16),
          const Text(
            'Driver Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            provider.driverName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(provider.driverRating),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Arriving in',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '$minutes:${seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return _buildImportMemberBottomSheet(context);
                          },
                        );
                      },
                      icon: const Icon(Icons.call, color: AppColor.primary),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColor.white,
                        shape: const CircleBorder(),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.message, color: AppColor.primary),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColor.white,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DriverInfoTile(
            icon: Icons.directions_car,
            title: 'Vehicle',
            subtitle: provider.carDetails,
          ),
          const Divider(),
          _DriverInfoTile(
            icon: Icons.payment,
            title: 'Payment',
            subtitle: provider.paymentMethod,
          ),
          const Divider(),
          _DriverInfoTile(
            icon: Icons.location_on,
            title: 'Destination',
            subtitle: provider.destinationAddress,
          ),
          const SizedBox(height: 16),
          ContinueButton(
            isLoading: false,
            text: "Cancel Ride",
            onPressed: provider.driverArrived,
            backgroundColor: Colors.red[50],
          ),
        ],
      ),
    );
  }
}

class _DriverArrivedContent extends StatelessWidget {
  final RideProvider provider;

  const _DriverArrivedContent({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 16),
          const Text(
            'Your driver has arrived',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.driverName} is waiting',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.carDetails.split(' • ')[0],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(provider.carDetails),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (BuildContext context) {
                        return _buildImportMemberBottomSheet(context);
                      },
                    );
                  },
                  icon: const Icon(Icons.call, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ContinueButton(
            isLoading: false,
            text: "Start Trip",
            onPressed: provider.startTrip,
            backgroundColor: AppColor.primary,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TripInProgressContent extends StatelessWidget {
  final RideProvider provider;

  const _TripInProgressContent({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 16),
          const Text(
            'Trip in progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColor.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.destinationAddress,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('Destination'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTripMetric('Distance', '2.4 km'),
              _buildTripMetric('Time', '8 min'),
              _buildTripMetric('Price', '£10.50'),
            ],
          ),
          const SizedBox(height: 16),
          ContinueButton(
            isLoading: false,
            text: "End Trip",
            onPressed: provider.resetToInitialState,
            backgroundColor: AppColor.primary,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTripMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _DriverInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DriverInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColor.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18),
      child: CustomPaint(
        size: const Size(2, 20),
        painter: DottedLinePainter(color: Colors.grey[400]!),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  const DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    const dashWidth = 2;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _buildImportMemberBottomSheet(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Make a call', style: AppTextStyle.paragraph3(AppColor.black)),
        SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.call, color: AppColor.black),
          title: Text(
            'Normal Call',
            style: AppTextStyle.fontWeightparagraph1(
              AppColor.blackText,
              FontWeight.w600,
            ),
          ),
          onTap: () async {
            Navigator.pop(context);
          },
        ),
        SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.call, color: AppColor.black),
          title: Text(
            'Online call',
            style: AppTextStyle.fontWeightparagraph1(
              AppColor.blackText,
              FontWeight.w600,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        SizedBox(height: 24),
      ],
    ),
  );
}
