import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'dio_helper.dart';
import 'notification_storage_service.dart';
import '../../main.dart' show navigatorKey;

/// Service for polling order notifications from backend
class OrderNotificationPollingService {
  static final OrderNotificationPollingService _instance = OrderNotificationPollingService._();
  factory OrderNotificationPollingService() => _instance;
  OrderNotificationPollingService._();

  Timer? _pollingTimer;
  bool _isPolling = false;
  final Set<int> _processedOrderIds = {};
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  BuildContext? _context;
  bool _isInitialized = false;

  /// Start polling for new orders
  void startPolling({
    required BuildContext context,
    Duration interval = const Duration(seconds: 30),
  }) {
    if (_isPolling) {
      log('⚠️ Polling already running');
      return;
    }

    _context = context;
    _isPolling = true;
    
    // Initialize local notifications if not done
    if (!_isInitialized) {
      _initializeLocalNotifications();
      _isInitialized = true;
    }
    
    log('🔄 Starting order notification polling (every ${interval.inSeconds}s)');

    // Initial check immediately
    _checkForNewOrders();

    // Setup periodic polling
    _pollingTimer = Timer.periodic(interval, (_) {
      _checkForNewOrders();
    });
  }
  
  /// Force immediate check (useful when app comes to foreground)
  Future<void> forceCheck() async {
    if (!_isPolling) {
      log('⚠️ Polling not running, cannot force check');
      return;
    }
    log('🔍 Force checking for new orders...');
    await _checkForNewOrders();
  }
  
  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      await _localNotifications.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
      );
      
      log('✅ Local notifications initialized for polling service');
    } catch (e) {
      log('❌ Error initializing local notifications: $e');
    }
  }

  /// Stop polling
  void stopPolling() {
    if (!_isPolling) return;

    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    log('🛑 Order notification polling stopped');
  }

  /// Check for new orders from API
  Future<void> _checkForNewOrders() async {
    try {
      log('🔍 Checking for new orders...');

      final response = await DioHelper.getData(
        url: 'admin/order/notification',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final int newOrdersCount = data['new_orders'] ?? 0;
        final List<dynamic> orderIds = data['order_id'] ?? [];

        log('📊 API Response: $newOrdersCount new orders, IDs: $orderIds');

        if (newOrdersCount > 0 && orderIds.isNotEmpty) {
          _processNewOrders(newOrdersCount, orderIds);
        } else {
          log('✅ No new orders');
        }
      } else {
        log('⚠️ Unexpected response: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error checking for new orders: $e');
      // Don't stop polling on error, just log and continue
    }
  }

  /// Process new orders and show notifications
  void _processNewOrders(int count, List<dynamic> orderIds) {
    final List<int> newOrderIds = [];

    log('🔄 Processing $count orders from API...');
    log('📋 Current processed orders: $_processedOrderIds');

    for (var id in orderIds) {
      final int orderId = id is int ? id : int.tryParse(id.toString()) ?? 0;
      
      // Only process orders we haven't seen before
      if (orderId > 0 && !_processedOrderIds.contains(orderId)) {
        newOrderIds.add(orderId);
        _processedOrderIds.add(orderId);
        log('✨ New order detected: #$orderId');
      } else if (orderId > 0) {
        log('⏭️ Order #$orderId already processed, skipping');
      }
    }

    if (newOrderIds.isEmpty) {
      log('ℹ️ All orders already processed');
      return;
    }

    log('🆕 Processing ${newOrderIds.length} NEW orders: $newOrderIds');

    // Show notification for each new order
    for (var orderId in newOrderIds) {
      _showOrderNotification(orderId);
      _saveOrderNotification(orderId);
    }
    
    log('✅ Finished processing new orders');
  }

  /// Show local notification for new order
  Future<void> _showOrderNotification(int orderId) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        orderId, // Use order ID as notification ID
        '🛒 New Order #$orderId',
        'You have received a new order. Tap to view details.',
        notificationDetails,
        payload: 'order_$orderId',
      );

      log('✅ Notification shown for order #$orderId');
    } catch (e) {
      log('❌ Error showing notification: $e');
    }
  }

  /// Save notification to storage
  void _saveOrderNotification(int orderId) {
    try {
      // Use navigatorKey to get current context
      final context = _context ?? navigatorKey.currentContext;
      if (context != null && context.mounted) {
        final service = Provider.of<NotificationService>(context, listen: false);
        
        final notification = NotificationItem(
          id: 'order_$orderId',
          title: '🛒 New Order #$orderId',
          body: 'You have received a new order. Tap to view details.',
          data: {
            'type': 'order',
            'order_id': orderId.toString(),
          },
          timestamp: DateTime.now(),
          isRead: false,
        );

        service.addNotification(notification);
        log('💾 Notification saved for order #$orderId and UI updated');
      } else {
        log('⚠️ No valid context to save notification');
      }
    } catch (e) {
      log('❌ Error saving notification: $e');
    }
  }

  /// Clear processed orders (useful for testing or reset)
  void clearProcessedOrders() {
    _processedOrderIds.clear();
    log('🗑️ Cleared processed orders cache');
  }

  /// Get polling status
  bool get isPolling => _isPolling;

  /// Get processed orders count
  int get processedOrdersCount => _processedOrderIds.length;
}
