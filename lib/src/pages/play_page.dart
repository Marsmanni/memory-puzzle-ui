import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dtos/api_dtos.dart';
import '../models/game_settings.dart';
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
  State<PlayPage> createState() => PlayPageState();
}

/// State class for PlayPage.
/// Handles game initialization, settings changes, loading overlays, and congratulation logic.
class PlayPageState extends State<PlayPage> {
  // --- Services & Managers ---
  final ApiService _apiService = ApiService();
  final AuthInfo _authInfo = AuthInfo();
  //late final GameSettings gameSettings;

  // --- UI State ---
  bool _loading = false;
  String? _error;
  bool _congratulationShown = false;

  GameManager get gameManager => Provider.of<GameManager>(context, listen: false);

  // --- Lifecycle ---
  @override
  void initState() {
    super.initState();

    gameManager.addListener(_checkGameFinished);
    gameManager.gameSettings.onSettingChanged = _onSettingsChanged;
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  // Preload assets and fetch puzzle data after first frame
    // Preload assets and fetch puzzle data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadPlaceholders();
      fetchGroupsAndImages();
    });
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
        });
        break;
      case GameSettings.keyPlaceholderChanged:
        setState(() {});
        break;
      default:
        break;
    }
  }

  void _onControlsChanged(String key, dynamic value) {
    switch (key) {
      case PlayPageAppBar.keyPuzzleChanged:
        if (value is int) {
          gameManager.gamePuzzles.setSelectedPuzzleIndex = value;
          //var selectedPuzzle = gameManager.gamePuzzles.getSelectedPuzzle();
          _initializeGame();
           //_congratulationShown = false;
        }
        break;
      case PlayPageAppBar.keyPlayerCountChanged:
        if (value is int) {
          setState(() {
            gameManager.playerStats.playerCount = value;
          });
          _initializeGame();
        }
        break;
      case PlayPageAppBar.keyReset:
        _initializeGame();
        break;
      default:
        break;
    }
  }

  // --- Game Finished Check ---
  void _checkGameFinished() {
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
    for (final placeholder in gameManager.gameSettings.placeholders) {
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
  Future<void> fetchGroupsAndImages() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final jwt = await AuthHelper.getJwt();
      final isLoggedIn = jwt != null && jwt.isNotEmpty;

      final puzzles = isLoggedIn 
          ? await _apiService.fetchPuzzlesByUser()
          : await _apiService.fetchPuzzlesDefaults();

      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      if (puzzles.isNotEmpty) {
        gameManager.gamePuzzles.puzzles = puzzles;
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
    if (gameManager.gamePuzzles.puzzles!.isEmpty) return;
    PuzzleDto? selectedPuzzle = gameManager.gamePuzzles.getSelectedPuzzle();

    _precacheImages(selectedPuzzle);

    gameManager.initializeGame(
      puzzle: selectedPuzzle,
      currentUser: _authInfo.user ?? 'Guest',
    );
    setState(() {
      _congratulationShown = false;
    });
  }

  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    if (gameManager.gamePuzzles.getSelectedPuzzle() == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: PlayPageAppBar(
        onControlChanged: (key, value) { _onControlsChanged(key, value); },
      ),
      body: Stack(
        children: [
          _error != null
              ? Center(child: Text(_error!))
              : PuzzleGrid(
                  key: ValueKey(gameManager.gameSettings.selectedAsset),
                  gameSettings: gameManager.gameSettings,
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

