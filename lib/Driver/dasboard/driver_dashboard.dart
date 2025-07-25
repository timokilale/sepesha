import 'package:flutter/material.dart';
import 'package:sepesha_app/screens/dashboard/account_screen.dart';
import 'package:sepesha_app/screens/dashboard/home_screen.dart';
import 'package:sepesha_app/screens/dashboard/rides_screen.dart';
import 'package:sepesha_app/widgets/app_drawer.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<IconData> _icons = [
    Icons.home,
    Icons.car_repair_rounded,

    Icons.person,
  ];

  final List<String> _titles = ["Home", "Rides", "Account"];

  final List<Widget> _pages = [HomeScreen(), RidesScreen(), AccountScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      drawer: const AppDrawer(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        // selectedItemColor: AppTheme.primary,
        // unselectedItemColor: AppTheme.textPrimary.withOpacity(0.5),
        items: List.generate(
          _icons.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _titles[index],
          ),
        ),
        onTap: (index) {
          setState(() {
            _currentPage = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
