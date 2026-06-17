import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../utils/helpers.dart';

class ApiResponse<T> {
  final T? data;
  final int statusCode;
  final String? message;
  final bool success;
  final dynamic error;

  ApiResponse({
    this.data,
    required this.statusCode,
    this.message,
    required this.success,
    this.error,
  });

  // Méthode pratique pour vérifier si le statut indique un succès
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

// Intercepteur pour les tokens d'authentification
class TokenInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  TokenInterceptor(this.storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Ne pas ajouter le token aux endpoints d'authentification
    if (!options.path.contains('auth/login') &&
        !options.path.contains('/register')) {
      // Récupérer le token depuis le stockage sécurisé
      final token = await storage.read(key: 'access_token');

      if (token != null) {
        // Ajouter le token aux en-têtes de la requête
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // Poursuivre avec la requête
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Get.offAll(()=> LoginView(),binding: LoginBinding());
    }
    return handler.next(err);
  }
}

class ApiRequest {
  final Dio dio;
  final FlutterSecureStorage storage;

  factory ApiRequest() {
    final storage = const FlutterSecureStorage();
    final dio = Dio(
      BaseOptions(
        baseUrl: 'AppConstants.API_BASE_URL',
        connectTimeout: const Duration(seconds: 10),
      ),
    );

    // Ajouter l'intercepteur de token
    dio.interceptors.add(TokenInterceptor(storage));

    // Configuration du cache
    CacheStore? cacheStore;
    CacheOptions? cacheOptions;
    cacheStore = MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576);
    cacheOptions = CacheOptions(store: cacheStore);
    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    // Logger
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          maxWidth: 200,
        ),
      );
    }

    return ApiRequest._(dio, storage);
  }

  const ApiRequest._(this.dio, this.storage);

  Future<ApiResponse> request<T>(
    RequestMethod method,
    String url, {
    dynamic data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    bool? showAlert,
  }) async {
    try {
      final response = await dio.request(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method.value, headers: headers),
      );

      return ApiResponse(
        data: response.data,
        statusCode: response.statusCode ?? 0,
        message: response.statusMessage,
        success: true,
      );
    } on DioException catch (e) {
      // Gérer les erreurs Dio (erreurs réseau, timeout, etc.)
      return ApiResponse(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message,
        success: false,
        error: e,
      );
    } catch (e) {
      // Gérer les autres types d'erreurs
      return ApiResponse(
        statusCode: 0,
        message: e.toString(),
        success: false,
        error: e,
      );
    }
  }

  // Méthode utilitaire pour sauvegarder le token d'authentification
  Future<void> saveToken(String token) async {
    await storage.write(key: 'access_token', value: token);
  }

  // Méthode utilitaire pour récupérer le token
  Future<String?> getToken() async {
    return await storage.read(key: 'access_token');
  }

  // Méthode utilitaire pour effacer le token (déconnexion)
  Future<void> clearToken() async {
    await storage.delete(key: 'access_token');
  }
}

enum RequestMethod {
  get,
  head,
  post,
  put,
  delete,
  connect,
  options,
  trace,
  patch,
}

extension RequestMethodX on RequestMethod {
  String get value => Helpers.getEnumValue(this).toUpperCase();
}
