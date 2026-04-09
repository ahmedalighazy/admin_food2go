import 'package:admin_food2go/core/services/cache_helper.dart.dart' show CacheHelper;
import 'package:admin_food2go/core/services/end_point.dart';
import 'package:admin_food2go/core/services/role_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:admin_food2go/core/services/session_helper.dart';
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

      // 🔥 Get FCM Token from cache
      final fcmToken = CacheHelper.getString(key: 'fcm_token');
      log('📱 FCM Token: ${fcmToken ?? "Not available"}');

      // ✅ Prepare login data with FCM token
      final loginData = {
        'email': email,
        'password': password,
        if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
      };

      log('📤 Sending login request with data: ${loginData.keys}');

      final response = await DioHelper.postData(
        url: EndPoint.login,
        data: loginData,
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

        // 💾 Cache the auth token (للبقاء مسجل دخول)
        if (userLogin.token != null && userLogin.token!.isNotEmpty) {
          final tokenSaved = await CacheHelper.saveData(
            key: 'token',
            value: userLogin.token!,
          );

          if (tokenSaved) {
            log('💾 ✅ Auth Token cached successfully');
            log('🔑 Token saved: ${userLogin.token}');
          } else {
            log('❌ Failed to cache auth token');
            emit(LoginError('Failed to save authentication data'));
            return;
          }
        } else {
          log('⚠️ No token received from server');
          emit(LoginError('Authentication failed: No token received'));
          return;
        }

        // 💾 Cache the user data
        if (userLogin.admin != null) {
          final adminSaved = await CacheHelper.saveModel<Admin>(
            key: 'admin',
            model: userLogin.admin!,
            toJson: (admin) => admin.toJson(),
          );

          if (adminSaved) {
            log('💾 ✅ Admin data cached successfully');
          } else {
            log('⚠️ Failed to cache admin data');
          }

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
        log('💾 All data cached successfully - User will stay logged in');
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

  Future<void> logout({bool clearRestaurantData = false}) async {
    try {
      log('🚪 Logout initiated (clearRestaurantData: $clearRestaurantData)');

      // Clear roles first
      RoleManager.clearRoles();
      log('✅ Roles cleared');

      // Clear all cached data
      await CacheHelper.clearAllData();
      log('✅ Cache cleared');

      // Only notify session expired if NOT clearing restaurant data
      // (because we want to go to restaurant selection, not login)
      if (!clearRestaurantData) {
        SessionManager.notifySessionExpired();
        log('✅ Session expired notification sent');
      } else {
        log('⏭️ Skipping session expired notification (going to restaurant selection)');
      }

      log('✅ Logout successful');
      emit(LoginInitial());
    } catch (e) {
      log('❌ Logout error: ${e.toString()}');
      final errorMessage = ErrorHandler.handleError(e);
      emit(LoginError(errorMessage));
    }
  }

  /// Check if user is already logged in (لتجنب إعادة تسجيل الدخول)
  Future<bool> checkLoginStatus() async {
    try {
      log('🔍 Checking login status...');

      final token = CacheHelper.getString(key: 'token');
      if (token == null || token.isEmpty) {
        log('❌ No token found');
        return false;
      }

      log('✅ Token found: ///////////${token}...');

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

      log('✅ User has ${accessibleTabs.length} accessible tabs');
      return true;
    } catch (e) {
      log('❌ Error checking login status: $e');
      return false;
    }
  }
}