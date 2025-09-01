import 'package:flutter/material.dart';
import '../dtos/api_dtos.dart';
import '../utils/app_localizations.dart';

class PuzzleAdminCard extends StatelessWidget {
  final PuzzleAdminDto puzzle;
  final void Function(bool?) onPublicChanged;

  const PuzzleAdminCard({
    required this.puzzle,
    required this.onPublicChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(puzzle.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppLocalizations.get('puzzleAdminCard.author')}: ${puzzle.creator}'),
            Text('${AppLocalizations.get('puzzleAdminCard.images')}: ${puzzle.imageCount}'),
            Row(
              children: [
                Text('${AppLocalizations.get('puzzleAdminCard.public')}: '),
                Checkbox(
                  value: puzzle.isPublic,
                  onChanged: onPublicChanged,
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          '${AppLocalizations.get('puzzleAdminCard.id')}: ${puzzle.id}\n'
          '${puzzle.creationTime.toLocal()}',
        ),
      ),
    );
  }
}