import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/screens/ride/ride_confirmation_screen.dart';

class LuggageSizeScreen extends StatefulWidget {
  const LuggageSizeScreen({Key? key}) : super(key: key);

  @override
  _LuggageSizeScreenState createState() => _LuggageSizeScreenState();
}

class _LuggageSizeScreenState extends State<LuggageSizeScreen> {
  String _selectedSize = 'International carry on';
  double _additionalCost = 5.15;
  double _rideAmount = 10.99;
  bool _proofTaken = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.lightGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Luggage Size',
          style: AppTextStyle.paragraph2(AppColor.blackText),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLuggageOption('Personal Item', '5 kgs'),
          _buildLuggageOption(
            'International carry on',
            '10 kgs',
            isSelected: _selectedSize == 'International carry on',
          ),
          _buildLuggageOption('Domestic Carry on', '12-15 kgs'),
          _buildLuggageOption('Small Checked', '16-20 kgs'),
          _buildLuggageOption('Medium Checked', '22-30 kgs'),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              setState(() {
                _proofTaken = !_proofTaken;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.primary),
                borderRadius: BorderRadius.circular(10),
                color: AppColor.lightGrey,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: AppColor.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Take proof of Pickup Parcel',
                    style: AppTextStyle.paragraph1(AppColor.blackText),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildPriceSummaryCard(),
          const SizedBox(height: 20),
          ContinueButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RideConfirmationScreen()),
              );
            },
            isLoading: false,
            text: 'Request a Ride',
            backgroundColor: AppColor.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLuggageOption(
    String title,
    String weight, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSize = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected || _selectedSize == title
                ? AppColor.primary
                : AppColor.grey,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: const Icon(Icons.local_shipping),
          title: Text(title, style: AppTextStyle.paragraph1(AppColor.blackText)),
          trailing: Text(weight, style: AppTextStyle.subtext1(AppColor.grey)),
        ),
      ),
    );
  }

  Widget _buildPriceSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ride Amount:', style: AppTextStyle.paragraph1(AppColor.blackText)),
            Text(
              'TZS $_rideAmount',
              style: AppTextStyle.fontWeightparagraph1(
                AppColor.blackText,
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('Additional Cost:', style: AppTextStyle.paragraph1(AppColor.blackText)),
            Text(
              'TZS ${_proofTaken ? _additionalCost.toStringAsFixed(2) : '0.00'}',
              style: AppTextStyle.fontWeightparagraph1(
                AppColor.blackText,
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Total:',
              style: AppTextStyle.paragraph1(AppColor.primary),
            ),
            Text(
              'TZS ${(_rideAmount + (_proofTaken ? _additionalCost : 0)).toStringAsFixed(2)}',
              style: AppTextStyle.fontWeightparagraph1(
                AppColor.primary,
                FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
