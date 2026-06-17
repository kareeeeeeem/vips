import 'package:get/get.dart';

class StaffMember {
  final String id;
  final String name;
  final String role;
  final String status; // 'Active', 'On Leave', 'Inactive'
  final double salary;
  final DateTime joinedDate;

  StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.salary,
    required this.joinedDate,
  });
}

class MerchantHRMController extends GetxController {
  final staffList = <StaffMember>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    staffList.assignAll([
      StaffMember(id: '1', name: 'John Doe', role: 'Manager', status: 'Active', salary: 3000.0, joinedDate: DateTime(2023, 1, 15)),
      StaffMember(id: '2', name: 'Jane Smith', role: 'Cashier', status: 'Active', salary: 1500.0, joinedDate: DateTime(2023, 5, 20)),
      StaffMember(id: '3', name: 'Mike Johnson', role: 'Chef', status: 'On Leave', salary: 2200.0, joinedDate: DateTime(2023, 2, 10)),
    ]);
  }

  void addStaff(StaffMember member) {
    staffList.add(member);
  }
}
