import 'package:flutter/material.dart';
import '../dtos/api_dtos.dart';
import '../services/auth_http_service.dart';
import '../utils/api_endpoints.dart';
import '../utils/app_localizations.dart';
import 'puzzle_admin_card.dart';

class PuzzleAdminList extends StatelessWidget {
  final List<PuzzleAdminDto> puzzles;
  final bool loading;
  final String? error;
  final void Function(void Function()) setState;

  const PuzzleAdminList({
    required this.puzzles,
    required this.loading,
    required this.error,
    required this.setState,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Text(
          error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (puzzles.isEmpty) {
      return Center(
        child: Text(AppLocalizations.get('puzzlePage.noPuzzles')),
      );
    }
    return ListView(
      children: puzzles.map((puzzle) => PuzzleAdminCard(
        puzzle: puzzle,
        onPublicChanged: (value) async {
          setState(() {
            puzzle.isPublic = value ?? false;
          });
          final payload = {'isPublic': value};
          final response = await AuthHttpService.put(
            Uri.parse('${ApiEndpoints.adminUpdatePuzzle}/${puzzle.id}'),
            payload,
          );
          if (response.statusCode != 204) {
            setState(() {
              puzzle.isPublic = !puzzle.isPublic;
            });
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.get('updateError'))),
              );
            }
          }
        },
      )).toList(),
    );
  }
}