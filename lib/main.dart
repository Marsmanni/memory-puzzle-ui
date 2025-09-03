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
  SystemInfoDto? _systemInfoDto; // <-- new field

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
    String clientVersion = '';
    DateTime? clientDeploymentTime;
    String clientGitVersion = '';
    final lines = text.trim().split('\n');
    for (final line in lines) {
      if (line.startsWith('version:')) clientVersion = line.split(':')[1].trim();
      if (line.startsWith('deploymentTime:')) clientDeploymentTime = DateTime.tryParse(line.split(':')[1].trim());
      if (line.startsWith('gitCommit:')) clientGitVersion = line.split(':')[1].trim();
    }
    setState(() {
      _systemInfoDto = SystemInfoDto(
        clientVersion: clientVersion,
        clientDeploymentTime: clientDeploymentTime,
        clientGitVersion: clientGitVersion,
        // You can set other fields to empty/default here; server info will be filled later
        databaseProvider: '',
        databaseConnectionString: '',
        efCoreVersion: '',
        aspNetVersion: '',
        serverIp: '',
        clientIp: '',
        serverTime: DateTime.now( ),
        serverVersion: '',
        serverDeploymentTime: null,
        serverGitVersion: '',
      );
    });
  } catch (e) {
    setState(() {
      _systemInfoDto = SystemInfoDto(
        clientVersion: 'local debug',
        clientDeploymentTime: null,
        clientGitVersion: '',
        databaseProvider: '',
        databaseConnectionString: '',
        efCoreVersion: '',
        aspNetVersion: '',
        serverIp: '',
        clientIp: '',
        serverTime: DateTime.now(),
        serverVersion: '',
        serverDeploymentTime: null,
        serverGitVersion: '',
      );
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

  void _showSystemInfoDialog(BuildContext context, SystemInfoDto info) {
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
            Text('Server Version: ${info.serverVersion}'),
            Text('Server Deployment Time: ${info.serverDeploymentTime != null ? info.serverDeploymentTime!.toIso8601String() : "-"}'),
            Text('Server Git Version: ${info.serverGitVersion}'),
            Text('Client Version: ${info.clientVersion}'),
            Text('Client Deployment Time: ${info.clientDeploymentTime != null ? info.clientDeploymentTime!.toIso8601String() : "-"}'),
            Text('Client Git Version: ${info.clientGitVersion}'),
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
      final serverInfo = SystemInfoDto.fromJson(jsonDecode(response.body));
      setState(() {
        // Merge server info into _systemInfoDto, keep client info
        _systemInfoDto = SystemInfoDto(
          clientVersion: _systemInfoDto?.clientVersion ?? '',
          clientDeploymentTime: _systemInfoDto?.clientDeploymentTime,
          clientGitVersion: _systemInfoDto?.clientGitVersion ?? '',
          databaseProvider: serverInfo.databaseProvider,
          databaseConnectionString: serverInfo.databaseConnectionString,
          efCoreVersion: serverInfo.efCoreVersion,
          aspNetVersion: serverInfo.aspNetVersion,
          serverIp: serverInfo.serverIp,
          clientIp: serverInfo.clientIp,
          serverTime: serverInfo.serverTime,
          serverVersion: serverInfo.serverVersion,
          serverDeploymentTime: serverInfo.serverDeploymentTime,
          serverGitVersion: serverInfo.serverGitVersion,
        );
      });
      _showSystemInfoDialog(context, _systemInfoDto!);
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
            'Memory Puzzle Test${_systemInfoDto != null && _systemInfoDto!.clientVersion.isNotEmpty ? " - ${_systemInfoDto!.clientVersion}" : ""}',
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