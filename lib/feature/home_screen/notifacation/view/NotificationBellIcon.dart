import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_ui.dart';
import '../../../../core/services/notification_storage_service.dart';
import '../view/notification_screen.dart';

// Notification Bell Icon with Badge
class NotificationBellIcon extends StatelessWidget {
  const NotificationBellIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        final unreadCount = notificationService.unreadCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: ResponsiveUI.iconSize(context, 26),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: ResponsiveUI.value(context, 8),
                top: ResponsiveUI.value(context, 8),
                child: Container(
                  padding: EdgeInsets.all(unreadCount > 99 ? ResponsiveUI.padding(context, 3) : ResponsiveUI.padding(context, 4)),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  constraints: BoxConstraints(
                    minWidth: ResponsiveUI.value(context, 18),
                    minHeight: ResponsiveUI.value(context, 18),
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveUI.fontSize(context, 10),
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}