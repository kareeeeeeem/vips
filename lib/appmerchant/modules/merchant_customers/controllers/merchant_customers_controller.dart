import 'package:get/get.dart';

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
}

class MerchantCustomersController extends GetxController {
  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockCustomers();
  }

  void _loadMockCustomers() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    customers.value = [
      CustomerModel(
        id: 'CUS-001',
        name: 'Ahmed Mahmoud',
        totalVisits: 12,
        pointsEarned: 1500,
        pointsSpent: 500,
        lastVisit: 'Today, 2:30 PM',
        imageUrl: 'https://ui-avatars.com/api/?name=Ahmed+Mahmoud&background=10B981&color=fff',
      ),
      CustomerModel(
        id: 'CUS-002',
        name: 'Sarah Khaled',
        totalVisits: 5,
        pointsEarned: 450,
        pointsSpent: 0,
        lastVisit: 'Yesterday, 6:15 PM',
        imageUrl: 'https://ui-avatars.com/api/?name=Sarah+Khaled&background=F59E0B&color=fff',
      ),
      CustomerModel(
        id: 'CUS-003',
        name: 'Omar Tarek',
        totalVisits: 1,
        pointsEarned: 50,
        pointsSpent: 0,
        lastVisit: '2 days ago',
        imageUrl: 'https://ui-avatars.com/api/?name=Omar+Tarek&background=3B82F6&color=fff',
      ),
      CustomerModel(
        id: 'CUS-004',
        name: 'Nour Ali',
        totalVisits: 28,
        pointsEarned: 3200,
        pointsSpent: 2800,
        lastVisit: '1 week ago',
        imageUrl: 'https://ui-avatars.com/api/?name=Nour+Ali&background=8B5CF6&color=fff',
      ),
    ];
    isLoading.value = false;
  }
}
