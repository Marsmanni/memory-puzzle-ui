import 'package:flutter/material.dart';

import '../dtos/api_dtos.dart';
import '../models/game_statistics.dart';
import '../models/game_settings.dart';
import '../utils/app_localizations.dart';
import 'play_settings_menu.dart';

class PlayPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  // --- Static keys for onControlChanged ---
  static const String keyPuzzleChanged = "puzzleChanged";
  static const String keyPlayerCountChanged = "playerCountChanged";
  static const String keyReset = "reset";

  final GameControls control;
  final GameSettings settings;
  final void Function(dynamic key, dynamic value) onControlChanged;

  const PlayPageAppBar({
    super.key,
    required this.control,
    required this.settings,
    required this.onControlChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(AppLocalizations.get('playPage.title')),
            const SizedBox(width: 16),
            DropdownButton<PuzzleDto>(
              value: control.getSelectedPuzzle(),
              items: control.puzzles!.isNotEmpty
                  ? List.generate(
                      control.puzzles!.length,
                      (i) => DropdownMenuItem(
                        value: control.puzzles![i],
                        child: Text(control.puzzles![i].name),
                      ),
                    )
                  : [],
              onChanged: control.puzzles!.isNotEmpty
                  ? (value) {
                      if (value != null) {
                        onControlChanged(keyPuzzleChanged, control.puzzles!.indexOf(value));
                      }
                    }
                  : null, // disables dropdown if empty
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => onControlChanged(keyReset, null),
              child: Text(AppLocalizations.get('playPage.reset')),
            ),
            const SizedBox(width: 16),
            DropdownButton<int>(
              value: control.playerStats.playerCount,
              items: [1, 2, 3]
                  .map(
                    (count) => DropdownMenuItem(
                      value: count,
                      child: Text(
                        '$count ${AppLocalizations.get(count > 1 ? 'playPage.players' : 'playPage.player')}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onControlChanged(keyPlayerCountChanged, value);
                }
              },
            ),
            const SizedBox(width: 16),
            ...List.generate(
              control.playerStats.playerCount,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text(
                    'P${i + 1}: ${control.playerStats.moves[i]} ${AppLocalizations.get('playPage.moves')}, ${control.playerStats.matches[i]} ${AppLocalizations.get('playPage.matches')}${control.playerStats.currentPlayer == i ? " ←" : ""}',
                    style: TextStyle(
                      fontWeight: control.playerStats.currentPlayer == i
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  backgroundColor: control.playerStats.currentPlayer == i
                      ? Colors.blue[100]
                      : Colors.grey[200],
                ),
              ),
            ),
            const SizedBox(width: 16),
            PlaySettingsMenu(
              settings: settings,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}