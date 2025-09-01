import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:affirmation/constants/app_colors.dart'; // Import the colors file
import 'package:affirmation/screens/profile_screen.dart';
import 'package:affirmation/screens/category_page.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';
import 'dart:collection';
import '../models/affirmation.dart';
import '../services/affirmation_service.dart';
import '../widgets/custom_drawer.dart';
import '../services/music_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final MusicService _musicService = MusicService();
  final GlobalKey _screenshotKey = GlobalKey();
  late Affirmation currentAffirmation;
  List<Affirmation> affirmations = [];
  List<Affirmation> filteredAffirmations = []; // Track filtered affirmations
  String? currentCategory;
  bool hasMoreAffirmations =
      true; // Track if there are more affirmations to show

  // Page controller for smooth scrolling
  late PageController _pageController;
  int _currentPageIndex = 0;
  bool isLoading = true;

  // Enhanced heart animation controllers
  late AnimationController _heartScaleController;
  late AnimationController _heartOpacityController;
  late AnimationController _heartPositionController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartOpacityAnimation;
  late Animation<Offset> _heartPositionAnimation;

  // Heart animation state
  bool _isShowingHeartAnimation = false;

  // Use colors from the app_colors.dart file
  List<Color> get backgroundColors => AppColors.affirmationBackgrounds;

  // Key for scaffold to access drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 1.0,
      keepPage: true,
    );

    // Initialize heart animation controllers
    _heartScaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _heartOpacityController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _heartPositionController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Create heart animations
    _heartScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartScaleController,
      curve: Curves.elasticOut,
    ));

    _heartOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _heartOpacityController,
      curve: Curves.easeOut,
    ));

    _heartPositionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.3),
    ).animate(CurvedAnimation(
      parent: _heartPositionController,
      curve: Curves.easeOutCubic,
    ));

    _loadAffirmations();
    _musicService.initialize();

    // Listen for widget launches
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
  }

  void _launchedFromWidget(Uri? uri) {
    if (uri != null) {
      // Handle widget launch here if needed
      print('App launched from widget with URI: $uri');
    }
  }

  Future<void> _updateHomeScreenWidget(Affirmation affirmation) async {
    try {
      // Save data to widget storage
      await HomeWidget.saveWidgetData('title', 'BeYou');
      await HomeWidget.saveWidgetData('message', affirmation.text);

      // Update Android widget
      await HomeWidget.updateWidget(
        qualifiedAndroidName: 'com.beyou.affirmation.AffirmationWidgetProvider',
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  // Get the appropriate text style for the current background
  TextStyle getAffirmationTextStyle(Color backgroundColor) {
    return GoogleFonts.merriweather(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.getTextColorForBackground(backgroundColor),
      height: 1.4,
    );
  }

  // Get text style for secondary text elements
  TextStyle getSecondaryTextStyle(Color backgroundColor) {
    return GoogleFonts.merriweather(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.getTextColorForBackground(backgroundColor),
    );
  }

  Future<void> _loadAffirmations() async {
    setState(() {
      isLoading = true;
    });

    affirmations = await AffirmationService.getAffirmations();
    filteredAffirmations = affirmations;

    // Select initial affirmation
    if (affirmations.isNotEmpty) {
      final randomIndex = Random().nextInt(affirmations.length);
      currentAffirmation = affirmations[randomIndex];

      // Play default music
      await _musicService
          .playMusicForCategory(currentAffirmation.category ?? 'General');

      hasMoreAffirmations = filteredAffirmations.length > 1;
    } else {
      // Handle case when there are no affirmations
      hasMoreAffirmations = false;
    }

    setState(() {
      isLoading = false;
    });
  }

  void _onPageChanged(int index) {
    if (index < filteredAffirmations.length) {
      setState(() {
        _currentPageIndex = index;
        currentAffirmation = filteredAffirmations[index];
      });

      // Play music for the new affirmation
      _musicService
          .playMusicForCategory(currentAffirmation.category ?? 'General');

      // Update widget
      _updateHomeScreenWidget(currentAffirmation);
    }
  }

  void _toggleFavorite() async {
    final updatedAffirmation = currentAffirmation.copyWith(
      isFavorite: !currentAffirmation.isFavorite,
    );

    await AffirmationService.updateAffirmation(updatedAffirmation);

    setState(() {
      currentAffirmation = updatedAffirmation;

      // Also update in our local lists
      final index =
          affirmations.indexWhere((a) => a.id == updatedAffirmation.id);
      if (index != -1) {
        affirmations[index] = updatedAffirmation;
      }

      final filteredIndex =
          filteredAffirmations.indexWhere((a) => a.id == updatedAffirmation.id);
      if (filteredIndex != -1) {
        filteredAffirmations[filteredIndex] = updatedAffirmation;
      }
    });
  }

  Future<void> _shareAffirmation() async {
    try {
      // Capture screenshot
      final RenderRepaintBoundary boundary = _screenshotKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // Save to temporary file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/affirmation.png');
        await file.writeAsBytes(pngBytes);

        // Share the image file
        await Share.shareXFiles(
          [XFile(file.path)],
          text: currentAffirmation.text,
        );
      } else {
        // Fallback to text-only sharing if image capture fails
        Share.share(currentAffirmation.text);
      }
    } catch (e) {
      // Fallback to text-only sharing if any error occurs
      Share.share(currentAffirmation.text);
      print('Error taking screenshot: $e');
    }
  }

  void _showHeartAnimation() {
    if (!currentAffirmation.isFavorite) {
      _toggleFavorite();
    }

    // Reset animation state
    _heartScaleController.reset();
    _heartOpacityController.reset();
    _heartPositionController.reset();

    setState(() {
      _isShowingHeartAnimation = true;
    });

    // Start scale animation immediately
    _heartScaleController.forward();

    // Start opacity and position animations with slight delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _heartOpacityController.forward();
        _heartPositionController.forward();
      }
    });

    // Hide animation after completion
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isShowingHeartAnimation = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: isLoading
          ? Center(
              child: Lottie.asset('assets/loader.json', height: 50),
            )
          : filteredAffirmations.isEmpty
              ? _buildEmptyState()
              : Stack(
                  children: [
                    // Smooth PageView for affirmations with Instagram-like physics
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      physics: const ClampingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      scrollDirection: Axis.vertical,
                      pageSnapping: true,
                      allowImplicitScrolling: false,
                      itemCount: filteredAffirmations.length,
                      itemBuilder: (context, index) {
                        final affirmation = filteredAffirmations[index];
                        final backgroundColor =
                            backgroundColors[index % backgroundColors.length];

                        return RepaintBoundary(
                          child: GestureDetector(
                            onDoubleTap: () {
                              if (index == _currentPageIndex) {
                                _showHeartAnimation();
                              }
                            },
                            child: Container(
                              color: backgroundColor,
                              child: Column(
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).padding.top),
                                  const SizedBox(height: kToolbarHeight),
                                  Expanded(
                                    child: RepaintBoundary(
                                      key: index == _currentPageIndex
                                          ? _screenshotKey
                                          : null,
                                      child: Container(
                                        color: backgroundColor,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40.0),
                                        child: Center(
                                          child: SelectableText(
                                            affirmation.text,
                                            style: getAffirmationTextStyle(
                                                backgroundColor),
                                            textAlign: TextAlign.center,
                                            enableInteractiveSelection: false,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  _buildBottomBar(affirmation, backgroundColor),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Enhanced heart animation overlay
                    if (_isShowingHeartAnimation)
                      Positioned.fill(
                        child: Center(
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _heartScaleController,
                              _heartOpacityController,
                              _heartPositionController,
                            ]),
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  0, // Keep horizontal position centered
                                  _heartPositionAnimation.value.dy *
                                      100, // Reduce movement distance
                                ),
                                child: Transform.scale(
                                  scale: _heartScaleAnimation.value,
                                  child: Opacity(
                                    opacity: _heartOpacityAnimation.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.3),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 100,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // Fixed app bar that doesn't move with swipe
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Material(
                        color: Colors.transparent,
                        child: SafeArea(
                          child: _buildAppBar(),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    final backgroundColor = backgroundColors[0];
    final textColor = AppColors.getTextColorForBackground(backgroundColor);

    return Container(
      color: backgroundColor,
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              const SizedBox(height: kToolbarHeight),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: 80,
                          color: textColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No affirmations yet",
                          style: GoogleFonts.merriweather(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentCategory == "Favorites"
                              ? "Double-tap on an affirmation to favorite it"
                              : "Try selecting a different category",
                          style: GoogleFonts.merriweather(
                            fontSize: 14,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: () {
                            _showCategoriesBottomSheet();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: textColor,
                            foregroundColor: backgroundColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            currentCategory != null
                                ? "Open Categories"
                                : "Open Categories",
                            style: GoogleFonts.merriweather(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: backgroundColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                child: _buildAppBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Category button on the left
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(FeatherIcons.alignCenter),
              color: Colors.black87,
              onPressed: _showCategoriesBottomSheet,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(_musicService.isMuted
                  ? FeatherIcons.volumeX
                  : FeatherIcons.volume2),
              color: Colors.black87,
              onPressed: () async {
                await _musicService.toggleMute();
                setState(() {}); // Update icon
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(FeatherIcons.user),
              color: Colors.black87,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoriesBottomSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(
          selectedCategory: currentCategory,
        ),
      ),
    ).then((selectedCategory) {
      if (selectedCategory != null) {
        setState(() {
          currentCategory = selectedCategory;
        });
        _loadAffirmationsByCategory(selectedCategory);
      }
    });
  }

  Future<void> _loadAffirmationsByCategory(String category) async {
    // Don't show loader - directly update affirmations
    await _musicService.playMusicForCategory(category ?? 'General');

    // Get all affirmations
    final allAffirmations = await AffirmationService.getAffirmations();

    // Filter based on category
    if (category == "Favorites") {
      filteredAffirmations =
          allAffirmations.where((a) => a.isFavorite).toList();
    } else if (category == "Confidence") {
      filteredAffirmations = allAffirmations
          .where((a) => a.category?.toLowerCase() == "confidence")
          .toList();
    } else if (category == "General") {
      filteredAffirmations = allAffirmations
          .where((a) =>
              a.category == null ||
              a.category!.isEmpty ||
              a.category!.toLowerCase() == "general")
          .toList();
    } else if (category == "Abundance") {
      filteredAffirmations = allAffirmations
          .where((a) => a.category?.toLowerCase() == "abundance")
          .toList();
    } else if (category == "Love") {
      filteredAffirmations = allAffirmations
          .where((a) => a.category?.toLowerCase() == "love")
          .toList();
    } else if (category == "Success") {
      filteredAffirmations = allAffirmations
          .where((a) => a.category?.toLowerCase() == "success")
          .toList();
    } else if (category == "Gratitude") {
      filteredAffirmations = allAffirmations
          .where((a) => a.category?.toLowerCase() == "gratitude")
          .toList();
    } else {
      // Default to all affirmations
      filteredAffirmations = allAffirmations;
    }

    // Check if we have any matching affirmations
    if (filteredAffirmations.isEmpty) {
      return;
    }

    // Select a random affirmation from the filtered list
    final randomIndex = Random().nextInt(filteredAffirmations.length);
    currentAffirmation = filteredAffirmations[randomIndex];

    // Reset page controller to first page
    _pageController.jumpToPage(0);
    _currentPageIndex = 0;

    hasMoreAffirmations = filteredAffirmations.length > 1;

    // Update UI without loader
    setState(() {});
  }

  Widget _buildBottomBar(Affirmation affirmation, Color backgroundColor) {
    final textColor = AppColors.getTextColorForBackground(backgroundColor);

    return Column(
      children: [
        // Position buttons at the very bottom center, above the gesture navigation bar
        Padding(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: Positioned(
            bottom: 60, // Align with the hamburger menu icon level
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Share button - smaller pill-shaped
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black87, width: 1),
                  ),
                  child: InkWell(
                    onTap: _shareAffirmation,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FeatherIcons.share,
                            color: Colors.black87, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          "Share",
                          style: GoogleFonts.merriweather(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Heart button - smaller circular
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black87, width: 1),
                  ),
                  child: InkWell(
                    onTap: affirmation.id == currentAffirmation.id
                        ? _toggleFavorite
                        : null,
                    child: Icon(
                      affirmation.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          affirmation.isFavorite ? Colors.red : Colors.black87,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heartScaleController.dispose();
    _heartOpacityController.dispose();
    _heartPositionController.dispose();
    _musicService.dispose();
    super.dispose();
  }
}
