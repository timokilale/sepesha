import 'package:flutter/material.dart';
import 'package:sepesha_app/l10n/app_localizations.dart';
import 'package:sepesha_app/screens/dashboard/new_account_screen.dart';
import 'package:sepesha_app/screens/dashboard/home_screen.dart';
import 'package:sepesha_app/screens/dashboard/rides_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<IconData> _icons = [
    Icons.home,
    Icons.car_repair_rounded,
    Icons.person,
  ];

List<String> _getTitles(BuildContext context) {
  final localizations = AppLocalizations.of(context)!;
  return [localizations.home, localizations.trips, localizations.account];
}
  final List<Widget> _pages = [HomeScreen(), RidesScreen(), NewAccountScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        elevation: 0,
        title: Text(_getTitles(context)[_currentPage]), 
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        type: BottomNavigationBarType.fixed,
        items: List.generate(
    _icons.length,
    (index) => BottomNavigationBarItem(
      icon: Icon(_icons[index]),
      label: _getTitles(context)[index],
    ),
  ),
        onTap: (index) {
          setState(() {
            _currentPage = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}