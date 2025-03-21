import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/affirmation.dart';

class AffirmationService {
  static const String _storageKey = 'affirmations';
  static const String _favoritesKey = 'favorites';
  static const String _apiUrl = 'https://beyou-api.onrender.com/affirmations/';
  static List<Affirmation> _affirmations = [];

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Try to fetch from API first
      await _fetchAffirmationsFromApi();
    } catch (e) {
      print('Error fetching from API: $e');
      
      // If API fetch fails, try to load from cache
      if (prefs.containsKey(_storageKey)) {
        final String affirmationsJson = prefs.getString(_storageKey) ?? '[]';
        
        try {
          final List<dynamic> decodedList = jsonDecode(affirmationsJson);
          _affirmations = decodedList.map((item) => Affirmation.fromJson(item)).toList();
          print('Loaded ${_affirmations.length} affirmations from cache');
        } catch (e) {
          print('Error loading from cache: $e');
          // If cache load fails, initialize with defaults as fallback
          _initializeDefaultAffirmations();
        }
      } else {
        // If no cache exists, initialize with defaults
        _initializeDefaultAffirmations();
      }
    }

    // Save to cache if we have affirmations (either from API or defaults)
    if (_affirmations.isNotEmpty) {
      await _saveAffirmations();
    }

    // Load favorites
    await _loadFavorites();
  }

  static Future<void> _fetchAffirmationsFromApi() async {
    final response = await http.get(Uri.parse(_apiUrl));
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      
      // Convert API response to Affirmation objects
      _affirmations = jsonData.map((item) {
        // Adjust these fields based on your API response structure
        return Affirmation(
          id: item['id'] ?? '',
          text: item['text'] ?? '',
          createdAt: DateTime.parse(item['createdAt'] ?? DateTime.now().toIso8601String()),
          category: item['category'] ?? 'General',
        );
      }).toList();
      
      print('Fetched ${_affirmations.length} affirmations from API');
    } else {
      throw Exception('Failed to load affirmations from API: ${response.statusCode}');
    }
  }

  // Keep the remaining methods unchanged
  static void _initializeDefaultAffirmations() {
    // This is your fallback in case both API and cache fail
    _affirmations = [
      Affirmation(
        id: 'default-1',
        text: 'I believe in my abilities and trust my decisions.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      // Add a few more default affirmations as emergency fallback
      Affirmation(
        id: 'default-2',
        text: 'I am constantly evolving and improving.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: 'default-3',
        text: 'I am a magnet for prosperity and abundance.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
    ];
    
    print('Using default affirmations as fallback');
  }

  static Future<void> _saveAffirmations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        _affirmations.map((affirmation) => affirmation.toJson()).toList();

    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  static Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String favoritesJson = prefs.getString(_favoritesKey) ?? '[]';

    try {
      final List<dynamic> favoriteIds = jsonDecode(favoritesJson);

      // Update the favorite status for each affirmation
      for (int i = 0; i < _affirmations.length; i++) {
        final affirmation = _affirmations[i];
        if (favoriteIds.contains(affirmation.id)) {
          _affirmations[i] = affirmation.copyWith(isFavorite: true);
        }
      }
    } catch (e) {
      // If there's an error, just continue with non-favorite status
    }
  }

  static Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoriteIds = _affirmations
        .where((affirmation) => affirmation.isFavorite)
        .map((affirmation) => affirmation.id)
        .toList();

    await prefs.setString(_favoritesKey, jsonEncode(favoriteIds));
  }

  static Future<List<Affirmation>> getAffirmations() async {
    return List.from(_affirmations);
  }

  static Future<Affirmation?> getAffirmationById(String id) async {
    try {
      return _affirmations.firstWhere((affirmation) => affirmation.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateAffirmation(Affirmation updatedAffirmation) async {
    final index = _affirmations
        .indexWhere((affirmation) => affirmation.id == updatedAffirmation.id);

    if (index != -1) {
      _affirmations[index] = updatedAffirmation;
      await _saveAffirmations();
      await _saveFavorites();
    }
  }

  static Future<void> addAffirmation(Affirmation affirmation) async {
    _affirmations.add(affirmation);
    await _saveAffirmations();
  }

  static Future<void> deleteAffirmation(String id) async {
    _affirmations.removeWhere((affirmation) => affirmation.id == id);
    await _saveAffirmations();
    await _saveFavorites();
  }

  static Future<List<Affirmation>> getFavorites() async {
    return _affirmations
        .where((affirmation) => affirmation.isFavorite)
        .toList();
  }

  static Future<Affirmation> getRandomAffirmation() async {
    if (_affirmations.isEmpty) {
      // If somehow we have no affirmations, initialize defaults
      _initializeDefaultAffirmations();
      await _saveAffirmations();
    }

    // Get a random index
    final random = DateTime.now().millisecondsSinceEpoch % _affirmations.length;
    return _affirmations[random];
  }
}