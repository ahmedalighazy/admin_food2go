import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/cache_helper.dart.dart';
import 'core/services/dio_helper.dart';
import 'feature/auth/view/login_screen.dart';
import 'feature/auth/cubit/login_cubit.dart';
import 'feature/first_screen/splash_screen.dart';
import 'feature/home_screen/dine_in_order_tab/cubit/dine_cubit.dart';
import 'feature/home_screen/home_screen.dart';
import 'feature/home_screen/order_tab/cubit/order_cubit.dart';
import 'feature/home_screen/profile_tab/cubit/profile_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await CacheHelper.init();
    log(' CacheHelper initialized successfully');

    DioHelper.init();
    log(' DioHelper initialized successfully');

  } catch (e) {
    log(' Initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginCubit(),
        ),
        BlocProvider(
          create: (context) => DineCubit(),
        ),
        BlocProvider(
          create: (context) => OrderCubit(),
        ),
        BlocProvider(
          create: (context) => ProfileCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Order Management',
        theme: ThemeData(
          primaryColor: const Color.fromRGBO(158, 9, 15, 1),
          useMaterial3: true,
        ),
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (context) => SplashScreen(),
          LoginScreen.routeName: (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          HomeScreen.routeName: (context) => HomeScreen(),
        },
      ),
    );
  }
}