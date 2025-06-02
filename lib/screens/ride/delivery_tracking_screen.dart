import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/components/route_info_card.dart';
import 'package:sepesha_app/screens/dashboard/dashboard.dart';
import 'dart:async';

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({Key? key}) : super(key: key);

  @override
  _DeliveryTrackingScreenState createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  double _progress = 0.0;
  bool _isAccepted = false;
  bool _isDelivered = false;
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
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        if (!_isAccepted) {
          _progress += 0.5;
          if (_progress >= 1.0) {
            _isAccepted = true;
            _progress = 0.0;
          }
        } else if (!_isDelivered) {
          _progress += 0.25;
          if (_progress >= 1.0) {
            _isDelivered = true;
          }
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
            startLocation: 'Pick Up',
            endLocation: 'Drop Off',
          ),

          // Bottom status card
          _buildStatusCard(),
        ],
      ),
    );
  }


  Widget _buildStatusCard() {
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
              if (!_isAccepted) _buildFindingDriverUI(),
              if (_isAccepted && !_isDelivered) _buildDeliveryInProgressUI(),
              if (_isDelivered) _buildDeliveryCompletedUI(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFindingDriverUI() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          color: AppColor.primary,
          backgroundColor: AppColor.lightGrey,
        ),
        const SizedBox(height: 10),
        Text(
          'Finding a driver...',
          style: AppTextStyle.paragraph1(AppColor.blackText),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColor.grey),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Reject',
                  style: AppTextStyle.paragraph1(AppColor.blackText),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isAccepted = true;
                    _progress = 0.0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Accept',
                  style: AppTextStyle.paragraph1(AppColor.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryInProgressUI() {
    return Column(
      children: [
        Text(
          '5 minutes to delivery',
          style: AppTextStyle.paragraph2(AppColor.blackText),
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColor.primary,
            child: Text(
              'DE',
              style: AppTextStyle.paragraph1(AppColor.white),
            ),
          ),
          title: Text(
            'Davidson Edgar',
            style: AppTextStyle.paragraph1(AppColor.blackText),
          ),
          subtitle: Text(
            '20 Deliveries ★★★★☆ 4.1',
            style: AppTextStyle.subtext1(AppColor.grey),
          ),
          trailing: TextButton(
            onPressed: () {},
            child: Text(
              'Call Recipient',
              style: AppTextStyle.paragraph1(AppColor.primary),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ContinueButton(
          onPressed: () {
            setState(() {
              _isDelivered = true;
            });
          },
          isLoading: false,
          text: 'Start Drop off process',
          backgroundColor: AppColor.primary,
        ),
      ],
    );
  }

  Widget _buildDeliveryCompletedUI() {
    // Add a delay before navigating to dashboard
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
        (route) => false, // Remove all previous routes
      );
    });

    return Column(
      children: [
        Text(
          'Delivery Completed!',
          style: AppTextStyle.paragraph3(AppColor.primary),
        ),
        const SizedBox(height: 16),
        Text(
          'Redirecting to dashboard...',
          style: AppTextStyle.paragraph1(AppColor.grey),
        ),
      ],
    );
  }
}
