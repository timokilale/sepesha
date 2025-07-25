import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Driver/driver_home_screen.dart';
import 'package:sepesha_app/Driver/history/presentation/history_viewmodel.dart';
import 'package:sepesha_app/Driver/history/presentation/widgets/ride_history_card.dart';


class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryViewModel(),
      child: Consumer<HistoryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.rideHistory.isEmpty) {
            return const Center(
              child: Text('No ride history available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.rideHistory.length,
            itemBuilder: (context, index) {
              final ride = viewModel.rideHistory[index];
              return RideHistoryCard(ride: ride);
            },
          );
        },
      ),
    );
  }
}