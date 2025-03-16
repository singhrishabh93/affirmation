import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryBottomSheet extends StatelessWidget {
  final Function(String)? onCategorySelected;
  final String? currentCategory;

  const CategoryBottomSheet({
    Key? key,
    this.onCategorySelected,
    this.currentCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: GoogleFonts.merriweather(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                'Categories',
                style: GoogleFonts.merriweather(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                  ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCategoryItem(
                      context,
                      'Favorites',
                      Icons.favorite,
                      isSelected: currentCategory == 'Favorites',
                    ),
                    _buildCategoryItem(
                      context,
                      'Confidence',
                      Icons.sentiment_satisfied_alt,
                      isSelected: currentCategory == 'Confidence',
                    ),
                    _buildCategoryItem(
                      context,
                      'General',
                      Icons.diamond_outlined,
                      isSelected: currentCategory == 'General',
                    ),
                    _buildCategoryItem(
                      context,
                      'Abundance',
                      Icons.monetization_on,
                      isSelected: currentCategory == 'Abundance',
                    ),
                    _buildCategoryItem(
                      context,
                      'Love',
                      Icons.favorite_border,
                      isSelected: currentCategory == 'Love',
                    ),
                    _buildCategoryItem(
                      context,
                      'Success',
                      Icons.check_circle_outline,
                      isSelected: currentCategory == 'Success',
                    ),
                    _buildCategoryItem(
                      context,
                      'Gratitude',
                      Icons.volunteer_activism,
                      isSelected: currentCategory == 'Gratitude',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    IconData icon, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (onCategorySelected != null) {
          onCategorySelected!(title);
        }
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black,
              size: 28,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.merriweather(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}