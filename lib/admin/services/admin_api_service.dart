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

  // ── Analytical dashboards ─────────────────────────────────
  /// The five dashboards share one shape: `{window, ...figures, ...tables}`.
  /// One method covers them all, so adding a sixth needs no new client code.
  ///
  /// `period` is a preset window (today/week/month/year/custom); when it is
  /// `custom`, `startDate` and `endDate` carry the range.
  Future<ApiResponse> dashboard(
    String name, {
    String? period,
    String? startDate,
    String? endDate,
    String? merchantId,
  }) =>
      _api.get('/admin/dashboards/$name', queryParams: _clean({
            'period': period,
            'startDate': startDate,
            'endDate': endDate,
            'merchantId': merchantId,
          }));

  Future<ApiResponse> exportDashboard(
    String name, {
    String? period,
    String? startDate,
    String? endDate,
  }) =>
      _api.get('/admin/dashboards/$name/export', queryParams: _clean({
            'format': 'csv',
            'period': period,
            'startDate': startDate,
            'endDate': endDate,
          }));

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

  Future<ApiResponse> createUser({
    required String fullName,
    required String phone,
    String? email,
    String? city,
  }) =>
      _api.post('/admin/users', _clean({
            'fullName': fullName,
            'phone': phone,
            'email': email,
            'city': city,
          }));

  /// Only the fields being changed are sent — the backend applies what it is
  /// given, so sending everything would rewrite a field nobody touched.
  Future<ApiResponse> updateUser(String id, Map<String, dynamic> changes) =>
      _api.put('/admin/users/$id', changes);

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

  // ── Guarantees (§5.1 / §5.2) ──────────────────────────────
  // A merchant's guarantee is cash they paid in, held against the points
  // their offers hand out. It is never platform revenue, so it is read and
  // reported apart from anything the platform has earned.

  Future<ApiResponse> merchantGuarantee(String id) =>
      _api.get('/admin/merchants/$id/guarantee');

  /// Records cash received. Admin-only: the deposit stands for money that
  /// actually arrived, so a merchant cannot credit their own.
  Future<ApiResponse> depositGuarantee(String id, num amount, {String note = ''}) =>
      _api.post('/admin/merchants/$id/guarantee/deposit', {'amount': amount, 'note': note});

  /// The plan sets the commission (§8); the earn rate is the merchant's own
  /// points-per-dinar policy (§4.1).
  Future<ApiResponse> setMerchantPlan(String id, {String? plan, num? earnRate}) =>
      _api.put('/admin/merchants/$id/plan', {
        if (plan != null) 'plan': plan,
        if (earnRate != null) 'earnRate': earnRate,
      });

  /// Guarantee held across every merchant — the platform's total exposure.
  Future<ApiResponse> guarantees() => _api.get('/admin/guarantees');

  /// Bank transfers merchants say they have sent, waiting to be confirmed.
  /// Points do not exist until one is confirmed here.
  Future<ApiResponse> guaranteeRequests({String status = 'pending'}) =>
      _api.get('/admin/guarantee-requests', queryParams: {'status': status});

  Future<ApiResponse> reviewGuaranteeRequest(String id, String action, {String note = ''}) =>
      _api.put('/admin/guarantee-requests/$id', {'action': action, 'note': note});

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

  /// Opens a new stock line. A line is one item in one location, so the same
  /// item in two store rooms is two lines.
  Future<ApiResponse> createInventoryItem(Map<String, dynamic> body) =>
      _api.post('/admin/inventory', body);

  Future<ApiResponse> deleteInventoryItem(String id) =>
      _api.delete('/admin/inventory/$id');

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

  // ── Product catalogue ─────────────────────────────────────
  /// The catalogue across every merchant. Separate from [merchantProducts],
  /// which reads the public content route for the till.
  Future<ApiResponse> products({
    int page = 1,
    int limit = 20,
    String? search,
    String? merchantId,
    String? category,
    String? status,
  }) =>
      _api.get('/admin/products', queryParams: _clean({
            'page': page,
            'limit': limit,
            'search': search,
            'merchantId': merchantId,
            'category': category,
            'status': status,
          }));

  Future<ApiResponse> productDetails(String id) => _api.get('/admin/products/$id');

  Future<ApiResponse> createProduct(Map<String, dynamic> body) =>
      _api.post('/admin/products', body);

  Future<ApiResponse> updateProduct(String id, Map<String, dynamic> changes) =>
      _api.put('/admin/products/$id', changes);

  Future<ApiResponse> deleteProduct(String id) => _api.delete('/admin/products/$id');

  // ── Point of sale ─────────────────────────────────────────
  Future<ApiResponse> posSession() => _api.get('/admin/pos/session');

  Future<ApiResponse> posStartSession(String merchantId, num openingFloat) =>
      _api.post('/admin/pos/session/start',
          {'merchantId': merchantId, 'openingFloat': openingFloat});

  Future<ApiResponse> posEndSession(num closingCount) =>
      _api.post('/admin/pos/session/end', {'closingCount': closingCount});

  Future<ApiResponse> posSessions({int limit = 20, String? status}) =>
      _api.get('/admin/pos/sessions',
          queryParams: _clean({'limit': limit, 'status': status}));

  Future<ApiResponse> posCart() => _api.get('/admin/pos/cart');

  Future<ApiResponse> posAddToCart(String productId, int quantity) =>
      _api.post('/admin/pos/cart/add', {'productId': productId, 'quantity': quantity});

  /// A quantity of 0 removes the line — the natural thing on a till keypad.
  Future<ApiResponse> posUpdateCartLine(String itemId, int quantity) =>
      _api.put('/admin/pos/cart/update', {'itemId': itemId, 'quantity': quantity});

  Future<ApiResponse> posRemoveCartLine(String itemId) =>
      _api.delete('/admin/pos/cart/remove/$itemId');

  Future<ApiResponse> posClearCart() => _api.delete('/admin/pos/cart/clear');

  Future<ApiResponse> posApplyDiscount(num amount, String type) =>
      _api.post('/admin/pos/cart/discount', {'amount': amount, 'type': type});

  Future<ApiResponse> posAttachCustomer({
    String? customerId,
    String? name,
    String? phone,
  }) =>
      _api.post('/admin/pos/cart/customer', _clean({
            'customerId': customerId,
            'name': name,
            'phone': phone,
          }));

  Future<ApiResponse> posCreateInvoice({
    required String paymentMethod,
    required num amountPaid,
    String note = '',
  }) =>
      _api.post('/admin/pos/invoice/create', {
        'paymentMethod': paymentMethod,
        'amountPaid': amountPaid,
        'note': note,
      });

  Future<ApiResponse> posInvoice(String id) => _api.get('/admin/pos/invoice/$id');

  Future<ApiResponse> posInvoices({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? merchantId,
    String? from,
    String? to,
  }) =>
      _api.get('/admin/pos/invoices', queryParams: _clean({
            'page': page,
            'limit': limit,
            'search': search,
            'status': status,
            'merchantId': merchantId,
            'from': from,
            'to': to,
          }));

  Future<ApiResponse> posRefundInvoice(String invoiceId, String reason) =>
      _api.post('/admin/pos/invoice/refund',
          {'invoiceId': invoiceId, 'reason': reason});

  Future<ApiResponse> posCustomers({String? search, int limit = 20}) =>
      _api.get('/admin/pos/customers',
          queryParams: _clean({'search': search, 'limit': limit}));

  Future<ApiResponse> posCreateCustomer({
    required String fullName,
    required String phone,
    String? email,
  }) =>
      _api.post('/admin/pos/customers', _clean({
            'fullName': fullName,
            'phone': phone,
            'email': email,
          }));

  /// The till sells the merchant's catalogue, so the product list comes from
  /// the public content route scoped to that merchant.
  Future<ApiResponse> merchantProducts(String merchantId, {String? search}) =>
      _api.get('/content/products',
          queryParams: _clean({'merchantId': merchantId, 'search': search, 'limit': 100}));

  // ── Reports ───────────────────────────────────────────────
  /// The seven reports share a shape: `{summary, ...sections}`. One method
  /// covers them all so a new report needs no new client code.
  Future<ApiResponse> report(
    String type, {
    String? from,
    String? to,
    String? groupBy,
    String? merchantId,
  }) =>
      _api.get('/admin/reports/$type', queryParams: _clean({
            'from': from,
            'to': to,
            'groupBy': groupBy,
            'merchantId': merchantId,
          }));

  /// The export URL. Handed to the browser rather than fetched, so the file
  /// lands in the user's downloads instead of in memory.
  String reportExportPath(String type, {String? from, String? to, String? groupBy}) {
    final params = _clean({
      'type': type,
      'format': 'csv',
      'from': from,
      'to': to,
      'groupBy': groupBy,
    }).entries.map((e) => '${e.key}=${Uri.encodeComponent('${e.value}')}').join('&');
    return '/admin/reports/export?$params';
  }

  Future<ApiResponse> exportReport(String type,
          {String? from, String? to, String? groupBy}) =>
      _api.get('/admin/reports/export', queryParams: _clean({
            'type': type,
            'format': 'csv',
            'from': from,
            'to': to,
            'groupBy': groupBy,
          }));

  // ── Analytics ─────────────────────────────────────────────
  /// Visitors and the conversion rate they give a denominator to.
  Future<ApiResponse> analyticsOverview({int days = 30}) =>
      _api.get('/admin/analytics/overview', queryParams: {'days': days});

  // ── Audit log ─────────────────────────────────────────────
  /// What operators have done in the console. `outcome` filters to
  /// 'success' or 'denied' — a refused attempt is the line this exists for.
  Future<ApiResponse> auditLogs({
    int page = 1,
    int limit = 20,
    String? search,
    String? actorId,
    String? targetType,
    String? outcome,
    String? from,
    String? to,
  }) =>
      _api.get('/admin/audit/logs', queryParams: _clean({
            'page': page,
            'limit': limit,
            'search': search,
            'actorId': actorId,
            'targetType': targetType,
            'outcome': outcome,
            'from': from,
            'to': to,
          }));

  Future<ApiResponse> auditEntry(String id) => _api.get('/admin/audit/logs/$id');

  // ── Staff and roles ───────────────────────────────────────
  Future<ApiResponse> staff({
    int page = 1,
    int limit = 20,
    String? search,
    String? adminRole,
  }) =>
      _api.get('/admin/staff', queryParams: _clean({
            'page': page,
            'limit': limit,
            'search': search,
            'adminRole': adminRole,
          }));

  Future<ApiResponse> staffMember(String id) => _api.get('/admin/staff/$id');

  Future<ApiResponse> createStaff({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String adminRole,
    List<String> permissions = const [],
  }) =>
      _api.post('/admin/staff', {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'adminRole': adminRole,
        'permissions': permissions,
      });

  /// Only the fields actually being changed are sent — the backend applies
  /// what it is given, so sending everything would overwrite a field the
  /// operator never touched.
  Future<ApiResponse> updateStaff(String id, Map<String, dynamic> changes) =>
      _api.put('/admin/staff/$id', changes);

  Future<ApiResponse> deleteStaff(String id) => _api.delete('/admin/staff/$id');

  Future<ApiResponse> permissionCatalogue() => _api.get('/admin/permissions');

  Future<ApiResponse> roles() => _api.get('/admin/roles');

  Future<ApiResponse> createRole({
    required String name,
    String description = '',
    List<String> permissions = const [],
  }) =>
      _api.post('/admin/roles', {
        'name': name,
        'description': description,
        'permissions': permissions,
      });

  Future<ApiResponse> updateRole(String id, Map<String, dynamic> changes) =>
      _api.put('/admin/roles/$id', changes);

  Future<ApiResponse> deleteRole(String id) => _api.delete('/admin/roles/$id');

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
