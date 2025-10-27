import 'package:admin_food2go/feature/home_screen/profile_tab/view/profile_tab.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dine_in_order_tab/cubit/dine_cubit.dart';
import 'dine_in_order_tab/view/dine_in_order_tab.dart';
import 'home_tab/home_tab.dart';
import 'order_tab/view/order_tab.dart';
import 'package:admin_food2go/core/services/role_manager.dart';
import 'dart:developer';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  final int? branchId;

  const HomeScreen({super.key, this.branchId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<NavigationTab> accessibleTabs;
  late Map<int, Widget> pageMap;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    // Create a map of page index to widget
    pageMap = {
      0: HomeTab(onNavigateToTab: _navigateToTab),
      1: OrderTab(),
      2: BlocProvider(
        create: (context) => DineCubit(),
        child: DineInOrderTab(),
      ),
      3: ProfileTab(),
    };

    // Get accessible tabs from RoleManager
    accessibleTabs = RoleManager.getAccessibleTabs();

    // CRITICAL: Ensure we have at least one tab
    if (accessibleTabs.isEmpty) {
      log('❌ CRITICAL: No accessible tabs found! This should never happen.');
      // Force add profile tab as emergency fallback
      accessibleTabs = [
        NavigationTab(index: 3, icon: 'profile', label: 'Profile', role: 'Profile')
      ];
    }

    // Set initial selected index to 0 (first accessible tab)
    _selectedIndex = 0;

    log('✅ HomeScreen initialized with ${accessibleTabs.length} tabs');
    log('📍 Initial tab: ${accessibleTabs[0].label} (page index: ${accessibleTabs[0].index})');
  }

  void _navigateToTab(int targetPageIndex) {
    // Find the position in accessibleTabs that matches the target page index
    final tabPosition = accessibleTabs.indexWhere((tab) => tab.index == targetPageIndex);

    if (tabPosition != -1) {
      setState(() {
        _selectedIndex = tabPosition;
      });
      log('📍 Navigated to ${accessibleTabs[tabPosition].label}');
    } else {
      log('⚠️ Cannot navigate to page index $targetPageIndex - not accessible');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You don\'t have permission to access this section'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _getCurrentPage() {
    if (_selectedIndex >= 0 && _selectedIndex < accessibleTabs.length) {
      final currentTab = accessibleTabs[_selectedIndex];
      final pageIndex = currentTab.index;

      if (pageMap.containsKey(pageIndex)) {
        return pageMap[pageIndex]!;
      }
    }

    // Fallback to profile if something goes wrong
    log('⚠️ Invalid page index, falling back to profile');
    return ProfileTab();
  }

  @override
  Widget build(BuildContext context) {
    // Safety check - should never happen with our fixes
    if (accessibleTabs.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[300],
              ),
              SizedBox(height: 24),
              Text(
                'No Access',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'You don\'t have access to any sections. Please contact your administrator.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate back or logout
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back),
                label: Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(158, 9, 15, 1),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Validate selectedIndex
    if (_selectedIndex >= accessibleTabs.length) {
      log('⚠️ Invalid _selectedIndex: $_selectedIndex, resetting to 0');
      _selectedIndex = 0;
    }

    return Scaffold(
      body: _getCurrentPage(),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 75,
        items: accessibleTabs
            .map((tab) => Icon(
          _getIconForTab(tab.icon),
          size: 30,
          color: Colors.white,
        ))
            .toList(),
        color: const Color.fromRGBO(158, 9, 15, 1),
        buttonBackgroundColor: const Color.fromRGBO(158, 9, 15, 1),
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          // Validate index before using it
          if (index >= 0 && index < accessibleTabs.length) {
            setState(() {
              _selectedIndex = index;
            });
            log('📍 Tab tapped: ${accessibleTabs[index].label}');
          } else {
            log('❌ Invalid tab index tapped: $index');
          }
        },
      ),
    );
  }

  IconData _getIconForTab(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'orders':
        return Icons.shopping_cart;
      case 'dine_in':
        return Icons.restaurant_menu;
      case 'profile':
        return Icons.person;
      default:
        log('⚠️ Unknown icon: $iconName, using default home icon');
        return Icons.home;
    }
  }

  @override
  void dispose() {
    log('🧹 HomeScreen disposed');
    super.dispose();
  }
}