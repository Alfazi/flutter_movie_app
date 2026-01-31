import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio _dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters['api_key'] = ApiConstants.apiKey;
          print('[API] Request: ${options.method} ${options.uri}');
          print('   ├─ Query params: ${options.queryParameters}');
          print('   └─ Headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '[API] Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          print(
            '   ├─ Status: ${response.statusCode} ${response.statusMessage}',
          );
          print('   └─ Data size: ${response.data.toString().length} bytes');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('[API] Error: ${error.type}');
          print('   ├─ Message: ${error.message}');
          print('   ├─ Path: ${error.requestOptions.path}');
          print('   └─ Status code: ${error.response?.statusCode}');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  String handleError(DioException error) {
    print('[ERROR_HANDLER] Processing DioException: ${error.type}');
    String errorMessage = '';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleBadResponse(error.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection. Please check your network.';
        break;
      default:
        errorMessage = 'An unexpected error occurred. Please try again.';
    }

    return errorMessage;
  }

  String _handleBadResponse(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please try again.';
      case 401:
        return 'Unauthorized. Please check your API key.';
      case 403:
        return 'Forbidden. Access denied.';
      case 404:
        return 'Not found. The requested resource was not found.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Error occurred with status code: $statusCode';
    }
  }
}
