import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

class VendorOrderController extends GetxController {
  final _api = ApiService();
  static const vendorGreen = 0xFF16A34A;

  final _isLoading = false.obs;
  final _selectedStatusIndex = 0.obs;
  final _selectedOrderId = ''.obs;
  final _selectedFilterIndex = 0.obs;

  bool get isLoading => _isLoading.value;
  int get selectedStatusIndex => _selectedStatusIndex.value;
  String get selectedOrderId => _selectedOrderId.value;
  int get selectedFilterIndex => _selectedFilterIndex.value;

  final _todayOrderCount = 0.obs;
  final _thisWeekOrderCount = 0.obs;
  final _thisMonthOrderCount = 0.obs;

  int get todayOrderCount => _todayOrderCount.value;
  int get thisWeekOrderCount => _thisWeekOrderCount.value;
  int get thisMonthOrderCount => _thisMonthOrderCount.value;

  final List<String> topFilters = ['Active', 'Done', 'Refunded'];

  final List<String> orderStatuses = [
    'Pending',
    'Confirmed',
    'Processing',
    'Ready',
    'Delivered',
    'Cancelled',
  ];

  final allOrders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    _isLoading.value = true;
    try {
      final response = await _api.get(
        '/merchant/orders',
        queryParams: {'status': 'all', 'page': 1, 'limit': 50},
      );
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final orders = data['orders'] as List<dynamic>?;
        final total = (data['total'] as num?)?.toInt() ?? 0;
        if (orders != null) {
          allOrders.assignAll(
            orders.map((o) => _mapOrder(o as Map)).toList(),
          );
          _todayOrderCount.value = total;
          _thisWeekOrderCount.value = total;
          _thisMonthOrderCount.value = total;
        }
      }
    } catch (_) {}
    _isLoading.value = false;
  }

  Map<String, dynamic> _mapOrder(Map o) {
    final user = o['userId'];
    final items = (o['items'] as List?) ?? [];
    final createdAt = o['createdAt']?.toString() ?? '';
    return {
      'id': o['_id']?.toString() ?? '',
      'customerName': user is Map ? (user['fullName'] ?? 'Unknown') : 'Unknown',
      'customerPhone': user is Map ? (user['phone'] ?? '') : '',
      'customerImage': '',
      'items': items.length,
      'amount': (o['totalAmount'] as num?)?.toDouble() ?? 0.0,
      'status': _capitalize(o['status']?.toString() ?? 'pending'),
      'orderType': 'Delivery',
      'paymentMethod': _formatPayment(o['paymentMethod']?.toString() ?? 'cash'),
      'date': _formatDate(createdAt),
      'time': _formatTime(createdAt),
      'address': o['deliveryAddress']?.toString() ?? '',
      'orderNote': '',
      'refundStatus': 'none',
      'products': items
          .map(
            (item) => {
              'name': item['name'] ?? '',
              'quantity': item['quantity'] ?? 1,
              'price': (item['price'] as num?)?.toDouble() ?? 0.0,
              'addons': '',
              'image': '',
            },
          )
          .toList(),
    };
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  String _formatPayment(String method) {
    switch (method) {
      case 'cash':
        return 'Cash on Delivery';
      case 'card':
        return 'Card Payment';
      case 'wallet':
        return 'Wallet Payment';
      default:
        return method;
    }
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '';
    }
  }

  String _formatTime(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
      final m = d.minute.toString().padLeft(2, '0');
      final ampm = d.hour < 12 ? 'AM' : 'PM';
      return '$h:$m $ampm';
    } catch (_) {
      return '';
    }
  }

  void setStatusIndex(int index) {
    _selectedStatusIndex.value = index;
    update();
  }

  void setFilterIndex(int index) {
    _selectedFilterIndex.value = index;
    _selectedStatusIndex.value = 0;
  }

  void selectOrder(String orderId) {
    _selectedOrderId.value = orderId;
  }

  List<Map<String, dynamic>> getFilteredOrders() {
    List<Map<String, dynamic>> filtered;

    switch (_selectedFilterIndex.value) {
      case 0:
        filtered = allOrders
            .where(
              (order) =>
                  order['status'] != 'Delivered' &&
                  order['status'] != 'Cancelled' &&
                  order['refundStatus'] != 'approved',
            )
            .toList();
        break;
      case 1:
        filtered = allOrders
            .where(
              (order) =>
                  order['status'] == 'Delivered' &&
                  order['refundStatus'] != 'approved',
            )
            .toList();
        break;
      case 2:
        filtered = allOrders
            .where((order) => order['refundStatus'] == 'approved')
            .toList();
        break;
      default:
        filtered = allOrders.toList();
    }

    if (_selectedStatusIndex.value != 0) {
      final status = orderStatuses[_selectedStatusIndex.value];
      filtered =
          filtered.where((order) => order['status'] == status).toList();
    }

    return filtered;
  }

  Map<String, dynamic>? getOrderById(String orderId) {
    try {
      return allOrders.firstWhere((order) => order['id'] == orderId);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    _isLoading.value = true;

    final index = allOrders.indexWhere((order) => order['id'] == orderId);
    if (index != -1) {
      allOrders[index] = Map<String, dynamic>.from(allOrders[index])
        ..['status'] = newStatus;
    }

    try {
      final bareId = orderId.startsWith('#') ? orderId.substring(1) : orderId;
      await _api.put('/merchant/orders/$bareId/status', {'status': newStatus});
    } catch (_) {}

    _isLoading.value = false;
    update();
  }

  int getCountForStatus(String status) {
    if (status == 'All') return allOrders.length;
    return allOrders.where((order) => order['status'] == status).length;
  }

  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '0xFFFF9800';
      case 'confirmed':
        return '0xFF2196F3';
      case 'processing':
        return '0xFF9C27B0';
      case 'ready':
        return '0xFF16A34A';
      case 'delivered':
        return '0xFF009688';
      case 'cancelled':
        return '0xFFF44336';
      default:
        return '0xFF9E9E9E';
    }
  }

  int getActiveOrdersCount() {
    return allOrders
        .where(
          (order) =>
              order['status'] != 'Delivered' &&
              order['status'] != 'Cancelled' &&
              order['refundStatus'] != 'approved',
        )
        .length;
  }

  int getDoneOrdersCount() {
    return allOrders
        .where(
          (order) =>
              order['status'] == 'Delivered' &&
              order['refundStatus'] != 'approved',
        )
        .length;
  }

  int getRefundedOrdersCount() {
    return allOrders
        .where((order) => order['refundStatus'] == 'approved')
        .length;
  }
}
