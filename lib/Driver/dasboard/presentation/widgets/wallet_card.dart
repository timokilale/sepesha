import 'package:flutter/material.dart';
import 'package:sepesha_app/Driver/model/user_model.dart';
import 'package:sepesha_app/helper/helper.dart';

class WalletCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback onTap;

  const WalletCard({super.key, required this.driver, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Wallet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppConstants.currencySymbol}${driver.walletBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('Total Rides', driver.totalRides.toString()),
                  _buildStatItem('Rating', driver.rating.toStringAsFixed(1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Row(
          children: [
            Icon(
              label == 'Total Rides' ? Icons.directions_car : Icons.star,
              color: label == 'Total Rides' ? Colors.blue : Colors.amber,
              size: 16,
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
