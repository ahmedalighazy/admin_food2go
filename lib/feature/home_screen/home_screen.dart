import 'package:admin_food2go/feature/home_screen/profile_tab/view/profile_tab.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dine_in_order_tab/cubit/dine_cubit.dart';
import 'dine_in_order_tab/view/dine_in_order_tab.dart';
import 'home_tab/home_tab.dart';
import 'order_tab/view/order_tab.dart';
import 'package:admin_food2go/core/services/role_manager.dart';
import 'package:admin_food2go/core/services/order_notification_polling_service.dart';
import 'package:admin_food2go/core/utils/responsive_ui.dart';
import 'dart:developer';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  final int? branchId;

  const HomeScreen({super.key, this.branchId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late List<NavigationTab> accessibleTabs;
  late Map<int, Widget> pageMap;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePages();
    
    // Start order notification polling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OrderNotificationPollingService().startPolling(
        context: context,
        interval: const Duration(seconds: 10), // Check every 10 seconds for faster updates
      );
      log('🔄 Order notification polling started');
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - force immediate check
      log('📱 App resumed - forcing notification check');
      OrderNotificationPollingService().forceCheck();
    }
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
      // Force add all tabs as emergency fallback
      accessibleTabs = [
        NavigationTab(index: 0, icon: 'home', label: 'Home', role: 'Home'),
        NavigationTab(index: 1, icon: 'orders', label: 'Orders', role: 'Order'),
        NavigationTab(index: 2, icon: 'dine_in', label: 'Dine-In', role: 'PosOrder'),
        NavigationTab(index: 3, icon: 'profile', label: 'Profile', role: 'Profile'),
      ];
    }

    // Set initial selected index to 0 (first accessible tab)
    _selectedIndex = 0;

    log('✅ HomeScreen initialized with ${accessibleTabs.length} tabs');
    log('📍 Initial tab: ${accessibleTabs[0].label} (page index: ${accessibleTabs[0].index})');
    
    // Log all accessible tabs
    for (var i = 0; i < accessibleTabs.length; i++) {
      log('   Tab $i: ${accessibleTabs[i].label} (index: ${accessibleTabs[i].index})');
    }
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
          duration: Duration(seconds: ResponsiveUI.value(context, 2).toInt()),
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
                size: ResponsiveUI.iconSize(context, 80),
                color: Colors.red[300],
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 24)),
              Text(
                'No Access',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 12)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 32)),
                child: Text(
                  'You don\'t have access to any sections. Please contact your administrator.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 16),
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 32)),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate back or logout
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back),
                label: Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(158, 9, 15, 1),
                  padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 32), vertical: ResponsiveUI.padding(context, 16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
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
        height: 60.0, // Fixed height instead of responsive
        items: accessibleTabs
            .map((tab) => Icon(
          _getIconForTab(tab.icon),
          size: 30.0, // Fixed size instead of responsive
          color: Colors.white,
        ))
            .toList(),
        color: const Color.fromRGBO(158, 9, 15, 1),
        buttonBackgroundColor: const Color.fromRGBO(158, 9, 15, 1),
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600), // Fixed duration
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
    WidgetsBinding.instance.removeObserver(this);
    // Stop polling when leaving home screen
    OrderNotificationPollingService().stopPolling();
    log('🧹 HomeScreen disposed - polling stopped');
    super.dispose();
  }
}