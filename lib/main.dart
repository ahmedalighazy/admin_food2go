import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'core/services/cache_helper.dart.dart';
import 'core/services/dio_helper.dart';
import 'core/services/notification_storage_service.dart';
import 'core/services/session_helper.dart';
import 'core/services/firebase_notification_service.dart';
import 'core/services/order_notification_polling_service.dart';
import 'feature/auth/view/login_screen.dart';
import 'feature/auth/cubit/login_cubit.dart';
import 'feature/first_screen/splash_screen.dart';
import 'feature/home_screen/dine_in_order_tab/cubit/dine_cubit.dart';
import 'feature/home_screen/home_screen.dart';
import 'feature/home_screen/order_tab/cubit/order_cubit.dart';
import 'feature/home_screen/profile_tab/cubit/profile_cubit.dart';
import 'feature/restaurant_selection/cubit/restaurant_cubit.dart';
import 'feature/restaurant_selection/view/restaurant_selection_screen.dart';
import 'feature/home_screen/notifacation/view/notification_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize cache & dio
    await CacheHelper.init();
    DioHelper.init();
    log('✅ Core services initialized');

    // Setup background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    log('❌ Initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => RestaurantCubit()),
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => DineCubit()),
        BlocProvider(create: (context) => OrderCubit()),
        BlocProvider(create: (context) => ProfileCubit()),
      ],
      child: ChangeNotifierProvider(
        create: (context) => NotificationService()..loadNotifications(),
        child: Builder(
          builder: (builderContext) {
            // Initialize Firebase notifications with context
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FirebaseNotificationService().initialize(builderContext);
              _setupSessionListener();
            });

            return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'Food2Go Admin',
              theme: ThemeData(
                primaryColor: const Color.fromRGBO(158, 9, 15, 1),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color.fromRGBO(158, 9, 15, 1),
                ),
                useMaterial3: true,
              ),
              home: const SplashScreen(),
              routes: {
                SplashScreen.routeName: (context) => const SplashScreen(),
                RestaurantSelectionScreen.routeName: (context) =>
                    const RestaurantSelectionScreen(),
                LoginScreen.routeName: (context) => LoginScreen(),
                HomeScreen.routeName: (context) => const HomeScreen(),
                '/home': (context) => const HomeScreen(),
                '/notifications': (context) => const NotificationScreen(),
              },
            );
          },
        ),
      ),
    );
  }

  void _setupSessionListener() {
    SessionManager.onSessionExpired.listen((_) {
      log('🚨 Session expired - navigating to login');
      
      // Stop polling when session expires
      OrderNotificationPollingService().stopPolling();
      
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushNamedAndRemoveUntil(
          LoginScreen.routeName,
          (route) => false,
        );
      }
    });
  }
}
