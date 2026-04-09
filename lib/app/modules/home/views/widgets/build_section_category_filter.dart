import 'package:flutter/material.dart';

/// Widget de catégories et filtres - Version exacte de l'image
class CategoryFilterBar extends StatefulWidget {
  final Function(int)? onCategoryChanged;
  final Function(String)? onFilterChanged;

  const CategoryFilterBar({
    Key? key,
    this.onCategoryChanged,
    this.onFilterChanged,
  }) : super(key: key);

  @override
  State<CategoryFilterBar> createState() => _CategoryFilterBarState();
}

class _CategoryFilterBarState extends State<CategoryFilterBar> {
  int selectedCategory = 0; // 0 = Category 1 par défaut
  String selectedFilter = 'Hot Deals';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Section des catégories
          _buildCategoriesRow(),

          const SizedBox(height: 20),

          // Section des filtres
          _buildFiltersRow(),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow() {
    return SizedBox(
      height: 110,
      child: Row(
        children: [
          const SizedBox(width: 16),

          // Badge % orange
          _buildPromoBadge(),

          const SizedBox(width: 16),

          // Ligne verticale
          Container(width: 1, height: 60, color: Colors.grey[300]),

          const SizedBox(width: 16),

          // Liste des catégories
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategory(
                  index: 0,
                  title: 'Category 1',
                  hasTopBadge: false,
                  imageUrl:
                      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200',
                ),
                _buildCategory(
                  index: 1,
                  title: 'Category 2',
                  hasTopBadge: false,
                  imageUrl:
                      'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=200',
                ),
                _buildCategory(
                  index: 2,
                  title: 'Category 3',
                  hasTopBadge: false,
                  imageUrl:
                      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200',
                ),
                _buildCategory(
                  index: 3,
                  title: 'Category 4',
                  hasTopBadge: false,
                  imageUrl:
                      'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=200',
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildPromoBadge() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B35),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.percent, color: Colors.white, size: 32),
    );
  }

  Widget _buildCategory({
    required int index,
    required String title,
    required bool hasTopBadge,
    required String imageUrl,
  }) {
    final isSelected = selectedCategory == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = index;
        });
        widget.onCategoryChanged?.call(index);
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image de la catégorie
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[400],
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 0),

            // Titre de la catégorie
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),

            // Badge "TOP" pour Category 1
            if (hasTopBadge && index == 0)
              Container(
                margin: const EdgeInsets.only(top: 2),
                child: const Text(
                  'TOP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ),

            // Ligne indicatrice de sélection
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 50,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Icône de filtre 1
          _buildFilterIcon(Icons.tune),

          const SizedBox(width: 12),

          // Icône de filtre 2 (tri)
          _buildFilterIcon(Icons.sort),

          const SizedBox(width: 16),

          // Ligne verticale
          Container(width: 1, height: 30, color: Colors.grey[300]),

          const SizedBox(width: 20),

          // Filtres texte
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterTab('Hot Deals'),
                _buildFilterTab('Nearest'),
                _buildFilterTab('Recent'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: Colors.grey[600]),
    );
  }

  Widget _buildFilterTab(String title) {
    final isSelected = selectedFilter == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
        widget.onFilterChanged?.call(title);
      },
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.grey[600],
        ),
      ),
    );
  }
}
