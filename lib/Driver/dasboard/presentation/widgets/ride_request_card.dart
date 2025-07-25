import 'package:flutter/material.dart';
import 'package:sepesha_app/Driver/model/ride_model.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/helper/helper.dart';
import 'package:sepesha_app/widgets/smart_driver_rating.dart';

class RideRequestCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const RideRequestCard({
    super.key,
    required this.ride,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                const SizedBox(height: 4),
                SmartDriverRating(
                  driverId: ride.customerId, // Show customer's rating to driver
                  iconSize: 14.0,
                  fallbackRating: 4.0,
                ),
                Text(
                  '${AppConstants.currencySymbol}${ride.fare.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Pickup: ${ride.pickupAddress}'),
            const SizedBox(height: 4),
            _buildInfoRow(
              Icons.flag,
              'Destination: ${ride.destinationAddress}',
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              Icons.directions_car,
              'Distance: ${ride.distance} km',
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ContinueButton(
                    onPressed: onReject,
                    isLoading: false,
                    text: 'Reject',
                    backgroundColor: AppColor.white,
                    textColor: AppColor.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ContinueButton(
                    onPressed: onAccept,
                    isLoading: false,
                    text: 'Accept',
                    backgroundColor: AppColor.greenBullet,
                    borderColor: AppColor.greenBullet,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}
