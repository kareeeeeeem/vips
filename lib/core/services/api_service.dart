import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central API service to communicate with the Node.js backend.
///
/// Usage:
/// ```dart
/// final api = ApiService();
/// await api.init();
/// final response = await api.post('/auth/login', {'email': '...', 'password': '...'});
/// if (response.success) { ... }
/// ```
class ApiService {
  // ── Change this URL based on your environment ──────────────
  // iOS Simulator:    http://localhost:3000/api
  // Android Emulator: http://10.0.2.2:3000/api
  // Real Device:      http://YOUR_COMPUTER_IP:3000/api
  static const String baseUrl = 'http://localhost:3000/api';

  late Dio _dio;
  String? _token;

  // ── Singleton ──
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Request interceptor: attach token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          print('➡️ ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ ${error.response?.statusCode} ${error.requestOptions.path}');
          return handler.next(error);
        },
      ),
    );
  }

  // ── Initialize (call once on app start) ──
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // ── Save token after login ──
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // ── Clear token on logout ──
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ── Check if logged in ──
  bool get isLoggedIn => _token != null;

  // ── GET Request ──
  Future<ApiResponse> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return ApiResponse.fromDioResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // ── POST Request ──
  Future<ApiResponse> post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(path, data: body);
      return ApiResponse.fromDioResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // ── PUT Request ──
  Future<ApiResponse> put(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.put(path, data: body);
      return ApiResponse.fromDioResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // ── DELETE Request ──
  Future<ApiResponse> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return ApiResponse.fromDioResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }
}

/// Standardized API response wrapper.
class ApiResponse {
  final bool success;
  final int statusCode;
  final String message;
  final dynamic data;

  ApiResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromDioResponse(Response response) {
    final body = response.data;
    return ApiResponse(
      success: body['success'] ?? true,
      statusCode: response.statusCode ?? 200,
      message: body['message'] ?? 'Success',
      data: body['data'],
    );
  }

  factory ApiResponse.fromDioError(DioException error) {
    String message;
    int statusCode = error.response?.statusCode ?? 0;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timeout. Check your internet.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Cannot connect to server. Is the backend running?';
    } else if (error.response != null) {
      final body = error.response?.data;
      message = body is Map ? (body['message'] ?? 'Server error') : 'Server error';
    } else {
      message = 'Something went wrong: ${error.message}';
    }

    return ApiResponse(
      success: false,
      statusCode: statusCode,
      message: message,
      data: null,
    );
  }

  @override
  String toString() =>
      'ApiResponse(success: $success, status: $statusCode, message: $message)';
}
