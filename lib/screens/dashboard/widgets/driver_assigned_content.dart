import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/components/home/sheet_handle.dart';
import 'package:sepesha_app/provider/ride_provider.dart';
import 'package:sepesha_app/screens/dashboard/widgets/driver_info_tile.dart';

class DriverAssignedContent extends StatelessWidget {
  final RideProvider provider;

  const DriverAssignedContent({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final minutes = provider.secondsToArrival ~/ 60;
    final seconds = provider.secondsToArrival % 60;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
          const SizedBox(height: 16),
          const Text(
            'Driver Found',
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
            provider.driverName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(provider.driverRating),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Arriving in',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '$minutes:${seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
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
                      icon: const Icon(Icons.call, color: AppColor.primary),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColor.white,
                        shape: const CircleBorder(),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.message, color: AppColor.primary),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColor.white,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DriverInfoTile(
            icon: Icons.directions_car,
            title: 'Vehicle',
            subtitle: provider.carDetails,
          ),
          const Divider(),
          DriverInfoTile(
            icon: Icons.payment,
            title: 'Payment',
            subtitle: provider.paymentMethod,
          ),
          const Divider(),
          DriverInfoTile(
            icon: Icons.location_on,
            title: 'Destination',
            subtitle: provider.destinationAddress,
          ),
          const SizedBox(height: 16),
          ContinueButton(
            isLoading: false,
            text: "Cancel Ride",
            onPressed: provider.driverArrived,
            backgroundColor: Colors.red[50],
          ),
        ],
      ),
    );
  }
}Widget _buildImportMemberBottomSheet(BuildContext context) {
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
