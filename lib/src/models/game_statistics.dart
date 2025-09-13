import '../dtos/api_dtos.dart';

class GameControls {
  List<PuzzleDto>? puzzles;
  int selectedPuzzleIndex;
  final int playerCount;
  final List<int> moves;
  final List<int> matches;
  final int currentPlayer;

  GameControls({
    required this.puzzles,
    required this.selectedPuzzleIndex,
    required this.playerCount,
    required this.moves,
    required this.matches,
    required this.currentPlayer,
  });

  set setPuzzles(List<PuzzleDto> value) => puzzles = value;
  set setSelectedPuzzleIndex(int value) => selectedPuzzleIndex = value;

  PuzzleDto? getSelectedPuzzle() {
    if (puzzles.isNotEmpty &&
        selectedPuzzleIndex >= 0 &&
        selectedPuzzleIndex < puzzles.length) {
      return puzzles[selectedPuzzleIndex];
    }
    return null;
  }
}