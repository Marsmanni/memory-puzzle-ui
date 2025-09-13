import '../dtos/api_dtos.dart';

class GamePuzzles {
  List<PuzzleDto>? puzzles;
  int selectedPuzzleIndex;

  GamePuzzles({
    this.puzzles,
    required this.selectedPuzzleIndex,
  });

  set setPuzzles(List<PuzzleDto> value) {
    puzzles = value.isNotEmpty ? value : null;
    selectedPuzzleIndex = 0; // Reset to first puzzle when list changes
  }

  set setSelectedPuzzleIndex(int value) => selectedPuzzleIndex = value;

  PuzzleDto? getSelectedPuzzle() {
    if (puzzles != null &&
        selectedPuzzleIndex >= 0 &&
        selectedPuzzleIndex < puzzles!.length) {
      return puzzles![selectedPuzzleIndex];
    }
    return null;
  }
}