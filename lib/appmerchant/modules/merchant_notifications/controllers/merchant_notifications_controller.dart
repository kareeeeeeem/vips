import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final String type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      time: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      type: json['type'] ?? 'system',
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
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    _updateUnreadCount();
    try {
      await ApiService().post('/merchant/notifications/read-all', {});
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    notifications.removeWhere((n) => n.id == id);
    _updateUnreadCount();
    try {
      await ApiService().delete('/merchant/notifications/$id');
    } catch (_) {}
  }
}
