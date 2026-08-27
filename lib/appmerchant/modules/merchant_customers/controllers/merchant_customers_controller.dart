import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class CustomerModel {
  final String id;
  final String name;
  /// Served by GET /merchant/customers and thrown away by this model, which
  /// left the list with nothing to act on.
  final String phone;
  final int totalVisits;
  final int pointsEarned;
  final int pointsSpent;
  final String lastVisit;
  final String imageUrl;

  CustomerModel({
    required this.id,
    required this.name,
    this.phone = '',
    required this.totalVisits,
    required this.pointsEarned,
    required this.pointsSpent,
    required this.lastVisit,
    required this.imageUrl,
  });

  static int _int(dynamic v) =>
      v is num ? v.toInt() : (int.tryParse('${v ?? ''}') ?? 0);

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final name = (json['fullName'] ?? json['name'] ?? 'Unknown').toString();
    // tryParse — a malformed timestamp used to throw out of the whole list.
    final visit = DateTime.tryParse('${json['lastVisit'] ?? ''}');
    final profileImage = (json['profileImage'] ?? '').toString();
    return CustomerModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: name,
      phone: (json['phone'] ?? '').toString(),
      // Backend aggregation can return these as either int or double —
      // a bare `as int` crashes on a double count.
      // All three are now merchant-scoped figures from GET /merchant/customers.
      // `pointsEarned` used to read `walletPoints` — the customer's
      // platform-wide balance, not what this merchant gave them — while
      // `totalVisits` was never served at all and `pointsSpent` was the
      // literal 0, so two of the three stats were always zero.
      totalVisits: _int(json['totalVisits']),
      pointsEarned: _int(json['pointsEarned']),
      pointsSpent: _int(json['pointsSpent']),
      lastVisit: visit == null
          ? 'No visits yet'
          : '${visit.toLocal().day}/${visit.toLocal().month}/${visit.toLocal().year}',
      // The customer's real picture when they have one; the generated
      // avatar is only the fallback (it used to be used unconditionally,
      // hitting an external host for every single row).
      imageUrl: profileImage.isNotEmpty
          ? profileImage.replaceFirst('http://', 'https://')
          : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=10B981&color=fff',
    );
  }
}

class MerchantCustomersController extends GetxController {
  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  List<CustomerModel> get filteredCustomers {
    if (searchQuery.value.isEmpty) return customers;
    return customers
        .where((c) => c.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    isLoading.value = true;
    try {
      final query = <String, dynamic>{};
      if (searchQuery.value.trim().isNotEmpty) {
        query['search'] = searchQuery.value.trim();
      }
      final response = await ApiService()
          .get('/merchant/customers', queryParams: query.isEmpty ? null : query);
      if (response.success && response.data != null) {
        final data = response.data;
        final list = (data is Map ? data['customers'] : data);
        customers.value = list is List
            ? list
                .whereType<Map>()
                .map((e) => CustomerModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : <CustomerModel>[];
      }
    } catch (e) {
      debugPrint('loadCustomers failed: $e');
      safeSnackbar('Error', 'Could not load customers. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Timer? _searchDebounce;

  /// The backend already supported `?search=` (name / phone / email) and
  /// nothing ever sent it — there was no search field on the screen at all,
  /// leaving `updateSearch` and `filteredCustomers` as dead code.
  void updateSearch(String q) {
    searchQuery.value = q;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), loadCustomers);
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    searchQuery.value = '';
    loadCustomers();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }
}
