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
        log('📱 Admin data loaded: ${cachedAdmin.name ?? "Unknown"}');
        log('📱 Admin role: ${cachedAdmin.role ?? "No direct role"}');
        log('📱 Admin userPositions: ${cachedAdmin.userPositions?.name ?? "No position"}');

        // Check if user has userPositions with roles
        if (cachedAdmin.userPositions?.roles != null &&
            cachedAdmin.userPositions!.roles!.isNotEmpty) {
          _userRoles = cachedAdmin.userPositions!.roles;
          _directRole = null;
          log('✅ Roles initialized: ${_userRoles?.length ?? 0} roles found');
          for (var role in _userRoles!) {
            log('   - Role: ${role.role}, Action: ${role.action}');
          }
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
    log('🔍 Checking role: $roleName (action: $action)');
    
    // If user has userPositions.roles (detailed role system)
    if (_userRoles != null && _userRoles!.isNotEmpty) {
      log('📋 Checking against ${_userRoles!.length} detailed roles');
      for (var role in _userRoles!) {
        log('   - Role: ${role.role}, Action: ${role.action}');
      }
      
      final hasAccess = _userRoles!.any((role) {
        final roleMatch = role.role?.toLowerCase() == roleName.toLowerCase();
        final actionMatch = role.action == 'all' || role.action == action;
        return roleMatch && actionMatch;
      });
      
      log('✅ Role check result for $roleName: $hasAccess');
      return hasAccess;
    }

    // If user has direct role (simple role system)
    if (_directRole != null && _directRole!.isNotEmpty) {
      log('👔 Checking direct role: $_directRole against required: $roleName');
      final result = _checkDirectRoleAccess(roleName);
      log('✅ Direct role check result for $roleName: $result');
      return result;
    }

    log('⚠️ No roles available for check: $roleName');
    return false;
  }

  // Check access based on direct role
  static bool _checkDirectRoleAccess(String requiredRole) {
    if (_directRole == null) {
      log('❌ No direct role set');
      return false;
    }

    final role = _directRole!.toLowerCase();
    final required = requiredRole.toLowerCase();
    
    log('🔍 Direct role check: "$role" vs required "$required"');

    // Admin has access to everything
    if (role == 'admin') {
      log('✅ Admin has access to everything');
      return true;
    }

    // Branch specific permissions
    if (role == 'branch') {
      final branchPermissions = [
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
      ];
      
      final hasAccess = branchPermissions.contains(required);
      log('🏢 Branch role check for "$required": $hasAccess');
      return hasAccess;
    }

    // Delivery specific permissions
    if (role == 'delivery' || role == 'delivery_man') {
      final deliveryPermissions = [
        'home',
        'order',
        'delivery',
        'profile',
      ];
      
      final hasAccess = deliveryPermissions.contains(required);
      log('🚚 Delivery role check for "$required": $hasAccess');
      return hasAccess;
    }

    // User with no specific role - profile only
    if (role == 'user') {
      final hasAccess = required == 'profile';
      log('👤 User role check for "$required": $hasAccess');
      return hasAccess;
    }

    // Default: check if roles match
    final hasAccess = role == required;
    log('🔄 Default role match check for "$required": $hasAccess');
    return hasAccess;
  }

  // Check if user can view Home tab
  static bool canViewHome() {
    // Admin always has access
    if (_directRole == 'admin') return true;
    
    // Branch users have access to home
    if (_directRole == 'branch') return true;
    
    // If user has detailed roles, check for Admin role
    if (_userRoles != null && _userRoles!.isNotEmpty) {
      final hasAdminRole = _userRoles!.any((role) => 
        role.role?.toLowerCase() == 'admin' && 
        (role.action == 'all' || role.action == 'view' || role.action == 'edit')
      );
      if (hasAdminRole) return true;
    }
    
    // TEMPORARY FIX: Allow all users to see home tab
    if (_directRole != null && _directRole!.isNotEmpty) return true;
    
    // Check detailed roles
    return hasRole('Home') || hasRole('home');
  }

  // Check if user can view Orders tab
  static bool canViewOrders() {
    // Admin always has access
    if (_directRole == 'admin') return true;
    
    // Branch users have access to orders
    if (_directRole == 'branch') return true;
    
    // If user has detailed roles, check for Admin role
    if (_userRoles != null && _userRoles!.isNotEmpty) {
      final hasAdminRole = _userRoles!.any((role) => 
        role.role?.toLowerCase() == 'admin' && 
        (role.action == 'all' || role.action == 'view' || role.action == 'edit')
      );
      if (hasAdminRole) return true;
    }
    
    // TEMPORARY FIX: Allow all users to see orders tab
    if (_directRole != null && _directRole!.isNotEmpty) return true;
    
    // Check detailed roles
    return hasRole('Order') || hasRole('order') || hasRole('orders');
  }

  // Check if user can view Dine-In/POS tab
  static bool canViewDineIn() {
    // Admin always has access
    if (_directRole == 'admin') return true;
    
    // Branch users have access to dine-in
    if (_directRole == 'branch') return true;
    
    // If user has detailed roles, check for Admin role
    if (_userRoles != null && _userRoles!.isNotEmpty) {
      final hasAdminRole = _userRoles!.any((role) => 
        role.role?.toLowerCase() == 'admin' && 
        (role.action == 'all' || role.action == 'view' || role.action == 'edit')
      );
      if (hasAdminRole) return true;
    }
    
    // TEMPORARY FIX: Allow all users to see dine-in tab
    if (_directRole != null && _directRole!.isNotEmpty) return true;
    
    // Check detailed roles
    return hasRole('PosOrder') || hasRole('PosTable') || hasRole('posorder') || hasRole('postable') || hasRole('dine_in');
  }

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

    log('🔍 Checking accessible tabs for role: ${_directRole ?? "roles-based"}');
    
    // Log all available roles for debugging
    if (_userRoles != null && _userRoles!.isNotEmpty) {
      log('📋 Available roles (${_userRoles!.length}):');
      final uniqueRoles = <String>{};
      for (var role in _userRoles!) {
        if (role.role != null) {
          uniqueRoles.add('${role.role} (${role.action})');
        }
      }
      for (var role in uniqueRoles) {
        log('   - $role');
      }
    }
    
    if (canViewHome()) {
      tabs.add(NavigationTab(
        index: 0,
        icon: 'home',
        label: 'Home',
        role: 'Home',
      ));
      log('✅ Added Home tab');
    } else {
      log('❌ Home tab not accessible');
    }

    if (canViewOrders()) {
      tabs.add(NavigationTab(
        index: 1,
        icon: 'orders',
        label: 'Orders',
        role: 'Order',
      ));
      log('✅ Added Orders tab');
    } else {
      log('❌ Orders tab not accessible');
    }

    if (canViewDineIn()) {
      tabs.add(NavigationTab(
        index: 2,
        icon: 'dine_in',
        label: 'Dine-In',
        role: 'PosOrder',
      ));
      log('✅ Added Dine-In tab');
    } else {
      log('❌ Dine-In tab not accessible');
    }

    // Profile is always accessible
    tabs.add(NavigationTab(
      index: 3,
      icon: 'profile',
      label: 'Profile',
      role: 'Profile',
    ));
    log('✅ Added Profile tab');

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

    log('✅ Final accessible tabs: ${tabs.length} (Role: ${_directRole ?? "roles-based"})');
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