// lib/services/music_service.dart
import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;
  String? _currentCategory;
  
  Future<void> initialize() async {
    // Set initial volume
    await _audioPlayer.setVolume(0.5);
  }
  
  Future<void> playMusicForCategory(String category) async {
    if (_currentCategory == category) return;
    
    _currentCategory = category;
    
    // Stop any currently playing music
    await _audioPlayer.stop();
    
    // Skip playing if muted
    if (_isMuted) return;
    
    String musicAsset;
    
    // Select music based on category
    switch (category.toLowerCase()) {
      case 'confidence':
        musicAsset = 'pure-love-304010.mp3';
        break;
      case 'abundance':
        musicAsset = 'pure-love-304010.mp3';
        break;
      case 'love':
        musicAsset = 'pure-love-304010.mp3';
        break;
      case 'gratitude':
        musicAsset = 'pure-love-304010.mp3';
        break;
      case 'success':
        musicAsset = 'pure-love-304010.mp3';
        break;
      case 'favorites':
        musicAsset = 'pure-love-304010.mp3';
        break;
      case 'general':
      default:
        musicAsset = 'pure-love-304010.mp3';
    }
    
    // Play selected music on loop
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setSource(AssetSource(musicAsset.replaceAll("assets/", "")));
    await _audioPlayer.resume();
  }
  
  Future<bool> toggleMute() async {
  _isMuted = !_isMuted;
  
  if (_isMuted) {
    await _audioPlayer.pause();
  } else {
    if (_currentCategory != null) {
      await _audioPlayer.resume();
    }
  }
  
  return _isMuted;
}
  
  bool get isMuted => _isMuted;
  
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}