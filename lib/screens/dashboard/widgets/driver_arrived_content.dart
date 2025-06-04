import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/components/home/sheet_handle.dart';
import 'package:sepesha_app/provider/ride_provider.dart';

class DriverArrivedContent extends StatelessWidget {
  final RideProvider provider;

  const DriverArrivedContent({required this.provider});

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
            'Your driver has arrived',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.driverName} is waiting',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.carDetails.split(' • ')[0],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(provider.carDetails),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (BuildContext context) {
                        return _buildImportMemberBottomSheet(context);
                      },
                    );
                  },
                  icon: const Icon(Icons.call, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ContinueButton(
            isLoading: false,
            text: "Start Trip",
            onPressed: provider.startTrip,
            backgroundColor: AppColor.primary,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

Widget _buildImportMemberBottomSheet(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Make a call', style: AppTextStyle.paragraph3(AppColor.black)),
        SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.call, color: AppColor.black),
          title: Text(
            'Normal Call',
            style: AppTextStyle.fontWeightparagraph1(
              AppColor.blackText,
              FontWeight.w600,
            ),
          ),
          onTap: () async {
            Navigator.pop(context);
          },
        ),
        SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.call, color: AppColor.black),
          title: Text(
            'Online call',
            style: AppTextStyle.fontWeightparagraph1(
              AppColor.blackText,
              FontWeight.w600,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        SizedBox(height: 24),
      ],
    ),
  );
}
