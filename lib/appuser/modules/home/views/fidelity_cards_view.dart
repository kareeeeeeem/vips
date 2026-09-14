import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/widgets/custom_network_image.dart';
import 'package:vip/appuser/routes/app_pages.dart';

class FidelityCardsView extends StatefulWidget {
  const FidelityCardsView({super.key});

  @override
  State<FidelityCardsView> createState() => _FidelityCardsViewState();
}

class _FidelityCardsViewState extends State<FidelityCardsView> {
  final _merchants = <Map<String, dynamic>>[];
  bool _loading = true;
  String? _error;

  static const _orange = Color(0xFFFF6B35);
  static const _ink = Color(0xFF1F2937);
  static const _muted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await ApiService().get('/content/following-merchants');
      if (!response.success) {
        throw Exception(response.message);
      }
      final data = response.data is Map ? response.data as Map : const {};
      final rows =
          data['merchants'] is List ? data['merchants'] as List : const [];
      if (mounted) {
        setState(() {
          _merchants
            ..clear()
            ..addAll(
              rows.whereType<Map>().map(
                (row) => Map<String, dynamic>.from(row),
              ),
            );
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load your followed stores.';
        });
      }
    }
  }

  int _points(Map<String, dynamic> merchant) =>
      (merchant['points'] as num?)?.toInt() ?? 0;

  String _offerLabel(Map<String, dynamic> offer) {
    final value = (offer['discount'] as num?)?.toDouble() ?? 0;
    final unit = offer['discountUnit']?.toString();
    if (offer['type'] == 'voucher' || unit == 'tnd') {
      final rate = (offer['voucherDiscountPercentage'] as num?)?.toInt();
      return rate == null
          ? 'D ${value.toStringAsFixed(0)} voucher'
          : '$rate% off voucher';
    }
    if (offer['type'] == 'shipping') return 'Free shipping';
    return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}% off';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Fidelity Card(s)',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: Icon(Icons.refresh_rounded, color: _ink, size: 21.sp),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child:
            _loading
                ? const Center(child: CircularProgressIndicator(color: _orange))
                : _error != null
                ? _message(_error!, Icons.cloud_off_outlined)
                : _merchants.isEmpty
                ? _emptyState()
                : ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
                  children: [
                    _totalReward(),
                    SizedBox(height: 18.h),
                    Text(
                      '${_merchants.length} followed store(s)',
                      style: TextStyle(fontSize: 13.sp, color: _muted),
                    ),
                    SizedBox(height: 10.h),
                    ..._merchants.map(_merchantCard),
                  ],
                ),
      ),
    );
  }

  Widget _totalReward() {
    final total = _merchants.fold<int>(
      0,
      (sum, merchant) => sum + _points(merchant),
    );
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFFD9C8)),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: const BoxDecoration(
              color: _orange,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stars_rounded, color: Colors.white, size: 23.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Reward',
                  style: TextStyle(fontSize: 13.sp, color: _muted),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$total pts',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: _orange,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'From followed stores',
            style: TextStyle(fontSize: 10.sp, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _merchantCard(Map<String, dynamic> merchant) {
    final id = (merchant['_id'] ?? merchant['id'])?.toString() ?? '';
    final name = (merchant['storeName'] ?? 'Store').toString();
    final offers =
        merchant['offers'] is List ? merchant['offers'] as List : const [];
    final points = _points(merchant);
    final logo = merchant['logo']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipOval(
                child:
                    logo.isEmpty
                        ? Container(
                          width: 42.w,
                          height: 42.w,
                          color: const Color(0xFFFFE8DE),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: _orange,
                            size: 23.sp,
                          ),
                        )
                        : CustomNetworkImage(
                          imageUrl: logo,
                          width: 42.w,
                          height: 42.w,
                          fit: BoxFit.cover,
                        ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Loyalty card',
                      style: TextStyle(fontSize: 11.sp, color: _muted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Column(
                  children: [
                    Text(
                      '$points',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    Text(
                      'points',
                      style: TextStyle(fontSize: 9.sp, color: _muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (offers.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Latest offers',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
            SizedBox(height: 7.h),
            ...offers.take(2).map((raw) {
              final offer = Map<String, dynamic>.from(raw as Map);
              return Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 15.sp,
                      color: _orange,
                    ),
                    SizedBox(width: 7.w),
                    Expanded(
                      child: Text(
                        _offerLabel(offer),
                        style: TextStyle(fontSize: 11.5.sp, color: _muted),
                      ),
                    ),
                    Text(
                      'New',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: _orange,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            height: 36.h,
            child: OutlinedButton(
              onPressed:
                  id.isEmpty
                      ? null
                      : () => Get.toNamed(
                        Routes.MERCHANT_DETAILS,
                        arguments: merchant,
                      ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _orange,
                side: const BorderSide(color: _orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.r),
                ),
              ),
              child: const Text('View store'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return _message(
      'Follow your favorite stores to see their loyalty cards and newest offers here.',
      Icons.loyalty_outlined,
      action: true,
    );
  }

  Widget _message(String text, IconData icon, {bool action = false}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(32.w),
      children: [
        SizedBox(height: 100.h),
        Icon(icon, size: 54.sp, color: const Color(0xFFFFB39A)),
        SizedBox(height: 16.h),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: _muted, height: 1.5),
        ),
        if (action) ...[
          SizedBox(height: 18.h),
          Center(
            child: TextButton(
              onPressed: () => Get.toNamed(Routes.ALL_MERCHANTS),
              child: const Text('Explore stores'),
            ),
          ),
        ],
      ],
    );
  }
}
