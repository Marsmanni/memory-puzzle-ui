import 'package:wunderwelt_memory/src/models/player_stats.dart';

import '../dtos/api_dtos.dart';

class GameControls {
  List<PuzzleDto>? puzzles;
  int selectedPuzzleIndex;
  PlayerStats playerStats = PlayerStats();

  GameControls({
    this.puzzles,
    required this.selectedPuzzleIndex,
    required this.playerStats,
  });

  set setPuzzles(List<PuzzleDto> value) => puzzles = value;
  set setSelectedPuzzleIndex(int value) => selectedPuzzleIndex = value;

  PuzzleDto? getSelectedPuzzle() {
    if (puzzles!.isNotEmpty &&
        selectedPuzzleIndex >= 0 &&
        selectedPuzzleIndex < puzzles!.length) {
      return puzzles![selectedPuzzleIndex];
    }
    return null;
  }
}