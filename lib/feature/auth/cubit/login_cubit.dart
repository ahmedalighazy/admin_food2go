import 'package:admin_food2go/core/services/end_point.dart';
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

        // Cache the token
        if (userLogin.token != null) {
          await CacheHelper.saveData(
            key: 'token',
            value: userLogin.token!,
          );
          log('💾 Token cached successfully');
        }

        // Cache the user data
        if (userLogin.admin != null) {
          await CacheHelper.saveModel<Admin>(
            key: 'admin',
            model: userLogin.admin!,
            toJson: (admin) => admin.toJson(),
          );
          log('💾 Admin data cached successfully');
        }

        log('🎉 Login successful for: ${userLogin.admin?.email}');
        emit(LoginSuccess(userLogin));
      } else {
        final errorMsg = 'Login failed with status code: ${response.statusCode}';
        log('❌ $errorMsg');
        emit(LoginError(errorMsg));
      }
    } on DioException catch (e) {
      log('❌ DioException caught');
      final errorMessage = ErrorHandler.handleError(e);
      log('📋 Error message: $errorMessage');
      emit(LoginError(errorMessage));
    } catch (e) {
      log('❌ Unexpected error: ${e.toString()}');
      final errorMessage = ErrorHandler.handleError(e);
      emit(LoginError(errorMessage));
    }
  }

  Future<void> logout() async {
    try {
      log('🚪 Logout initiated');
      await CacheHelper.clearAllData();
      SessionManager.notifySessionExpired();
      log('✅ Logout successful');
      emit(LoginInitial());
    } catch (e) {
      log('❌ Logout error: ${e.toString()}');
      final errorMessage = ErrorHandler.handleError(e);
      emit(LoginError(errorMessage));
    }
  }
}