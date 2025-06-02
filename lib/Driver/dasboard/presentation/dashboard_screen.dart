import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/dashboard_viewmodel.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/widgets/ride_request_card.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/widgets/wallet_card.dart';
import 'package:sepesha_app/Driver/history/presentation/history_screen.dart';
import 'package:sepesha_app/Driver/live/presentation/live_screen.dart';
import 'package:sepesha_app/Driver/live/presentation/widgets/live_status_card.dart';
import 'package:sepesha_app/Driver/model/ride_model.dart';
import 'package:sepesha_app/Driver/model/user_model.dart';
import 'package:sepesha_app/Driver/wallet/presentation/wallet_screen.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/components/app_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  GoogleMapController? _mapController;
  final LatLng _initialPosition = const LatLng(
    37.7749,
    -122.4194,
  ); // Default to San Francisco
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: Scaffold(
        appBar: AppBar(
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
        ),
        drawer: _buildDrawer(context),
        body: Consumer<DashboardViewModel>(
          builder: (context, viewModel, child) {
            // Update map when ride is accepted
            if (viewModel.currentRide != null && _mapController != null) {
              _updateMapForRide(viewModel.currentRide!);
            }

            return Stack(
              children: [
                // Map View
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (viewModel.currentRide != null) {
                      _updateMapForRide(viewModel.currentRide!);
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),

                // Dashboard Content Overlay
                if (viewModel.currentRide == null) ...[
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        // WalletCard(
                        //   driver: viewModel.driver!,
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => const WalletScreen(),
                        //       ),
                        //     );
                        //   },
                        // ),
                        const SizedBox(height: 12),
                        LiveStatusCard(
                          isOnline: viewModel.isOnline,
                          onToggle: viewModel.toggleOnlineStatus,
                          // In the LiveStatusCard onLivePressed callback:
                          onLivePressed: () {
                            if (viewModel.isOnline &&
                                viewModel.currentRide != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => LiveScreen(
                                        rideId: viewModel.currentRide!.id,
                                      ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                // Ride Request Cards (when available)
                if (viewModel.pendingRides.isNotEmpty &&
                    viewModel.currentRide == null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight:
                            MediaQuery.of(context).size.height *
                            0.45, // Limit height to 40% of screen
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...viewModel.pendingRides.map(
                              (ride) => RideRequestCard(
                                ride: ride,
                                onAccept: () => viewModel.acceptRide(ride),
                                onReject: () => viewModel.rejectRide(ride),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Current Ride Info (when active)
                if (viewModel.currentRide != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: _buildCurrentRideCard(viewModel.currentRide!),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _updateMapForRide(Ride ride) async {
    // In a real app, you would get these coordinates from geocoding services
    final pickupLatLng = const LatLng(37.7749, -122.4194); // Example pickup
    final dropoffLatLng = const LatLng(37.3352, -122.0324); // Example dropoff

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

      // In a real app, you would calculate the route using a directions API
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            pickupLatLng,
            LatLng(pickupLatLng.latitude + 0.01, pickupLatLng.longitude - 0.01),
            LatLng(
              dropoffLatLng.latitude - 0.01,
              dropoffLatLng.longitude + 0.01,
            ),
            dropoffLatLng,
          ],
          color: AppColor.blue2,
          width: 5,
        ),
      };
    });

    // Zoom to fit both markers
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(northeast: pickupLatLng, southwest: dropoffLatLng),
        100, // padding
      ),
    );
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

  Widget _buildDrawer(BuildContext context) {
    final driver = Driver(
      id: 'driver123',
      name: 'John Driver',
      email: 'john.driver@example.com',
      phone: '+1234567890',
      vehicleNumber: 'ABC123',
      vehicleType: 'Sedan',
      walletBalance: 1250.75,
      rating: 4.8,
      totalRides: 245,
    );

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(driver.name),
            accountEmail: Text(driver.email),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 48),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to profile
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
              // Navigate to help
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}
