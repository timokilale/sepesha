import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/screens/ride/luggage_size_screen.dart';

class RideSelectionScreen extends StatefulWidget {
  const RideSelectionScreen({super.key});

  @override
  _RideSelectionScreenState createState() => _RideSelectionScreenState();
}

class _RideSelectionScreenState extends State<RideSelectionScreen> {
  String _selectedRide = 'Rideway';
  bool _luggageEnabled = true;
  String _discountCode = '';

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
          'Choose a ride',
          style: AppTextStyle.paragraph2(AppColor.blackText),
        ),
      ),
      body: Column(
        children: [
          _buildRideTypeSelector(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildRideOption(
                  'Rideway',
                  'Affordable rides, all to yourself',
                  'TZS 10.99',
                  Icons.directions_car,
                ),
                _buildRideOption(
                  'Rideway SUV',
                  'Luxury rides',
                  'TZS 32.86',
                  Icons.directions_car,
                ),
              ],
            ),
          ),
          _buildBottomOptions(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ContinueButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LuggageSizeScreen()),
                );
              },
              isLoading: false,
              text: 'Next',
              backgroundColor: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '2 Wheeler',
            style: AppTextStyle.paragraph1(AppColor.grey),
          ),
          const SizedBox(width: 10),
          Container(
            height: 20,
            width: 1,
            color: AppColor.grey,
          ),
          const SizedBox(width: 10),
          Text(
            '4 Wheeler',
            style: AppTextStyle.paragraph1(AppColor.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildRideOption(
    String title,
    String subtitle,
    String price,
    IconData icon,
  ) {
    final bool isSelected = _selectedRide == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRide = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColor.primary : AppColor.grey,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: AppTextStyle.paragraph1(AppColor.blackText),
          ),
          subtitle: Text(
            subtitle,
            style: AppTextStyle.subtext1(AppColor.grey),
          ),
          trailing: Text(
            price,
            style: AppTextStyle.paragraph1(AppColor.blackText),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomOptions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColor.grey),
              ),
              child: Text(
                'Luggage',
                style: AppTextStyle.paragraph1(AppColor.blackText),
              ),
            ),
          ),
          Switch(
            value: _luggageEnabled,
            onChanged: (value) {
              setState(() {
                _luggageEnabled = value;
              });
            },
            activeColor: AppColor.primary,
          ),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _showDiscountCodeDialog();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColor.primary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.percent, color: AppColor.primary),
                  Text(
                    'Discount code',
                    style: AppTextStyle.paragraph1(AppColor.blackText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDiscountCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Enter Discount Code',
          style: AppTextStyle.paragraph2(AppColor.blackText),
        ),
        content: TextField(
          onChanged: (value) {
            setState(() {
              _discountCode = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Enter code',
            hintStyle: AppTextStyle.subtext1(AppColor.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Apply',
              style: AppTextStyle.paragraph1(AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }
}
