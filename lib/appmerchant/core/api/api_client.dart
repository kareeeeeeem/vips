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

import '../../routes/merchant_routes.dart';
import '../util/app_constants.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static const String noInternetMessage =
      'Connection to API server failed due to internet connection';
  final int timeoutInSeconds = 30;

  String? token;
  String? type;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);
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
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey: languageCode ?? 'en',
      AppConstants.moduleId: moduleID != null ? moduleID.toString() : '',
      'Authorization': 'Bearer ${token ?? ''}',
      'vendorType': type ?? '',
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
          .get(Uri.parse(appBaseUrl + uri), headers: headers ?? _mainHeaders)
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
            headers: headers ?? _mainHeaders,
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
            headers: headers ?? _mainHeaders,
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
      request.headers.addAll(_mainHeaders);

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
      if (response.statusCode == 401) {
        token = null;
        sharedPreferences.remove(AppConstants.token);
        Get.offAllNamed(MerchantRoutes.LOGIN);
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
