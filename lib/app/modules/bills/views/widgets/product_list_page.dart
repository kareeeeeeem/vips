import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/bills_controller.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatelessWidget {
  final String? category;
  final String title;

  const ProductListPage({
    Key? key,
    this.category,
    this.title = 'Best Selling Theme',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BillsController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Tabs - AVEC ICÔNE DE GRILLE
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // GRID ICON BUTTON (sélectionné en orange)
                  _buildGridIconButton(true),
                  const SizedBox(width: 8),
                  // Liste icon button
                  _buildListIconButton(false),
                  const SizedBox(width: 16),
                  // Filtres textuels
                  _buildFilterChip('Hot Deals', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Top Rate', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Recent', false),
                ],
              ),
            ),
          ),

          // Products Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(12.w),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: controller.allProducts.length,
              itemBuilder: (context, index) {
                return _buildProductGridItem(controller.allProducts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // NOUVEAU: Bouton Grid Icon
  Widget _buildGridIconButton(bool isSelected) {
    return Container(
      width: 48,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.grid_view,
        color: isSelected ? Colors.white : Colors.grey[600],
        size: 20,
      ),
    );
  }

  // NOUVEAU: Bouton List Icon
  Widget _buildListIconButton(bool isSelected) {
    return Container(
      width: 48,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.format_list_bulleted,
        color: isSelected ? Colors.white : Colors.grey[600],
        size: 20,
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0066FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF0066FF) : Colors.grey[300]!,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildProductGridItem(ProductItem product) {
    return GestureDetector(
      onTap: () {
        // Navigate to product detail
        Get.to(() => ProductDetailPage(product: product));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with favorite and price
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 140,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Color(0xFF0066FF),
                      size: 18,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${product.price.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    product.category,
                    style: const TextStyle(
                      color: Color(0xFF0066FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sell count and rating
                  Row(
                    children: [
                      const Icon(Icons.download, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${product.sellCount} Sell',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      ...List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
