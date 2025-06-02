import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Driver/driver_home_screen.dart';
import 'package:sepesha_app/Driver/live/presentation/live_viewmodel.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/components/app_button.dart';

class LiveScreen extends StatefulWidget {
  final String rideId;

  const LiveScreen({super.key, required this.rideId});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  GoogleMapController? _mapController;
  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LiveViewModel(widget.rideId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Ride'),
          actions: [
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () => _callPassenger(context),
            ),
          ],
        ),
        body: Consumer<LiveViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialPosition,
                  markers: viewModel.markers,
                  polylines: viewModel.polylines,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _zoomToFitMarkers(viewModel);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onCameraMove: (position) {
                    // In a real app, you would update driver position here
                  },
                ),

                // Ride Info Card
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildRideInfoCard(viewModel),
                ),

                // Action Buttons
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildActionButtons(context, viewModel),
                ),

                // Navigation Button
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () => _zoomToFitMarkers(viewModel),
                    child: const Icon(Icons.zoom_out_map),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRideInfoCard(LiveViewModel viewModel) {
    final ride = viewModel.currentRide;
    if (ride == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
                  '\$${ride.fare.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, LiveViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: ContinueButton(
            onPressed: () => _openNavigationApp(viewModel),
            isLoading: false,
            text: 'Navigate',
            backgroundColor: AppColor.black,
            icon: Icons.directions,
            borderColor: AppColor.black,
          ),
        ),

        const SizedBox(width: 8),
        Expanded(
          child: ContinueButton(
            onPressed: () => _completeRide(context, viewModel),
            isLoading: false,
            icon: Icons.done,
            text: 'Complete Ride',
            backgroundColor: AppColor.greenBullet,
            borderColor: AppColor.greenBullet,
          ),
        ),

        // Expanded(
        //   child: ElevatedButton.icon(
        //     icon: const Icon(Icons.done),
        //     label: const Text('Complete'),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.green,
        //       padding: const EdgeInsets.symmetric(vertical: 16),
        //     ),
        //     onPressed: () => _completeRide(context, viewModel),
        //   ),
        // ),
      ],
    );
  }

  void _zoomToFitMarkers(LiveViewModel viewModel) {
    if (_mapController == null || viewModel.driverPosition == null) return;

    final bounds = LatLngBounds(
      southwest: viewModel.driverPosition!,
      northeast: const LatLng(37.3352, -122.0324), // Destination
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  Future<void> _callPassenger(BuildContext context) async {
    final viewModel = Provider.of<LiveViewModel>(context, listen: false);
    final ride = viewModel.currentRide;
    if (ride?.passengerPhone == null) return;

    // In a real app, you would use url_launcher to make the call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling passenger: ${ride!.passengerPhone}')),
    );
  }

  Future<void> _openNavigationApp(LiveViewModel viewModel) async {
    // In a real app, you would launch Google Maps or Apple Maps
    final destination = const LatLng(37.3352, -122.0324); // Destination
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening navigation app...')));
  }

  Future<void> _completeRide(
    BuildContext context,
    LiveViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Complete Ride'),
            content: const Text('Are you sure you want to complete this ride?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainLayout()),
                  );
                },
                child: const Text('Complete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await viewModel.completeRide();
      Navigator.pop(context);
    }
  }
}
