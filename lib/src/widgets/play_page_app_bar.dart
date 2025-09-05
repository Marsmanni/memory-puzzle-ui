import 'package:flutter/material.dart';
import '../dtos/api_dtos.dart';
import '../utils/app_localizations.dart';
import 'play_settings_menu.dart';

class PlayPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<PuzzleDto> groups;
  final int selectedPuzzleIndex;
  final ValueChanged<int> onPuzzleChanged;
  final VoidCallback onReset;
  final int playerCount;
  final ValueChanged<int> onPlayerCountChanged;
  final List<int> moves;
  final List<int> matches;
  final int currentPlayer;
  final int selectedPlaceholderIndex;
  final List<Map<String, String>> placeholders;
  final ValueChanged<int> onPlaceholderChanged;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;

  const PlayPageAppBar({
    super.key,
    required this.groups,
    required this.selectedPuzzleIndex,
    required this.onPuzzleChanged,
    required this.onReset,
    required this.playerCount,
    required this.onPlayerCountChanged,
    required this.moves,
    required this.matches,
    required this.currentPlayer,
    required this.selectedPlaceholderIndex,
    required this.placeholders,
    required this.onPlaceholderChanged,
    required this.languageCode,
    required this.onLanguageChanged,
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
              value: (groups.isNotEmpty && selectedPuzzleIndex >= 0 && selectedPuzzleIndex < groups.length)
                  ? groups[selectedPuzzleIndex]
                  : null,
              items: groups.isNotEmpty
                  ? List.generate(
                      groups.length,
                      (i) => DropdownMenuItem(
                        value: groups[i],
                        child: Text(groups[i].name),
                      ),
                    )
                  : [],
              onChanged: groups.isNotEmpty
                  ? (value) {
                      if (value != null) {
                        onPuzzleChanged(groups.indexOf(value));
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
              value: playerCount,
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
              playerCount,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text(
                    'P${i + 1}: ${moves[i]} ${AppLocalizations.get('playPage.moves')}, ${matches[i]} ${AppLocalizations.get('playPage.matches')}${currentPlayer == i ? " ←" : ""}',
                    style: TextStyle(
                      fontWeight: currentPlayer == i
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  backgroundColor: currentPlayer == i
                      ? Colors.blue[100]
                      : Colors.grey[200],
                ),
              ),
            ),
            const SizedBox(width: 16),
            PlaySettingsMenu(
              selectedPlaceholderIndex: selectedPlaceholderIndex,
              placeholders: placeholders,
              onPlaceholderChanged: onPlaceholderChanged,
              languageCode: languageCode,
              onLanguageChanged: onLanguageChanged,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}