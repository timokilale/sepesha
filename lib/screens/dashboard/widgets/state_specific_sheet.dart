import 'package:flutter/material.dart';
import 'package:sepesha_app/provider/ride_provider.dart';
import 'package:sepesha_app/screens/dashboard/widgets/draggable_sheet.dart';
import 'package:sepesha_app/screens/dashboard/widgets/driver_arrived_content.dart';
import 'package:sepesha_app/screens/dashboard/widgets/driver_assigned_content.dart';
import 'package:sepesha_app/screens/dashboard/widgets/ride_selection_content.dart';
import 'package:sepesha_app/screens/dashboard/widgets/serching_content.dart';
import 'package:sepesha_app/screens/dashboard/widgets/trip_in_progress.dart';

class StateSpecificSheet extends StatelessWidget {
  final RideProvider provider;

  const StateSpecificSheet({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    switch (provider.currentState) {
      case RideFlowState.idle:
        return const SizedBox.shrink();
      case RideFlowState.loadedLocation:
        return DraggableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 1,
          fitToContent: true,
          child: RideSelectionContent(provider: provider),
        );
      case RideFlowState.searching:
        return DraggableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.15,
          maxChildSize: 0.6,
          fitToContent: true,
          child: SearchingContent(provider: provider),
        );
      case RideFlowState.driverAssigned:
        return DraggableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          child: DriverAssignedContent(provider: provider),
        );
      case RideFlowState.arrived:
        return DraggableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.7,
          child: DriverArrivedContent(provider: provider),
        );
      case RideFlowState.onTrip:
        return DraggableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.15,
          maxChildSize: 0.6,
          child: TripInProgressContent(provider: provider),
        );
    }
  }
}
