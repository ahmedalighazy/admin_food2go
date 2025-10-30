import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:convert'; // Added for jsonEncode/jsonDecode
import 'package:shared_preferences/shared_preferences.dart'; // Add to pubspec.yaml if needed: shared_preferences: ^2.2.2

// Notification Service to manage notifications
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Load notifications from cache on init
  Future<void> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJsonStrings = prefs.getStringList('notifications') ?? [];
      _notifications.clear();
      for (final jsonString in notificationsJsonStrings) {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>; // Parse string to Map
        final notification = NotificationItem.fromJson(jsonMap);
        _notifications.add(notification);
      }
      notifyListeners();
      log('✅ Loaded ${notificationsJsonStrings.length} notifications from cache');
    } catch (e) {
      log('❌ Error loading notifications: $e');
    }
  }

  // Save notifications to cache
  Future<void> _saveNotificationsToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJsonMaps = _notifications.map((n) => n.toJson()).toList();
      final notificationsJsonStrings = notificationsJsonMaps.map((map) => jsonEncode(map)).toList(); // Encode Maps to Strings
      await prefs.setStringList('notifications', notificationsJsonStrings);
      log('💾 Saved ${_notifications.length} notifications to cache');
    } catch (e) {
      log('❌ Error saving notifications: $e');
    }
  }

  // Add new notification
  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
    _saveNotificationsToCache(); // Persist after add
    log('✅ Notification added. Total: ${_notifications.length}, Unread: $unreadCount');
  }

  // Mark notification as read
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      _saveNotificationsToCache(); // Persist after update
    }
  }

  // Mark all as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
    _saveNotificationsToCache(); // Persist after update
  }

  // Delete notification
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    _saveNotificationsToCache(); // Persist after delete
  }

  // Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
    _saveNotificationsToCache(); // Persist (empty list)
  }

  // Create notification from RemoteMessage
  NotificationItem createFromRemoteMessage(RemoteMessage message) {
    return NotificationItem(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      data: message.data,
      timestamp: DateTime.now(),
      isRead: false,
    );
  }
}

// Notification Item Model
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  // JSON serialization for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}