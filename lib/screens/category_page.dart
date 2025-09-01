import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryPage extends StatefulWidget {
  final String? selectedCategory;

  const CategoryPage({
    Key? key,
    this.selectedCategory,
  }) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory ?? 'Confidence';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark theme background
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),

            // Categories Grid
            Expanded(
              child: _buildCategoriesGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),

          const Spacer(),

          // Notification bell icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Categories',
            style: GoogleFonts.merriweather(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          // Categories Grid
          Expanded(
            child: Column(
              children: [
                // Favorites - Full width
                _buildFullWidthCategory(
                  'Favorites',
                  _buildImageIcon('assets/favourites.png'),
                  isSelected: selectedCategory == 'Favorites',
                ),

                const SizedBox(height: 16),

                // Other categories in grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      // Abundance
                      _buildCategoryItem(
                        'Abundance',
                        _buildImageIcon('assets/abudeance.png'),
                        isSelected: selectedCategory == 'Abundance',
                      ),

                      // Confidence
                      _buildCategoryItem(
                        'Confidence',
                        _buildImageIcon('assets/confidence.png'),
                        isSelected: selectedCategory == 'Confidence',
                      ),

                      // General
                      _buildCategoryItem(
                        'General',
                        _buildImageIcon('assets/general.png'),
                        isSelected: selectedCategory == 'General',
                      ),

                      // Gratitude
                      _buildCategoryItem(
                        'Gratitude',
                        _buildImageIcon('assets/gratitude.png'),
                        isSelected: selectedCategory == 'Gratitude',
                      ),

                      // Love
                      _buildCategoryItem(
                        'Love',
                        _buildImageIcon('assets/love.png'),
                        isSelected: selectedCategory == 'Love',
                      ),

                      // Success
                      _buildCategoryItem(
                        'Success',
                        _buildImageIcon('assets/success.png'),
                        isSelected: selectedCategory == 'Success',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthCategory(String title, Widget icon,
      {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _onCategorySelected(title),
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.merriweather(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, Widget icon,
      {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _onCategorySelected(title),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.merriweather(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Image icon builder
  Widget _buildImageIcon(String imagePath) {
    return Container(
      width: 40,
      height: 40,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });

    // Navigate back with selected category
    Navigator.pop(context, category);
  }
}
