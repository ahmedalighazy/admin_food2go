import 'package:admin_food2go/core/services/end_point.dart';
import 'package:admin_food2go/core/services/role_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:admin_food2go/core/services/session_helper.dart';
import '../../../core/services/cache_helper.dart.dart';
import '../../../core/services/dio_helper.dart';
import '../../../core/utils/error_handler.dart';
import '../model/user_login.dart';
import 'login_state.dart';
import 'dart:developer';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(LoginLoading());
    try {
      log('🔐 Login attempt with email: $email');

      final response = await DioHelper.postData(
        url: EndPoint.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      log('✅ Response received: ${response.statusCode}');
      log('📊 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userLogin = UserLogin.fromJson(response.data);

        log('👤 User: ${userLogin.admin?.name}');
        log('🔑 Token: ${userLogin.token}');
        log('👔 Role: ${userLogin.role}');

        // Validate user has some form of access
        final hasRoles = userLogin.admin?.userPositions?.roles != null &&
            userLogin.admin!.userPositions!.roles!.isNotEmpty;
        final hasDirectRole = userLogin.admin?.role != null &&
            userLogin.admin!.role!.isNotEmpty;

        if (!hasRoles && !hasDirectRole) {
          log('❌ User has no roles or permissions assigned');
          emit(LoginError(
            'Your account has no permissions assigned. Please contact your administrator.',
          ));
          return;
        }

        // Cache the token
        if (userLogin.token != null) {
          await CacheHelper.saveData(
            key: 'token',
            value: userLogin.token!,
          );
          log('💾 Token cached successfully');
        } else {
          log('⚠️ No token received from server');
          emit(LoginError('Authentication failed: No token received'));
          return;
        }

        // Cache the user data
        if (userLogin.admin != null) {
          await CacheHelper.saveModel<Admin>(
            key: 'admin',
            model: userLogin.admin!,
            toJson: (admin) => admin.toJson(),
          );
          log('💾 Admin data cached successfully');

          // Log user roles/permissions
          if (hasRoles) {
            final roles = userLogin.admin!.userPositions!.roles!;
            log('👥 User has ${roles.length} detailed roles:');
            for (var role in roles) {
              log('   - ${role.role} (${role.action})');
            }
          } else if (hasDirectRole) {
            log('👔 User has direct role: ${userLogin.admin!.role}');
            if (userLogin.admin!.role!.toLowerCase() == 'branch') {
              final branchId = userLogin.admin!.userPositionId ?? userLogin.admin!.id;
              log('🏢 Branch ID: $branchId');
            }
          }

          // Initialize RoleManager with the logged-in user's data
          await RoleManager.initializeRoles();

          // Verify RoleManager initialization
          final accessibleTabs = RoleManager.getAccessibleTabs();
          if (accessibleTabs.isEmpty) {
            log('❌ CRITICAL: RoleManager returned no accessible tabs after initialization!');
            emit(LoginError(
              'Failed to load user permissions. Please try again or contact support.',
            ));
            await logout(); // Clean up
            return;
          }

          log('✅ RoleManager initialized successfully with ${accessibleTabs.length} accessible tabs');
        } else {
          log('❌ No admin data received from server');
          emit(LoginError('Authentication failed: No user data received'));
          return;
        }

        log('🎉 Login successful for: ${userLogin.admin?.email}');
        emit(LoginSuccess(userLogin));
      } else {
        final errorMsg = 'Login failed with status code: ${response.statusCode}';
        log('❌ $errorMsg');
        emit(LoginError(errorMsg));
      }
    } on DioException catch (e) {
      log('❌ DioException caught: ${e.type}');
      log('📋 Error response: ${e.response?.data}');
      final errorMessage = ErrorHandler.handleError(e);
      log('📋 Error message: $errorMessage');
      emit(LoginError(errorMessage));
    } catch (e, stackTrace) {
      log('❌ Unexpected error: ${e.toString()}');
      log('📋 Stack trace: $stackTrace');
      final errorMessage = ErrorHandler.handleError(e);
      emit(LoginError(errorMessage));
    }
  }

  Future<void> logout() async {
    try {
      log('🚪 Logout initiated');

      // Clear roles first
      RoleManager.clearRoles();
      log('✅ Roles cleared');

      // Clear all cached data
      await CacheHelper.clearAllData();
      log('✅ Cache cleared');

      // Notify session expired
      SessionManager.notifySessionExpired();
      log('✅ Session expired notification sent');

      log('✅ Logout successful');
      emit(LoginInitial());
    } catch (e) {
      log('❌ Logout error: ${e.toString()}');
      final errorMessage = ErrorHandler.handleError(e);
      emit(LoginError(errorMessage));
    }
  }

  /// Check if user is already logged in
  Future<bool> checkLoginStatus() async {
    try {
      log('🔍 Checking login status...');

      final token = CacheHelper.getData(key: 'token');
      if (token == null || token.toString().isEmpty) {
        log('❌ No token found');
        return false;
      }

      final admin = CacheHelper.getModel<Admin>(
        key: 'admin',
        fromJson: (json) => Admin.fromJson(json),
      );

      if (admin == null) {
        log('❌ No admin data found');
        return false;
      }

      log('✅ User is logged in: ${admin.email}');

      // Re-initialize roles
      await RoleManager.initializeRoles();

      // Verify we have accessible tabs
      final accessibleTabs = RoleManager.getAccessibleTabs();
      if (accessibleTabs.isEmpty) {
        log('⚠️ No accessible tabs after re-initialization');
        return false;
      }

      return true;
    } catch (e) {
      log('❌ Error checking login status: $e');
      return false;
    }
  }
}