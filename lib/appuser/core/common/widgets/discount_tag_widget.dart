import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../util/dimensions.dart';
import '../../util/styles.dart';

class DiscountTagWidget extends StatelessWidget {
  final double? discount;
  final String? discountType;
  final double fromTop;
  final double? fontSize;
  final bool freeDelivery;
  const DiscountTagWidget({
    super.key,
    required this.discount,
    required this.discountType,
    this.fromTop = 10,
    this.fontSize,
    this.freeDelivery = false,
  });

  @override
  Widget build(BuildContext context) {
    return (discount! > 0 || freeDelivery)
        ? Positioned(
          top: fromTop,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(Dimensions.radiusSmall),
              ),
            ),
            child: Text(
              'free_delivery'.tr,
              style: robotoMedium.copyWith(
                color: Colors.white,
                fontSize: fontSize ?? (12),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
        : const SizedBox();
  }
}
