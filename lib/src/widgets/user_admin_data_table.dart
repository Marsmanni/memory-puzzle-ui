import 'package:flutter/material.dart';
import '../dtos/api_dtos.dart';
import '../utils/app_localizations.dart';

class UserAdminDataTable extends StatelessWidget {
  final List<UserAdminDto> users;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int, bool) onSort;

  const UserAdminDataTable({
    required this.users,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        columns: [
          DataColumn(
            label: Text(AppLocalizations.get('username')),
            onSort: onSort,
          ),
          DataColumn(
            label: Text(AppLocalizations.get('puzzles')),
            numeric: true,
            onSort: onSort,
          ),
          DataColumn(
            label: Text(AppLocalizations.get('lastLogin')),
            onSort: onSort,
          ),
        ],
        rows: users.map((user) => DataRow(
          cells: [
            DataCell(Text(user.username)),
            DataCell(Text(user.puzzleCount.toString())),
            DataCell(Text(user.lastLogin != null
                ? user.lastLogin.toString()
                : AppLocalizations.get('neverLoggedIn'))),
          ],
        )).toList(),
      ),
    );
  }
}