import 'package:flutter/material.dart';
import '../dtos/api_dtos.dart';
import '../utils/app_localizations.dart';

class UserAdminCard extends StatelessWidget {
  final UserAdminDto user;
  const UserAdminCard({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user.username),
        subtitle: Text(
          '${AppLocalizations.get('userAdminCard.puzzles')}: ${user.puzzleCount}\n'
          '${AppLocalizations.get('userAdminCard.roles')}: ${user.roles.join(", ")}'
        ),
        trailing: Text(
          user.lastLogin != null
              ? '${AppLocalizations.get('userAdminCard.lastLogin')}: ${user.lastLogin}'
              : AppLocalizations.get('userAdminCard.neverLoggedIn'),
        ),
      ),
    );
  }
}