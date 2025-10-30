import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'core/services/cache_helper.dart.dart';
import 'core/services/dio_helper.dart';
import 'core/services/notification_storage_service.dart';
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

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool isFlutterLocalNotificationsInitialized = false;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await initializeFirebase();
  await setupFlutterNotifications();
  showFlutterNotification(message);
  log('📩 Background message: ${message.messageId}');
}

Future<void> initializeFirebase() async {
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyC2wem9KvYp-Wm7pgpYgkT4HjBi0aHAd3w",
        appId: "1:191292342718:android:383cd678217426a6aef9ef",
        messagingSenderId: "191292342718",
        projectId: "food2go-8676e",
        storageBucket: "food2go-8676e.firebasestorage.app",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  log('✅ Firebase initialized successfully');
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      log('🔔 Notification tapped: ${response.payload}');
      _navigateToNotifications();
    },
  );

  // ⭐ السطر المصحح - كان في مشكلة في الأقواس
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  isFlutterLocalNotificationsInitialized = true;
  log('✅ Local notifications setup complete');
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;

  if (notification != null) {
    log('🔔 Showing notification: ${notification.title}');

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }
}

void _navigateToNotifications() {
  if (navigatorKey.currentState != null) {
    navigatorKey.currentState!.pushNamed('/notifications');
    log('📱 Navigated to notifications screen');
  }
}

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  log('🔐 Permission status: ${settings.authorizationStatus}');
}

Future<void> setupFCMToken() async {
  try {
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      log('═══════════════════════════════════════');
      log('🔥 FCM TOKEN:');
      log(fcmToken);
      log('═══════════════════════════════════════');

      await CacheHelper.saveData(key: 'fcm_token', value: fcmToken);
    } else {
      log('❌ FCM Token is null');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen(
          (newToken) async {
        log('🔄 FCM Token refreshed: $newToken');
        await CacheHelper.saveData(key: 'fcm_token', value: newToken);
      },
      onError: (error) {
        log('❌ Token refresh error: $error');
      },
    );
  } catch (e) {
    log('❌ Error getting FCM Token: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebase();
    await setupFlutterNotifications();
    await requestNotificationPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await CacheHelper.init();
    log('✅ CacheHelper initialized');
    DioHelper.init();
    log('✅ DioHelper initialized');
    await setupFCMToken();
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
  static bool _listenersSetup = false;

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
            // ⭐ Setup Firebase listeners here with valid context
            if (!_listenersSetup) {
              _setupFirebaseMessagingListeners(builderContext);
            }

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

  void _setupFirebaseMessagingListeners(BuildContext context) {
    if (_listenersSetup) return;
    _listenersSetup = true;

    log('🔧 Setting up Firebase messaging listeners');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📨 Foreground message received');
      log('Data: ${message.data}');

      if (message.notification != null) {
        log('Title: ${message.notification!.title}');
        log('Body: ${message.notification!.body}');
        showFlutterNotification(message);

        try {
          final notificationService =
          Provider.of<NotificationService>(context, listen: false);
          final notificationItem =
          notificationService.createFromRemoteMessage(message);
          notificationService.addNotification(notificationItem);
          log('✅ Notification added to service');
        } catch (e) {
          log('❌ Error adding notification: $e');
        }
      }
    });

    // Background - App opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('📬 App opened from background notification');
      log('Data: ${message.data}');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToNotifications();
      });
    });

    // Terminated - App opened from notification
    _handleInitialMessage();
  }

  void _handleInitialMessage() async {
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      log('📭 App opened from terminated state');
      log('Data: ${initialMessage.data}');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToNotifications();
      });
    }
  }
}