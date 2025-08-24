import 'package:flutter/material.dart';
import 'package:flutter_application_2/src/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../services/auth_http_service.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  List<String> _imageUrls = [];
  Set<int> _selectedIndexes = {};
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _fileGroups = [];
  String? _selectedGroupName;
  bool _loadingFileGroups = true;

  @override
  void initState() {
    super.initState();
    _fetchFileGroups();
    _fetchImages();
  }

  Future<void> _fetchFileGroups() async {
    setState(() {
      _loadingFileGroups = true;
    });

    try {
      final response = await AuthHttpService.get(Uri.parse(ApiEndpoints.imagesFilegroups));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _fileGroups = data
              .where((e) => e['groupName'] != null && (e['groupName'] as String).isNotEmpty)
              .map<Map<String, dynamic>>((e) => {
                    //'groupId': e['groupId'],
                    'groupName': e['groupName'],
                    'imageCount': e['imageCount'],
                  })
              .toList();
          _selectedGroupName = _fileGroups.isNotEmpty ? _fileGroups[0]['groupName'] : null;
          _loadingFileGroups = false;
        });
      } else {
        setState(() {
          _fileGroups = [];
          _selectedGroupName = null;
          _loadingFileGroups = false;
        });
      }
    } catch (e) {
      setState(() {
        _fileGroups = [];
        _selectedGroupName = null;
        _loadingFileGroups = false;
      });
    }
  }

  Future<void> _fetchImages() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Replace 'testgroup' with your actual group name or pass it as a parameter
      final url = Uri.parse(ApiEndpoints.imagesTestGroup);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _imageUrls = data.cast<String>();
          _loading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    // Example: Replace these with your actual user state variables
    final String userName = 'JohnDoe'; // Get from your user state
    final String userRole = 'admin';   // Get from your user state

    final TextEditingController _saveToController = TextEditingController();
    final List<String> _dropdownSamples = [
      'Group A',
      'Group B',
      'Group C',
      'Group D',
      'Group E',
    ];
    String _selectedDropdown = _dropdownSamples[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create the puzzle'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                        ),
                        itemCount: _imageUrls.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedIndexes.contains(index);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedIndexes.remove(index);
                                  debugPrint(
                                      'Deselected image at index $index: ${_imageUrls[index]}');
                                } else {
                                  _selectedIndexes.add(index);
                                  debugPrint(
                                      'Selected image at index $index: ${_imageUrls[index]}');
                                }
                              });
                            },
                            child: Stack(
                              children: [
                                Card(
                                  child: Image.network(
                                    _imageUrls[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 32,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndexes =
                          Set.from(List.generate(_imageUrls.length, (i) => i));
                    });
                    debugPrint('Selected all images');
                  },
                  child: const Text('Select All'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndexes.clear();
                    });
                    debugPrint('Deselected all images');
                  },
                  child: const Text('Deselect All'),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: DropdownButton<String>(
                    value: _selectedDropdown,
                    items: _dropdownSamples
                        .map((sample) => DropdownMenuItem(
                              value: sample,
                              child: Text(sample),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        if (value != null) _selectedDropdown = value;
                      });
                      debugPrint('Dropdown selected: $_selectedDropdown');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 180,
                  child: _loadingFileGroups
                      ? const CircularProgressIndicator()
                      : DropdownButton<String>(
                          value: _selectedGroupName,
                          items: _fileGroups
                              .map((group) => DropdownMenuItem<String>(
                                    value: group['groupName'],
                                    child: Text(
                                        '${group['groupName']} (${group['imageCount']})'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGroupName = value;
                            });
                          },
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _saveToController,
                    decoration: const InputDecoration(
                      labelText: 'Save To',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    debugPrint(
                      'SaveTo: ${_saveToController.text}, Dropdown: $_selectedDropdown, Selected: $_selectedIndexes');

                    // Collect selected image UIDs (assuming _imageUrls contains UIDs or URLs)
                    final selectedUids = _selectedIndexes.map((i) => _imageUrls[i]).toList();

                    // Prepare payload matching PuzzleDto and PuzzleImageDto
                    final payload = {
                      'name': _saveToController.text,
                      'images': selectedUids.map((uid) => {'imageUid': uid}).toList(),
                      // 'creationTime' and 'id' are typically set by the backend
                    };

                    // Call the new endpoint (POST recommended for creating new resources)
                    final response = await AuthHttpService.post(Uri.parse(ApiEndpoints.puzzlesCreate), payload);

                    if (response.statusCode == 200 || response.statusCode == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Puzzle setup saved successfully!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save puzzle setup: ${response.statusCode}')),
                      );
                    }
                  },
                  child: const Text('SaveTo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
