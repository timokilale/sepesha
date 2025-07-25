import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/dashboard_screen.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/data/dashboard_repository.dart';
import 'package:sepesha_app/Driver/history/presentation/history_screen.dart';
import 'package:sepesha_app/Driver/model/user_model.dart';
import 'package:sepesha_app/Driver/profile/driver_profile_screen.dart';
import 'package:sepesha_app/Driver/wallet/presentation/wallet_screen.dart';
import 'package:sepesha_app/provider/payment_provider.dart';
import 'package:sepesha_app/screens/auth/auth_screen.dart';
import 'package:sepesha_app/screens/auth/support/support_screen.dart';
import 'package:sepesha_app/screens/payment_methods_screen.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/widgets/smart_driver_rating.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const WalletScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // We'll handle leading manually
        title: Text(_getTitleForIndex(_currentIndex)),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: _getActionsForIndex(_currentIndex),
      ),
      drawer: _buildDrawer(context), // Always show drawer
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Trips',
          ),
        ],
      ),
    );
  }
  String _getTitleForIndex(int index) {
    switch (index) {
      case 0: return 'Driver Dashboard';
      case 1: return 'Wallet';
      case 2: return 'Ride History';
      default: return 'Driver';
    }
  }

  List<Widget> _getActionsForIndex(int index) {
    switch (index) {
      case 0: // Dashboard
        return [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              setState(() => _currentIndex = 2); // Switch to history tab
            },
          ),
        ];
      case 1: // Wallet
        return [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<PaymentProvider>(
                context,
                listen: false,
              ).refreshWalletBalance();
            },
          ),
        ];
      case 2: // History
        return [];
      default:
        return [];
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return FutureBuilder<User>(
      future: DashboardRepository().getUserData(),
      builder: (context, snapshot) {
        // Show loading while fetching user data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Drawer(child: Center(child: CircularProgressIndicator()));
        }

        // Use fetched data or fallback
        final driver =
            snapshot.data ??
            User(
              id: 'fallback',
              name: 'Driver',
              email: 'driver@sepesha.com',
              phone: '+255000000000',
              vehicleNumber: 'N/A',
              vehicleType: 'Car',
              walletBalance: 0.0,
              rating: 0.0,
              totalRides: 0,
            );

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(driver.name),
                accountEmail: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(driver.email),
                    const SizedBox(height: 4),
                    SmartDriverRating(
                      driverId: driver.id,
                      iconSize: 12.0,
                      fallbackRating: driver.rating,
                      fallbackReviews: driver.totalRides,
                    ),
                  ],
                ),
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.person, size: 48),
                ),
              ),

              // Dynamic Payment Method Section
              Consumer<PaymentProvider>(
                builder: (context, provider, child) {
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.payment, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Payment Preference',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.selectedPaymentMethodName,
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (provider.selectedPaymentMethod?.type.name ==
                            'wallet') ...[
                          const SizedBox(height: 4),
                          Text(
                            'Balance: ${provider.getFormattedWalletBalance()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              // Vehicle Information Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Vehicle Info',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${driver.vehicleType} • ${driver.vehicleNumber}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${driver.totalRides} rides completed',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverProfileScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Wallet'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WalletScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Payment Methods'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentMethodsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {
                    Navigator.pop(context);
                    _navigateToSupport(context);
                  },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

   void _navigateToSupport(BuildContext context) {
  Navigator.pop(context); // Close drawer first
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SupportScreen(),
    ),
  );
}

  void _showLogoutDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (route) => false,
              );
            }
            AuthServices.logout(context);
          },
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
}