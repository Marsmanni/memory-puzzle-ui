import '../dtos/api_dtos.dart';
import '../services/auth_http_service.dart';
import '../utils/api_endpoints.dart';
import '../utils/log.dart'; 

// Call this when ending play (e.g., when the puzzle is solved or user exits)
Future<void> logPuzzlePlay({
  required int puzzleId,
  required String user,
  required DateTime startTime,
  required DateTime endTime,
  required int playerCount,
  required int draws,
  required String tileOrder,
  required String drawOrder,
  required String mode,
}) async {
  final comment = 'Players: $playerCount, Draws: $draws, '
      'TileOrder: $tileOrder, DrawOrder: $drawOrder, Mode: $mode';

  final logDto = PuzzleLogDto(
    puzzleId: puzzleId,
    user: user,
    startTime: startTime,
    endTime: endTime,
    mode: mode,
    comment: comment,
  );

  final endpoint = ApiEndpoints.puzzlesLogPuzzle.replaceFirst(
    '{puzzleId}', puzzleId.toString(),
  );

  try {
    final response = await AuthHttpService.post(
      Uri.parse(endpoint),
      logDto.toJson(),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      Log.i('Puzzle play logged successfully.');
    } else {
      Log.w('Failed to log puzzle play: ${response.statusCode}');
    }
  } catch (e) {
    Log.e('Error logging puzzle play: $e');
  }
}