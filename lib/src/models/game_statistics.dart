import '../dtos/api_dtos.dart';

class GameControls {
  final List<PuzzleDto> groups;
  final int selectedPuzzleIndex;
  final int playerCount;
  final List<int> moves;
  final List<int> matches;
  final int currentPlayer;

  GameControls({
    required this.groups,
    required this.selectedPuzzleIndex,
    required this.playerCount,
    required this.moves,
    required this.matches,
    required this.currentPlayer,
  });

  PuzzleDto? getSelectedPuzzle() {
    if (groups.isNotEmpty &&
        selectedPuzzleIndex >= 0 &&
        selectedPuzzleIndex < groups.length) {
      return groups[selectedPuzzleIndex];
    }
    return null;
  }
}