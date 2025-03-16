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

    // Select initial affirmation
    final randomIndex = Random().nextInt(affirmations.length);
    currentAffirmation = affirmations[randomIndex];

    // Add to history
    _history.addLast(currentAffirmation);

    // Prepare next and previous affirmations
    _prepareNextAffirmation();
    _preparePreviousAffirmation();

    setState(() {
      isLoading = false;
    });
  }

  void _prepareNextAffirmation() {
    // Get a different affirmation for next card
    List<Affirmation> availableAffirmations =
        affirmations.where((a) => a.id != currentAffirmation.id).toList();

    if (availableAffirmations.isEmpty) {
      // Fallback if only one affirmation exists
      nextAffirmation = currentAffirmation;
    } else {
      final randomIndex = Random().nextInt(availableAffirmations.length);
      nextAffirmation = availableAffirmations[randomIndex];
    }
  }

  void _preparePreviousAffirmation() {
    if (_history.length > 1) {
      // Get the previous item from history
      previousAffirmation = _history.elementAt(_history.length - 2);
    } else {
      // No previous history, create one
      List<Affirmation> availableAffirmations = affirmations
          .where((a) =>
              a.id != currentAffirmation.id &&
              (nextAffirmation == null || a.id != nextAffirmation!.id))
          .toList();

      if (availableAffirmations.isEmpty) {
        previousAffirmation = currentAffirmation;
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

      // Also update in our local list
      final index =
          affirmations.indexWhere((a) => a.id == updatedAffirmation.id);
      if (index != -1) {
        affirmations[index] = updatedAffirmation;
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
          : Stack(
              children: [
                // Next card (positioned under current card)
                if (nextAffirmation != null)
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
                      if (details.delta.dy < 0) {
                        // Dragging up (next)
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
                      if (isDraggingUp) {
                        // Swiping up to next
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
