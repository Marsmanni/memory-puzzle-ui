import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/pages/create_page.dart';
import 'src/pages/image_cropper_page.dart';
import 'src/pages/play_page.dart';
import 'src/pages/users_page.dart';
import 'src/services/game_manager.dart';
import 'src/services/system_info_service.dart';
import 'src/utils/constants.dart';
import 'src/widgets/app_bar_actions.dart';
import 'src/widgets/login_dialog.dart';
import 'src/widgets/system_info_dialog.dart';

/// Entry point of the application
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameManager(),
      child: const MyApp(),
    ),
  );
}

/// Root widget of the application
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class AuthInfo {
  String? jwt;
  String? role;
  String? user;

  AuthInfo({this.jwt, this.role, this.user});
}

class _MyAppState extends State<MyApp> {
  AuthInfo _auth = AuthInfo();

  @override
  void initState() {
    super.initState();
    _loadJwt();
  }

  Future<void> _loadJwt() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _auth = AuthInfo(
        jwt: prefs.getString('jwt'),
        role: prefs.getString('role'),
        user: prefs.getString('user'),
      );
    });
  }

  Future<void> _showLoginDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => LoginDialog(
        onLoginSuccess: (jwt, role, user) {
          setState(() {
            _auth = AuthInfo(jwt: jwt, role: role, user: user);
          });
        },
      ),
    );
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    try {
      final systemInfoService = SystemInfoService();
      final info = await systemInfoService.getCombinedSystemInfo();
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => SystemInfoDialog(info: info),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load system info: $e')));
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('role');
    await prefs.remove('user');
    setState(() {
      _auth = AuthInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: true,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Wunderwelt Memory'),
          actions: [
            AppBarActions(
              auth: _auth,
              showLoginDialog: (context) => _showLoginDialog(context),
              logout: _logout,
              showSystemInfoDialog: (context, _) => _showInfoDialog(context),
              selectedIndex: _selectedIndex,
              setSelectedIndex: (i) => setState(() => _selectedIndex = i),
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  int _selectedIndex = 0;

  /// Returns the main content widget based on the selected navigation index and user authentication.
  /// Each page is protected according to the user's role and authentication status.
  Widget _buildBody() {
    // Play page is always accessible
    if (_selectedIndex == 0) {
      return const PlayPage();
    }

    // Image upload/crop page: only for authenticated writers or admins
    if (_selectedIndex == 1) {
      if (_auth.jwt != null &&
          (_auth.role == 'writer' || _auth.role == 'admin')) {
        return const ImageCropperPage();
      }
      return const Center(child: Text('Login required to upload.'));
    }

    // Create page: only for authenticated writers or admins
    if (_selectedIndex == 2) {
      if (_auth.jwt != null &&
          (_auth.role == 'writer' || _auth.role == 'admin')) {
        return const CreatePage();
      }
      return const Center(child: Text('Login required to play.'));
    }

    // Users admin page: only for authenticated admins
    if (_selectedIndex == 3) {
      if (_auth.jwt != null && _auth.role == 'admin') {
        return const UsersPage();
      }
      return const Center(child: Text('Admin access required for user admin.'));
    }

    // Fallback for unknown index
    return const SizedBox.shrink();
  }
}
