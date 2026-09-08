import 'package:vip/core/services/api_service.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' as foundation;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/safe_snackbar.dart';
import '../../routes/merchant_routes.dart';
import '../util/app_constants.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static const String noInternetMessage =
      'Connection to API server failed due to internet connection';
  final int timeoutInSeconds = 60;

  String? token;
  String? type;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    // Sign-in through ApiService only writes 'auth_token'; this client reads
    // AppConstants.token. Falling back keeps a single session across both
    // instead of the Orders screen silently running unauthenticated.
    token = sharedPreferences.getString(AppConstants.token) ??
        sharedPreferences.getString('auth_token');
    type = sharedPreferences.getString(AppConstants.type);
    updateHeader(
      token,
      sharedPreferences.getString(AppConstants.languageCode),
      null,
      type,
    );
  }

  void updateHeader(
    String? token,
    String? languageCode,
    int? moduleID,
    String? type,
  ) {
    this.token = token;
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey: languageCode ?? 'en',
      AppConstants.moduleId: moduleID != null ? moduleID.toString() : '',
      'Authorization': 'Bearer ${token ?? ''}',
      'vendorType': type ?? '',
    };
  }

  // Read the current session for every request: a client may survive a
  // logout/login while GetX reuses its repository.
  Map<String, String> get _sessionHeaders {
    token = sharedPreferences.getString('auth_token') ??
        sharedPreferences.getString(AppConstants.token);
    final headers = Map<String, String>.from(_mainHeaders)
      ..remove('Authorization');
    return {
      ...headers,
      if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Response> getData(
    String uri, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool handleError = true,
  }) async {
    try {
      http.Response response = await http
          .get(
            Uri.parse(appBaseUrl + uri).replace(queryParameters: {
              ...Uri.parse(appBaseUrl + uri).queryParameters,
              ...?query?.map((key, value) => MapEntry(key, value.toString())),
            }),
            headers: headers ?? _sessionHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
    bool handleError = true,
  }) async {
    try {
      http.Response response = await http
          .post(
            Uri.parse(appBaseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? _sessionHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
    bool handleError = true,
  }) async {
    try {
      http.Response response = await http
          .put(
            Uri.parse(appBaseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? _sessionHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(
    String uri,
    Map<String, String> body,
    List<MultipartBody> multipartBody, {
    List<MultipartDocument>? multipartDocument,
    bool handleError = true,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      request.headers.addAll(_sessionHeaders);

      for (var bodyPart in multipartBody) {
        if (foundation.kIsWeb) {
          Uint8List data = await bodyPart.file.readAsBytes();
          var multipartFile = http.MultipartFile.fromBytes(
            bodyPart.field,
            data,
            filename: bodyPart.file.name,
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(multipartFile);
        } else {
          File file = File(bodyPart.file.path);
          request.files.add(
            await http.MultipartFile.fromPath(
              bodyPart.field,
              file.path,
              filename: basename(file.path),
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        }
      }

      request.fields.addAll(body);
      http.Response response = await http.Response.fromStream(
        await request.send().timeout(Duration(seconds: timeoutInSeconds)),
      );
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(
    http.Response response,
    String uri,
    bool handleError,
  ) {
    if (handleError) {
      // 401 is an expired or unknown session; 403 with ACCOUNT_SUSPENDED is
      // the shop being suspended from the admin console mid-session. Both
      // mean every subsequent request is refused, so both end the session
      // rather than leaving the merchant tapping through failures.
      final suspended = response.statusCode == 403 &&
          response.body.contains('ACCOUNT_SUSPENDED');
      if (response.statusCode == 401 || suspended) {
        final isAuthUri = uri.contains('/auth/merchant-login') ||
            uri.contains('/auth/login') ||
            uri.contains(AppConstants.loginUri);
        if (!isAuthUri) {
          token = null;
          ApiService().clearToken();
          _mainHeaders.remove('Authorization');
          Get.offAllNamed(MerchantRoutes.LOGIN);
          if (suspended) {
            safeSnackbar(
              'Account suspended',
              'This shop has been suspended. Please contact support.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      }
    }

    dynamic decodedBody;
    try {
      decodedBody = jsonDecode(response.body);
    } catch (_) {
      decodedBody = response.body;
    }

    return Response(
      statusCode: response.statusCode,
      body: decodedBody,
      statusText: response.reasonPhrase,
    );
  }
}

class MultipartBody {
  final String field;
  final XFile file;

  MultipartBody(this.field, this.file);
}

class MultipartDocument {
  final String field;
  final String path;
  final String contentType;

  MultipartDocument(this.field, this.path, this.contentType);
}
