import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../core/constants/app_assets.dart';
import '../../../design_system/atoms/app_colors.dart';

enum NotificationType { promotion, account, payment, partnership }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final String? image;
  bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.image,
    required this.isRead,
    required this.type,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? UniqueKey().toString(),
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      time: json['time'] ?? 'Just now',
      image: json['image'],
      isRead: json['isRead'] == true,
      type: _notificationTypeFromString(json['type'] ?? 'account'),
    );
  }

  static NotificationType _notificationTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'promotion':
        return NotificationType.promotion;
      case 'payment':
        return NotificationType.payment;
      case 'partnership':
        return NotificationType.partnership;
      case 'account':
      default:
        return NotificationType.account;
    }
  }
}

class NotificationsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Observable variables
  var notifications = <NotificationItem>[].obs;
  var selectedFilter = 'All'.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _loadNotifications();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic),
    );

    animationController.forward();
  }

  void _loadNotifications() async {
    isLoading.value = true;

    try {
      final response = await ApiService().get('/user/notifications');
      if (response.success && response.data != null) {
        final data = response.data as List<dynamic>;
        notifications.value = data
            .map((item) => NotificationItem.fromJson(item))
            .toList();
      } else {
        _loadLocalNotifications();
      }
    } catch (e) {
      print('Error loading notifications: $e');
      _loadLocalNotifications();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadLocalNotifications() {
    notifications.value = [
      NotificationItem(
        id: '1',
        title: 'LC WAIKIKI',
        message:
            'Welcome to resort paradise we ensure the best service in bali with an emphasis on customer satisfaction and comfort.',
        time: '1 day ago',
        image: AppImages.LC,
        isRead: false,
        type: NotificationType.promotion,
      ),
      NotificationItem(
        id: '2',
        title: 'VIP Account Update',
        message:
            'Your profile has been successfully updated. All changes are now active.',
        time: '2 hours ago',
        isRead: true,
        type: NotificationType.account,
      ),
      NotificationItem(
        id: '3',
        title: 'Payment Successful',
        message:
            'Your payment of \$89.99 has been processed successfully for your VIP membership.',
        time: '3 hours ago',
        isRead: false,
        type: NotificationType.payment,
      ),
      NotificationItem(
        id: '4',
        title: 'New Partner Added',
        message:
            'Great news! A new exclusive partner has joined our VIP network.',
        time: '1 day ago',
        isRead: true,
        type: NotificationType.partnership,
      ),
      NotificationItem(
        id: '5',
        title: 'Special Offer',
        message:
            'Limited time offer: Get 20% off on all premium services this week!',
        time: '2 days ago',
        isRead: false,
        type: NotificationType.promotion,
      ),
    ];
  }

  // Getters
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get filteredNotifications {
    switch (selectedFilter.value) {
      case 'Unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'Promotions':
        return notifications
            .where((n) => n.type == NotificationType.promotion)
            .toList();
      default:
        return notifications.toList();
    }
  }

  // Actions
  void goBack() {
    // Use Navigator directly to avoid GetX snackbar queue crash
    if (Get.context != null && Navigator.of(Get.context!).canPop()) {
      Navigator.of(Get.context!).pop();
    }
  }

  void markAllAsRead() {
    for (var notification in notifications) {
      notification.isRead = true;
    }
    notifications.refresh();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void markAsRead(NotificationItem notification) {
    notification.isRead = true;
    notifications.refresh();
  }

  void markAsUnread(NotificationItem notification) {
    notification.isRead = false;
    notifications.refresh();
  }

  void deleteNotification(NotificationItem notification) {
    notifications.remove(notification);
  }

  void handleNotificationTap(NotificationItem notification) {
    if (!notification.isRead) {
      markAsRead(notification);
    }
    showNotificationDetail(notification);
  }

  void showNotificationDetail(NotificationItem notification) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildNotificationIcon(notification),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF6B7280),
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
                fontFamily: 'SF Pro Text',
                height: 1.5,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Get.back(),
                        child: Center(
                          child: Text(
                            'Dismiss',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.AppPrimaryColor,
                          AppColors.AppPrimaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Get.back();
                          handleNotificationAction(notification);
                        },
                        child: Center(
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void showNotificationOptions(NotificationItem notification) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            _buildOptionItem(
              icon:
                  notification.isRead
                      ? Icons.mark_email_unread_rounded
                      : Icons.mark_email_read_rounded,
              title: notification.isRead ? 'Mark as Unread' : 'Mark as Read',
              onTap: () {
                if (notification.isRead) {
                  markAsUnread(notification);
                } else {
                  markAsRead(notification);
                }
                Get.back();
              },
            ),
            _buildOptionItem(
              icon: Icons.delete_outline_rounded,
              title: 'Delete Notification',
              isDestructive: true,
              onTap: () {
                deleteNotification(notification);
                Get.back();
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildNotificationIcon(NotificationItem notification) {
    if (notification.image != null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8ECF4)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(notification.image!, fit: BoxFit.cover),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: getTypeColor(notification.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        getTypeIcon(notification.type),
        color: getTypeColor(notification.type),
        size: 24,
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.AppPrimaryColor,
                size: 24,
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : const Color(0xFF1F2937),
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  IconData getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.promotion:
        return Icons.local_offer_rounded;
      case NotificationType.account:
        return Icons.person_rounded;
      case NotificationType.payment:
        return Icons.payment_rounded;
      case NotificationType.partnership:
        return Icons.handshake_rounded;
    }
  }

  Color getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.promotion:
        return const Color(0xFFEF4444);
      case NotificationType.account:
        return AppColors.AppPrimaryColor;
      case NotificationType.payment:
        return const Color(0xFF10B981);
      case NotificationType.partnership:
        return const Color(0xFF8B5CF6);
    }
  }

  String getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.account:
        return 'Account';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.partnership:
        return 'Partnership';
    }
  }

  void handleNotificationAction(NotificationItem notification) {
    // Handle specific actions based on notification type
    switch (notification.type) {
      case NotificationType.promotion:
        // Navigate to offers page
        Get.toNamed('/offers');
        break;
      case NotificationType.account:
        // Navigate to profile
        Get.toNamed('/profile');
        break;
      case NotificationType.payment:
        // Navigate to payment history
        Get.toNamed('/payment-history');
        break;
      case NotificationType.partnership:
        // Navigate to partnerships
        Get.toNamed('/partnerships');
        break;
    }
  }

  void openFilterOptions() {
    // Logic pour ouvrir les options de filtre
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro Display',
              ),
            ),
            SizedBox(height: 20),
            ...['All', 'Unread', 'Promotions']
                .map(
                  (filter) => ListTile(
                    title: Text(filter),
                    trailing:
                        selectedFilter.value == filter
                            ? Icon(
                              Icons.check,
                              color: AppColors.AppPrimaryColor,
                            )
                            : null,
                    onTap: () {
                      setFilter(filter);
                      Get.back();
                    },
                  ),
                )
                .toList(),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
