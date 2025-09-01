import 'dart:convert';

import 'package:flutter/material.dart';

import '../dtos/api_dtos.dart';
import '../services/auth_http_service.dart';
import '../utils/api_endpoints.dart';
import '../utils/app_localizations.dart';
import '../widgets/puzzle_admin_list.dart';
import '../widgets/user_admin_card.dart';
import '../widgets/user_admin_data_table.dart';

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
      final puzzlesResponse = await AuthHttpService.get(Uri.parse(ApiEndpoints.adminAllPuzzles));

      // Fetch users
      final usersResponse = await AuthHttpService.get(Uri.parse(ApiEndpoints.adminAllUsers));

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
        title: Text(AppLocalizations.get('usersPage.title')),
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
                    AppLocalizations.get('usersPage.puzzles'),
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
            UserListSection(users: _users, loading: _loading, error: _error),
            const SizedBox(width: 32),
            // Table View (third column)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.get('usersPage.table'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _loading
                        ? const LoadingIndicator()
                        : _error != null
                            ? ErrorMessage(_error!)
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

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}

class ErrorMessage extends StatelessWidget {
  final String error;
  const ErrorMessage(this.error, {super.key});
  @override
  Widget build(BuildContext context) => Center(child: Text(error, style: const TextStyle(color: Colors.red)));
}

class UserListSection extends StatelessWidget {
  final List<UserAdminDto> users;
  final bool loading;
  final String? error;
  const UserListSection({required this.users, required this.loading, required this.error, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.get('usersPage.list'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Expanded(
          child: loading
              ? const LoadingIndicator()
              : error != null
                  ? ErrorMessage(error!)
                  : ListView(
                      children: users.map((user) => UserAdminCard(user: user)).toList(),
                    ),
        ),
      ],
    );
  }
}
