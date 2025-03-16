import 'package:flutter/material.dart';

class AppColors {
  // List of background colors for affirmations
  static final List<Color> affirmationBackgrounds = [
    // Original blues
    const Color(0xFF1A237E),
    const Color(0xFF0D47A1),
    const Color(0xFF1976D2),
    const Color(0xFF64B5F6),
    const Color(0xFFBBDEFB),
    const Color(0xFFE3F2FD),
    const Color(0xFF80DEEA),
    const Color(0xFF4FC3F7),
    const Color(0xFF0288D1),
    const Color(0xFF039BE5),
    const Color(0xFFD5E6EA),
    const Color(0xFFABC6D1),
    const Color(0xFF7E9EAC),
    const Color(0xFF5C7D8C),
    
    // Original greens
    const Color(0xFF1B5E20),
    const Color(0xFF2E7D32),
    const Color(0xFF43A047),
    const Color(0xFF66BB6A),
    const Color(0xFF81C784),
    const Color(0xFFA5D6A7),
    const Color(0xFFE8F5E9),
    const Color(0xFF00BFA5),
    const Color(0xFFD5EAE4),
    const Color(0xFF1DE9B6),
    const Color(0xFF00897B),
    const Color(0xFF4CAF50),
    const Color(0xFF8BC34A),
    const Color(0xFFCDDC39),
    const Color(0xFF7CB342),
    
    // Original reds
    const Color(0xFFB71C1C),
    const Color(0xFFC62828),
    const Color(0xFFE53935),
    const Color(0xFFF44336),
    const Color(0xFFEF5350),
    const Color(0xFFFFCDD2),
    const Color(0xFFEF9A9A),
    const Color(0xFFE57373),
    const Color(0xFFFF8A80),
    const Color(0xFFFF5252),
    const Color(0xFFD50000),
    const Color(0xFFEAD5D5),
    const Color(0xFFAD5E5E),
    const Color(0xFFD88484),
    const Color(0xFF8C4646),
    
    // Original purples
    const Color(0xFF4A148C),
    const Color(0xFF6A1B9A),
    const Color(0xFF8E24AA),
    const Color(0xFFAB47BC),
    const Color(0xFFCE93D8),
    const Color(0xFFE1BEE7),
    const Color(0xFFE8D5EA),
    const Color(0xFFBA68C8),
    const Color(0xFF9C27B0),
    const Color(0xFF7B1FA2),
    const Color(0xFFE0D5EA),
    
    // Original pinks
    const Color(0xFF880E4F),
    const Color(0xFFC2185B),
    const Color(0xFFE91E63),
    const Color(0xFFF06292),
    
    // Original yellows and ambers
    const Color(0xFFF57F17),
    const Color(0xFFFBC02D),
    const Color(0xFFFFEB3B),
    const Color(0xFFFFF176),
    const Color(0xFFFFF9C4),
    const Color(0xFFEAE4D5),
    const Color(0xFFFFE0B2),
    const Color(0xFFFFB74D),
    const Color(0xFFFF9800),
    const Color(0xFFF57C00),
    const Color(0xFFE65100),
    const Color(0xFFBF360C),
    const Color(0xFFFF6F00),
    const Color(0xFFFFD600),
    const Color(0xFFFFAB00),
    
    // Original grays and browns
    const Color(0xFF212121),
    const Color(0xFF424242),
    const Color(0xFF616161),
    const Color(0xFF757575),
    const Color(0xFF9E9E9E),
    const Color(0xFFE0E0E0),
    const Color(0xFFF5F5F5),
    const Color(0xFF3E2723),
    const Color(0xFF5D4037),
    const Color(0xFF8D6E63),
    const Color(0xFFD7CCC8),
    const Color(0xFF795548),
    const Color(0xFF4E342E),
    const Color(0xFFBCAAA4),
    const Color(0xFFEFEBE9),
    
    // Original teals and accent colors
    const Color(0xFF006064),
    const Color(0xFF00BCD4),
    const Color(0xFF18FFFF),
    const Color(0xFF304FFE),
    const Color(0xFFAA00FF),
    const Color(0xFFFF80AB),
    const Color(0xFFFFD180),
    const Color(0xFFFFFF00),
    const Color(0xFF76FF03),
    const Color(0xFFF8BBD0),
    
    // Additional 40 colors for more variety (100 total)
    const Color(0xFF263238), // Blue Grey 900
    const Color(0xFF37474F), // Blue Grey 800
    const Color(0xFF455A64), // Blue Grey 700
    const Color(0xFF546E7A), // Blue Grey 600
    const Color(0xFF607D8B), // Blue Grey 500
    const Color(0xFF78909C), // Blue Grey 400
    const Color(0xFF90A4AE), // Blue Grey 300
    const Color(0xFFB0BEC5), // Blue Grey 200
    const Color(0xFFCFD8DC), // Blue Grey 100
    const Color(0xFFECEFF1), // Blue Grey 50
    const Color(0xFF004D40), // Teal 900
    const Color(0xFF00695C), // Teal 800
    const Color(0xFF00796B), // Teal 700
    const Color(0xFF00897B), // Teal 600
    const Color(0xFF009688), // Teal 500
    const Color(0xFF26A69A), // Teal 400
    const Color(0xFF4DB6AC), // Teal 300
    const Color(0xFF80CBC4), // Teal 200
    const Color(0xFFB2DFDB), // Teal 100
    const Color(0xFFE0F2F1), // Teal 50
    const Color(0xFF311B92), // Deep Purple 900
    const Color(0xFF4527A0), // Deep Purple 800
    const Color(0xFF512DA8), // Deep Purple 700
    const Color(0xFF5E35B1), // Deep Purple 600
    const Color(0xFF673AB7), // Deep Purple 500
    const Color(0xFF7E57C2), // Deep Purple 400
    const Color(0xFF9575CD), // Deep Purple 300
    const Color(0xFFB39DDB), // Deep Purple 200
    const Color(0xFFD1C4E9), // Deep Purple 100
    const Color(0xFFEDE7F6), // Deep Purple 50
    const Color(0xFF263836), // Deep Teal
    const Color(0xFF365754), // Slate Green
    const Color(0xFF1D3030), // Dark Forest
    const Color(0xFF002244), // Navy
    const Color(0xFF4F4A48), // Charcoal
    const Color(0xFF6B3E26), // Chocolate
    const Color(0xFF3D1C02), // Dark Brown
    const Color(0xFF36013F), // Deep Violet
    const Color(0xFF420C55), // Plum
    const Color(0xFF054B63), // Deep Ocean
  ];
  
  // Get the appropriate text color for a background color
  static Color getTextColorForBackground(Color backgroundColor) {
    // Calculate luminance - a value between 0 and 1
    // Closer to 0 means darker, closer to 1 means lighter
    final double luminance = backgroundColor.computeLuminance();
    
    // If the background is dark, use white text
    // If the background is light, use dark text
    return luminance > 0.5 
        ? Colors.black87 
        : Colors.white;
  }
  
  // Get contrasting text style based on background color
  static TextStyle getTextStyleForBackground(Color backgroundColor, {double fontSize = 28.0, FontWeight fontWeight = FontWeight.bold}) {
    return TextStyle(
      color: getTextColorForBackground(backgroundColor),
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.4,
    );
  }
}