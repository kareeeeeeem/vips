import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final String type;
  /// The notification's payload (e.g. {orderId, orderNumber}). It was parsed
  /// away entirely, so a notification could never lead anywhere.
  final Map<String, dynamic> data;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.data = const {},
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      time: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      type: json['type'] ?? 'system',
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : const {},
      isRead: json['isRead'] ?? false,
    );
  }
}

class MerchantNotificationsController extends GetxController {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final response = await ApiService().get('/merchant/notifications');
      if (response.success && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data
            : (response.data['notifications'] ?? []);
        notifications.value = list.map((e) => NotificationItem.fromJson(e)).toList();
        _updateUnreadCount();
      }
    } catch (e) {
      // Silently fail — notifications are not critical
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
      _updateUnreadCount();
    }
    try {
      await ApiService().put('/merchant/notifications/$id/read', {});
    } catch (_) {
      // Local state already flipped optimistically — resync with the
      // server on failure so it doesn't silently drift (e.g. showing read
      // here but reverting to unread on the next load with no explanation).
      await loadNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    _updateUnreadCount();
    try {
      await ApiService().post('/merchant/notifications/read-all', {});
    } catch (_) {
      await loadNotifications();
    }
  }

  /// Marks the notification read and opens whatever it is about. Tapping a
  /// notification used to do nothing but flip it to read — an order alert
  /// could not take the merchant to the order.
  Future<void> openNotification(NotificationItem n) async {
    await markAsRead(n.id);

    switch (n.type) {
      case 'order':
      case 'review':
        final orderNumber = n.data['orderNumber'];
        final parsed = orderNumber is int
            ? orderNumber
            : int.tryParse(orderNumber?.toString() ?? '');
        if (parsed != null) {
          Get.toNamed(MerchantRoutes.ORDER_DETAIL, arguments: parsed);
        } else {
          Get.toNamed(MerchantRoutes.ORDERS);
        }
        break;
      case 'payment':
      case 'gift_back':
        Get.toNamed(MerchantRoutes.WALLET);
        break;
      case 'subscription':
        Get.toNamed(MerchantRoutes.BUSINESS_PLAN);
        break;
      default:
        // 'system' / 'alert' carry no destination — the body is the message.
        break;
    }
  }

  Future<void> deleteNotification(String id) async {
    notifications.removeWhere((n) => n.id == id);
    _updateUnreadCount();
    try {
      await ApiService().delete('/merchant/notifications/$id');
    } catch (_) {
      safeSnackbar('Error', 'Could not delete notification. Refreshing...', snackPosition: SnackPosition.BOTTOM);
      await loadNotifications();
    }
  }
}
