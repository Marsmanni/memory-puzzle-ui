import 'package:flutter/material.dart';

import '../dtos/api_dtos.dart';
import '../models/game_statistics.dart';
import '../models/settings.dart';
import '../utils/app_localizations.dart';
import 'play_settings_menu.dart';

class PlayPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<int> onPuzzleChanged;
  final VoidCallback onReset;
  final ValueChanged<int> onPlayerCountChanged;
  final GameControls control;
  final GameSettings settings;

  const PlayPageAppBar({
    super.key,
    required this.control,
    required this.onPuzzleChanged,
    required this.onReset,
    required this.onPlayerCountChanged,
    required this.settings,
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
              items: control.groups.isNotEmpty
                  ? List.generate(
                      control.groups.length,
                      (i) => DropdownMenuItem(
                        value: control.groups[i],
                        child: Text(control.groups[i].name),
                      ),
                    )
                  : [],
              onChanged: control.groups.isNotEmpty
                  ? (value) {
                      if (value != null) {
                        onPuzzleChanged(control.groups.indexOf(value));
                      }
                    }
                  : null, // disables dropdown if empty
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: onReset,
              child: Text(AppLocalizations.get('playPage.reset')),
            ),
            const SizedBox(width: 16),
            DropdownButton<int>(
              value: control.playerCount,
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
                  onPlayerCountChanged(value);
                }
              },
            ),
            const SizedBox(width: 16),
            ...List.generate(
              control.playerCount,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text(
                    'P${i + 1}: ${control.moves[i]} ${AppLocalizations.get('playPage.moves')}, ${control.matches[i]} ${AppLocalizations.get('playPage.matches')}${control.currentPlayer == i ? " ←" : ""}',
                    style: TextStyle(
                      fontWeight: control.currentPlayer == i
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  backgroundColor: control.currentPlayer == i
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