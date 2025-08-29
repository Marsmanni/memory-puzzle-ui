import 'package:flutter/material.dart';
import '../dtos/api_dtos.dart';
import 'dart:math';

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

  GameManager() {
    _moves = List<int>.filled(_playerCount, 0);
    _matches = List<int>.filled(_playerCount, 0);
  }

  void initializeGame(List<PuzzleImageDto> images) {
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
    notifyListeners();
  }

  void onCardTap(int index) {
    if (_isProcessingMove || _flipped[index] || _matchedIndexes.contains(index) || _selectedIndexes.length == 2) {
      return;
    }

    _flipped[index] = true;
    _selectedIndexes.add(index);
    
    if (_selectedIndexes.length == 2) {
      _isProcessingMove = true;
      final firstIdx = _selectedIndexes[0];
      final secondIdx = _selectedIndexes[1];
      final firstImg = _images[_shuffledIndexes[firstIdx]];
      final secondImg = _images[_shuffledIndexes[secondIdx]];

      if (firstImg.imageUid == secondImg.imageUid) { // Compare by UID, not object reference
        _matches[_currentPlayer]++;
        _matchedIndexes.addAll(_selectedIndexes);
        _selectedIndexes.clear();
        _isProcessingMove = false;
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
    // We'll leave this up to the `initializeGame` method to handle a full reset
    // by calling it from the UI after a new group is selected.
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