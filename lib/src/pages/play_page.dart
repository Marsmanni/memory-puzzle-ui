import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dtos/api_dtos.dart';
import '../models/game_statistics.dart';
import '../models/settings.dart';
import '../services/api_service.dart';
import '../services/game_manager.dart';
import '../utils/api_endpoints.dart';
import '../utils/app_localizations.dart';
import '../utils/constants.dart';
import '../widgets/play_page_app_bar.dart';
import '../widgets/puzzle_card.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  final ApiService _apiService = ApiService();

  late final GameSettings settings;

  List<PuzzleDto> _groups = [];
  int _selectedPuzzleIndex = 0;
  bool _loading = false;
  String? _error;
  bool _congratulationShown = false;

  @override
  void initState() {
    super.initState();
    settings = GameSettings(
      languageCode: 'de',
      isSoundMuted: true,
      selectedPlaceholderIndex: 0,
    );
    settings.onSettingChanged = _onSettingsChanged;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadPlaceholders();
      _fetchGroupsAndImages();
    });
  }

  void _onSettingsChanged(String key, dynamic value) {
    switch (key) {
      case GameSettings.keyLanguageChanged:
        setState(() {
          AppLocalizations.setLanguage(value as String);
        });
        break;
      case GameSettings.keySoundChanged:
        setState(() {
          final gameManager = Provider.of<GameManager>(context, listen: false);
          gameManager.isSoundMuted = value as bool;
        });
        break;
      case GameSettings.keyPlaceholderChanged:
        setState(() {
        });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameManager = Provider.of<GameManager>(context);

    final gameStatistics = GameControls(
      groups: _groups,
      selectedPuzzleIndex: _selectedPuzzleIndex,
      playerCount: gameManager.playerStats.playerCount,
      moves: gameManager.playerStats.moves,
      matches: gameManager.playerStats.matches,
      currentPlayer: gameManager.playerStats.currentPlayer,
    );

    return Scaffold(
      appBar: PlayPageAppBar(
        control: gameStatistics,
        settings: settings,
        onReset: _initializeGame,
        onPlayerCountChanged: (count) {
          gameManager.onPlayerCountChanged(count);
          _initializeGame();
        },
        onPuzzleChanged: (index) {
          setState(() {
            _selectedPuzzleIndex = index;
          });
          _initializeGame();
        },
      ),
      body: Stack(
        children: [
          _error != null
              ? Center(child: Text(_error!))
              : PuzzleGrid(
                  key: ValueKey(settings.selectedAsset),
                  gameManager: gameManager,
                  gameSettings: settings,
                ),
          PlayPageLoadingOverlay(loading: _loading),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameManager = Provider.of<GameManager>(context);
    gameManager.addListener(_checkGameFinished);
  }
    
  void _checkGameFinished() {
    final gameManager = Provider.of<GameManager>(context, listen: false);
    if (gameManager.isGameFinished && !_congratulationShown) {
      setState(() {
        _congratulationShown = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.get('playPage.congratulations')),
          backgroundColor: Colors.green,
        ),
      );
    }
    // Reset the flag if a new game starts
    if (!gameManager.isGameFinished && _congratulationShown) {
      setState(() {
        _congratulationShown = false;
      });
    }
  }

  void _preloadPlaceholders() {
    for (final placeholder in settings.placeholders) {
      precacheImage(
        AssetImage('${placeholder['asset']}'),
        context,
      );
    }
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
        _error = null;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.get('playPage.backendNotAvailable')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _initializeGame() {
    final gameManager = Provider.of<GameManager>(context, listen: false);
    final selectedPuzzle = (_selectedPuzzleIndex >= 0 && _groups.isNotEmpty)
        ? _groups[_selectedPuzzleIndex]
        : null;
    gameManager.initializeGame(
      selectedPuzzle?.images ?? [],
      puzzleId: selectedPuzzle?.id ?? 0,
      currentUser: '',
    );
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
  final GameSettings gameSettings;

  const PuzzleGrid({
    required this.gameManager,
    required this.gameSettings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (gameManager.isGridEmpty) {
      return Container();
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: gameManager.imageCount * 2,
      itemBuilder: (context, index) {
        final imgUid = gameManager.getShuffledImageUid(index);
        final imgUrl = AppConstants.replace(ApiEndpoints.imagesGetById, {
          'id': imgUid,
        });
        return PuzzleCard(
          key: ValueKey('${gameSettings.selectedAsset}_$index'),
          imgUrl: imgUrl,
          state: gameManager.getCardState(index),
          placeholderAsset: gameSettings.selectedAsset,
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
        color: const Color.fromRGBO(0, 0, 0, 0.6),
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

