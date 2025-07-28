import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/dashboard_screen.dart';
import 'package:sepesha_app/Driver/history/presentation/history_screen.dart';
import 'package:sepesha_app/Driver/account/new_driver_account_screen.dart';
import 'package:sepesha_app/l10n/app_localizations.dart';
import 'package:sepesha_app/provider/payment_provider.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const NewDriverAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: Text(_getTitleForIndex(_currentIndex)),
        actions: _getActionsForIndex(_currentIndex),
      ),

      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: AppLocalizations.of(context)!.trips,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: AppLocalizations.of(context)!.account,
          ),
        ],
      ),
    );
  }

  String _getTitleForIndex(int index) {
    final localizations = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return localizations.home;
      case 1:
        return localizations.trips;
      case 2:
        return localizations.account;
      default:
        return localizations.home;
    }
  }

  List<Widget> _getActionsForIndex(int index) {
    switch (index) {
      case 0: // Dashboard
        return [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications - you can navigate to notifications screen here
              // For now, we'll show a simple snackbar
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.notificationsComingSoon),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ];
      case 1: // History
        return [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // Handle trip history filters
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.filterTrips),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ];
      case 2: // Account
        return [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications feature coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ];
      default:
        return [];
    }
  }

  // Remove all the drawer-related methods (_buildDrawer, _showLogoutDialog, etc.)
  // They're now handled in DriverAccountScreen
}