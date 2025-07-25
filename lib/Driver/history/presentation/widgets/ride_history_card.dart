import 'package:flutter/material.dart';
import 'package:sepesha_app/Driver/model/ride_model.dart';
import 'package:sepesha_app/helper/helper.dart';

class RideHistoryCard extends StatelessWidget {
  final Ride ride;

  const RideHistoryCard({super.key, required this.ride});

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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Helpers.formatCurrency(ride.fare),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'From: ${ride.pickupAddress}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'To: ${ride.destinationAddress}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${ride.distance} km',
                  style: const TextStyle(fontSize: 14),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      ride.rating?.toStringAsFixed(1) ?? 'N/A',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  Helpers.formatDate(ride.requestTime),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}