import 'package:flutter/material.dart';

import '../services/game_manager.dart';
import '../models/settings.dart';
import '../utils/api_endpoints.dart';
import '../utils/constants.dart';
import 'puzzle_card.dart';

class PuzzleGrid extends StatelessWidget {
  final GameManager gameManager;
  final GameSettings gameSettings;

  const PuzzleGrid({
    required this.gameManager,
    required this.gameSettings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (gameManager.isGridEmpty) {
      return Container();
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: gameManager.imageCount * 2,
      itemBuilder: (context, index) {
        final imgUid = gameManager.getShuffledImageUid(index);
        final imgUrl = AppConstants.replace(ApiEndpoints.imagesGetById, {
          'id': imgUid,
        });
        return PuzzleCard(
          key: ValueKey('${gameSettings.selectedAsset}_$index'),
          imgUrl: imgUrl,
          state: gameManager.getCardState(index),
          placeholderAsset: gameSettings.selectedAsset,
        );
      },
    );
  }
}