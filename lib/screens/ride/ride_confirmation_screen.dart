import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/components/route_info_card.dart';
import 'package:sepesha_app/screens/ride/delivery_tracking_screen.dart';
import 'dart:async';

class RideConfirmationScreen extends StatefulWidget {
  const RideConfirmationScreen({super.key});

  @override
  _RideConfirmationScreenState createState() => _RideConfirmationScreenState();
}

class _RideConfirmationScreenState extends State<RideConfirmationScreen> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _progress += 0.1;
        if (_progress >= 1.0) {
          timer.cancel();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DeliveryTrackingScreen()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map background
          Image.asset(
            'assets/map.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),

          // Route info card
          const RouteInfoCard(
            startLocation: 'Airport',
            endLocation: 'Market',
          ),

          // Bottom progress card
          _buildProgressCard(),
        ],
      ),
    );
  }


  Widget _buildProgressCard() {
    return Positioned(
      bottom: 20,
      left: 10,
      right: 10,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Your travel takes 13 minutes.',
                style: AppTextStyle.paragraph1(AppColor.blackText),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: _progress,
                color: AppColor.primary,
                backgroundColor: AppColor.lightGrey,
              ),
              const SizedBox(height: 10),
              Text(
                'Finding the nearest Ride...',
                style: AppTextStyle.paragraph1(AppColor.blackText),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _progress = 0.0;
                      _timer?.cancel();
                      _startProgress();
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: Text(
                    'Cancel ride',
                    style: AppTextStyle.paragraph1(AppColor.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
