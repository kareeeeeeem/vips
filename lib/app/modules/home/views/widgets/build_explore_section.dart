import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/app/modules/home/controllers/home_controller.dart';

class BuildExploreSection extends GetView<HomeController> {
  const BuildExploreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.explore_outlined,
                    size: 20.sp,
                    color: const Color(0xFFFF6B35),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'explore_outings'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => controller.navigateToAllOutings(),
                  child: Row(
                    children: [
                      Text(
                        'view_all'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF6B35),
                          fontFamily: 'SF Pro Text',
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward,
                        size: 16.sp,
                        color: const Color(0xFFFF6B35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Scroll horizontal avec groupes de 3 cartes
          SizedBox(
            height: 300.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: (controller.outings.length / 3).ceil(),
              itemBuilder: (context, groupIndex) {
                int startIndex = groupIndex * 3;
                int endIndex = (startIndex + 3).clamp(
                  0,
                  controller.outings.length,
                );

                // Récupérer les 3 outings pour ce groupe
                List<Map<String, dynamic>> groupOutings = controller.outings
                    .sublist(startIndex, endIndex);

                return Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: EdgeInsets.only(right: 12.w),
                  child: Row(
                    children: [
                      // Grande carte à gauche
                      Expanded(
                        flex: 3,
                        child:
                            groupOutings.isNotEmpty
                                ? _buildOutingCard(
                                  outing: groupOutings[0],
                                  onTap:
                                      () => controller.navigateToOuting(
                                        groupOutings[0],
                                      ),
                                )
                                : Container(),
                      ),

                      SizedBox(width: 12.w),

                      // Deux petites cartes à droite
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(
                              child:
                                  groupOutings.length > 1
                                      ? _buildOutingCard(
                                        outing: groupOutings[1],
                                        onTap:
                                            () => controller.navigateToOuting(
                                              groupOutings[1],
                                            ),
                                      )
                                      : Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                        ),
                                      ),
                            ),
                            SizedBox(height: 12.h),
                            Expanded(
                              child:
                                  groupOutings.length > 2
                                      ? _buildOutingCard(
                                        outing: groupOutings[2],
                                        onTap:
                                            () => controller.navigateToOuting(
                                              groupOutings[2],
                                            ),
                                      )
                                      : Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutingCard({
    required Map<String, dynamic> outing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image de fond
              Image.network(
                outing['image'],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                        strokeWidth: 2,
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[500],
                        size: 32.sp,
                      ),
                    ),
                  );
                },
              ),

              // Overlay gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Contenu texte
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 16.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre
                    Text(
                      outing['title'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'SF Pro Text',
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4.h),

                    // Sous-titre/description
                    if (outing['subtitle'] != null)
                      Text(
                        outing['subtitle'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'SF Pro Text',
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Badge catégorie (optionnel)
              if (outing['category'] != null)
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      outing['category'],
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
