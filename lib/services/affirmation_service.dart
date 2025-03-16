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
        _affirmations =
            decodedList.map((item) => Affirmation.fromJson(item)).toList();
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
      // Confidence - 20 affirmations
      Affirmation(
        id: '1',
        text: 'I believe in my abilities and trust my decisions.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '2',
        text: 'I am confident in my unique perspective and skills.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '3',
        text: 'I speak with conviction and others value my input.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '4',
        text: 'I face challenges with courage and unwavering belief in myself.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '5',
        text: 'I am worthy of respect and recognition.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '6',
        text: 'I embrace my strengths and acknowledge my growth areas.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '7',
        text: 'I radiate confidence in everything I do.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '8',
        text: 'I trust my intuition and make decisions with certainty.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '9',
        text: 'I am secure in who I am and what I offer to the world.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '10',
        text: 'I stand tall in the face of criticism and doubt.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '11',
        text: 'My self-assurance empowers others around me.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '12',
        text: 'I acknowledge my value without seeking external validation.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '13',
        text: 'I express myself openly and honestly with confidence.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '14',
        text: 'I am the architect of my life and design it with confidence.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '15',
        text: 'I am confident that I can handle whatever comes my way.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '16',
        text: 'My confidence grows stronger with each passing day.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '17',
        text: 'I embrace new challenges with confidence and enthusiasm.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '18',
        text: 'I am confident in my ability to create positive change.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '19',
        text: 'I project confidence and others respond positively to me.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),
      Affirmation(
        id: '20',
        text: 'My self-confidence is unshakable and grows every day.',
        createdAt: DateTime.now(),
        category: 'Confidence',
      ),

      // General - 20 affirmations
      Affirmation(
        id: '21',
        text: 'I am becoming better every single day.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '22',
        text: 'I am constantly evolving and improving.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '23',
        text: 'I honor my true self and inner wisdom.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '24',
        text: 'I am exactly where I need to be right now.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '25',
        text: 'I embrace change and welcome new beginnings.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '26',
        text: 'I am mindful and present in each moment.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '27',
        text: 'I release all tension and embrace inner peace.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '28',
        text: 'I am aligned with my highest purpose and potential.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '29',
        text: 'I treat myself with kindness, respect, and compassion.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '30',
        text: 'My possibilities are endless and my potential is limitless.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '31',
        text: 'I am whole, complete, and perfect as I am.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '32',
        text: 'I release what no longer serves me.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '33',
        text: 'I transform challenges into opportunities for growth.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '34',
        text: 'I am the author of my story and the creator of my destiny.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '35',
        text: 'I choose thoughts that empower and uplift me.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '36',
        text: 'I am resilient and bounce back stronger from setbacks.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '37',
        text: 'I embrace the journey of personal growth and self-discovery.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '38',
        text: 'I nurture my mind, body, and spirit with positive energy.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '39',
        text: 'I am balanced and centered in all aspects of my life.',
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Affirmation(
        id: '40',
        text: 'I embrace the beauty of who I am becoming.',
        createdAt: DateTime.now(),
        category: 'General',
      ),

      // Abundance - 20 affirmations
      Affirmation(
        id: '41',
        text: 'I am a magnet for prosperity and abundance.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '42',
        text: 'Wealth flows to me easily and effortlessly.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '43',
        text: 'I am open to receiving all the abundance the universe offers.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '44',
        text: 'My life is filled with unlimited abundance in all forms.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '45',
        text: 'I deserve prosperity and welcome it into my life.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '46',
        text: 'Opportunities for abundance surround me everywhere I go.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '47',
        text: 'My abundant mindset creates abundant results.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '48',
        text: 'I live in a universe of abundance and prosperity.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '49',
        text: 'Money comes to me in expected and unexpected ways.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '50',
        text: 'I am worthy of financial freedom and prosperity.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '51',
        text: 'My income is constantly increasing.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '52',
        text: 'I attract abundance by sharing my abundance with others.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '53',
        text: 'I am aligned with the energy of abundance and wealth.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '54',
        text: 'I release all resistance to prosperity and wealth.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '55',
        text: 'I am abundant in all areas of my life.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '56',
        text: 'My relationship with money is positive and healthy.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '57',
        text: 'I easily recognize and seize opportunities for abundance.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '58',
        text: 'The more I give, the more I receive.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '59',
        text: 'I am grateful for the abundance that flows into my life daily.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),
      Affirmation(
        id: '60',
        text: 'I claim my divine right to financial abundance now.',
        createdAt: DateTime.now(),
        category: 'Abundance',
      ),

      // Love - 20 affirmations
      Affirmation(
        id: '61',
        text: 'I am worthy of deep, genuine love and affection.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '62',
        text: 'I attract loving relationships that nurture my soul.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '63',
        text: 'My heart is open to giving and receiving love freely.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '64',
        text: 'I am surrounded by love in all its beautiful forms.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '65',
        text: 'I love myself deeply and completely as I am.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '66',
        text: 'My capacity to love and be loved expands every day.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '67',
        text: 'I release past hurts and open myself to new love.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '68',
        text: 'I am deserving of a loving, supportive partnership.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '69',
        text: 'I am a magnet for loving, healthy relationships.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '70',
        text: 'Love flows through me and connects me with others.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '71',
        text: 'I choose to see myself through eyes of love and acceptance.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '72',
        text: 'I cultivate love in my heart and spread it to the world.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '73',
        text: 'I am deserving of love that respects my boundaries.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '74',
        text: 'I trust in the perfect timing of love in my life.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '75',
        text: 'I attract relationships that honor and cherish who I am.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '76',
        text: 'My heart radiates love that touches everyone around me.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '77',
        text: 'I am a loving presence in all my relationships.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '78',
        text: 'I embrace love as a guiding force in my life.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '79',
        text: 'I accept love in all the ways it shows up for me.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),
      Affirmation(
        id: '80',
        text: 'Love is my natural state of being.',
        createdAt: DateTime.now(),
        category: 'Love',
      ),

      // Success - 20 affirmations
      Affirmation(
        id: '81',
        text: 'I am destined for success and prosperity.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '82',
        text: 'I accomplish goals with ease and determination.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '83',
        text: 'Success flows to me naturally in all that I do.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '84',
        text: 'I am worthy of success and claim it as my birthright.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '85',
        text: 'I turn obstacles into stepping stones for success.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '86',
        text: 'My success contributes to the greater good of all.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '87',
        text: 'I celebrate my achievements and successes, both big and small.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '88',
        text: 'I am determined and persistent in pursuing my goals.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '89',
        text: 'I attract opportunities that lead to my success.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '90',
        text: 'I am focused and disciplined in achieving my dreams.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '91',
        text: 'Success comes easily to me in expected and unexpected ways.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '92',
        text: 'I define success on my own terms and achieve it my way.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '93',
        text: 'I welcome challenges as opportunities to succeed.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '94',
        text: 'My mindset is aligned with success and achievement.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '95',
        text: 'I am resilient and turn failures into future successes.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '96',
        text: 'I celebrate the success of others while creating my own.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '97',
        text: 'Each day brings me closer to my vision of success.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '98',
        text: 'I have the power to create the success I desire.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '99',
        text: 'I am deserving of all the success I achieve.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),
      Affirmation(
        id: '100',
        text: 'Success is my natural state and I embrace it fully.',
        createdAt: DateTime.now(),
        category: 'Success',
      ),

      // Gratitude - 20 affirmations
      Affirmation(
        id: '101',
        text: 'I am grateful for all the abundance in my life.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '102',
        text: 'Thank you for the blessings that flow to me daily.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '103',
        text: 'I appreciate the simple joys and miracles in everyday life.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '104',
        text: 'Gratitude opens my heart to receive more goodness.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '105',
        text: 'I am thankful for the lessons each challenge brings.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '106',
        text: 'My heart is filled with appreciation for all that I have.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '107',
        text: 'I express gratitude for the people who enrich my life.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '108',
        text: 'I am grateful for my body and all it does for me.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '109',
        text: 'I find joy in expressing gratitude for small blessings.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '110',
        text: 'Gratitude transforms my perspective and brightens my day.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '111',
        text: 'I am thankful for the growth opportunities in my life.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '112',
        text: 'I appreciate the beauty and wonder that surrounds me.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '113',
        text: 'I am grateful for this moment and all it contains.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '114',
        text: 'Thank you for the gifts of health, love, and prosperity.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '115',
        text: 'I cultivate an attitude of gratitude throughout my day.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '116',
        text: 'I am grateful for the divine guidance in my life.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '117',
        text: 'Gratitude is the foundation of my abundant mindset.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '118',
        text: 'I thank the universe for always providing what I need.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '119',
        text: 'I start and end each day with a grateful heart.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
      Affirmation(
        id: '120',
        text: 'My life is filled with countless reasons to be thankful.',
        createdAt: DateTime.now(),
        category: 'Gratitude',
      ),
    ];
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
