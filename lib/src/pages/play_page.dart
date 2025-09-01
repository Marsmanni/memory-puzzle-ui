import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dtos/api_dtos.dart';
import '../services/api_service.dart';
import '../services/game_manager.dart';
import '../utils/api_endpoints.dart';
import '../utils/app_localizations.dart';
import '../utils/constants.dart';
import '../widgets/play_page_app_bar.dart';
import 'puzzle_card.dart';

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
  Widget build(BuildContext context) {
    final gameManager = Provider.of<GameManager>(context);

    return Scaffold(
      appBar: PlayPageAppBar(
        groups: _groups,
        selectedPuzzleIndex: _selectedPuzzleIndex,
        onPuzzleChanged: (index) {
          setState(() {
            _selectedPuzzleIndex = index;
          });
          _initializeGame();
        },
        onReset: _initializeGame,
        playerCount: gameManager.playerCount,
        onPlayerCountChanged: (count) {
          gameManager.onPlayerCountChanged(count);
          _initializeGame();
        },
        moves: gameManager.moves,
        matches: gameManager.matches,
        currentPlayer: gameManager.currentPlayer,
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
      body: Stack(
        children: [
          // Main content
          _error != null
              ? Center(child: Text(_error!))
              : PuzzleGrid(
                  gameManager: gameManager,
                  placeholders: _placeholders,
                  selectedPlaceholderIndex: _selectedPlaceholderIndex,
                ),
          // Intro overlay
          PlayPageLoadingOverlay(loading: _loading),
        ],
      ),
    );
  }

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
      final imgUrl = AppConstants.replace(ApiEndpoints.imagesGetById, {
        'id': img.imageUid,
      });
      precacheImage(NetworkImage(imgUrl), context);
    }
  }
}

class PuzzleGrid extends StatelessWidget {
  final GameManager gameManager;
  final List<Map<String, String>> placeholders;
  final int selectedPlaceholderIndex;

  const PuzzleGrid({
    required this.gameManager,
    required this.placeholders,
    required this.selectedPlaceholderIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: gameManager.images.length * 2,
      itemBuilder: (context, index) {
        if (gameManager.shuffledIndexes.isEmpty || gameManager.images.isEmpty) {
          return Container();
        }
        final imgUid = gameManager.images[gameManager.shuffledIndexes[index]].imageUid;
        final imgUrl = AppConstants.replace(
          ApiEndpoints.imagesGetById,
          {'id': imgUid},
        );
        return PuzzleCard(
          imgUrl: imgUrl,
          isMatched: gameManager.matchedIndexes.contains(index),
          isFlipped: gameManager.flipped[index],
          isDisabled: gameManager.isCardDisabled(index),
          onTap: () => gameManager.onCardTap(index),
          placeholderAsset: placeholders[selectedPlaceholderIndex]['asset']!,
        );
      },
    );
  }
}

class PlayPageLoadingOverlay extends StatelessWidget {
  final bool loading;
  const PlayPageLoadingOverlay({required this.loading, super.key});

  @override
  Widget build(BuildContext context) {
    if (!loading) return const SizedBox.shrink();
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.get('playPage.introLoading'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
