import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/api_endpoints.dart';
import 'dart:math';

class PlayPage extends StatefulWidget {
  const PlayPage({Key? key}) : super(key: key);

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  final List<String> _groups = ['Memory', 'Landschaft', 'Pflanzen'];
  String _selectedGroup = 'Memory';
  List<String> _images = [];
  bool _loading = false;
  String? _error;
  late List<bool> _flipped;
  late List<int> _shuffledIndexes;
  List<int> _selectedIndexes = [];
  Set<int> _matchedIndexes = {};

  int _playerCount = 1;
  int _currentPlayer = 0;
  List<int> _moves = [0, 0, 0];
  List<int> _matches = [0, 0, 0];

  final List<Map<String, String>> _placeholders = [
    {'name': 'Himmel', 'asset': 'assets/placeholder1.png'},
    {'name': 'Puzzle', 'asset': 'assets/placeholder2.png'},
    {'name': 'Wiese', 'asset': 'assets/placeholder3.png'},
    {'name': 'Smiley', 'asset': 'assets/placeholder0.png'},
  ];
  int _selectedPlaceholderIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse(ApiEndpoints.puzzlesDefault));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> imagesList = data['images'] ?? [];
        setState(() {
          _images = imagesList.map((img) => img['imageUid'] as String).toList();
          _flipped = List<bool>.filled(_images.length * 2, false);

          // Create and shuffle index array for mixing images
          _shuffledIndexes = List<int>.generate(_images.length * 2, (i) => i % _images.length);
          _shuffledIndexes.shuffle(Random());
          
          _loading = false;
        });

        // Preload images
        for (final uid in _images) {
          final imgUrl = AppConstants.replace(ApiEndpoints.imagesGetById, {'id': uid});
          precacheImage(NetworkImage(imgUrl), context);
        }
      } else {
        setState(() {
          _error = 'Failed to load images: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  void _reset() {
    setState(() {
      // Reset all play state
      _matchedIndexes.clear();
      _selectedIndexes.clear();
      _currentPlayer = 0;
      _moves = List<int>.filled(_playerCount, 0);
      _matches = List<int>.filled(_playerCount, 0);
    });
    _fetchImages();
  }

  void _onCardTap(int index) {
    if (_flipped[index] || _matchedIndexes.contains(index) || _selectedIndexes.length == 2) return;

    setState(() {
      _flipped[index] = true;
      _selectedIndexes.add(index);
      // Do NOT increment moves here
    });

    if (_selectedIndexes.length == 2) {
      final firstIdx = _selectedIndexes[0];
      final secondIdx = _selectedIndexes[1];
      final firstImg = _images[_shuffledIndexes[firstIdx]];
      final secondImg = _images[_shuffledIndexes[secondIdx]];

      if (firstImg == secondImg) {
        // Increment match counter for current player
        setState(() {
          _matches[_currentPlayer]++;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _matchedIndexes.addAll(_selectedIndexes);
            _selectedIndexes.clear();
            // Player gets another turn on match
          });
        });
      } else {
        // Increment moves counter for current player on miss
        setState(() {
          _moves[_currentPlayer]++;
        });
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _flipped[firstIdx] = false;
            _flipped[secondIdx] = false;
            _selectedIndexes.clear();
            // Switch to next player on miss
            _currentPlayer = (_currentPlayer + 1) % _playerCount;
          });
        });
      }
    }
  }

  void _onPlayerCountChanged(int count) {
    setState(() {
      _playerCount = count;
      _moves = List<int>.filled(count, 0);
      _matches = List<int>.filled(count, 0);
      _currentPlayer = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text('Play'),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedGroup,
                items: _groups
                    .map((group) => DropdownMenuItem(
                          value: group,
                          child: Text(group),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGroup = value;
                    });
                    _fetchImages();
                  }
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _reset,
                child: const Text('Reset'),
              ),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: _playerCount,
                items: [1, 2, 3]
                    .map((count) => DropdownMenuItem(
                          value: count,
                          child: Text('$count Player${count > 1 ? 's' : ''}'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _onPlayerCountChanged(value);
                  }
                },
              ),
              const SizedBox(width: 16),
              ...List.generate(_playerCount, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text(
                    'P${i + 1}: ${_moves[i]} moves, ${_matches[i]} matches${_currentPlayer == i ? " ←" : ""}',
                    style: TextStyle(
                      fontWeight: _currentPlayer == i ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  backgroundColor: _currentPlayer == i ? Colors.blue[100] : Colors.grey[200],
                ),
              )),
              const SizedBox(width: 16),
              PopupMenuButton<int>(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    enabled: false,
                    child: Text('Select Placeholder'),
                  ),
                  ...List.generate(_placeholders.length, (i) => PopupMenuItem<int>(
                    value: i,
                    child: Text(_placeholders[i]['name']!),
                  )),
                ],
                onSelected: (value) {
                  setState(() {
                    _selectedPlaceholderIndex = value;
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
                  itemCount: _images.length * 2,
                  itemBuilder: (context, index) {
                    final imgUrl = AppConstants.replace(ApiEndpoints.imagesGetById, {'id': _images[_shuffledIndexes[index]]});
                    final isMatched = _matchedIndexes.contains(index);
                    final isFlipped = _flipped[index];
                    final isDisabled = isFlipped || isMatched || _selectedIndexes.contains(index);

                    return AbsorbPointer(
                      absorbing: isDisabled,
                      child: GestureDetector(
                        onTap: () => _onCardTap(index),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            final rotate = isFlipped
                                ? Tween(begin: 0.0, end: 1.0).animate(animation)
                                : Tween(begin: 1.0, end: 0.0).animate(animation);
                            return AnimatedBuilder(
                              animation: rotate,
                              builder: (context, _) {
                                final showFront = rotate.value < 0.5;
                                Widget cardContent = showFront
                                    ? Image.asset(
                                        _placeholders[_selectedPlaceholderIndex]['asset']!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                    : Image.network(
                                        imgUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      );
                                if (isMatched) {
                                  cardContent = ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.grey,
                                      BlendMode.saturation,
                                    ),
                                    child: cardContent,
                                  );
                                }
                                return Transform(
                                  transform: Matrix4.rotationY(rotate.value * 3.1416),
                                  alignment: Alignment.center,
                                  child: cardContent,
                                );
                              },
                            );
                          },
                          child: SizedBox(
                            key: ValueKey(isFlipped),
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
