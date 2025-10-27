import 'package:admin_food2go/core/services/cache_helper.dart.dart';
import 'package:admin_food2go/feature/auth/model/user_login.dart';
import 'dart:developer';

class RoleManager {
  static Admin? _currentAdmin;
  static List<Roles>? _userRoles;
  static String? _directRole; // For users with direct role like 'branch'
  static num? _currentBranchId; // For branch users

  // Initialize roles from cached admin data
  static Future<void> initializeRoles() async {
    try {
      final cachedAdmin = CacheHelper.getModel<Admin>(
        key: 'admin',
        fromJson: (json) => Admin.fromJson(json),
      );

      if (cachedAdmin != null) {
        _currentAdmin = cachedAdmin;

        // Check if user has userPositions with roles
        if (cachedAdmin.userPositions?.roles != null &&
            cachedAdmin.userPositions!.roles!.isNotEmpty) {
          _userRoles = cachedAdmin.userPositions!.roles;
          _directRole = null;
          log('✅ Roles initialized: ${_userRoles?.length ?? 0} roles found');
        }
        // Check if user has direct role (like 'branch', 'admin', etc.)
        else if (cachedAdmin.role != null && cachedAdmin.role!.isNotEmpty) {
          _directRole = cachedAdmin.role!.toLowerCase();
          _userRoles = null;
          // For branch role, set current branch ID from userPositionId or admin ID
          if (_directRole == 'branch') {
            _currentBranchId = cachedAdmin.userPositionId ?? cachedAdmin.id;
            await CacheHelper.saveData(key: 'branch_id', value: _currentBranchId);
          }
          log('✅ Direct role initialized: $_directRole');
          if (_currentBranchId != null) {
            log('✅ Current branch ID: $_currentBranchId');
          }
        }
        else {
          log('⚠️ No roles or direct role found - defaulting to profile only');
          // Set a minimal default role to avoid empty tabs
          _directRole = 'user';
        }
      } else {
        log('⚠️ No cached admin found - defaulting to profile only');
        _directRole = 'user';
      }
    } catch (e) {
      log('❌ Error initializing roles: $e');
      _directRole = 'user'; // Fallback to minimal access
    }
  }

  // Get current admin
  static Admin? getCurrentAdmin() => _currentAdmin;

  // Get all user roles
  static List<Roles>? getUserRoles() => _userRoles;

  // Get direct role (for branch users, etc.)
  static String? getDirectRole() => _directRole;

  // Get current branch ID for branch users
  static num? getCurrentBranchId() => _currentBranchId;

  // Check if user has a specific role with specific action
  static bool hasRole(String roleName, {String action = 'all'}) {
    // If user has userPositions.roles (detailed role system)
    if (_userRoles != null && _userRoles!.isNotEmpty) {
      final hasAccess = _userRoles!.any((role) {
        final roleMatch = role.role?.toLowerCase() == roleName.toLowerCase();
        final actionMatch = role.action == 'all' || role.action == action;
        return roleMatch && actionMatch;
      });
      return hasAccess;
    }

    // If user has direct role (simple role system)
    if (_directRole != null && _directRole!.isNotEmpty) {
      return _checkDirectRoleAccess(roleName);
    }

    log('⚠️ No roles available for check: $roleName');
    return false;
  }

  // Check access based on direct role
  static bool _checkDirectRoleAccess(String requiredRole) {
    if (_directRole == null) return false;

    final role = _directRole!.toLowerCase();
    final required = requiredRole.toLowerCase();

    // Admin has access to everything
    if (role == 'admin') return true;

    // Branch specific permissions
    if (role == 'branch') {
      return [
        'home',
        'order',
        'posorder',
        'postable',
        'branch',
        'profile',
        'posreports',
        'kitchen',
        'cashier',
        'cashierman',
        'captain',
      ].contains(required);
    }

    // Delivery specific permissions
    if (role == 'delivery' || role == 'delivery_man') {
      return [
        'home',
        'order',
        'delivery',
        'profile',
      ].contains(required);
    }

    // User with no specific role - profile only
    if (role == 'user') {
      return required == 'profile';
    }

    // Default: check if roles match
    return role == required;
  }

  // Check if user can view Home tab
  static bool canViewHome() => hasRole('Home');

  // Check if user can view Orders tab
  static bool canViewOrders() => hasRole('Order');

  // Check if user can view Dine-In/POS tab
  static bool canViewDineIn() => hasRole('PosOrder') || hasRole('PosTable');

  // Check if user can view Profile tab
  static bool canViewProfile() => true; // Everyone can view their profile

  // Check if user can view Admin section
  static bool canViewAdmin() => _directRole == 'admin' || hasRole('Admin');

  // Check if user can manage categories
  static bool canManageCategories() => hasRole('Category');

  // Check if user can manage products
  static bool canManageProducts() => hasRole('Product');

  // Check if user can manage branches
  static bool canManageBranches() => hasRole('Branch');

  // Check if user can manage customers
  static bool canManageCustomers() => hasRole('Customer');

  // Check if user can manage deliveries
  static bool canManageDeliveries() => hasRole('Delivery');

  // Check if user can view reports
  static bool canViewReports() => hasRole('PosReports');

  // Check if user can manage kitchen
  static bool canManageKitchen() => hasRole('Kitchen');

  // Check if user can manage cashier
  static bool canManageCashier() => hasRole('Cashier') || hasRole('CashierMan');

  // Check if user can manage captains
  static bool canManageCaptains() => hasRole('Captain');

  // Check if user can manage settings
  static bool canManageSettings() => hasRole('Settings');

  // Get accessible tabs for bottom navigation
  static List<NavigationTab> getAccessibleTabs() {
    final tabs = <NavigationTab>[];

    if (canViewHome()) {
      tabs.add(NavigationTab(
        index: 0,
        icon: 'home',
        label: 'Home',
        role: 'Home',
      ));
    }

    if (canViewOrders()) {
      tabs.add(NavigationTab(
        index: 1,
        icon: 'orders',
        label: 'Orders',
        role: 'Order',
      ));
    }

    if (canViewDineIn()) {
      tabs.add(NavigationTab(
        index: 2,
        icon: 'dine_in',
        label: 'Dine-In',
        role: 'PosOrder',
      ));
    }

    // Profile is always accessible
    tabs.add(NavigationTab(
      index: 3,
      icon: 'profile',
      label: 'Profile',
      role: 'Profile',
    ));

    // CRITICAL FIX: Ensure at least profile tab exists
    if (tabs.isEmpty) {
      log('⚠️ No accessible tabs found, adding profile tab as fallback');
      tabs.add(NavigationTab(
        index: 3,
        icon: 'profile',
        label: 'Profile',
        role: 'Profile',
      ));
    }

    log('✅ Accessible tabs: ${tabs.length} (Role: ${_directRole ?? "roles-based"})');
    for (var tab in tabs) {
      log('   - ${tab.label} (index: ${tab.index}, role: ${tab.role})');
    }

    return tabs;
  }

  // Get user type for display
  static String getUserType() {
    if (_directRole != null) {
      switch (_directRole!.toLowerCase()) {
        case 'admin':
          return 'Administrator';
        case 'branch':
          return 'Branch Manager';
        case 'delivery':
        case 'delivery_man':
          return 'Delivery Person';
        case 'user':
          return 'User';
        default:
          return _directRole!.toUpperCase();
      }
    }

    if (_currentAdmin?.userPositions?.name != null) {
      return _currentAdmin!.userPositions!.name!;
    }

    return 'User';
  }

  // Clear roles (on logout)
  static void clearRoles() {
    _currentAdmin = null;
    _userRoles = null;
    _directRole = null;
    _currentBranchId = null;
    log('✅ Roles cleared');
  }
}

class NavigationTab {
  final int index;
  final String icon;
  final String label;
  final String role;

  NavigationTab({
    required this.index,
    required this.icon,
    required this.label,
    required this.role,
  });
}