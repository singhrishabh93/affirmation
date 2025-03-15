import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/affirmation.dart';

class AffirmationCard extends StatelessWidget {
  final Affirmation affirmation;
  final VoidCallback onFavoriteToggle;
  final bool showActions;

  const AffirmationCard({
    Key? key,
    required this.affirmation,
    required this.onFavoriteToggle,
    this.showActions = true,
  }) : super(key: key);

  void _shareAffirmation() {
    Share.share(affirmation.text);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (affirmation.category != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD5EAE4).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  affirmation.category!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Text(
              affirmation.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            if (showActions)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: _shareAffirmation,
                      color: Colors.black54,
                      tooltip: 'Share',
                    ),
                    IconButton(
                      icon: Icon(
                        affirmation.isFavorite 
                            ? Icons.favorite 
                            : Icons.favorite_border,
                      ),
                      onPressed: onFavoriteToggle,
                      color: affirmation.isFavorite ? Colors.red : Colors.black54,
                      tooltip: affirmation.isFavorite 
                          ? 'Remove from favorites' 
                          : 'Add to favorites',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}