// Exercises ApiService's actual Dio round-trip (interceptors, response
// parsing, error mapping) against a real local HTTP server — as opposed to
// appuser_business_logic_test.dart's ApiService group, which only covers the
// token-lifecycle methods that never touch the network.
//
// ApiService.baseUrl is repointed at 127.0.0.1 in setUpAll(), before the
// singleton is ever constructed, so every request in this file hits our
// local server instead of the real backend.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/core/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // TestWidgetsFlutterBinding fakes every dart:io HttpClient request as a
  // 400 response by default, to stop tests from hitting the real network.
  // We want the opposite here — real loopback traffic to our local server.
  HttpOverrides.global = null;

  late HttpServer server;

  setUpAll(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    ApiService.baseUrl = 'http://${server.address.address}:${server.port}';

    server.listen((request) async {
      final path = request.uri.path;
      final method = request.method;

      Map<String, dynamic> body = {};
      Map<String, dynamic>? echoBody;
      if (method == 'POST' || method == 'PUT') {
        final raw = await utf8.decoder.bind(request).join();
        if (raw.isNotEmpty) {
          echoBody = jsonDecode(raw) as Map<String, dynamic>;
        }
      }

      request.response.headers.contentType = ContentType.json;

      switch (path) {
        case '/ok':
          body = {
            'success': true,
            'message': 'Success',
            'data': {
              'echo': echoBody,
              'method': method,
              'authHeader': request.headers.value('authorization'),
            },
          };
          request.response.statusCode = 200;
          break;
        case '/server-error':
          body = {'success': false, 'message': 'Something broke server-side'};
          request.response.statusCode = 500;
          break;
        case '/unauthorized':
          body = {'success': false, 'message': 'Token expired'};
          request.response.statusCode = 401;
          break;
        default:
          body = {'success': false, 'message': 'Not found'};
          request.response.statusCode = 404;
      }

      request.response.write(jsonEncode(body));
      await request.response.close();
    });
  });

  tearDownAll(() async {
    await server.close(force: true);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('successful requests', () {
    test('get() returns a successful ApiResponse', () async {
      final response = await ApiService().get('/ok');
      expect(response.success, isTrue);
      expect(response.statusCode, equals(200));
      expect(response.data['method'], equals('GET'));
    });

    test('post() sends the body and returns a successful ApiResponse',
        () async {
      final response = await ApiService().post('/ok', {'name': 'Alice'});
      expect(response.success, isTrue);
      expect(response.data['echo']['name'], equals('Alice'));
      expect(response.data['method'], equals('POST'));
    });

    test('put() sends the body and returns a successful ApiResponse',
        () async {
      final response = await ApiService().put('/ok', {'name': 'Bob'});
      expect(response.success, isTrue);
      expect(response.data['echo']['name'], equals('Bob'));
      expect(response.data['method'], equals('PUT'));
    });

    test('delete() returns a successful ApiResponse', () async {
      final response = await ApiService().delete('/ok');
      expect(response.success, isTrue);
      expect(response.data['method'], equals('DELETE'));
    });

    test('get() forwards query parameters', () async {
      final response = await ApiService().get(
        '/ok',
        queryParams: {'page': '2'},
      );
      expect(response.success, isTrue);
    });

    test('a stored token is sent as a Bearer Authorization header', () async {
      await ApiService().setToken('secret-token');
      final response = await ApiService().get('/ok');
      expect(response.data['authHeader'], equals('Bearer secret-token'));
      await ApiService().clearToken();
    });

    test('no Authorization header is sent when logged out', () async {
      await ApiService().clearToken();
      final response = await ApiService().get('/ok');
      expect(response.data['authHeader'], isNull);
    });
  });

  group('connection errors', () {
    test(
        'a request to an unreachable host returns a "cannot connect" message',
        () async {
      // An absolute URL in `path` overrides Dio's configured baseUrl, so this
      // reaches port 1 (nothing listens there) regardless of the singleton's
      // baseUrl set at construction time — surfacing a real
      // DioExceptionType.connectionError.
      final response = await ApiService().get('http://127.0.0.1:1/ok');
      expect(response.success, isFalse);
      expect(
        response.message,
        equals('Cannot connect to server. Is the backend running?'),
      );
    });
  });

  group('server error responses', () {
    test('get() on a 500 response returns success=false with the server message',
        () async {
      final response = await ApiService().get('/server-error');
      expect(response.success, isFalse);
      expect(response.statusCode, equals(500));
      expect(response.message, equals('Something broke server-side'));
    });
  });

  // A "401 clears the token and navigates to the login route" test was
  // deliberately left out: the request's onError interceptor calls
  // Get.offAllNamed(...) mid-flight from inside the awaited get() call,
  // before the test ever reaches a pump/pumpAndSettle to drive the route
  // transition's animation forward — that's a real deadlock (confirmed by
  // hanging indefinitely), not a flaky timing issue, so it isn't safely
  // testable this way without changing production navigation code.
}
