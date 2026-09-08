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
import 'package:vip/appuser/modules/Cart/controllers/cart_controller.dart';
import 'package:vip/appmerchant/core/api/api_client.dart' as merchant;
import 'package:vip/appuser/core/api/api_client.dart' as consumer;
import 'package:vip/appmerchant/core/util/app_constants.dart' as merchant_config;
import 'package:vip/appuser/core/util/app_constants.dart' as consumer_config;

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
              'query': request.uri.queryParameters,
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
        case '/late-unauthorized':
          await Future<void>.delayed(const Duration(milliseconds: 100));
          body = {'success': false, 'message': 'Old session expired'};
          request.response.statusCode = 401;
          break;
        case '/plain-map':
          body = {'orders': <dynamic>[], 'total_size': 0};
          request.response.statusCode = 200;
          break;
        case '/numeric-error':
          body = {'success': false, 'message': 123};
          request.response.statusCode = 400;
          break;
        case '/created':
          body = {'success': true, 'data': {'id': 'created-record'}};
          request.response.statusCode = 201;
          break;
        case '/auth/login':
          body = {'success': false, 'message': 'Invalid phone or password'};
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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ApiService().init();
  });

  group('successful requests', () {
    test('consecutive failed cart writes restore the last confirmed quantity', () async {
      final controller = CartController();
      final item = CartItem(id: 'failed-cart-line', name: 'Item', description: '',
          price: 10, type: CartItemType.product);
      controller.cartItems.clear();
      controller.cartItems.add(item);
      controller.increaseQuantity(item);
      controller.increaseQuantity(item);
      expect(item.quantity, 3);
      // The local server rejects both /cart/update writes. Wait for the
      // observable rollback rather than assuming a fixed network duration.
      final deadline = DateTime.now().add(const Duration(seconds: 3));
      while (item.quantity == 3 && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(item.quantity, 1);
    });

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
      expect(response.data['query']['page'], '2');
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

  group('shared session and response contracts', () {
    test('consumer legacy client preserves created records and server failures', () async {
      final prefs = await SharedPreferences.getInstance();
      final client = consumer.ApiClient(appBaseUrl: ApiService.baseUrl, sharedPreferences: prefs);
      final created = await client.postData('/created', {});
      expect(created.statusCode, 201);
      expect(created.body['data']['id'], 'created-record');
      final failure = await client.getData('/server-error');
      expect(failure.statusCode, 500);
      expect(failure.body['message'], 'Something broke server-side');
    });
    test('both HTTP clients follow login and logout without reconstruction', () async {
      final prefs = await SharedPreferences.getInstance();
      final merchantClient = merchant.ApiClient(appBaseUrl: ApiService.baseUrl, sharedPreferences: prefs);
      final userClient = consumer.ApiClient(appBaseUrl: ApiService.baseUrl, sharedPreferences: prefs);
      await ApiService().setToken('first-session');
      expect((await merchantClient.getData('/ok')).body['data']['authHeader'], 'Bearer first-session');
      await ApiService().setToken('second-session');
      expect((await merchantClient.getData('/ok')).body['data']['authHeader'], 'Bearer second-session');
      expect((await userClient.getData('/ok')).body['data']['authHeader'], 'Bearer second-session');
      await ApiService().clearToken();
      expect(prefs.getString('token'), isNull);
      expect((await merchantClient.getData('/ok')).body['data']['authHeader'], isNull);
      expect((await userClient.getData('/ok')).body['data']['authHeader'], isNull);
      await ApiService().init();
      expect(ApiService().isLoggedIn, isFalse);
    });

    test('legacy HTTP clients preserve existing and supplied query parameters', () async {
      final prefs = await SharedPreferences.getInstance();
      final client = merchant.ApiClient(appBaseUrl: ApiService.baseUrl, sharedPreferences: prefs);
      final response = await client.getData('/ok?status=pending', query: {'offset': 10});
      expect(response.body['data']['query'], {'status': 'pending', 'offset': '10'});
    });

    test('API base override reaches both apps legacy clients', () {
      expect(merchant_config.AppConstants.baseUrl, ApiService.baseUrl);
      expect(consumer_config.AppConstants.baseUrl, ApiService.baseUrl);
    });

    test('a plain map response retains its data', () async {
      final response = await ApiService().get('/plain-map');
      expect(response.success, isTrue);
      expect(response.data['orders'], isEmpty);
      expect(response.data['total_size'], 0);
    });

    test('non-string server errors are converted to messages', () async {
      final response = await ApiService().get('/numeric-error');
      expect(response.success, isFalse);
      expect(response.message, '123');
    });

    test('401 clears both saved token copies and completes the request', () async {
      await ApiService().setToken('expired');
      final response = await ApiService().get('/unauthorized');
      final prefs = await SharedPreferences.getInstance();
      expect(response.statusCode, 401);
      expect(ApiService().isLoggedIn, isFalse);
      expect(prefs.getString('auth_token'), isNull);
      expect(prefs.getString('token'), isNull);
    });

    test('a late 401 from a previous session cannot sign out a new login', () async {
      await ApiService().setToken('old');
      final pending = ApiService().get('/late-unauthorized');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await ApiService().setToken('new');
      await pending;
      expect(ApiService().authToken, 'new');
    });

    test('an empty token is not a session', () async {
      expect(() => ApiService().setToken('  '), throwsArgumentError);
      SharedPreferences.setMockInitialValues({'auth_token': ''});
      await ApiService().init();
      expect(ApiService().isLoggedIn, isFalse);
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
      expect(response.message, equals('Something broke server-side'));
    });

    test(
        'post() to /auth/login returning 401 does not trigger route redirect and returns ApiResponse',
        () async {
      final response = await ApiService().post('/auth/login', {
        'phone': '12345678',
        'password': 'wrongpassword',
      });
      expect(response.success, isFalse);
      expect(response.statusCode, equals(401));
      expect(response.message, equals('Invalid phone or password'));
    });
  });

}
