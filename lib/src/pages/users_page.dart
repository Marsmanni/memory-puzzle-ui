import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_http_service.dart';
import '../dtos/api_dtos.dart';
import '../utils/api_endpoints.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<PuzzleAdminDto> _puzzles = [];
  List<UserAdminDto> _users = [];
  bool _loading = true;
  String? _error;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Fetch puzzles
      final puzzlesResponse =  await AuthHttpService.get(Uri.parse(ApiEndpoints.adminAllPuzzles));

      // Fetch users
      final usersResponse =  await AuthHttpService.get(Uri.parse(ApiEndpoints.adminAllUsers));

      if (puzzlesResponse.statusCode == 200 && usersResponse.statusCode == 200) {
        final List<dynamic> puzzlesData = jsonDecode(puzzlesResponse.body);
        final List<dynamic> usersData = jsonDecode(usersResponse.body);

        setState(() {
          _puzzles = puzzlesData.map((e) => PuzzleAdminDto.fromJson(e)).toList();
          _users = usersData.map((e) => UserAdminDto.fromJson(e)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Fehler: ${puzzlesResponse.statusCode}, ${usersResponse.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Fehler: $e';
        _loading = false;
      });
    }
  }

  List<UserAdminDto> get _sortedUsers {
    List<UserAdminDto> sorted = List<UserAdminDto>.from(_users);
    if (_sortColumnIndex == 0) {
      sorted.sort((a, b) => _sortAscending
          ? a.username.compareTo(b.username)
          : b.username.compareTo(a.username));
    } else if (_sortColumnIndex == 1) {
      sorted.sort((a, b) => _sortAscending
          ? a.puzzleCount.compareTo(b.puzzleCount)
          : b.puzzleCount.compareTo(a.puzzleCount));
    } else if (_sortColumnIndex == 2) {
      sorted.sort((a, b) => _sortAscending
          ? (a.lastLogin?.compareTo(b.lastLogin ?? DateTime(1970)) ?? 0)
          : (b.lastLogin?.compareTo(a.lastLogin ?? DateTime(1970)) ?? 0));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Übersicht'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Puzzle List
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alle Puzzles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                            : ListView(
                                children: _puzzles.map((puzzle) => Card(
                                  child: ListTile(
                                    title: Text(puzzle.name),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Autor: ${puzzle.creator}'),
                                        Text('Bilder: ${puzzle.imageCount}'),
                                        Row(
                                          children: [
                                            const Text('Öffentlich: '),
                                            Checkbox(
                                              value: puzzle.isPublic,
                                              onChanged: (value) async {
                                                // Optimistically update UI
                                                setState(() {
                                                  puzzle.isPublic = value ?? false;
                                                });
                                                // Call PUT endpoint
                                                final payload = {
                                                  'isPublic': value,
                                                };

                                                final response = await AuthHttpService.put(
                                                  Uri.parse('${ApiEndpoints.adminUpdatePuzzle}/${puzzle.id}'),
                                                  payload,
                                                );
                                                if (response.statusCode != 204) {
                                                  // Revert UI if failed
                                                  setState(() {
                                                    puzzle.isPublic = !puzzle.isPublic;
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Fehler beim Aktualisieren!')),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Text('ID: ${puzzle.id}\n${puzzle.creationTime.toLocal()}'),
                                  ),
                                )).toList(),
                              ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            // User List
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alle Benutzer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                            : ListView(
                                children: _users.map((user) => Card(
                                  child: ListTile(
                                    title: Text(user.username),
                                    subtitle: Text('Puzzles: ${user.puzzleCount}\nRollen: ${user.roles.join(", ")}'),
                                    trailing: Text(
                                      user.lastLogin != null
                                          ? 'Letzter Login: ${user.lastLogin}'
                                          : 'Nie eingeloggt',
                                    ),
                                  ),
                                )).toList(),
                              ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            // Table View (third column)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Benutzer (Tabelle)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                            : SingleChildScrollView(
                                child: DataTable(
                                  sortColumnIndex: _sortColumnIndex,
                                  sortAscending: _sortAscending,
                                  columns: [
                                    DataColumn(
                                      label: const Text('Benutzername'),
                                      onSort: (columnIndex, ascending) {
                                        setState(() {
                                          _sortColumnIndex = columnIndex;
                                          _sortAscending = ascending;
                                        });
                                      },
                                    ),
                                    DataColumn(
                                      label: const Text('Puzzles'),
                                      numeric: true,
                                      onSort: (columnIndex, ascending) {
                                        setState(() {
                                          _sortColumnIndex = columnIndex;
                                          _sortAscending = ascending;
                                        });
                                      },
                                    ),
                                    DataColumn(
                                      label: const Text('Letzter Login'),
                                      onSort: (columnIndex, ascending) {
                                        setState(() {
                                          _sortColumnIndex = columnIndex;
                                          _sortAscending = ascending;
                                        });
                                      },
                                    ),
                                  ],
                                  rows: _sortedUsers.map((user) => DataRow(
                                    cells: [
                                      DataCell(Text(user.username)),
                                      DataCell(Text(user.puzzleCount.toString())),
                                      DataCell(Text(user.lastLogin != null
                                          ? user.lastLogin.toString()
                                          : 'Nie eingeloggt')),
                                    ],
                                  )).toList(),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
