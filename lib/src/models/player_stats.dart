class GameStats {
  int _playerCount;
  int _currentPlayer;
  late List<int> _moves;
  late List<int> _matches;

  GameStats({int playerCount = 1})
      : _playerCount = playerCount,
        _currentPlayer = 0 {
    _moves = List<int>.filled(_playerCount, 0);
    _matches = List<int>.filled(_playerCount, 0);
  }

  int get playerCount => _playerCount;
  int get currentPlayer => _currentPlayer;
  set currentPlayer(int value) => _currentPlayer = value;
  List<int> get moves => _moves;
  List<int> get matches => _matches;

  set playerCount(int count) {
    _playerCount = count;
    _moves = List<int>.filled(count, 0);
    _matches = List<int>.filled(count, 0);
    _currentPlayer = 0;
  }

  void nextPlayer() {
    _currentPlayer = (_currentPlayer + 1) % _playerCount;
  }

  void incrementMove() {
    _moves[_currentPlayer]++;
  }

  void incrementMatch() {
    _matches[_currentPlayer]++;
  }
}