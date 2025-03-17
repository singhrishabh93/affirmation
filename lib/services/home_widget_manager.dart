import 'dart:math';
import 'package:home_widget/home_widget.dart';
import '../models/affirmation.dart';
import 'affirmation_service.dart';

class HomeWidgetManager {
  static const String _appGroupId = 'com.beyou.affirmation';
  
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await HomeWidget.registerInteractivityCallback(interactivityCallback);
    await updateWidget();
  }
  
  static Future<void> updateWidget() async {
    try {
      // Get a random affirmation
      final Affirmation affirmation = await AffirmationService.getRandomAffirmation();
      
      // Set widget title and message
      await HomeWidget.saveWidgetData<String>('title', 'BeYou');
      await HomeWidget.saveWidgetData<String>('message', affirmation.text);
      
      // Update the widget
      await _refreshWidget();
    } catch (e) {
      print('Error updating widget: $e');
    }
  }
  
  static Future<void> _refreshWidget() async {
    try {
      await HomeWidget.updateWidget(
        qualifiedAndroidName: 'com.beyou.affirmation.AffirmationWidgetProvider',
      );
    } catch (e) {
      print('Error refreshing widget: $e');
    }
  }
}

/// Called when user interacts with the widget
Future<void> interactivityCallback(Uri? uri) async {
  if (uri?.host == 'titleclicked') {
    final affirmations = await AffirmationService.getAffirmations();
    final randomIndex = Random().nextInt(affirmations.length);
    final selectedAffirmation = affirmations[randomIndex];
    
    await HomeWidget.setAppGroupId('com.beyou.affirmation');
    await HomeWidget.saveWidgetData<String>('message', selectedAffirmation.text);
    
    await HomeWidget.updateWidget(
      qualifiedAndroidName: 'com.beyou.affirmation.AffirmationWidgetProvider',
    );
  }
}