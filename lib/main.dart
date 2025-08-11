import 'package:flutter/material.dart';
import 'src/pages/image_cropper_page.dart';
import 'src/pages/play_page.dart';
import 'src/pages/create_page.dart';
import 'src/pages/users_page.dart';
import 'src/widgets/login_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/utils/constants.dart';

/// Entry point of the application
void main() {
  runApp(const MyApp());
}

/// Root widget of the application
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _jwt;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadJwt();
  }

  Future<void> _loadJwt() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _jwt = prefs.getString('jwt');
      _role = prefs.getString('role');
    });
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => LoginDialog(
        onLoginSuccess: (jwt, role) {
          setState(() {
            _jwt = jwt;
            _role = "admin";
          });
        },
      ),
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('role');
    setState(() {
      _jwt = null;
      _role = null;
    });
  }

@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: AppConstants.appTitle,
    debugShowCheckedModeBanner: true,
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Memory Puzzle'),
        actions: [
          if (_jwt == null)
            // Hier den Builder hinzufügen
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.login),
                tooltip: 'Login',
                onPressed: () => _showLoginDialog(context),
              ),
            )
          else
            PopupMenuButton<String>(
              icon: const CircleAvatar(child: Icon(Icons.person)),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') _logout();
              },
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.crop),
            label: 'Crop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    ),
  );
}
  int _selectedIndex = 0;

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return const PlayPage();
    } else if (_selectedIndex == 1) {
      // Only allow access if logged in and role is writer or admin
      if (_jwt != null && (_role == 'writer' || _role == 'admin')) {
        return const ImageCropperPage();
      } else {
        return const Center(child: Text('Login required to upload.'));
      }
    } else if (_selectedIndex == 2) {
      // Only allow access if logged in and role is writer or admin
      if (_jwt != null && (_role == 'writer' || _role == 'admin')) {
        return const CreatePage();
      } else {
        return const Center(child: Text('Login required to play.'));
      }
    } else if (_selectedIndex == 3) {
      // Only allow access if logged in and role is admin
      if (_jwt != null && _role == 'admin') {
        return const UsersPage();
      } else {
        return const Center(child: Text('Admin access required for user admin.'));
      }
    }
    return const SizedBox.shrink();
  }
}