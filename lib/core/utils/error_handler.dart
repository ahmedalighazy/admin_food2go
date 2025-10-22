import 'package:dio/dio.dart';

class ErrorHandler {
  static String handleError(dynamic error) {
    if (error is DioException) {
      print('🔍 ErrorHandler: Processing DioException');
      print('DioException Type: ${error.type}');
      print('Status Code: ${error.response?.statusCode}');
      print('Response Data: ${error.response?.data}');

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection';

        case DioExceptionType.badResponse:
          return _handleBadResponse(error.response);

        case DioExceptionType.cancel:
          return 'Request was cancelled';

        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your network';

        case DioExceptionType.unknown:
          return 'Connection failed. Please check your internet connection';

        default:
          return 'An unexpected error occurred';
      }
    }

    return 'An error occurred. Please try again';
  }

  static String _handleBadResponse(Response? response) {
    if (response == null) {
      return 'Server error. Please try again later';
    }

    print('🔎 Handling bad response: ${response.statusCode}');
    print('📦 Response data type: ${response.data.runtimeType}');
    print('📦 Response data: ${response.data}');

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    String? errorMessage;

    if (data is Map<String, dynamic>) {
      errorMessage = data['message'] as String? ??
          data['error'] as String? ??
          data['faield'] as String? ??
          data['failed'] as String? ??
          data['msg'] as String? ??
          data['detail'] as String?;

      print('✅ Extracted error message: $errorMessage');
    } else if (data is String) {
      errorMessage = data;
    }

    if (errorMessage != null && errorMessage.isNotEmpty) {
      return errorMessage;
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input';
      case 401:
        return 'Invalid credentials. Please try again';
      case 403:
        return 'Access denied. You don\'t have permission';
      case 404:
        return 'Resource not found';
      case 405:
        return 'This user does not have permission to login';
      case 409:
        return 'Conflict. This resource already exists';
      case 422:
        return 'Invalid data provided';
      case 500:
        return 'Server error. Please try again later';
      case 503:
        return 'Service unavailable. Please try again later';
      default:
        return 'An error occurred (Code: $statusCode)';
    }
  }

}