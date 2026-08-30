import 'package:vip/core/services/api_service.dart';

/// Every `/api/admin` endpoint in one place.
///
/// Deliberately a thin wrapper over the shared [ApiService] rather than a
/// second HTTP client: token storage, the 60s Render cold-start timeout and
/// the app-wide 401 redirect are already solved there, and a parallel client
/// would quietly drift out of sync with them.
///
/// Every method returns the raw [ApiResponse] so callers decide how to
/// surface failures — controllers here show a message and keep the previous
/// data on screen rather than blanking it.
class AdminApiService {
  static final AdminApiService _instance = AdminApiService._internal();
  factory AdminApiService() => _instance;
  AdminApiService._internal();

  final ApiService _api = ApiService();

  // ── Auth ──────────────────────────────────────────────────
  Future<ApiResponse> login(String email, String password) =>
      _api.post('/admin/login', {'email': email, 'password': password});

  Future<ApiResponse> me() => _api.get('/admin/me');

  Future<ApiResponse> logout() => _api.post('/admin/logout', {});

  // ── Top bar ───────────────────────────────────────────────
  Future<ApiResponse> notifications() => _api.get('/admin/notifications');

  Future<ApiResponse> search(String query, {int limit = 5}) =>
      _api.get('/admin/search', queryParams: {'q': query, 'limit': limit});

  // ── Dashboard ─────────────────────────────────────────────
  Future<ApiResponse> dashboardStats() => _api.get('/admin/dashboard/stats');

  Future<ApiResponse> dashboardCharts({int days = 30}) =>
      _api.get('/admin/dashboard/charts', queryParams: {'days': days});

  Future<ApiResponse> dashboardRecent({int limit = 8}) =>
      _api.get('/admin/dashboard/recent', queryParams: {'limit': limit});

  // ── Users ─────────────────────────────────────────────────
  Future<ApiResponse> users({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
    String? status,
  }) =>
      _api.get('/admin/users', queryParams: _clean({
            'page': page,
            'limit': limit,
            'search': search,
            'role': role,
            'status': status,
          }));

  Future<ApiResponse> userDetails(String id) => _api.get('/admin/users/$id');

  Future<ApiResponse> banUser(String id, bool banned) =>
      _api.put('/admin/users/$id/ban', {'banned': banned});

  Future<ApiResponse> changeUserRole(String id, String role) =>
      _api.put('/admin/users/$id/role', {'role': role});

  Future<ApiResponse> deleteUser(String id) => _api.delete('/admin/users/$id');

  // ── Merchants ─────────────────────────────────────────────
  Future<ApiResponse> merchants({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? approval,
  }) =>
      _api.get('/admin/merchants', queryParams: _clean({
            'page': page,
            'limit': limit,
            'search': search,
            'status': status,
            'approval': approval,
          }));

  Future<ApiResponse> merchantDetails(String id) => _api.get('/admin/merchants/$id');

  Future<ApiResponse> approveMerchant(String id, bool approved, {String reason = ''}) =>
      _api.put('/admin/merchants/$id/approve', {'approved': approved, 'reason': reason});

  Future<ApiResponse> activateMerchant(String id, bool active) =>
      _api.put('/admin/merchants/$id/activate', {'active': active});

  Future<ApiResponse> deleteMerchant(String id) => _api.delete('/admin/merchants/$id');

  // ── Orders ────────────────────────────────────────────────
  Future<ApiResponse> orders({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? paymentStatus,
    String? orderType,
    String? merchantId,
    String? userId,
    String? from,
    String? to,
  }) =>
      _api.get('/admin/orders', queryParams: _clean({
            'page': page,
            'limit': limit,
            'search': search,
            'status': status,
            'paymentStatus': paymentStatus,
            'orderType': orderType,
            'merchantId': merchantId,
            'userId': userId,
            'from': from,
            'to': to,
          }));

  Future<ApiResponse> orderDetails(String id) => _api.get('/admin/orders/$id');

  Future<ApiResponse> updateOrderStatus(String id, String status) =>
      _api.put('/admin/orders/$id/status', {'status': status});

  Future<ApiResponse> cancelOrder(String id, String reason) =>
      _api.delete('/admin/orders/$id?reason=${Uri.encodeComponent(reason)}');

  // ── Inventory ─────────────────────────────────────────────
  Future<ApiResponse> inventory({
    int page = 1,
    int limit = 20,
    String? search,
    String? merchantId,
    String? location,
    bool lowStockOnly = false,
  }) =>
      _api.get('/admin/inventory', queryParams: _clean({
            'page': page,
            'limit': limit,
            'search': search,
            'merchantId': merchantId,
            'location': location,
            'lowStock': lowStockOnly ? 'true' : null,
          }));

  Future<ApiResponse> updateInventoryItem(String id, Map<String, dynamic> body) =>
      _api.put('/admin/inventory/$id', body);

  Future<ApiResponse> inventoryAlerts({int limit = 50}) =>
      _api.get('/admin/inventory/alerts', queryParams: {'limit': limit});

  Future<ApiResponse> inventoryMovements({
    int page = 1,
    int limit = 20,
    String? search,
    String? merchantId,
    String? stockId,
    String? type,
    String? location,
    String? from,
    String? to,
  }) =>
      _api.get('/admin/inventory/movements', queryParams: _clean({
            'page': page,
            'limit': limit,
            'search': search,
            'merchantId': merchantId,
            'stockId': stockId,
            'type': type,
            'location': location,
            'from': from,
            'to': to,
          }));

  Future<ApiResponse> inventoryLocations({String? merchantId}) =>
      _api.get('/admin/inventory/locations',
          queryParams: _clean({'merchantId': merchantId}));

  /// Give either [toStockId] (an existing destination line) or [toLocation]
  /// (found or opened for the same item), never both.
  Future<ApiResponse> transferStock({
    required String fromStockId,
    required num quantity,
    String? toStockId,
    String? toLocation,
    String reason = '',
  }) =>
      _api.post('/admin/inventory/transfer', _clean({
            'fromStockId': fromStockId,
            'quantity': quantity,
            'toStockId': toStockId,
            'toLocation': toLocation,
            'reason': reason,
          }));

  // ── Reports ───────────────────────────────────────────────
  Future<ApiResponse> salesReport({String? from, String? to}) =>
      _api.get('/admin/reports/sales', queryParams: _clean({'from': from, 'to': to}));

  Future<ApiResponse> usersReport({String? from, String? to}) =>
      _api.get('/admin/reports/users', queryParams: _clean({'from': from, 'to': to}));

  Future<ApiResponse> merchantsReport() => _api.get('/admin/reports/merchants');

  Future<ApiResponse> ordersReport({String? from, String? to}) =>
      _api.get('/admin/reports/orders', queryParams: _clean({'from': from, 'to': to}));

  // ── Platform settings ─────────────────────────────────────
  Future<ApiResponse> settings() => _api.get('/admin/settings');

  Future<ApiResponse> createAdmin({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) =>
      _api.post('/admin/settings/admins', {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      });

  Future<ApiResponse> deleteAdmin(String id) => _api.delete('/admin/settings/admins/$id');

  /// Drop null/empty params so an unset filter is absent from the query
  /// string rather than sent as the literal string "null", which the
  /// backend would then treat as a real filter value and match nothing.
  Map<String, dynamic> _clean(Map<String, dynamic> params) {
    final out = <String, dynamic>{};
    params.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      out[key] = value;
    });
    return out;
  }
}

// ── Shared JSON coercion ────────────────────────────────────
// Backend numbers arrive as int or double depending on the aggregation, and
// ids as String or ObjectId-shaped Map. Parsing through these keeps a single
// unexpected shape from throwing inside a list builder and blanking a whole
// screen — the failure mode that has bitten this codebase repeatedly.

double adminDouble(dynamic v) =>
    v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);

int adminInt(dynamic v, [int fallback = 0]) =>
    v is num ? v.toInt() : (int.tryParse('${v ?? ''}') ?? fallback);

String adminString(dynamic v, [String fallback = '']) {
  if (v == null) return fallback;
  if (v is String) return v;
  if (v is Map) return adminString(v['_id'] ?? v['id'], fallback);
  return v.toString();
}

bool adminBool(dynamic v, [bool fallback = false]) =>
    v is bool ? v : (v == null ? fallback : '$v'.toLowerCase() == 'true');

DateTime? adminDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());

/// Every list endpoint here returns the same
/// `{items, total, page, limit, pages}` envelope.
List<Map<String, dynamic>> adminItems(dynamic data, [String key = 'items']) {
  if (data is! Map) return const [];
  final raw = data[key];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}
