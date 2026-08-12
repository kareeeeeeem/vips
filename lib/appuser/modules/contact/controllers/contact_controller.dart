import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class ContactController extends GetxController {
  final RxList<Map<String, dynamic>> contacts = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  Future<void> loadContacts() async {
    try {
      isLoading.value = true;
      final response = await ApiService().get('/user/contacts');
      if (response.success && response.data != null) {
        contacts.value = List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to load contacts: $e');
    } finally {
      isLoading.value = false;
    }
  }
  void navigateToSearch() {
    Get.toNamed('/search');
  }

  final RxString filterType = 'all'.obs;

  final RxString newContactName = ''.obs;
  final RxString newContactPhone = ''.obs;

  void showAddContactSheet() {
    newContactName.value = '';
    newContactPhone.value = '';
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => newContactName.value = v,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (v) => newContactPhone.value = v,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (newContactName.value.isEmpty || newContactPhone.value.isEmpty) {
                    safeSnackbar('Error', 'Name and phone are required');
                    return;
                  }
                  Get.back();
                  try {
                    final response = await ApiService().post('/user/contacts', {
                      'name': newContactName.value,
                      'phone': newContactPhone.value,
                    });
                    if (response.success) {
                      safeSnackbar('Success', 'Contact added',
                          backgroundColor: const Color(0xFF10B981),
                          colorText: Colors.white);
                      loadContacts();
                    } else {
                      safeSnackbar('Error', response.message);
                    }
                  } catch (_) {
                    safeSnackbar('Error', 'Failed to add contact');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Contact',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void showFilterSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Contacts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Obx(() => Wrap(
              spacing: 8,
              children: ['all', 'recent', 'frequent'].map((f) {
                final selected = filterType.value == f;
                return ChoiceChip(
                  label: Text(f[0].toUpperCase() + f.substring(1)),
                  selected: selected,
                  selectedColor: const Color(0xFF10B981),
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87),
                  onSelected: (_) {
                    filterType.value = f;
                    Get.back();
                    loadContacts();
                  },
                );
              }).toList(),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

}
