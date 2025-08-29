import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/auth_http_service.dart';
import '../dtos/api_dtos.dart';
import '../utils/api_endpoints.dart';
import '../widgets/user_admin_card.dart';
import '../widgets/user_admin_data_table.dart';
import '../widgets/puzzle_admin_list.dart';
import '../utils/app_localizations.dart'; 

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

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
        title: Text(AppLocalizations.get('adminOverview')),
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
                  Text(
                    AppLocalizations.get('allPuzzles'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: PuzzleAdminList(
                      puzzles: _puzzles,
                      loading: _loading,
                      error: _error,
                      setState: setState,
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
                  Text(
                    AppLocalizations.get('allUsers'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                            : ListView(
                                children: _users.map((user) => UserAdminCard(user: user)).toList(),
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
                  Text(
                    AppLocalizations.get('usersTable'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                            : UserAdminDataTable(
                                users: _sortedUsers,
                                sortColumnIndex: _sortColumnIndex,
                                sortAscending: _sortAscending,
                                onSort: (columnIndex, ascending) {
                                  setState(() {
                                    _sortColumnIndex = columnIndex;
                                    _sortAscending = ascending;
                                  });
                                },
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
