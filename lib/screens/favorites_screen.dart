import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../models/affirmation.dart';
import '../services/affirmation_service.dart';
import '../widgets/affirmation_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Affirmation> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      isLoading = true;
    });
    
    final allAffirmations = await AffirmationService.getAffirmations();
    final favoriteAffirmations = allAffirmations.where((a) => a.isFavorite).toList();
    
    setState(() {
      favorites = favoriteAffirmations;
      isLoading = false;
    });
  }

  Future<void> _removeFromFavorites(Affirmation affirmation) async {
    final updatedAffirmation = affirmation.copyWith(isFavorite: false);
    await AffirmationService.updateAffirmation(updatedAffirmation);
    
    // Refresh the list
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Favorites', style: GoogleFonts.merriweather(),),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: Lottie.asset('assets/loader.json', height: 50))
          : favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 60,
                        color: Colors.black54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: GoogleFonts.merriweather(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the heart icon to add affirmations to your favorites',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.merriweather(color: Colors.black54),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final affirmation = favorites[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AffirmationCard(
                        affirmation: affirmation,
                        onFavoriteToggle: () => _removeFromFavorites(affirmation),
                      ),
                    );
                  },
                ),
    );
  }
}