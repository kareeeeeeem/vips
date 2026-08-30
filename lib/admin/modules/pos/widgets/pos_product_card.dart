import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';

/// One tile in the till's product grid.
///
/// An out-of-stock product is shown greyed and untappable rather than hidden:
/// the cashier needs to see that the item exists and is unavailable, which is
/// what they have to tell the customer.
class PosProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final num price;
  final int stock;
  final VoidCallback onTap;

  const PosProductCard({
    super.key,
    required this.product,
    required this.price,
    required this.stock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final out = stock <= 0;
    final low = !out && stock <= 5;
    final name = adminString(product['name'], 'Unnamed');
    final hasDiscount = product['discountPrice'] is num &&
        (product['discountPrice'] as num) > 0 &&
        adminDouble(product['price']) > price;

    return Opacity(
      opacity: out ? 0.5 : 1,
      child: InkWell(
        onTap: out ? null : onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: out ? AdminColors.border : AdminColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: AdminColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    child: Icon(Icons.local_mall_outlined,
                        size: 15.sp, color: AdminColors.accent),
                  ),
                  const Spacer(),
                  AdminStatusPill(
                    label: out ? 'Out' : '$stock left',
                    color: out
                        ? AdminColors.danger
                        : low
                            ? AdminColors.warning
                            : AdminColors.success,
                    compact: true,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        adminMoney(price),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AdminColors.primary,
                        ),
                      ),
                    ),
                  ),
                  // The struck-through original only appears when the
                  // merchant really did set a lower selling price.
                  if (hasDiscount) ...[
                    SizedBox(width: 6.w),
                    Text(
                      adminMoney(adminDouble(product['price'])),
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: AdminColors.textMuted,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
