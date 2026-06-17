import 'package:get/get.dart';

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
}

class MerchantNotificationsController extends GetxController {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyNotifications();
  }

  void _loadDummyNotifications() {
    notifications.value = [
      NotificationItem(
        id: '1',
        title: 'New Order Received! 🚀',
        body: 'Order #10234 has been placed. Please accept it.',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        type: 'order',
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Payment Successful',
        body: 'Payment for order #10233 was received successfully.',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'payment',
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'System Maintenance',
        body: 'VIPs system will undergo maintenance tonight at 2 AM.',
        time: DateTime.now().subtract(const Duration(days: 1)),
        type: 'system',
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: 'Order Cancelled',
        body: 'Customer cancelled order #10230.',
        time: DateTime.now().subtract(const Duration(days: 2)),
        type: 'alert',
        isRead: true,
      ),
    ];
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
      _updateUnreadCount();
    }
  }

  void markAllAsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    _updateUnreadCount();
  }
}
