import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';
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
  bool isLoading = true;
  List<Affirmation> affirmations = [];
  
  // For drag gesture tracking
  double dragDistance = 0;
  bool isDragging = false;

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
  
  // Key for scaffold to access drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadAffirmations();
    currentColor = backgroundColors[0];
    _pickNextColor();
  }

  void _pickNextColor() {
    // Pick a different color than the current one
    Color newColor;
    do {
      newColor = backgroundColors[Random().nextInt(backgroundColors.length)];
    } while (newColor == currentColor && backgroundColors.length > 1);
    
    nextColor = newColor;
  }

  Future<void> _loadAffirmations() async {
    setState(() {
      isLoading = true;
    });
    
    affirmations = await AffirmationService.getAffirmations();
    
    // Select initial affirmation
    final randomIndex = Random().nextInt(affirmations.length);
    currentAffirmation = affirmations[randomIndex];
    
    // Prepare next affirmation
    _prepareNextAffirmation();
    
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

  void _changeAffirmation() {
    if (nextAffirmation != null) {
      setState(() {
        currentAffirmation = nextAffirmation!;
        currentColor = nextColor;
        _prepareNextAffirmation();
        _pickNextColor();
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
    
    // Calculate the opacity for the current and next screens
    final currentOpacity = isDragging ? 1.0 - (dragDistance / dragThreshold).clamp(0.0, 1.0) : 1.0;
    final nextOpacity = isDragging ? (dragDistance / dragThreshold).clamp(0.0, 1.0) : 0.0;
    
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(), // Add drawer here
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onVerticalDragStart: (details) {
                setState(() {
                  isDragging = true;
                  dragDistance = 0;
                });
              },
              onVerticalDragUpdate: (details) {
                // Only track upward drag (negative delta)
                if (details.delta.dy < 0) {
                  setState(() {
                    dragDistance += -details.delta.dy;
                  });
                }
              },
              onVerticalDragEnd: (details) {
                if (dragDistance > dragThreshold || 
                    (details.primaryVelocity != null && details.primaryVelocity! < -1500)) {
                  _changeAffirmation();
                } else {
                  setState(() {
                    dragDistance = 0;
                    isDragging = false;
                  });
                }
              },
              child: Stack(
                children: [
                  // Next affirmation (background)
                  if (nextAffirmation != null)
                    Positioned.fill(
                      child: Opacity(
                        opacity: nextOpacity,
                        child: Container(
                          color: nextColor,
                          child: SafeArea(
                            child: Column(
                              children: [
                                _buildAppBar(),
                                Expanded(
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
                                _buildBottomBar(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                  // Current affirmation
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(0, -dragDistance),
                      child: Opacity(
                        opacity: currentOpacity,
                        child: Container(
                          color: currentColor,
                          child: SafeArea(
                            child: Column(
                              children: [
                                _buildAppBar(),
                                Expanded(
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
                                _buildBottomBar(),
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
              // Use the scaffold key to open the drawer
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
  
  Widget _buildBottomBar() {
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
                  onTap: _toggleFavorite,
                  child: Icon(
                    currentAffirmation.isFavorite 
                        ? Icons.favorite 
                        : Icons.favorite_border,
                    color: currentAffirmation.isFavorite 
                        ? Colors.red 
                        : Colors.black87,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 5,
          width: 120,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}