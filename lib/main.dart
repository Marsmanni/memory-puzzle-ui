import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/src/widgets/app_bar_actions.dart';
import 'src/pages/image_cropper_page.dart';
import 'src/pages/play_page.dart';
import 'src/pages/create_page.dart';
import 'src/pages/users_page.dart';
import 'src/utils/app_localizations.dart';
import 'src/widgets/login_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/utils/constants.dart';
import 'dart:convert';
import 'package:flutter_application_2/src/services/auth_http_service.dart';
import 'package:flutter_application_2/src/utils/api_endpoints.dart';
import 'package:flutter_application_2/src/dtos/api_dtos.dart';
import 'package:flutter_application_2/src/services/game_manager.dart';
import 'package:provider/provider.dart';

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
  String _deploymentText = '';

  @override
  void initState() {
    super.initState();
    _loadJwt();
    _loadDeploymentText();
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

  Future<void> _loadDeploymentText() async {
    try {
      final text = await rootBundle.loadString('assets/deployment.txt');
      setState(() {
        _deploymentText = text.trim();
      });
    } catch (e) {
      setState(() {
        _deploymentText = 'local debug';
      });
    }
  }

  void _showLoginDialog(BuildContext context) {
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

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('role');
    await prefs.remove('user');
    setState(() {
      _auth = AuthInfo();
    });
  }

  void _showSystemInfoDialog(BuildContext context, dynamic info) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.get('systemInfo')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Database Provider: ${info.databaseProvider}'),
            Text('Connection String: ${info.databaseConnectionString}'),
            Text('EF Core Version: ${info.efCoreVersion}'),
            Text('ASP.NET Version: ${info.aspNetVersion}'),
            Text('Server IP: ${info.serverIp}'),
            Text('Client IP: ${info.clientIp}'),
            Text('Server Time: ${info.serverTime}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> fetchAndShowSystemInfo(BuildContext context) async {
    final response = await AuthHttpService.get(Uri.parse(ApiEndpoints.adminInfo));
    if (!mounted) return;
    if (response.statusCode == 200) {
      final info = SystemInfoDto.fromJson(jsonDecode(response.body));
      _showSystemInfoDialog(context, info);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Systeminfo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: true,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Memory Puzzle Test${_deploymentText.isNotEmpty ? " - $_deploymentText" : ""}',
          ),
          actions: [
            AppBarActions(
              auth: _auth,
              showLoginDialog: _showLoginDialog,
              logout: _logout,
              showSystemInfoDialog: (context, _) => fetchAndShowSystemInfo(context), // <-- use the new method
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
      if (_auth.jwt != null && (_auth.role == 'writer' || _auth.role == 'admin')) {
        return const ImageCropperPage();
      }
      return const Center(child: Text('Login required to upload.'));
    }

    // Create page: only for authenticated writers or admins
    if (_selectedIndex == 2) {
      if (_auth.jwt != null && (_auth.role == 'writer' || _auth.role == 'admin')) {
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