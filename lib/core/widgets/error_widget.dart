import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_ui.dart';
import '../../feature/home_screen/dine_in_order_tab/cubit/dine_cubit.dart';

class ErrorWidgetDine extends StatelessWidget {
  final String message;

  const ErrorWidgetDine({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.colorPrimary, size: ResponsiveUI.iconSize(context, 80)),
            SizedBox(height: ResponsiveUI.spacing(context, 24)),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 12)),
            Text(
              message,
              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 16), color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 24)),
            ElevatedButton.icon(
              onPressed: () {

              },
              icon: Icon(Icons.refresh, size: ResponsiveUI.iconSize(context, 20)),
              label: Text('Try Again', style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 16))),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUI.padding(context, 32),
                  vertical: ResponsiveUI.padding(context, 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}