import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantCashiersController extends GetxController {
  final RxList<Map<String, dynamic>> cashiers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final RxString selectedRole = 'Cashier'.obs;

  final List<String> roles = ['Cashier', 'Manager', 'Supervisor', 'Staff'];

  @override
  void onInit() {
    super.onInit();
    loadCashiers();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> loadCashiers() async {
    isLoading.value = true;
    try {
      final response = await ApiService().get('/merchant/cashiers');
      if (response.success && response.data is List) {
        cashiers.value = (response.data as List)
            .whereType<Map>()
            .map((c) => Map<String, dynamic>.from(c))
            .toList();
      }
    } catch (e) {
      debugPrint('loadCashiers failed: $e');
      safeSnackbar('Error', 'Could not load your staff. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Id of the cashier currently being edited; null when adding a new one.
  final RxnString editingId = RxnString();

  void showAddCashierSheet() {
    editingId.value = null;
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    selectedRole.value = 'Cashier';
    Get.bottomSheet(
      _AddCashierSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// PUT /merchant/cashiers/:id has always existed; nothing in the app ever
  /// called it, so a cashier's name, phone or role could never be corrected
  /// — only deleted and re-added.
  void showEditCashierSheet(Map<String, dynamic> cashier) {
    editingId.value = cashier['_id']?.toString();
    nameController.text = (cashier['name'] ?? '').toString();
    emailController.text = (cashier['email'] ?? '').toString();
    phoneController.text = (cashier['phone'] ?? '').toString();
    final role = (cashier['role'] ?? 'Cashier').toString();
    selectedRole.value = roles.contains(role) ? role : 'Cashier';
    Get.bottomSheet(
      _AddCashierSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> addCashier() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      safeSnackbar('Error', 'Name and phone are required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      safeSnackbar('Error', 'That email address is not valid',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final id = editingId.value;
    isLoading.value = true;
    try {
      final body = {
        'name': name,
        'email': email,
        'phone': phone,
        'role': selectedRole.value,
      };
      final response = id == null
          ? await ApiService().post('/merchant/cashiers', body)
          : await ApiService().put('/merchant/cashiers/$id', body);

      if (response.success && response.data != null) {
        final saved = Map<String, dynamic>.from(response.data as Map);
        if (id == null) {
          cashiers.insert(0, saved);
        } else {
          final index = cashiers.indexWhere((c) => c['_id']?.toString() == id);
          if (index >= 0) {
            cashiers[index] = saved;
          } else {
            await loadCashiers();
          }
        }
        Get.back();
        safeSnackbar('Success', id == null ? 'Cashier added successfully' : 'Cashier updated',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white);
      } else {
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('save cashier failed: $e');
      safeSnackbar('Error', 'Could not save that cashier. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeCashier(String id) async {
    try {
      final response = await ApiService().delete('/merchant/cashiers/$id');
      if (response.success) {
        cashiers.removeWhere((c) => c['_id']?.toString() == id);
        safeSnackbar('Removed', 'Cashier removed', snackPosition: SnackPosition.BOTTOM);
      } else {
        // A failed delete used to do nothing at all — the row stayed and no
        // message was shown, so it read as a silent no-op.
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('removeCashier failed: $e');
      safeSnackbar('Error', 'Could not remove that cashier. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Color roleColor(String role) {
    switch (role) {
      case 'Manager': return const Color(0xFF6366F1);
      case 'Supervisor': return const Color(0xFFF59E0B);
      case 'Staff': return const Color(0xFF6B7280);
      default: return const Color(0xFF10B981);
    }
  }
}

class _AddCashierSheet extends StatelessWidget {
  final MerchantCashiersController controller;
  const _AddCashierSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Obx(() => Text(
                  controller.editingId.value == null ? 'Add Cashier' : 'Edit Cashier',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            _field(controller.nameController, 'Full Name', Icons.person_outline),
            const SizedBox(height: 12),
            _field(controller.phoneController, 'Phone Number', Icons.phone_outlined, type: TextInputType.phone),
            const SizedBox(height: 12),
            _field(controller.emailController, 'Email (optional)', Icons.email_outlined, type: TextInputType.emailAddress),
            const SizedBox(height: 12),
            Obx(() => DropdownButtonFormField<String>(
              key: ValueKey(controller.selectedRole.value),
              initialValue: controller.selectedRole.value,
              decoration: InputDecoration(
                labelText: 'Role',
                prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF10B981)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981))),
              ),
              items: controller.roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => controller.selectedRole.value = v!,
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.addCashier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        controller.editingId.value == null ? 'Add Cashier' : 'Save Changes',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              )),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981))),
      ),
    );
  }
}
