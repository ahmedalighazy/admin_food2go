import 'package:admin_food2go/feature/home_screen/profile_tab/view/profile_tab.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dine_in_order_tab/cubit/dine_cubit.dart';
import 'dine_in_order_tab/view/dine_in_order_tab.dart';
import 'home_tab/home_tab.dart';
import 'order_tab/view/order_tab.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  final int? branchId;

  const HomeScreen({super.key, this.branchId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int? _branchId;

  @override
  void initState() {
    super.initState();
  }


  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeTab(onNavigateToTab: _navigateToTab),
      OrderTab(),
      BlocProvider(
        create: (context) => DineCubit(),
        child: DineInOrderTab(),
      ),
      ProfileTab(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 75,
        items: const [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.shopping_cart, size: 30, color: Colors.white),
          Icon(Icons.restaurant_menu, size: 30, color: Colors.white), // Changed icon to restaurant
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        color: const Color.fromRGBO(158, 9, 15, 1),
        buttonBackgroundColor: const Color.fromRGBO(158, 9, 15, 1),
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}