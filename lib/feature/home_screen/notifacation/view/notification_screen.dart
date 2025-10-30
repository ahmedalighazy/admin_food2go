import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_ui.dart';
import '../../../../core/services/notification_storage_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all as read when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService = context.read<NotificationService>();
      notificationService.markAllAsRead();
    });
  }

  void _deleteNotification(String id) {
    final notificationService = context.read<NotificationService>();
    notificationService.deleteNotification(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification deleted'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear All Notifications',
          style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 18)),
        ),
        content: Text(
          'Are you sure you want to delete all notifications?',
          style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final notificationService = context.read<NotificationService>();
              notificationService.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All notifications cleared'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorPrimary,
            ),
            child: Text(
              'Clear All',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        final notifications = notificationService.notifications;
        final unreadCount = notificationService.unreadCount;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.colorPrimary,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: ResponsiveUI.iconSize(context, 24),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUI.fontSize(context, 20),
                  ),
                ),
                if (unreadCount > 0)
                  Text(
                    '$unreadCount unread',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: ResponsiveUI.fontSize(context, 12),
                    ),
                  ),
              ],
            ),
            actions: [
              if (notifications.isNotEmpty)
                PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: ResponsiveUI.iconSize(context, 24),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_sweep,
                            size: ResponsiveUI.iconSize(context, 20),
                          ),
                          SizedBox(width: ResponsiveUI.spacing(context, 12)),
                          Text(
                            'Clear All',
                            style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'clear') _clearAll();
                  },
                ),
            ],
          ),
          body: notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
            decoration: BoxDecoration(
              color: AppColors.colorPrimaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: ResponsiveUI.iconSize(context, 64),
              color: AppColors.colorPrimary.withOpacity(0.5),
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 24)),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 8)),
          Text(
            'You\'re all caught up!\nNotifications will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: ResponsiveUI.padding(context, 20)),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: ResponsiveUI.iconSize(context, 24),
        ),
      ),
      onDismissed: (_) => _deleteNotification(notification.id),
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : AppColors.colorPrimaryLight,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
          border: Border.all(
            color: notification.isRead
                ? Colors.grey.shade200
                : AppColors.colorPrimary.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: ResponsiveUI.value(context, 8),
              offset: Offset(0, ResponsiveUI.value(context, 2)),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
            onTap: () {
              _showNotificationDetails(notification);
            },
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
                    decoration: BoxDecoration(
                      color: AppColors.colorPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.data),
                      color: AppColors.colorPrimary,
                      size: ResponsiveUI.iconSize(context, 24),
                    ),
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 16),
                                  fontWeight: notification.isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: ResponsiveUI.value(context, 8),
                                height: ResponsiveUI.value(context, 8),
                                decoration: BoxDecoration(
                                  color: AppColors.colorPrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 6)),
                        Text(
                          notification.body,
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 8)),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: ResponsiveUI.iconSize(context, 14),
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: ResponsiveUI.spacing(context, 4)),
                            Text(
                              _formatTimestamp(notification.timestamp),
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 12),
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(Map<String, dynamic> data) {
    final type = data['type']?.toString().toLowerCase();

    switch (type) {
      case 'order':
        return Icons.shopping_cart;
      case 'delivery':
        return Icons.delivery_dining;
      case 'payment':
        return Icons.payment;
      case 'alert':
        return Icons.warning_amber;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }

  void _showNotificationDetails(NotificationItem notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveUI.borderRadius(context, 24))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: ResponsiveUI.value(context, 40),
                height: ResponsiveUI.value(context, 4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 2)),
                ),
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 24)),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.data),
                    color: AppColors.colorPrimary,
                    size: ResponsiveUI.iconSize(context, 28),
                  ),
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 16)),
                Expanded(
                  child: Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 20),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            Text(
              notification.body,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 16),
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            Container(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: ResponsiveUI.iconSize(context, 16),
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 8)),
                  Text(
                    DateFormat('MMMM dd, yyyy - hh:mm a').format(notification.timestamp),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (notification.data.isNotEmpty) ...[
              SizedBox(height: ResponsiveUI.spacing(context, 16)),
              Text(
                'Additional Data:',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 8)),
              Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: notification.data.entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 4)),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 13),
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            SizedBox(height: ResponsiveUI.spacing(context, 24)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorPrimary,
                  padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}