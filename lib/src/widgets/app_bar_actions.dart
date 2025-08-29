import 'package:flutter/material.dart';
import '../../main.dart'; // For AuthInfo

class AppBarActions extends StatelessWidget {
  final AuthInfo auth;
  final void Function(BuildContext) showLoginDialog;
  final void Function() logout;
  final void Function(BuildContext, dynamic) showSystemInfoDialog;
  final int selectedIndex;
  final void Function(int) setSelectedIndex;

  const AppBarActions({
    super.key,
    required this.auth,
    required this.showLoginDialog,
    required this.logout,
    required this.showSystemInfoDialog,
    required this.selectedIndex,
    required this.setSelectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (auth.jwt == null) {
      return Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.login),
          tooltip: 'Login',
          onPressed: () => showLoginDialog(context),
        ),
      );
    } else {
      return Builder(
        builder: (context) => Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  '${auth.user ?? "?"} (${auth.role ?? "?"})',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const CircleAvatar(child: Icon(Icons.person)),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'play',
                  child: ListTile(
                    leading: Icon(Icons.play_arrow),
                    title: Text('Play'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'crop',
                  child: ListTile(
                    leading: Icon(Icons.crop),
                    title: Text('Crop'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'create',
                  child: ListTile(
                    leading: Icon(Icons.create),
                    title: Text('Create'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'users',
                  child: ListTile(
                    leading: Icon(Icons.people),
                    title: Text('Users'),
                  ),
                ),
                if (auth.role == 'admin')
                  const PopupMenuDivider(),
                if (auth.role == 'admin')
                  const PopupMenuItem(
                    value: 'systemInfo',
                    child: ListTile(
                      leading: Icon(Icons.info),
                      title: Text('System Info'),
                    ),
                  ),
              ],
              onSelected: (value) async {
                if (value == 'logout') {
                  logout();
                } else if (value == 'play') {
                  setSelectedIndex(0);
                } else if (value == 'crop') {
                  setSelectedIndex(1);
                } else if (value == 'create') {
                  setSelectedIndex(2);
                } else if (value == 'users') {
                  setSelectedIndex(3);
                } else if (value == 'systemInfo') {
                  showSystemInfoDialog(context, null);
                }
              },
            ),
          ],
        ),
      );
    }
  }
}