import 'package:flutter/material.dart';
import 'package:admin_food2go/core/services/role_manager.dart';

/// Widget that shows content only if user has the required role
class RoleBasedWidget extends StatelessWidget {
  final String requiredRole;
  final String? requiredAction;
  final Widget child;
  final Widget? fallback;

  const RoleBasedWidget({
    super.key,
    required this.requiredRole,
    this.requiredAction,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final hasAccess = RoleManager.hasRole(
      requiredRole,
      action: requiredAction ?? 'all',
    );

    if (hasAccess) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Button that is enabled only if user has the required role
class RoleBasedButton extends StatelessWidget {
  final String requiredRole;
  final String? requiredAction;
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;

  const RoleBasedButton({
    super.key,
    required this.requiredRole,
    this.requiredAction,
    required this.onPressed,
    required this.child,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final hasAccess = RoleManager.hasRole(
      requiredRole,
      action: requiredAction ?? 'all',
    );

    return ElevatedButton(
      onPressed: hasAccess ? onPressed : null,
      style: style,
      child: child,
    );
  }
}

/// Shows a restricted access message
class RestrictedAccessWidget extends StatelessWidget {
  final String message;

  const RestrictedAccessWidget({
    super.key,
    this.message = 'You don\'t have permission to access this feature',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Access Restricted',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// ListTile that shows/hides based on role
class RoleBasedListTile extends StatelessWidget {
  final String requiredRole;
  final String? requiredAction;
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final VoidCallback? onTap;

  const RoleBasedListTile({
    super.key,
    required this.requiredRole,
    this.requiredAction,
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAccess = RoleManager.hasRole(
      requiredRole,
      action: requiredAction ?? 'all',
    );

    if (!hasAccess) {
      return const SizedBox.shrink();
    }

    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

/// Tab Bar Item that shows/hides based on role
class RoleBasedTab extends StatelessWidget {
  final String requiredRole;
  final IconData icon;
  final String label;

  const RoleBasedTab({
    super.key,
    required this.requiredRole,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final hasAccess = RoleManager.hasRole(requiredRole);

    if (!hasAccess) {
      return const SizedBox.shrink();
    }

    return Tab(
      icon: Icon(icon, size: 22),
      text: label,
      height: 60,
    );
  }
}