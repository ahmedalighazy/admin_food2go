import 'dart:developer';
import 'package:admin_food2go/core/services/session_helper.dart';
import 'package:dio/dio.dart';
import 'cache_helper.dart.dart';

class DioHelper {
  static late Dio dio;

  static void init() {
    // Get base URL from cache or use default
    final String baseUrl = CacheHelper.getData(key: 'base_url') ??
        'https://bcknd.food2go.online/';

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            print('🚨 Unauthorized — broadcasting sessionExpired');
            await CacheHelper.clearAllData();
            SessionManager.notifySessionExpired();
          }
          return handler.next(e);
        },
      ),
    );

    log('🌐 DioHelper initialized with base URL: $baseUrl');
  }

  // Method to update base URL dynamically
  static void updateBaseUrl(String newBaseUrl) {
    // Ensure the URL ends with a slash
    String formattedUrl = newBaseUrl;
    if (!formattedUrl.endsWith('/')) {
      formattedUrl = '$formattedUrl/';
    }

    dio.options.baseUrl = formattedUrl;
    log('🔄 Base URL updated to: $formattedUrl');
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    String? lang = 'en',
    String? token,
  }) async {
    final String? token = CacheHelper.getData(key: 'token');

    dio.options.headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // Convert query parameters to String values
    final Map<String, dynamic>? convertedQuery = query?.map(
          (key, value) => MapEntry(key, value.toString()),
    );

    final uri = Uri.parse(
      dio.options.baseUrl + url,
    ).replace(queryParameters: convertedQuery);
    log('🔗 Full Request URL: $uri');

    return await dio.get(url, queryParameters: convertedQuery);
  }

  static Future<Response> postData({
    required dynamic data,
    required String url,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final String? token = CacheHelper.getData(key: 'token');

    dio.options.headers = {
      'Content-Type': data is FormData
          ? 'multipart/form-data'
          : 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // Convert query parameters to String values
    final Map<String, dynamic>? convertedQuery = query?.map(
          (key, value) => MapEntry(key, value.toString()),
    );

    // Check if URL is a full URL (starts with http:// or https://)
    final bool isFullUrl = url.startsWith('http://') || url.startsWith('https://');

    if (isFullUrl) {
      // For full URLs, use them directly
      log('🔗 Full Request URL (absolute): $url');

      // Create temporary dio instance for full URL
      final tempDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

      tempDio.options.headers = dio.options.headers;
      return await tempDio.post(url, data: data, queryParameters: convertedQuery);
    } else {
      // For relative URLs, use base URL
      final uri = Uri.parse(
        dio.options.baseUrl + url,
      ).replace(queryParameters: convertedQuery);
      log('🔗 Full Request URL (relative): $uri');

      return await dio.post(url, data: data, queryParameters: convertedQuery);
    }
  }

  static Future<Response> putData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    String? token,
    String lang = 'en',
    bool isFormData = false,
  }) async {
    final String? token = CacheHelper.getData(key: 'token');

    dio.options.headers = {
      'Content-Type': isFormData
          ? 'application/x-www-form-urlencoded'
          : 'application/json',
      'lang': lang,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // Convert query parameters to String values
    final Map<String, dynamic>? convertedQuery = query?.map(
          (key, value) => MapEntry(key, value.toString()),
    );

    return await dio.put(
      url,
      data: isFormData ? FormData.fromMap(data ?? {}) : data,
      queryParameters: convertedQuery,
    );
  }

  static Future<Response> patchData({
    Map<String, dynamic>? query,
    required String url,
    Map<String, dynamic>? data,
    String? token,
  }) async {
    final String? token = CacheHelper.getData(key: 'token');

    dio.options.headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // Convert query parameters to String values
    final Map<String, dynamic>? convertedQuery = query?.map(
          (key, value) => MapEntry(key, value.toString()),
    );

    final uri = Uri.parse(
      dio.options.baseUrl + url,
    ).replace(queryParameters: convertedQuery);
    log('🔗 Full Request URL: $uri');

    return await dio.patch(url, data: data, queryParameters: convertedQuery);
  }

  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final String? token = CacheHelper.getData(key: 'token');

    dio.options.headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // Convert query parameters to String values
    final Map<String, dynamic>? convertedQuery = query?.map(
          (key, value) => MapEntry(key, value.toString()),
    );

    final uri = Uri.parse(
      dio.options.baseUrl + url,
    ).replace(queryParameters: convertedQuery);
    log('🔗 Full Request URL: $uri');

    return await dio.delete(url, queryParameters: convertedQuery);
  }

  static void printResponse(Response response) {
    log('📊 Response Status: ${response.statusCode}');
    log('📊 Response Data: ${response.data}');
    log('📊 Response Headers: ${response.headers}');
  }
}