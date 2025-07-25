import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/dashboard_viewmodel.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/data/dashboard_repository.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/widgets/driver_status_toggle.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/widgets/ride_request_card.dart';
import 'package:sepesha_app/Driver/history/presentation/history_screen.dart';
import 'package:sepesha_app/Driver/model/ride_model.dart';
import 'package:sepesha_app/Driver/model/user_model.dart';
import 'package:sepesha_app/screens/auth/auth_screen.dart';
import 'package:sepesha_app/Driver/profile/driver_profile_screen.dart';
import 'package:sepesha_app/Driver/wallet/presentation/wallet_screen.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/provider/payment_provider.dart';
import 'package:sepesha_app/screens/auth/support/support_screen.dart';
import 'package:sepesha_app/screens/payment_methods_screen.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/services/request_assistance.dart';
import 'package:sepesha_app/Utilities/secret_variables.dart';
import 'package:sepesha_app/widgets/smart_driver_rating.dart';

// Point class for polyline decoding
class Point {
  final double latitude;
  final double longitude;

  Point(this.latitude, this.longitude);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  GoogleMapController? _mapController;
LatLng get _initialPosition {
  final viewModel = Provider.of<DashboardViewModel>(context, listen: false);
  return viewModel.currentLocation ?? const LatLng(-6.7924, 39.2083); // Fallback to Dar es Salaam
}
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  _pulseController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );
  _pulseAnimation = Tween<double>(
    begin: 0.8,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _pulseController,
    curve: Curves.easeInOut,
  ));
  _pulseController.repeat(reverse: true);
}

  @override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);
  if (state == AppLifecycleState.resumed && mounted) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final viewModel = Provider.of<DashboardViewModel>(context, listen: false);
          viewModel.refreshPermissionStatus();
        } catch (e) {
          print('Error refreshing permission status: $e');
        }
      }
    });
  }
}

  @override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  _pulseController.dispose();
  _mapController?.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: Scaffold(
        /*appBar: AppBar(
          title: const Text('Driver Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
          ],
          surfaceTintColor: AppColor.white,
          backgroundColor: AppColor.white,
        ),*/
        drawer: _buildDrawer(context),
        body: Consumer<DashboardViewModel>(
          builder: (context, viewModel, child) {
            // Update map when ride is accepted
            if (viewModel.currentRide != null && _mapController != null) {
              _updateMapForRide(viewModel.currentRide!);
            }

            // Move camera to current location when it becomes available
            if (viewModel.currentLocation != null && _mapController != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                print('Consumer detected location change, moving camera to: ${viewModel.currentLocation}');
                _moveToCurrentLocation(viewModel.currentLocation!);
              });
            }

            return Stack(
              children: [
                // Map View
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: viewModel.currentLocation ?? const LatLng(-6.7924, 39.2083),
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) async {
                    _mapController = controller;
                    print('Map created, controller set');

                    // Wait for map to be ready
                    await Future.delayed(const Duration(milliseconds: 500));

                    // Move to current location if available
                    if (viewModel.currentLocation != null) {
                      print('Moving camera to current location: ${viewModel.currentLocation}');
                      _moveToCurrentLocation(viewModel.currentLocation!);
                    } else {
                      print('Current location not available, requesting location...');
                      // Request location and move camera when available
                      _requestLocationAndMoveCamera(viewModel);
                    }

                    if (viewModel.currentRide != null) {
                      _updateMapForRide(viewModel.currentRide!);
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),

                // Dashboard Content Overlay
                if (viewModel.currentRide == null) ...[
                  // Location permission status indicator
                  if (!viewModel.hasLocationPermission || !viewModel.isLocationServiceEnabled)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: GestureDetector(
                              onTap: () async {
                                await _handleLocationPermissionRequest(viewModel);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.location_off, color: Colors.blue),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Location Access Required',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[800],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      viewModel.locationError ?? 'Tap to enable location permissions to go online',
                                      style: TextStyle(color: Colors.blue[700]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Online/Offline Toggle
                  if (viewModel.hasLocationPermission && viewModel.isLocationServiceEnabled)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  viewModel.isOnline ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                  color: viewModel.isOnline ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    viewModel.isOnline ? 'You are Online' : 'You are Offline',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: viewModel.isOnline ? Colors.green[800] : Colors.grey[800],
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: viewModel.isOnline,
                                  onChanged: (value) async {
                                    bool success = await viewModel.toggleOnlineStatus();
                                    if (!success && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Cannot go online without location permissions'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            if (viewModel.isOnline) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Waiting for ride requests...',
                                style: TextStyle(color: Colors.green[700]),
                              ),
                            ],
                          ],
                        ),
                        ),
                      ),
                    ),
                ],

                // Current Ride Card
                if (viewModel.currentRide != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: _buildCurrentRideCard(viewModel.currentRide!),
                  ),

                // Refresh Location Button
                Positioned(
                  top: 50,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () async {
                      print('Manually refreshing location...');
                      await viewModel.refreshPermissionStatus();

                      if (viewModel.currentLocation != null) {
                        _moveToCurrentLocation(viewModel.currentLocation!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Location updated: ${viewModel.currentLocation!.latitude.toStringAsFixed(4)}, ${viewModel.currentLocation!.longitude.toStringAsFixed(4)}'),
                            backgroundColor: Colors.blue,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not get current location. Check permissions.'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.my_location),
                    tooltip: 'Refresh Location',
                  ),
                ),

                // Pending Rides List
                if (viewModel.pendingRides.isNotEmpty && viewModel.currentRide == null)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        itemCount: viewModel.pendingRides.length,
                        itemBuilder: (context, index) {
                          final ride = viewModel.pendingRides[index];
                          return _buildPendingRideCard(ride, viewModel);
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _updateMapForRide(Ride ride) async {
    // Use actual coordinates from the ride booking
    final pickupLatLng = (ride.pickupLatitude != null && ride.pickupLongitude != null)
        ? LatLng(ride.pickupLatitude!, ride.pickupLongitude!)
: const LatLng(-6.7924, 39.2083); // Fallback to Dar es Salaam

    final dropoffLatLng = (ride.destinationLatitude != null && ride.destinationLongitude != null)
        ? LatLng(ride.destinationLatitude!, ride.destinationLongitude!)
: const LatLng(-6.8000, 39.2500); // Fallback to Dar es Salaam area    
try {
  await _calculateRoute(pickupLatLng, dropoffLatLng);
} catch (e) {
  debugPrint('Error calculating route: $e');
  // Fallback to straight line if API fails
  _setFallbackPolyline(pickupLatLng, dropoffLatLng);
}

    if(mounted){
        setState(() {
          _markers = {
            Marker(
              markerId: const MarkerId('pickup'),
              position: pickupLatLng,
              infoWindow: const InfoWindow(title: 'Pickup Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
            ),
            Marker(
              markerId: const MarkerId('dropoff'),
              position: dropoffLatLng,
              infoWindow: const InfoWindow(title: 'Dropoff Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          };
        });

         // Zoom to fit both markers
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
  southwest: LatLng(
    math.min(pickupLatLng.latitude, dropoffLatLng.latitude),
    math.min(pickupLatLng.longitude, dropoffLatLng.longitude),
  ),
  northeast: LatLng(
    math.max(pickupLatLng.latitude, dropoffLatLng.latitude),
    math.max(pickupLatLng.longitude, dropoffLatLng.longitude),
  ),
),
        100, // padding
      ),
    );
      }
   
  }

  void _moveToCurrentLocation(LatLng location) {
  if (_mapController != null) {
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(location, 14),
    );
  }
}

Future<void> _requestLocationAndMoveCamera(DashboardViewModel viewModel) async {
  print('Requesting location and moving camera...');

  // Request location permissions and get current location
  await viewModel.refreshPermissionStatus();

  // Wait a bit for location to be retrieved
  await Future.delayed(const Duration(milliseconds: 1000));

  // If location is available and map controller is ready, move camera
  if (viewModel.currentLocation != null && _mapController != null) {
    print('Moving camera to current location: ${viewModel.currentLocation}');
    _moveToCurrentLocation(viewModel.currentLocation!);
  } else {
    print('Location still not available after request');
  }
}

  /// Calculate route between pickup and dropoff using Google Directions API
  Future<void> _calculateRoute(LatLng pickup, LatLng dropoff) async {
    try {
      String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${pickup.latitude},${pickup.longitude}&destination=${dropoff.latitude},${dropoff.longitude}&key=$mapKey';

      var response = await RequestAssistance.receiveRequest(url);

      if (response == 'Error occurred. Failed to receive request.' || response["status"] != "OK") {
        // Fallback to straight line if API fails
        _setFallbackPolyline(pickup, dropoff);
        return;
      }

      String encodedPoints = response["routes"][0]["overview_polyline"]["points"];
      List<LatLng> polylineCoordinates = _convertToLatLngList(_decodePoly(encodedPoints));

      if (mounted) {
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: polylineCoordinates,
              color: AppColor.blue2,
              width: 5,
            ),
          };
        });
      }
    } catch (e) {
      debugPrint('Error calculating route: $e');
      // Fallback to straight line if API fails
      _setFallbackPolyline(pickup, dropoff);
    }
  }

  /// Set fallback polyline (straight line) if route calculation fails
  void _setFallbackPolyline(LatLng pickup, LatLng dropoff) {
    if (mounted) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [pickup, dropoff],
            color: AppColor.blue2,
            width: 5,
          ),
        };
      });
    }
  }

  /// Decode polyline points from Google Directions API
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

  /// Convert Point list to LatLng list
  List<LatLng> _convertToLatLngList(List<Point> points) {
    return points.map((point) => LatLng(point.latitude, point.longitude)).toList();
  }

  Widget _buildCurrentRideCard(Ride ride) {
    return Card(
      color: AppColor.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ride.passengerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tsh ${ride.fare.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.greenBullet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Pickup:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(ride.pickupAddress),
            const SizedBox(height: 8),
            const Text(
              'Destination:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(ride.destinationAddress),
            const SizedBox(height: 16),
            ContinueButton(
              onPressed: () {},
              isLoading: false,
              text: 'Start Ride',
              backgroundColor: AppColor.primary,
              textColor: AppColor.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRideCard(Ride ride, DashboardViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'New Ride Request',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '\$${ride.fare?.toStringAsFixed(2) ?? 'N/A'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'From: ${ride.pickupAddress ?? 'Unknown location'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'To: ${ride.destinationAddress ?? 'Unknown destination'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => viewModel.rejectRide(ride),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => viewModel.acceptRide(ride),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return FutureBuilder<User>(
      future: DashboardRepository().getUserData(),
      builder: (context, snapshot) {
        // Show loading while fetching user data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Drawer(child: Center(child: CircularProgressIndicator()));
        }

        // Use fetched data or fallback
        final driver =
            snapshot.data ??
            User(
              id: 'fallback',
              name: 'Driver',
              email: 'driver@sepesha.com',
              phone: '+255000000000',
              vehicleNumber: 'N/A',
              vehicleType: 'Car',
              walletBalance: 0.0,
              rating: 0.0,
              totalRides: 0,
            );

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(driver.name),
                accountEmail: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(driver.email),
                    const SizedBox(height: 4),
                    SmartDriverRating(
                      driverId: driver.id,
                      iconSize: 12.0,
                      fallbackRating: driver.rating,
                      fallbackReviews: driver.totalRides,
                    ),
                  ],
                ),
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.person, size: 48),
                ),
              ),

              // Dynamic Payment Method Section
              Consumer<PaymentProvider>(
                builder: (context, provider, child) {
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.payment, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Payment Preference',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.selectedPaymentMethodName,
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (provider.selectedPaymentMethod?.type.name ==
                            'wallet') ...[
                          const SizedBox(height: 4),
                          Text(
                            'Balance: ${provider.getFormattedWalletBalance()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              // Vehicle Information Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Vehicle Info',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${driver.vehicleType} • ${driver.vehicleNumber}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${driver.totalRides} rides completed',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverProfileScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Wallet'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WalletScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Payment Methods'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentMethodsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {
                    Navigator.pop(context);
                    _navigateToSupport(context);
                  },
              ),
              const Divider(),
              ListTile(
  leading: const Icon(Icons.logout),
  title: const Text('Logout'),
  onTap: () {
    Navigator.pop(context);
    _showLogoutDialog();
  },
),
            ],
          ),
        );
      },
    );
  }

   void _navigateToSupport(BuildContext context) {
  Navigator.pop(context); // Close drawer first
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SupportScreen(),
    ),
  );
}

  void _showLogoutDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (route) => false,
              );
            }
            AuthServices.logout(context);
            },
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

  /// Handles location permission request with user-friendly dialogs
  Future<void> _handleLocationPermissionRequest(DashboardViewModel viewModel) async {
    try {
      // First refresh the current permission status
      await viewModel.requestLocationPermissions();

      // If permissions are already granted, no need to do anything
      if (viewModel.canGoOnline) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are already enabled! You can go online.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        // Show dialog to enable location services
        if (mounted) {
          _showLocationServiceDialog();
        }
        return;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.deniedForever) {
        // Show dialog to open app settings
        if (mounted) {
          _showOpenSettingsDialog();
        }
        return;
      }

      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          // Permission denied, show explanation
          if (mounted) {
            _showPermissionDeniedDialog();
          }
          return;
        }

        if (permission == LocationPermission.deniedForever) {
          // Permission permanently denied, show settings dialog
          if (mounted) {
            _showOpenSettingsDialog();
          }
          return;
        }
      }

      // Permission granted (or already granted), refresh the view model
      await viewModel.requestLocationPermissions();

      // Check if permissions are now available
      if (!viewModel.canGoOnline) {
        // Still no permissions, something went wrong
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to get location permissions. Please check your device settings.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Location permissions granted! Getting your location...'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ),
  );
  
  // Force get current location after permission is granted
  await viewModel.refreshPermissionStatus();
  
  // Wait a bit for location to be retrieved, then move camera
  await Future.delayed(const Duration(milliseconds: 1000));
  
  if (viewModel.currentLocation != null && mounted) {
    _moveToCurrentLocation(viewModel.currentLocation!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location found! Map updated to your current position.'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  } else {
    print('Current location still null after permission grant');
  }
}

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting location permission: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Shows dialog when location services are disabled
  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Location services are turned off. Please enable location services in your device settings to use this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Shows dialog when permission is permanently denied
  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'Location permission is required to go online as a driver. Please enable location permission in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Shows dialog when permission is denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Denied'),
          content: const Text(
            'Location permission is required to track your position as a driver. Please grant location permission to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleLocationPermissionRequest(
                  Provider.of<DashboardViewModel>(context, listen: false),
                );
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }
}
