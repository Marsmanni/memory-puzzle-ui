import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/game_manager.dart';
import '../models/game_settings.dart';
import '../utils/api_endpoints.dart';
import '../utils/constants.dart';
import 'puzzle_card.dart';

class PuzzleGrid extends StatelessWidget {
  final GameSettings gameSettings;

  const PuzzleGrid({
    required this.gameSettings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final gameManager = Provider.of<GameManager>(context);
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
        final state = gameManager.getCardState(index);

        // image url still might be ''
        final imgUrl = AppConstants.replace(ApiEndpoints.imagesGetById, {
          'id': imgUid,
        });

        //log("Building card $index with image UID: $imgUid and URL: $imgUrl");
        if (state == null) {
          return const SizedBox.shrink();
        }
        else {
          return PuzzleCard(
            key: ValueKey('${gameSettings.selectedAsset}_$index'),
            imgUrl: imgUrl,
            state: state,
            placeholderAsset: gameSettings.selectedAsset,
          );
        }
      },
    );
  }
}