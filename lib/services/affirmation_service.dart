import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/affirmation.dart';

class AffirmationService {
  static const String _storageKey = 'affirmations';
  static const String _favoritesKey = 'favorites';
  static List<Affirmation> _affirmations = [];
  
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we have stored affirmations
    if (prefs.containsKey(_storageKey)) {
      final String affirmationsJson = prefs.getString(_storageKey) ?? '[]';
      
      try {
        final List<dynamic> decodedList = jsonDecode(affirmationsJson);
        _affirmations = decodedList
            .map((item) => Affirmation.fromJson(item))
            .toList();
      } catch (e) {
        // If there's an error, initialize with default affirmations
        _initializeDefaultAffirmations();
      }
    } else {
      // First time app is run, initialize with defaults
      _initializeDefaultAffirmations();
      await _saveAffirmations();
    }
    
    // Load favorites
    await _loadFavorites();
  }
  
  static void _initializeDefaultAffirmations() {
    _affirmations = [
      Affirmation(
        id: '1',
        text: 'You are a light in moments of darkness.',
        createdAt: DateTime.now(),
        category: 'Motivation',
      ),
      Affirmation(
        id: '2',
        text: 'You are capable of amazing things.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '3',
        text: 'Your potential is limitless.',
        createdAt: DateTime.now(),
        category: 'Growth',
      ),
      Affirmation(
        id: '4',
        text: 'You deserve all good things coming your way.',
        createdAt: DateTime.now(),
        category: 'Self-Love',
      ),
      Affirmation(
        id: '5',
        text: 'Your presence makes a difference.',
        createdAt: DateTime.now(),
        category: 'Purpose',
      ),
      Affirmation(
        id: '6',
        text: 'You are enough, just as you are.',
        createdAt: DateTime.now(),
        category: 'Self-Acceptance',
      ),
      Affirmation(
        id: '7',
        text: 'Your courage inspires those around you.',
        createdAt: DateTime.now(),
        category: 'Courage',
      ),
      Affirmation(
        id: '8',
        text: 'You turn obstacles into opportunities.',
        createdAt: DateTime.now(),
        category: 'Resilience',
      ),
      Affirmation(
        id: '9',
        text: 'Your strength is greater than any challenge.',
        createdAt: DateTime.now(),
        category: 'Strength',
      ),
      Affirmation(
        id: '10',
        text: 'You are worthy of love and respect.',
        createdAt: DateTime.now(),
        category: 'Worth',
      ),
    ];
  }
  
  static Future<void> _saveAffirmations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = _affirmations
        .map((affirmation) => affirmation.toJson())
        .toList();
    
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
    final index = _affirmations.indexWhere(
      (affirmation) => affirmation.id == updatedAffirmation.id
    );
    
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
    return _affirmations.where((affirmation) => affirmation.isFavorite).toList();
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