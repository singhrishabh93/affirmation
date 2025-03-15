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
    } while ((newColor == currentColor || newColor == nextColor) && backgroundColors.length > 2);
    
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
    List<Affirmation> availableAffirmations = affirmations.where(
      (a) => a.id != currentAffirmation.id
    ).toList();
    
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
      List<Affirmation> availableAffirmations = affirmations.where(
        (a) => a.id != currentAffirmation.id && (nextAffirmation == null || a.id != nextAffirmation!.id)
      ).toList();
      
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
      final index = affirmations.indexWhere((a) => a.id == updatedAffirmation.id);
      if (index != -1) {
        affirmations[index] = updatedAffirmation;
      }
    });
  }

  void _shareAffirmation() {
    Share.share(currentAffirmation.text);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dragThreshold = screenHeight * 0.3; // 30% of screen height
    
    // Calculate the opacity for the current, next and previous screens
    final currentOpacity = isDragging ? 1.0 - (dragDistance / dragThreshold).clamp(0.0, 1.0) : 1.0;
    final nextOpacity = isDragging && isDraggingUp ? (dragDistance / dragThreshold).clamp(0.0, 1.0) : 0.0;
    final previousOpacity = isDragging && !isDraggingUp ? (dragDistance / dragThreshold).clamp(0.0, 1.0) : 0.0;
    
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Swipeable content area
                GestureDetector(
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
                          (details.primaryVelocity != null && details.primaryVelocity! < -1500)) {
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
                          (details.primaryVelocity != null && details.primaryVelocity! > 1500)) {
                        _goToPrevious();
                      } else {
                        setState(() {
                          dragDistance = 0;
                          isDragging = false;
                        });
                      }
                    }
                  },
                  child: Stack(
                    children: [
                      // Previous affirmation (visible when swiping down)
                      if (previousAffirmation != null)
                        Positioned.fill(
                          child: Opacity(
                            opacity: previousOpacity,
                            child: Container(
                              color: previousColor,
                              child: SafeArea(
                                child: Column(
                                  children: [
                                    Spacer(flex: 1), // Space for app bar
                                    Expanded(
                                      flex: 9,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                                          child: Text(
                                            previousAffirmation!.text,
                                            style: Theme.of(context).textTheme.displayLarge,
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
                          ),
                        ),
                        
                      // Next affirmation (visible when swiping up)
                      if (nextAffirmation != null)
                        Positioned.fill(
                          child: Opacity(
                            opacity: nextOpacity,
                            child: Container(
                              color: nextColor,
                              child: SafeArea(
                                child: Column(
                                  children: [
                                    Spacer(flex: 1), // Space for app bar
                                    Expanded(
                                      flex: 9,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                                          child: Text(
                                            nextAffirmation!.text,
                                            style: Theme.of(context).textTheme.displayLarge,
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
                          ),
                        ),
                        
                      // Current affirmation
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(0, isDraggingUp ? -dragDistance : dragDistance),
                          child: Opacity(
                            opacity: currentOpacity,
                            child: Container(
                              color: currentColor,
                              child: SafeArea(
                                child: Column(
                                  children: [
                                    Spacer(flex: 1), // Space for app bar
                                    Expanded(
                                      flex: 9,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                                          child: Text(
                                            currentAffirmation.text,
                                            style: Theme.of(context).textTheme.displayLarge,
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
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Fixed app bar that doesn't move with swipe
                SafeArea(
                  child: _buildAppBar(),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  onTap: affirmation.id == currentAffirmation.id ? _toggleFavorite : null,
                  child: Icon(
                    affirmation.isFavorite 
                        ? Icons.favorite 
                        : Icons.favorite_border,
                    color: affirmation.isFavorite 
                        ? Colors.red 
                        : Colors.black87,
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