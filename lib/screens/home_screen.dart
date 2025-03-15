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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAffirmation();
  }

  Future<void> _loadAffirmation() async {
    setState(() {
      isLoading = true;
    });
    
    final affirmations = await AffirmationService.getAffirmations();
    final randomIndex = Random().nextInt(affirmations.length);
    
    setState(() {
      currentAffirmation = affirmations[randomIndex];
      isLoading = false;
    });
  }

  void _changeAffirmation() async {
    await _loadAffirmation();
  }

  void _toggleFavorite() async {
    final updatedAffirmation = currentAffirmation.copyWith(
      isFavorite: !currentAffirmation.isFavorite,
    );
    
    await AffirmationService.updateAffirmation(updatedAffirmation);
    
    setState(() {
      currentAffirmation = updatedAffirmation;
    });
  }

  void _shareAffirmation() {
    Share.share(currentAffirmation.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard),
            onPressed: () {
              // Premium features or store
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: _changeAffirmation,
              child: Column(
                children: [
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
              ),
            ),
    );
  }
}