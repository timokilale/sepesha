import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/components/home/sheet_handle.dart';
import 'package:sepesha_app/provider/ride_provider.dart';

class SearchingContent extends StatelessWidget {
  final RideProvider provider;

  const SearchingContent({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
          const SizedBox(height: 20),
          SizedBox(
            width: 40,
            height: 40,
            child: RotationTransition(
              turns: provider.loadingController!,
              child: const CircularProgressIndicator(
                color: AppColor.primary,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Looking for a driver',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re finding the best driver for you',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ContinueButton(
            isLoading: false,
            text: "Cancel",
            onPressed: provider.resetToInitialState,
            backgroundColor: Colors.red[50],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
