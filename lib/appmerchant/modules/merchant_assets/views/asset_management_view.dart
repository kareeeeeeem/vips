import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/utils/safe_snackbar.dart';
import '../controllers/merchant_asset_controller.dart';

class AssetManagementView extends GetView<MerchantAssetController> {
  const AssetManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Asset Management',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
      ),
      // The controller has always had addAsset()/deleteAsset() and the
      // backend has always served the CRUD routes — this screen had no
      // control but the back arrow, so neither could ever be reached.
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssetDialog,
        backgroundColor: const Color(0xFFF97316),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSummaryHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.assets.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.assets.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                onRefresh: controller.loadAssets,
                child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: controller.assets.length,
              itemBuilder: (context, index) {
                final asset = controller.assets[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.inventory, color: const Color(0xFFF97316), size: 24.sp),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(asset.name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                            Text(asset.type, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      Text(
                        'D ${asset.value.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937)),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            size: 20.sp, color: const Color(0xFFEF4444)),
                        onPressed: () => _confirmDelete(asset),
                      ),
                    ],
                  ),
                );
              },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: controller.loadAssets,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 48.sp, color: const Color(0xFFD1D5DB)),
                SizedBox(height: 12.h),
                Text('No assets recorded yet',
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4B5563))),
                SizedBox(height: 4.h),
                Text('Tap + to add equipment, vehicles or property',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BusinessAsset asset) {
    Get.dialog(AlertDialog(
      title: const Text('Delete asset'),
      content: Text('Remove "${asset.name}" from your assets?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.deleteAsset(asset.id);
          },
          child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
        ),
      ],
    ));
  }

  void _showAddAssetDialog() {
    final nameCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    // Matches what the merchant is likely to record; the Asset model keeps
    // `type` as a free string with an 'Other' default.
    const types = ['Equipment', 'Vehicle', 'Property', 'Furniture', 'Other'];
    final selectedType = types.first.obs;

    Get.dialog(AlertDialog(
      title: const Text('Add Asset'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Asset name'),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: valueCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Value (D)'),
            ),
            SizedBox(height: 12.h),
            Obx(() => DropdownButtonFormField<String>(
                  initialValue: selectedType.value,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => selectedType.value = v ?? types.first,
                )),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            final name = nameCtrl.text.trim();
            final value = double.tryParse(valueCtrl.text.trim());
            if (name.isEmpty) {
              safeSnackbar('Error', 'Enter an asset name',
                  snackPosition: SnackPosition.BOTTOM);
              return;
            }
            if (value == null || value < 0) {
              safeSnackbar('Error', 'Enter a valid value',
                  snackPosition: SnackPosition.BOTTOM);
              return;
            }
            Get.back();
            controller.addAsset({
              'name': name,
              'type': selectedType.value,
              'value': value,
              'purchaseDate': DateTime.now().toIso8601String(),
            });
          },
          child: const Text('Add'),
        ),
      ],
    ));
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFFB923C)]),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Asset Value', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                SizedBox(height: 4.h),
                Obx(() {
                  double total = controller.assets.fold(0, (sum, item) => sum + item.value);
                  return Text('D ${total.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w900));
                }),
              ],
            ),
            const Icon(Icons.assessment, color: Colors.white, size: 40),
          ],
        ),
      ),
    );
  }
}
