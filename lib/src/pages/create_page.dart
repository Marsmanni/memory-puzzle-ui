import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../dtos/api_dtos.dart';
import '../services/auth_http_service.dart';
import '../utils/api_endpoints.dart';
import '../utils/app_localizations.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  List<String> _imageUrls = [];
  Set<int> _selectedIndexes = {};
  bool _loading = true;
  String? _error;

  List<FileGroupDto> _fileGroups = [];
  String? _selectedGroupName;
  bool _loadingFileGroups = true;

  final TextEditingController saveToController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFileGroups();
    _fetchImagesDefault();
  }

  Future<void> _fetchFileGroups() async {
    setState(() {
      _loadingFileGroups = true;
    });

    try {
      final response = await AuthHttpService.get(Uri.parse(ApiEndpoints.imagesFilegroups));
      if (response.statusCode == 200) {
        final List<FileGroupDto> groups = (jsonDecode(response.body) as List)
            .map((e) => FileGroupDto.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _fileGroups = groups;
          _selectedGroupName = _fileGroups.isNotEmpty ? _fileGroups[0].groupName : null;
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

  Future<void> _fetchImagesDefault() async {
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

  Future<void> _fetchImagesGroup(String? groupName) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = Uri.parse(
        ApiEndpoints.imagesFilegroup.replaceFirst('{groupName}', groupName ?? ''),
      );
      final response = await AuthHttpService.get(url);

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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get('createPage.title')), // e.g. 'Create the puzzle'
        actions: [
          IconButton(
            tooltip: AppLocalizations.get('selectAll'),
            icon: const Icon(Icons.select_all),
            onPressed: () {
              setState(() {
                _selectedIndexes = Set.from(List.generate(_imageUrls.length, (i) => i));
              });
            },
          ),
          IconButton(
            tooltip: AppLocalizations.get('deselectAll'),
            icon: const Icon(Icons.remove_done),
            onPressed: () {
              setState(() {
                _selectedIndexes.clear();
              });
            },
          ),
          SizedBox(
            width: 180,
            child: _loadingFileGroups
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CircularProgressIndicator(),
                  )
                : DropdownButton<String>(
                    value: _selectedGroupName,
                    underline: Container(),
                    items: _fileGroups
                        .map((group) => DropdownMenuItem<String>(
                              value: group.groupName,
                              child: Text(
                                '${group.groupName} (${group.imageCount})',
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGroupName = value;
                        _fetchImagesGroup(_selectedGroupName);
                      });
                    },
                  ),
          ),
          SizedBox(
            width: 180,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: TextField(
                controller: saveToController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.get('saveTo'),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton(
              onPressed: () async {
                final selectedUids = _selectedIndexes.map((i) => _imageUrls[i]).toList();
                final puzzleDto = PuzzleDtoBase(
                  name: saveToController.text,
                  images: selectedUids.map((uid) => PuzzleImageDto(imageUid: uid)).toList(),
                );
                final response = await AuthHttpService.post(
                  Uri.parse(ApiEndpoints.puzzlesCreate),
                  puzzleDto.toJson(),
                );
                if (response.statusCode == 200 || response.statusCode == 201) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.get('saveSuccess'))),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                        '${AppLocalizations.get('saveFailed')}: ${response.statusCode}',
                      )),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.get('saveTo')),
            ),
          ),
        ],
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
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                } else {
                                  _selectedIndexes.add(index);
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
        ],
      ),
    );
  }
}
