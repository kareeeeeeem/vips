import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();

    final imageWidget = cleanUrl.isEmpty || !cleanUrl.startsWith('http')
        ? _buildErrorWidget()
        : CachedNetworkImage(
            imageUrl: cleanUrl,
            width: width,
            height: height,
            fit: fit,
            placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
            errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
          );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: Colors.grey.shade300,
      colorOpacity: 0.3,
      enabled: true,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: Colors.grey.shade200,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey.shade400,
          size: 24.sp,
        ),
      ),
    );
  }
}
