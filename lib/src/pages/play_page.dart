import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dtos/api_dtos.dart';
import '../services/api_service.dart';
import '../services/game_manager.dart';
import '../utils/constants.dart';
import '../utils/api_endpoints.dart';
import 'puzzle_card.dart';
import '../widgets/play_settings_menu.dart';
import '../utils/app_localizations.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  final ApiService _apiService = ApiService();
  final List<Map<String, String>> _placeholders = [
    {'key': 'placeholder_himmel', 'asset': 'assets/placeholder1.png'},
    {'key': 'placeholder_puzzle', 'asset': 'assets/placeholder2.png'},
    {'key': 'placeholder_wiese', 'asset': 'assets/placeholder3.png'},
    {'key': 'placeholder_smiley', 'asset': 'assets/placeholder0.png'},
  ];
  int _selectedPlaceholderIndex = 0;
  List<PuzzleDto> _groups = [];
  int _selectedPuzzleIndex = 0;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGroupsAndImages();
  }

  Future<void> _fetchGroupsAndImages() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final puzzles = await _apiService.fetchPuzzlesDefaults();
      if (!mounted) return;
      setState(() {
        _groups = puzzles;
        _selectedPuzzleIndex = puzzles.isNotEmpty ? 0 : -1;
        _loading = false;
      });
      if (_selectedPuzzleIndex >= 0 && _groups.isNotEmpty) {
        _initializeGame();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  void _initializeGame() {
    final gameManager = Provider.of<GameManager>(context, listen: false);
    final selectedPuzzle = (_selectedPuzzleIndex >= 0 && _groups.isNotEmpty)
        ? _groups[_selectedPuzzleIndex]
        : null;
    gameManager.initializeGame(selectedPuzzle?.images ?? []);
    _precacheImages(selectedPuzzle);
  }

  void _precacheImages(PuzzleDto? selectedPuzzle) {
    final images = selectedPuzzle?.images ?? [];
    for (final img in images) {
      final imgUrl = AppConstants.replace(ApiEndpoints.imagesGetById, {'id': img.imageUid});
      precacheImage(NetworkImage(imgUrl), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameManager = Provider.of<GameManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text('Play'),
              const SizedBox(width: 16),
              DropdownButton<PuzzleDto>(
                value: _selectedPuzzleIndex >= 0 ? _groups[_selectedPuzzleIndex] : null,
                items: List.generate(_groups.length, (i) => DropdownMenuItem(
                  value: _groups[i],
                  child: Text(_groups[i].name),
                )),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPuzzleIndex = _groups.indexOf(value);
                    });
                    _initializeGame();
                  }
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _initializeGame(),
                child: const Text('Reset'),
              ),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: gameManager.playerCount,
                items: [1, 2, 3].map((count) => DropdownMenuItem(
                  value: count,
                  child: Text('$count Player${count > 1 ? 's' : ''}'),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    gameManager.onPlayerCountChanged(value);
                    _initializeGame();
                  }
                },
              ),
              const SizedBox(width: 16),
              ...List.generate(gameManager.playerCount, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text(
                    'P${i + 1}: ${gameManager.moves[i]} moves, ${gameManager.matches[i]} matches${gameManager.currentPlayer == i ? " ←" : ""}',
                    style: TextStyle(
                      fontWeight: gameManager.currentPlayer == i ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  backgroundColor: gameManager.currentPlayer == i ? Colors.blue[100] : Colors.grey[200],
                ),
              )),
              const SizedBox(width: 16),
              PlaySettingsMenu(
                selectedPlaceholderIndex: _selectedPlaceholderIndex,
                placeholders: _placeholders,
                onPlaceholderChanged: (index) {
                  setState(() {
                    _selectedPlaceholderIndex = index;
                  });
                },
                languageCode: AppLocalizations.languageCode,
                onLanguageChanged: (code) {
                  setState(() {
                    AppLocalizations.setLanguage(code);
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: gameManager.images.length * 2,
                  itemBuilder: (context, index) {
                    if (gameManager.shuffledIndexes.isEmpty || gameManager.images.isEmpty) {
                      return Container(); // Safety check
                    }
                    final imgUid = gameManager.images[gameManager.shuffledIndexes[index]].imageUid;
                    final imgUrl = AppConstants.replace(ApiEndpoints.imagesGetById, {'id': imgUid});
                    
                    return PuzzleCard(
                      imgUrl: imgUrl,
                      isMatched: gameManager.matchedIndexes.contains(index),
                      isFlipped: gameManager.flipped[index],
                      isDisabled: gameManager.isCardDisabled(index),
                      onTap: () => gameManager.onCardTap(index),
                      placeholderAsset: _placeholders[_selectedPlaceholderIndex]['asset']!,
                    );
                  },
                ),
    );
  }
}