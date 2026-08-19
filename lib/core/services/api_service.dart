import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

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
  // Mutable (not const) so tests can repoint it at a local server before
  // the singleton is first constructed.
  static String baseUrl = 'https://vips-backend.onrender.com/api';

  /// Set this to the app-specific login route before calling [init].
  /// Merchant app sets it to MerchantRoutes.LOGIN ('/merchant-login').
  /// User app defaults to '/login'.
  static String unauthorizedRoute = '/login';

  late Dio _dio;
  String? _token;

  // ── Singleton ──
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60), // Render free: 50s+ cold start
        receiveTimeout: const Duration(seconds: 60),
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
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            final path = error.requestOptions.path;
            final isAuthPath = path.contains('/auth/login') ||
                path.contains('/auth/merchant-login') ||
                path.contains('/auth/register') ||
                path.contains('/auth/social');
            // Only treat this as "your session expired" when we actually
            // had a token that got rejected. A guest browsing with no
            // token hitting an auth-required endpoint is expected to 401 -
            // that must not force-navigate them away from wherever they
            // are (e.g. straight back to Login right after tapping
            // "Continue as Guest").
            if (!isAuthPath && _token != null) {
              clearToken();
              Get.offAllNamed(unauthorizedRoute);
            }
          } else if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError) {
            safeSnackbar(
              'Network Error',
              'Cannot connect to server. Please check your connection.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
          }
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
  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
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

  // ── PATCH Request ──
  Future<ApiResponse> patch(String path, [Map<String, dynamic>? body]) async {
    try {
      final response = await _dio.patch(path, data: body);
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

  factory ApiResponse.fromDioResponse(Response<dynamic> response) {
    final body = response.data;
    final statusCode = response.statusCode ?? 200;

    if (body is Map) {
      return ApiResponse(
        success: body['success'] ?? true,
        statusCode: statusCode,
        message: (body['message'] ?? 'Success').toString(),
        data: body['data'],
      );
    }

    // Some backend routes return a bare array, plain string, or an empty
    // body (e.g. 204 No Content) instead of the standard
    // {success, message, data} envelope. Treat any 2xx as success and pass
    // the raw body through as `data` instead of throwing a TypeError on
    // `body['success']`, which would otherwise crash whatever screen
    // triggered the call.
    return ApiResponse(
      success: statusCode >= 200 && statusCode < 300,
      statusCode: statusCode,
      message: 'Success',
      data: body,
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
      message =
          body is Map ? (body['message'] ?? 'Server error') : 'Server error';
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
