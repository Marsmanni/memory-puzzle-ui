import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wunderwelt_memory/src/services/game_manager.dart';

import '../dtos/api_dtos.dart';
import '../utils/app_localizations.dart';
import 'play_settings_menu.dart';

class PlayPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  // --- Static keys for onControlChanged ---
  static const String keyPuzzleChanged = "puzzleChanged";
  static const String keyPlayerCountChanged = "playerCountChanged";
  static const String keyReset = "reset";

  final void Function(dynamic key, dynamic value) onControlChanged;

  const PlayPageAppBar({
    super.key,
    required this.onControlChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) => AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(AppLocalizations.get('playPage.title')),
              const SizedBox(width: 16),
              DropdownButton<PuzzleDto>(
                value: gameManager.gamePuzzles.getSelectedPuzzle(),
                items: gameManager.gamePuzzles.puzzles!.isNotEmpty
                    ? List.generate(
                        gameManager.gamePuzzles.puzzles!.length,
                        (i) => DropdownMenuItem(
                          value: gameManager.gamePuzzles.puzzles![i],
                          child: Text(gameManager.gamePuzzles.puzzles![i].name),
                        ),
                      )
                    : [],
                onChanged: gameManager.gamePuzzles.puzzles!.isNotEmpty
                    ? (value) {
                        if (value != null) {
                          onControlChanged(keyPuzzleChanged, gameManager.gamePuzzles.puzzles!.indexOf(value));
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
                value: gameManager.playerStats.playerCount,
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
                gameManager.playerStats.playerCount,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Chip(
                    label: Text(
                      'P${i + 1}: ${gameManager.playerStats.moves[i]} ${AppLocalizations.get('playPage.moves')}, ${gameManager.playerStats.matches[i]} ${AppLocalizations.get('playPage.matches')}${gameManager.playerStats.currentPlayer == i ? " ←" : ""}',
                      style: TextStyle(
                        fontWeight: gameManager.playerStats.currentPlayer == i
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    backgroundColor: gameManager.playerStats.currentPlayer == i
                        ? Colors.blue[100]
                        : Colors.grey[200],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              PlaySettingsMenu(
                settings: gameManager.gameSettings,
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  gameManager.gameSettings.isSoundMuted ? Icons.volume_off : Icons.volume_up,
                  color: gameManager.gameSettings.isSoundMuted ? Colors.red : Colors.green,
                ),
                tooltip: gameManager.gameSettings.isSoundMuted
                    ? AppLocalizations.get('playPage.soundOff')
                    : AppLocalizations.get('playPage.soundOn'),
                onPressed: () {
                  gameManager.gameSettings.isSoundMuted = !gameManager.gameSettings.isSoundMuted;
                  // Optionally, call notifyListeners() in the setter if not already done
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}