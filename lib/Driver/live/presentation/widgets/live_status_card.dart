import 'package:flutter/material.dart';

class LiveStatusCard extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggle;
  final VoidCallback onLivePressed;

  const LiveStatusCard({
    super.key,
    required this.isOnline,
    required this.onToggle,
    required this.onLivePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Driver Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 18,
                    color: isOnline ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: isOnline,
                  onChanged: (value) => onToggle(),
                  activeColor: Colors.green,
                ),
              ],
            ),
            if (isOnline) ...[
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'You are now available for ride requests',
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onLivePressed,
                  child: const Text('Go Live'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}