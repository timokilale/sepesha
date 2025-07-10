import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/components/home/sheet_handle.dart';
import 'package:sepesha_app/provider/ride_provider.dart';

class TripInProgressContent extends StatelessWidget {
  final RideProvider provider;

  const TripInProgressContent({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
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
