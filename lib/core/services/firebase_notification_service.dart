import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'cache_helper.dart.dart';
import 'firebase_options.dart';
import 'notification_storage_service.dart';
import '../../main.dart' show navigatorKey;

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log('📩 Background message: ${message.notification?.title}');
}

/// Firebase Notification Service - Clean & Organized
class FirebaseNotificationService {
  static final FirebaseNotificationService _instance = FirebaseNotificationService._();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  late AndroidNotificationChannel _channel;
  bool _initialized = false;
  BuildContext? _appContext;

  /// Initialize Firebase & Notifications
  Future<void> initialize(BuildContext context) async {
    if (_initialized) return;
    _appContext = context;

    try {
      // Initialize Firebase
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      log('✅ Firebase initialized');

      // Setup local notifications
      await _setupLocalNotifications();

      // Request permissions
      await _requestPermissions();

      // Setup FCM token
      await _setupFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      _initialized = true;
      log('✅ Firebase Notification Service initialized');
    } catch (e) {
      log('❌ Initialization error: $e');
    }
  }

  /// Setup local notifications
  Future<void> _setupLocalNotifications() async {
    _channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications',
      importance: Importance.high,
    );

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    log('✅ Local notifications configured');
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('🔐 Permission status: ${settings.authorizationStatus}');
  }

  /// Setup FCM token
  Future<void> _setupFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        log('═══════════════════════════════════════');
        log('🔥 FCM TOKEN: $token');
        log('═══════════════════════════════════════');
        await CacheHelper.saveData(key: 'fcm_token', value: token);
      }

      _messaging.onTokenRefresh.listen((newToken) async {
        log('🔄 Token refreshed: $newToken');
        await CacheHelper.saveData(key: 'fcm_token', value: newToken);
      });
    } catch (e) {
      log('❌ FCM Token error: $e');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      log('📨 Foreground message: ${message.notification?.title}');
      _showNotification(message);
      _saveNotification(message);
    });

    // Background - app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('📬 App opened from notification');
      _navigateToNotifications();
    });

    // Terminated - app opened from notification
    _handleInitialMessage();
  }

  /// Show local notification
  void _showNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
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

  /// Save notification to storage
  void _saveNotification(RemoteMessage message) {
    try {
      // Use navigatorKey to get current context
      final context = _appContext ?? navigatorKey.currentContext;
      if (context != null && context.mounted) {
        final service = Provider.of<NotificationService>(context, listen: false);
        final item = service.createFromRemoteMessage(message);
        service.addNotification(item);
        log('✅ Notification saved and UI updated');
      } else {
        log('⚠️ No valid context to save notification');
      }
    } catch (e) {
      log('❌ Error saving notification: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    log('🔔 Notification tapped');
    _navigateToNotifications();
  }

  /// Navigate to notifications screen
  void _navigateToNotifications() {
    final context = _appContext ?? navigatorKey.currentContext;
    if (context != null && context.mounted) {
      Navigator.of(context).pushNamed('/notifications');
    } else {
      log('⚠️ No valid context to navigate');
    }
  }

  /// Handle initial message (app opened from terminated state)
  Future<void> _handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      log('📭 App opened from terminated state');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToNotifications();
      });
    }
  }

  /// Get FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
