import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_ui.dart';

class EmptyStateDine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyStateDine({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 32)),
              decoration: BoxDecoration(color: AppColors.colorPrimaryLight, shape: BoxShape.circle),
              child: Icon(icon, size: ResponsiveUI.iconSize(context, 80), color: AppColors.colorPrimary),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 24)),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 22),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 12)),
            Text(
              message,
              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 15), color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}