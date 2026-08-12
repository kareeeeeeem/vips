import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class CustomerModel {
  final String id;
  final String name;
  final int totalVisits;
  final int pointsEarned;
  final int pointsSpent;
  final String lastVisit;
  final String imageUrl;

  CustomerModel({
    required this.id,
    required this.name,
    required this.totalVisits,
    required this.pointsEarned,
    required this.pointsSpent,
    required this.lastVisit,
    required this.imageUrl,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final name = json['fullName'] ?? json['name'] ?? 'Unknown';
    return CustomerModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: name,
      totalVisits: (json['totalVisits'] ?? 0) as int,
      pointsEarned: (json['walletPoints'] ?? 0) as int,
      pointsSpent: 0,
      lastVisit: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal().toString().split('.')[0]
          : 'Unknown',
      imageUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=10B981&color=fff',
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
      final response = await ApiService().get('/merchant/customers');
      if (response.success && response.data != null) {
        final data = response.data;
        final List<dynamic> list = data['customers'] ?? data ?? [];
        customers.value = list.map((e) => CustomerModel.fromJson(e)).toList();
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to load customers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String q) {
    searchQuery.value = q;
  }
}
