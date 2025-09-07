import 'dart:math';

import 'package:flutter/material.dart';

import '../dtos/api_dtos.dart';
import '../services/log_puzzle_play.dart';

class GameManager extends ChangeNotifier {
  // Game state variables
  int _playerCount = 1;
  int _currentPlayer = 0;
  late List<int> _moves;
  late List<int> _matches;

  late List<bool> _flipped;
  late List<int> _shuffledIndexes;
  final List<int> _selectedIndexes = [];
  final Set<int> _matchedIndexes = {};

  List<PuzzleImageDto> _images = [];
  bool _isProcessingMove = false;

  // Logging variables
  DateTime? _playStartTime;
  int? _puzzleId;
  String? _currentUser;
  String _mode = 'standard';
  List<int> _drawOrder = [];

  // Getters for the UI to access state
  int get playerCount => _playerCount;
  int get currentPlayer => _currentPlayer;
  List<int> get moves => _moves;
  List<int> get matches => _matches;
  List<bool> get flipped => _flipped;
  List<int> get shuffledIndexes => _shuffledIndexes;
  Set<int> get matchedIndexes => _matchedIndexes;
  List<PuzzleImageDto> get images => _images;
  bool get isProcessingMove => _isProcessingMove;
  List<int> get drawOrder => _drawOrder;

  GameManager() {
    _moves = List<int>.filled(_playerCount, 0);
    _matches = List<int>.filled(_playerCount, 0);
  }

  // Call this from UI when starting a new game
  void initializeGame(
    List<PuzzleImageDto> images, {
    required int puzzleId,
    required String currentUser,
    String mode = 'standard',
  }) {
    _images = images;
    _flipped = List<bool>.filled(_images.length * 2, false);
    _shuffledIndexes = List<int>.generate(_images.length * 2, (i) => i % _images.length);
    _shuffledIndexes.shuffle(Random());
    _selectedIndexes.clear();
    _matchedIndexes.clear();
    _isProcessingMove = false;
    _currentPlayer = 0;
    _moves = List<int>.filled(_playerCount, 0);
    _matches = List<int>.filled(_playerCount, 0);
    _playStartTime = DateTime.now();
    _puzzleId = puzzleId;
    _currentUser = currentUser;
    _mode = mode;
    _drawOrder = [];
    notifyListeners();
  }

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
      final firstImg = _images[_shuffledIndexes[firstIdx]];
      final secondImg = _images[_shuffledIndexes[secondIdx]];

      if (firstImg.imageUid == secondImg.imageUid) {
        _matches[_currentPlayer]++;
        _matchedIndexes.addAll(_selectedIndexes);
        _selectedIndexes.clear();
        _isProcessingMove = false;

        // Check if all cards are matched (game finished)
        if (_matchedIndexes.length == _flipped.length) {
          // Collect parameters and call the centralized log function in the background
          logPuzzlePlay(
            puzzleId: _puzzleId!,
            user: _currentUser!,
            startTime: _playStartTime!,
            endTime: DateTime.now(),
            playerCount: _playerCount,
            draws: _drawOrder.length,
            tileOrder: _shuffledIndexes.join(','),
            drawOrder: _drawOrder.join(','),
            mode: _mode,
          );
          // Notify listeners immediately
          notifyListeners();
        }
      } else {
        _moves[_currentPlayer]++;
        Future.delayed(const Duration(seconds: 1), () {
          _flipped[firstIdx] = false;
          _flipped[secondIdx] = false;
          _selectedIndexes.clear();
          _currentPlayer = (_currentPlayer + 1) % _playerCount;
          _isProcessingMove = false;
          notifyListeners();
        });
      }
    }
    notifyListeners();
  }

  void resetGame() {
    // Call initializeGame from UI to reset and start a new game
  }

  void onPlayerCountChanged(int count) {
    _playerCount = count;
    _moves = List<int>.filled(count, 0);
    _matches = List<int>.filled(count, 0);
    _currentPlayer = 0;
    notifyListeners();
  }

  bool isCardDisabled(int index) {
    return isProcessingMove || flipped[index] || matchedIndexes.contains(index);
  }
}