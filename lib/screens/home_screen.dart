import 'package:affirmation/widgets/category_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';
import 'dart:collection';
import '../models/affirmation.dart';
import '../services/affirmation_service.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Affirmation currentAffirmation;
  Affirmation? nextAffirmation;
  Affirmation? previousAffirmation;
  bool isLoading = true;
  List<Affirmation> affirmations = [];
  List<Affirmation> filteredAffirmations = []; // Track filtered affirmations
  String? currentCategory;
  bool hasMoreAffirmations = true; // Track if there are more affirmations to show

  // History stack to track visited affirmations
  final Queue<Affirmation> _history = Queue<Affirmation>();
  final Queue<Affirmation> _forward = Queue<Affirmation>();

  // For drag gesture tracking
  double dragDistance = 0;
  bool isDragging = false;
  bool isDraggingUp = false;

  // For heart animation
  bool _isShowingHeartAnimation = false;

  // Background colors
  final List<Color> backgroundColors = [
    const Color(0xFFD5EAE4), // teal
    const Color(0xFFE8D5EA), // lavender
    const Color(0xFFEAE4D5), // cream
    const Color(0xFFD5E6EA), // light blue
    const Color(0xFFE0D5EA), // purple
    const Color(0xFFEAD5D5), // light pink
  ];

  late Color currentColor;
  late Color nextColor;
  late Color previousColor;

  // Key for scaffold to access drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadAffirmations();
    currentColor = backgroundColors[0];
    _pickNextColor();
    _pickPreviousColor();
  }

  void _pickNextColor() {
    // Pick a different color than the current one
    Color newColor;
    do {
      newColor = backgroundColors[Random().nextInt(backgroundColors.length)];
    } while (newColor == currentColor && backgroundColors.length > 1);

    nextColor = newColor;
  }

  void _pickPreviousColor() {
    // Pick a different color than the current one and next one
    Color newColor;
    do {
      newColor = backgroundColors[Random().nextInt(backgroundColors.length)];
    } while ((newColor == currentColor || newColor == nextColor) &&
        backgroundColors.length > 2);

    previousColor = newColor;
  }

  Future<void> _loadAffirmations() async {
    setState(() {
      isLoading = true;
    });

    affirmations = await AffirmationService.getAffirmations();
    filteredAffirmations = affirmations; // Initialize filtered list with all affirmations

    // Select initial affirmation
    if (affirmations.isNotEmpty) {
      final randomIndex = Random().nextInt(affirmations.length);
      currentAffirmation = affirmations[randomIndex];

      // Add to history
      _history.addLast(currentAffirmation);

      // Prepare next and previous affirmations
      _prepareNextAffirmation();
      _preparePreviousAffirmation();
      
      hasMoreAffirmations = filteredAffirmations.length > 1;
    } else {
      // Handle case when there are no affirmations
      hasMoreAffirmations = false;
    }

    setState(() {
      isLoading = false;
    });
  }

  void _prepareNextAffirmation() {
    // Get a different affirmation for next card
    List<Affirmation> availableAffirmations = filteredAffirmations
        .where((a) => a.id != currentAffirmation.id)
        .toList();

    if (availableAffirmations.isEmpty) {
      // No more affirmations available in this category
      nextAffirmation = null;
      hasMoreAffirmations = false;
    } else {
      final randomIndex = Random().nextInt(availableAffirmations.length);
      nextAffirmation = availableAffirmations[randomIndex];
      hasMoreAffirmations = true;
    }
  }

  void _preparePreviousAffirmation() {
    if (_history.length > 1) {
      // Get the previous item from history
      previousAffirmation = _history.elementAt(_history.length - 2);
    } else {
      // No previous history, create one
      List<Affirmation> availableAffirmations = filteredAffirmations
          .where((a) =>
              a.id != currentAffirmation.id &&
              (nextAffirmation == null || a.id != nextAffirmation!.id))
          .toList();

      if (availableAffirmations.isEmpty) {
        previousAffirmation = null;
      } else {
        final randomIndex = Random().nextInt(availableAffirmations.length);
        previousAffirmation = availableAffirmations[randomIndex];
      }
    }
  }

  void _goToNext() {
    if (nextAffirmation != null) {
      setState(() {
        // Store current in history before moving
        _history.addLast(nextAffirmation!);

        // Move forward
        _forward.clear(); // Clear forward history when new path is taken
        previousAffirmation = currentAffirmation;
        currentAffirmation = nextAffirmation!;
        previousColor = currentColor;
        currentColor = nextColor;

        // Prepare new next
        _prepareNextAffirmation();
        _pickNextColor();

        // Reset drag
        dragDistance = 0;
        isDragging = false;
      });
    }
  }

  void _goToPrevious() {
    if (previousAffirmation != null) {
      setState(() {
        // Add current to forward queue
        _forward.addFirst(currentAffirmation);

        // Remove current from history
        if (_history.isNotEmpty) {
          _history.removeLast();
        }

        // Move backward
        nextAffirmation = currentAffirmation;
        currentAffirmation = previousAffirmation!;
        nextColor = currentColor;
        currentColor = previousColor;

        // Prepare new previous if available
        _preparePreviousAffirmation();
        _pickPreviousColor();

        // Reset drag
        dragDistance = 0;
        isDragging = false;
      });
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
      final index = affirmations.indexWhere((a) => a.id == updatedAffirmation.id);
      if (index != -1) {
        affirmations[index] = updatedAffirmation;
      }
      
      final filteredIndex = filteredAffirmations.indexWhere((a) => a.id == updatedAffirmation.id);
      if (filteredIndex != -1) {
        filteredAffirmations[filteredIndex] = updatedAffirmation;
      }
    });
  }

  void _shareAffirmation() {
    Share.share(currentAffirmation.text);
  }

  void _showHeartAnimation() {
    // First make sure the animation is off to restart it
    setState(() {
      _isShowingHeartAnimation = false;
    });

    // Toggle favorite if not already favorited
    if (!currentAffirmation.isFavorite) {
      _toggleFavorite();
    }

    // Small delay to ensure animation restarts
    Future.delayed(const Duration(milliseconds: 10), () {
      if (mounted) {
        setState(() {
          _isShowingHeartAnimation = true;
        });

        // Hide animation after delay
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _isShowingHeartAnimation = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final dragThreshold =
        screenHeight * 0.4; // 40% of screen height for card transition

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredAffirmations.isEmpty
              ? _buildEmptyState()
              : Stack(
                  children: [
                    // Next card (positioned under current card)
                    if (nextAffirmation != null && hasMoreAffirmations)
                      Positioned(
                        top: isDraggingUp ? screenHeight - dragDistance : 0,
                        left: 0,
                        right: 0,
                        height: screenHeight,
                        child: Container(
                          color: nextColor,
                          child: Column(
                            children: [
                              SizedBox(height: MediaQuery.of(context).padding.top),
                              SizedBox(height: kToolbarHeight), // Space for app bar
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40.0),
                                    child: Text(
                                      nextAffirmation!.text,
                                      style:
                                          Theme.of(context).textTheme.displayLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              _buildBottomBar(nextAffirmation!),
                            ],
                          ),
                        ),
                      ),

                    // Previous card (positioned under current card)
                    if (previousAffirmation != null)
                      Positioned(
                        top: !isDraggingUp ? -screenHeight + dragDistance : 0,
                        left: 0,
                        right: 0,
                        height: screenHeight,
                        child: Container(
                          color: previousColor,
                          child: Column(
                            children: [
                              SizedBox(height: MediaQuery.of(context).padding.top),
                              SizedBox(height: kToolbarHeight), // Space for app bar
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40.0),
                                    child: Text(
                                      previousAffirmation!.text,
                                      style:
                                          Theme.of(context).textTheme.displayLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              _buildBottomBar(previousAffirmation!),
                            ],
                          ),
                        ),
                      ),

                    // Current card with gesture detector
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragStart: (details) {
                          setState(() {
                            isDragging = true;
                            dragDistance = 0;
                          });
                        },
                        onVerticalDragUpdate: (details) {
                          if (details.delta.dy < 0 && hasMoreAffirmations) {
                            // Dragging up (next) - only if there are more affirmations
                            setState(() {
                              isDraggingUp = true;
                              dragDistance += -details.delta.dy;
                            });
                          } else if (details.delta.dy > 0 && _history.length > 1) {
                            // Dragging down (previous)
                            setState(() {
                              isDraggingUp = false;
                              dragDistance += details.delta.dy;
                            });
                          }
                        },
                        onVerticalDragEnd: (details) {
                          if (isDraggingUp && hasMoreAffirmations) {
                            // Swiping up to next - only if there are more affirmations
                            if (dragDistance > dragThreshold ||
                                (details.primaryVelocity != null &&
                                    details.primaryVelocity! < -1500)) {
                              _goToNext();
                            } else {
                              setState(() {
                                dragDistance = 0;
                                isDragging = false;
                              });
                            }
                          } else {
                            // Swiping down to previous
                            if (dragDistance > dragThreshold ||
                                (details.primaryVelocity != null &&
                                    details.primaryVelocity! > 1500)) {
                              _goToPrevious();
                            } else {
                              setState(() {
                                dragDistance = 0;
                                isDragging = false;
                              });
                            }
                          }
                        },
                        onDoubleTap: _showHeartAnimation,
                        child: Container(
                          transform: Matrix4.translationValues(
                              0,
                              isDragging
                                  ? (isDraggingUp ? -dragDistance : dragDistance)
                                  : 0,
                              0),
                          color: currentColor,
                          child: Column(
                            children: [
                              SizedBox(height: MediaQuery.of(context).padding.top),
                              const SizedBox(
                                  height: kToolbarHeight), // Space for app bar
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40.0),
                                    child: Text(
                                      currentAffirmation.text,
                                      style:
                                          Theme.of(context).textTheme.displayLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              _buildBottomBar(currentAffirmation),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Heart animation overlay
                    if (_isShowingHeartAnimation)
                      Positioned.fill(
                        child: Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.1, end: 1.0),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: AnimatedOpacity(
                                  opacity: _isShowingHeartAnimation ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 100,
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
    return Container(
      color: currentColor,
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
                        const Icon(
                          Icons.format_quote,
                          size: 80,
                          color: Colors.black38,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "No affirmations yet",
                          style: Theme.of(context).textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentCategory == "Favorites"
                              ? "Double-tap on an affirmation to favorite it"
                              : "Try selecting a different category",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            if (currentCategory != null) {
                              setState(() {
                                currentCategory = null;
                              });
                              _loadAffirmations();
                            } else {
                              _showCategoriesBottomSheet();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            currentCategory != null ? "View All Affirmations" : "Open Categories",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            color: Colors.black87,
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            color: Colors.black87,
            onPressed: _showCategoriesBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.card_giftcard),
            color: Colors.black87,
            onPressed: () {
              // Premium features or store
            },
          ),
        ],
      ),
    );
  }

  void _showCategoriesBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) => CategoryBottomSheet(
        currentCategory: currentCategory,
        onCategorySelected: (category) {
          setState(() {
            currentCategory = category;
          });
          _loadAffirmationsByCategory(category);
        },
      ),
    );
  }

  Future<void> _loadAffirmationsByCategory(String category) async {
    setState(() {
      isLoading = true;
    });

    // Get all affirmations
    final allAffirmations = await AffirmationService.getAffirmations();

    // Clear current lists
    _history.clear();
    _forward.clear();
    
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
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Select a random affirmation from the filtered list
    final randomIndex = Random().nextInt(filteredAffirmations.length);
    currentAffirmation = filteredAffirmations[randomIndex];

    // Add to history
    _history.addLast(currentAffirmation);

    // Prepare next and previous affirmations
    _prepareNextAffirmation();
    _preparePreviousAffirmation();

    hasMoreAffirmations = filteredAffirmations.length > 1;

    setState(() {
      isLoading = false;
    });
  }

  Widget _buildBottomBar(Affirmation affirmation) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: InkWell(
                  onTap: _shareAffirmation,
                  child: Row(
                    children: [
                      const Icon(Icons.ios_share, color: Colors.black87),
                      const SizedBox(width: 10),
                      Text(
                        "Share",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  onTap: affirmation.id == currentAffirmation.id
                      ? _toggleFavorite
                      : null,
                  child: Icon(
                    affirmation.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: affirmation.isFavorite ? Colors.red : Colors.black87,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}