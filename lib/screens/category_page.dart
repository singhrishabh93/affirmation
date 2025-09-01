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
                  _buildHeartIcon(),
                  isSelected: selectedCategory == 'Favorites',
                ),

                const SizedBox(height: 16),

                // Other categories in grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      // Abundance
                      _buildCategoryItem(
                        'Abundance',
                        _buildAbundanceIcon(),
                        isSelected: selectedCategory == 'Abundance',
                      ),

                      // Confidence
                      _buildCategoryItem(
                        'Confidence',
                        _buildConfidenceIcon(),
                        isSelected: selectedCategory == 'Confidence',
                      ),

                      // General
                      _buildCategoryItem(
                        'General',
                        _buildGeneralIcon(),
                        isSelected: selectedCategory == 'General',
                      ),

                      // Gratitude
                      _buildCategoryItem(
                        'Gratitude',
                        _buildGratitudeIcon(),
                        isSelected: selectedCategory == 'Gratitude',
                      ),

                      // Love
                      _buildCategoryItem(
                        'Love',
                        _buildLoveIcon(),
                        isSelected: selectedCategory == 'Love',
                      ),

                      // Success
                      _buildCategoryItem(
                        'Success',
                        _buildSuccessIcon(),
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
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.merriweather(
                fontSize: 18,
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
            const SizedBox(height: 12),
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

  // Pixel art style icons
  Widget _buildHeartIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFF69B4), // Pink heart
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: HeartPainter(),
      ),
    );
  }

  Widget _buildAbundanceIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700), // Gold
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: CoinPainter(),
      ),
    );
  }

  Widget _buildConfidenceIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700), // Gold
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: SmileyPainter(),
      ),
    );
  }

  Widget _buildGeneralIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF00BFFF), // Blue diamond
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: DiamondPainter(),
      ),
    );
  }

  Widget _buildGratitudeIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF32CD32), // Green plant
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: PlantPainter(),
      ),
    );
  }

  Widget _buildLoveIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000), // Red heart
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: ArrowHeartPainter(),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000), // Red flame
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: FlamePainter(),
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

// Custom painters for pixel art style icons
class HeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Simple heart shape
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.6,
        size.width * 0.3, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.2,
        size.width * 0.5, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.2,
        size.width * 0.7, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.6,
        size.width * 0.5, size.height * 0.8);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Coin with dollar sign
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5), size.width * 0.4, paint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '\$',
        style: TextStyle(
            color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(
          size.width * 0.5 - textPainter.width * 0.5,
          size.height * 0.5 - textPainter.height * 0.5,
        ));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SmileyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Smiley face
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5), size.width * 0.4, paint);

    // Eyes
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.4), 4,
        Paint()..color = Colors.black);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.4), 4,
        Paint()..color = Colors.black);

    // Smile
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: size.width * 0.3,
        height: size.height * 0.3,
      ),
      0,
      3.14,
      false,
      smilePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Diamond shape
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.9);
    path.lineTo(size.width * 0.2, size.height * 0.5);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PlantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Plant stem
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.45, size.height * 0.6, size.width * 0.1,
          size.height * 0.3),
      paint,
    );

    // Leaves
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.3, size.width * 0.3,
          size.height * 0.2),
      paint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.5, size.height * 0.2, size.width * 0.3,
          size.height * 0.2),
      paint,
    );

    // Flower (pink heart)
    final heartPaint = Paint()..color = const Color(0xFFFF69B4);
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.3,
        size.width * 0.35, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.1,
        size.width * 0.5, size.height * 0.1);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.1,
        size.width * 0.65, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.3,
        size.width * 0.5, size.height * 0.1);
    canvas.drawPath(path, heartPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ArrowHeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Heart shape
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.6,
        size.width * 0.3, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.2,
        size.width * 0.5, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.2,
        size.width * 0.7, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.6,
        size.width * 0.5, size.height * 0.8);
    canvas.drawPath(path, paint);

    // Arrow
    final arrowPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.5),
      arrowPaint,
    );

    // Arrow head
    final arrowHeadPath = Path();
    arrowHeadPath.moveTo(size.width * 0.8, size.height * 0.5);
    arrowHeadPath.lineTo(size.width * 0.7, size.height * 0.4);
    arrowHeadPath.lineTo(size.width * 0.7, size.height * 0.6);
    arrowHeadPath.close();
    canvas.drawPath(arrowHeadPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FlamePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Flame shape
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.lineTo(size.width * 0.3, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.4);
    path.lineTo(size.width * 0.7, size.height * 0.5);
    path.close();
    canvas.drawPath(path, paint);

    // Lightning bolts
    final lightningPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Left lightning
    final leftPath = Path();
    leftPath.moveTo(size.width * 0.3, size.height * 0.3);
    leftPath.lineTo(size.width * 0.2, size.height * 0.5);
    leftPath.lineTo(size.width * 0.25, size.height * 0.6);
    canvas.drawPath(leftPath, lightningPaint);

    // Right lightning
    final rightPath = Path();
    rightPath.moveTo(size.width * 0.7, size.height * 0.3);
    rightPath.lineTo(size.width * 0.8, size.height * 0.5);
    rightPath.lineTo(size.width * 0.75, size.height * 0.6);
    canvas.drawPath(rightPath, lightningPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
