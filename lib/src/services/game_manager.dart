import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../dtos/api_dtos.dart';
import '../models/card_state.dart';
import '../models/player_stats.dart';
import '../services/log_puzzle_play.dart';
import '../utils/log.dart';

/// Manages the state and logic for the memory puzzle game.
class GameManager extends ChangeNotifier {
  // --- Player state ---
  final PlayerStats _playerStats = PlayerStats();

  // --- Game state ---
  late PuzzleDto _puzzle;
  late List<bool> _flipped;
  List<int>? _shuffledIndexes;
  final List<int> _selectedIndexes = [];
  final Set<int> _matchedIndexes = {};
  bool _isProcessingMove = false;

  // --- Sound ---
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundMuted = true; // Default: Off

  // --- Logging ---
  DateTime? _playStartTime;
  int? _puzzleId;
  String? _currentUser;
  String _mode = 'standard';
  List<int> _drawOrder = [];

  // --- Getters for UI ---
  PlayerStats get playerStats => _playerStats;
  int get imageCount => _puzzle.images.length;
  bool get isGameFinished => (_flipped.isNotEmpty && _matchedIndexes.length == _flipped.length);
  bool get isGridEmpty => (_shuffledIndexes == null || _shuffledIndexes!.isEmpty) || _puzzle.images.isEmpty;

  set isSoundMuted(bool value) {
    if (_isSoundMuted != value) {
      _isSoundMuted = value;
      notifyListeners();
    }
  }

  /// Returns true if the card at [index] should be disabled.
  bool isCardDisabled(int index) {
    return _isProcessingMove || _flipped[index] || _matchedIndexes.contains(index);
  }

  /// Returns the image UID for the shuffled card at [index].
  String getShuffledImageUid(int index) {
    return getShuffledImage(index)?.imageUid ?? '';
  }

  /// Returns the shuffled [PuzzleImageDto] for the card at [index].
  PuzzleImageDto? getShuffledImage(int index) {
    if (_shuffledIndexes == null || _shuffledIndexes!.isEmpty || _puzzle.images.isEmpty) return null;
    final imgIndex = _shuffledIndexes![index];
    if (imgIndex < 0 || imgIndex >= _puzzle.images.length) return null;
    return _puzzle.images[imgIndex];
  }

  /// Returns the [CardState] for the card at [index].
  CardState getCardState(int index) {
    return CardState(
      isMatched: _matchedIndexes.contains(index),
      isFlipped: _flipped[index],
      isDisabled: isCardDisabled(index),
      onTap: () => onCardTap(index),
    );
  }

  /// Constructor
  GameManager();
   
  // --- Game initialization & reset ---

  /// Initializes a new game with the given images and parameters.
  void initializeGame(
  {
    PuzzleDto? puzzle,
    required String currentUser,
    String mode = 'standard', 
  }) {
    _flipped = List<bool>.filled(_puzzle.images.length * 2, false);
    _shuffledIndexes = List<int>.generate(_puzzle.images.length * 2, (i) => i % _puzzle.images.length);
    _shuffledIndexes!.shuffle(Random());
    _selectedIndexes.clear();
    _matchedIndexes.clear();
    _isProcessingMove = false;
    _playerStats.currentPlayer = 0;
    _playStartTime = DateTime.now();
    _currentUser = currentUser;
    _mode = mode;
    _drawOrder = [];
    notifyListeners();
  }

  /// Resets the game. Call initializeGame from UI to reset and start a new game.
  void resetGame() {
    // Implement if needed
  }

  /// Updates the player count and resets player stats.
  void onPlayerCountChanged(int count) {
    _playerStats.playerCount = count;
    notifyListeners();
  }

  // --- Card interaction logic ---

  /// Handles a card tap at [index].
  void onCardTap(int index) async {
    if (_isProcessingMove || _flipped[index] || _matchedIndexes.contains(index) || _selectedIndexes.length == 2) {
      return;
    }

    _flipped[index] = true;
    _selectedIndexes.add(index);
    _drawOrder.add(index);

    if (_selectedIndexes.length == 2) {
      _isProcessingMove = true;
      final firstIdx = _selectedIndexes[0];
      final secondIdx = _selectedIndexes[1];
      final firstImg = getShuffledImage(firstIdx);
      final secondImg = getShuffledImage(secondIdx);

      if (firstImg?.imageUid == secondImg?.imageUid) {
        _playerStats.incrementMatch();
        _matchedIndexes.addAll(_selectedIndexes);
        _selectedIndexes.clear();
        _isProcessingMove = false;

        // Game finished
        if (isGameFinished) {
          logPuzzlePlay(
            puzzleId: _puzzleId!,
            user: _currentUser!,
            startTime: _playStartTime!,
            endTime: DateTime.now(),
            playerCount: _playerStats.playerCount,
            draws: _drawOrder.length,
            tileOrder: _shuffledIndexes!.join(','),
            drawOrder: _drawOrder.join(','),
            mode: _mode,
          );
          try {
            if (!_isSoundMuted) {
              final source = AssetSource('sounds/fanfare.mp3');
              await _audioPlayer.play(source);
            }
          } catch (e) {
            Log.e('Failed to play fanfare: $e');
          }
          notifyListeners();
          // Show congratulation (call from UI after notifyListeners)
        }
      } else {
        _playerStats.incrementMove();
        Future.delayed(const Duration(seconds: 1), () {
          _flipped[firstIdx] = false;
          _flipped[secondIdx] = false;
          _selectedIndexes.clear();
          _isProcessingMove = false;
          _playerStats.nextPlayer();
          notifyListeners();
        });
      }
    }
    notifyListeners();
  }
}