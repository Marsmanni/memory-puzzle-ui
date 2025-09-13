import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dtos/api_dtos.dart';
import '../models/game_statistics.dart';
import '../models/settings.dart';
import '../services/auth_helper.dart';
import '../services/api_service.dart';
import '../services/game_manager.dart';
import '../utils/api_endpoints.dart';
import '../utils/app_localizations.dart';
import '../utils/constants.dart';
import '../widgets/play_page_app_bar.dart';
import '../widgets/puzzle_grid.dart';

/// Main PlayPage widget for the Memory Puzzle game.
class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

/// State class for PlayPage.
/// Handles game initialization, settings changes, loading overlays, and congratulation logic.
class _PlayPageState extends State<PlayPage> {
  // --- Services & Managers ---
  final ApiService _apiService = ApiService();
  final AuthInfo _authInfo = AuthInfo();
  late final GameSettings gameSettings;
  late final GameManager gameManager;
  late final GameControls gameStatistics;

  // --- UI State ---
  bool _loading = false;
  String? _error;
  bool _congratulationShown = false;

  // --- Lifecycle ---
  @override
  void initState() {
    super.initState();

    // Get GameManager from Provider
    gameManager = Provider.of<GameManager>(context);

    // Initialize game settings
    gameSettings = GameSettings(
      languageCode: 'de',
      isSoundMuted: true,
      selectedPlaceholderIndex: 0,
    );

    // Listen for settings changes
    gameSettings.onSettingChanged = _onSettingsChanged;

    // Initialize game statistics
    gameStatistics = GameControls(
      puzzles: [],
      selectedPuzzleIndex: -1,
      playerCount: gameManager.playerStats.playerCount,
      moves: gameManager.playerStats.moves,
      matches: gameManager.playerStats.matches,
      currentPlayer: gameManager.playerStats.currentPlayer,
    );

    // Preload assets and fetch puzzle data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadPlaceholders();
      _fetchGroupsAndImages();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameManager = Provider.of<GameManager>(context);
    gameManager.addListener(_checkGameFinished);
  }

  // --- Settings Change Handler ---
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
        setState(() {});
        break;
      default:
        break;
    }
  }

  // --- Game Finished Check ---
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

  // --- Asset Preloading ---
  void _preloadPlaceholders() {
    for (final placeholder in gameSettings.placeholders) {
      precacheImage(
        AssetImage('${placeholder['asset']}'),
        context,
      );
    }
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

  // --- Data Fetching ---
  Future<void> _fetchGroupsAndImages() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final puzzles = await _apiService.fetchPuzzlesDefaults();
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      if (puzzles.isNotEmpty) {
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

  // --- Game Initialization ---
  void _initializeGame() {
    gameManager.initializeGame(
      puzzle: gameStatistics.getSelectedPuzzle(),
      currentUser: _authInfo.user ?? 'Guest',
    );
    _precacheImages(gameStatistics.getSelectedPuzzle());
  }

  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlayPageAppBar(
        control: gameStatistics,
        settings: gameSettings,
        onReset: () => _initializeGame(),
        onPlayerCountChanged: (count) {
          gameManager.onPlayerCountChanged(count);
          _initializeGame();
        },
        onPuzzleChanged: (index) {
          setState(() {
            gameStatistics.selectedPuzzleIndex = index;
          });
          () => _initializeGame();
        },
      ),
      body: Stack(
        children: [
          _error != null
              ? Center(child: Text(_error!))
              : PuzzleGrid(
                  key: ValueKey(gameSettings.selectedAsset),
                  gameManager: gameManager,
                  gameSettings: gameSettings,
                ),
          PlayPageLoadingOverlay(loading: _loading),
        ],
      ),
    );
  }
}

/// Loading overlay widget for PlayPage.
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

