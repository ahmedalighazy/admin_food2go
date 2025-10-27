import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:admin_food2go/core/services/dio_helper.dart';
import 'package:admin_food2go/core/services/cache_helper.dart.dart';
import 'restaurant_state.dart';
import 'dart:developer';

class RestaurantCubit extends Cubit<RestaurantState> {
  RestaurantCubit() : super(RestaurantInitial());

  static RestaurantCubit get(context) => BlocProvider.of(context);

  Future<void> setRestaurantId({required String restaurantId}) async {
    emit(RestaurantLoading());

    try {
      log('🏪 Setting restaurant ID: $restaurantId');

      // Create a separate Dio instance for this specific API call
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://clientbcknd.food2go.online/',
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // Call the API - Note: their API has a typo 'restuarant_id'
      final response = await dio.post(
        'api/cashier/login',
        data: {
          'restuarant_id': restaurantId,  // Their API has this typo
        },
      );

      log('📊 Response Status: ${response.statusCode}');
      log('📊 Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final baseUrl = response.data['back_end'];

        if (baseUrl != null && baseUrl.isNotEmpty) {
          log('✅ Received base URL: $baseUrl');

          // Save restaurant ID and base URL to cache
          await CacheHelper.saveData(key: 'restaurant_id', value: restaurantId);
          await CacheHelper.saveData(key: 'base_url', value: baseUrl);

          // Update DioHelper with new base URL
          DioHelper.updateBaseUrl(baseUrl);

          log('💾 Restaurant ID and base URL saved successfully');
          emit(RestaurantSuccess(restaurantId: restaurantId, baseUrl: baseUrl));
        } else {
          log('❌ Base URL not found in response');
          emit(RestaurantError('Failed to get restaurant configuration'));
        }
      } else {
        log('❌ Invalid response: ${response.statusCode}');
        emit(RestaurantError('Failed to configure restaurant'));
      }
    } on DioException catch (e) {
      log('❌ DioException: ${e.type}');
      log('❌ Status Code: ${e.response?.statusCode}');
      log('❌ Response Data: ${e.response?.data}');

      String errorMessage = 'Failed to configure restaurant';

      try {
        if (e.response?.statusCode == 400) {
          final responseData = e.response?.data;

          if (responseData is Map) {
            // Try to extract error message
            if (responseData.containsKey('error')) {
              final error = responseData['error'];
              if (error is Map && error.isNotEmpty) {
                // Get first error
                final firstKey = error.keys.first;
                final firstError = error[firstKey];
                if (firstError is List && firstError.isNotEmpty) {
                  errorMessage = firstError[0].toString();
                } else {
                  errorMessage = firstError.toString();
                }
              }
            } else if (responseData.containsKey('message')) {
              errorMessage = responseData['message'].toString();
            }
          } else if (responseData is String) {
            errorMessage = responseData;
          }
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Restaurant not found. Please check the ID.';
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Connection timeout. Please check your internet.';
        } else if (e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Server timeout. Please try again.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Connection error. Please check your internet.';
        } else {
          errorMessage = 'Network error. Please try again.';
        }
      } catch (parseError) {
        log('❌ Error parsing error message: $parseError');
      }

      log('📋 Final error message: $errorMessage');
      emit(RestaurantError(errorMessage));
    } catch (error) {
      log('❌ Unexpected error: $error');
      emit(RestaurantError('An unexpected error occurred'));
    }
  }

  // Check if restaurant is already configured
  Future<bool> isRestaurantConfigured() async {
    try {
      final restaurantId = CacheHelper.getData(key: 'restaurant_id');
      final baseUrl = CacheHelper.getData(key: 'base_url');

      if (restaurantId != null && baseUrl != null) {
        // Update DioHelper with cached base URL
        DioHelper.updateBaseUrl(baseUrl);
        log('✅ Restaurant already configured: $restaurantId');
        log('✅ Base URL: $baseUrl');
        return true;
      }
      return false;
    } catch (e) {
      log('❌ Error checking restaurant config: $e');
      return false;
    }
  }

  // Clear restaurant configuration
  Future<void> clearRestaurantConfig() async {
    try {
      await CacheHelper.removeData(key: 'restaurant_id');
      await CacheHelper.removeData(key: 'base_url');
      log('✅ Restaurant configuration cleared');
      emit(RestaurantInitial());
    } catch (e) {
      log('❌ Error clearing restaurant config: $e');
    }
  }
}