import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/src/dtos/api_dtos.dart';
import 'src/pages/image_cropper_page.dart';
import 'src/pages/play_page.dart';
import 'src/pages/create_page.dart';
import 'src/pages/users_page.dart';
import 'src/widgets/login_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/utils/constants.dart';
import 'src/services/auth_http_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'src/utils/api_endpoints.dart';

/// Entry point of the application
void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  String? _user;
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
      _jwt = prefs.getString('jwt');
      _role = prefs.getString('role');
      _user = prefs.getString('user'); // Add this line
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
            _jwt = jwt;
            _role = role;
            _user = user;
          });
        },
      ),
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('role');
    await prefs.remove('user'); // Add this line
    setState(() {
      _jwt = null;
      _role = null;
      _user = null; // Add this line
    });
  }

  @@override
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
          if (_jwt == null)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.login),
                tooltip: 'Login',
                onPressed: () => _showLoginDialog(context),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  '${_user ?? "?"} (${_role ?? "?"})',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            // This Builder provides a new, stable context for the menu actions.
            Builder(
              builder: (context) => PopupMenuButton<String>(
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
                  if (_role == 'admin')
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
                    _logout();
                  } else if (value == 'play') {
                    setState(() => _selectedIndex = 0);
                  } else if (value == 'crop') {
                    setState(() => _selectedIndex = 1);
                  } else if (value == 'create') {
                    setState(() => _selectedIndex = 2);
                  } else if (value == 'users') {
                    setState(() => _selectedIndex = 3);
                  } else if (value == 'systemInfo') {
                    // Use a temporary variable to hold the context from the Builder
                    final safeContext = context;
                    
                    final response = await AuthHttpService.get(Uri.parse(ApiEndpoints.adminInfo));
                    
                    if (!mounted) return;
                    
                    if (response.statusCode == 200) {
                      final info = SystemInfoDto.fromJson(jsonDecode(response.body));
                      
                      // Now, use the safeContext for the showDialog call
                      showDialog(
                        context: safeContext,
                        builder: (context) => AlertDialog(
                          title: const Text('System Info'),
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
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ],
      ),
      body: _buildBody(),
    ),
  );
}
  int _selectedIndex = 0;

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return const PlayPage();
    } else if (_selectedIndex == 1) {
      if (_jwt != null && (_role == 'writer' || _role == 'admin')) {
        return const ImageCropperPage();
      } else {
        return const Center(child: Text('Login required to upload.'));
      }
    } else if (_selectedIndex == 2) {
      if (_jwt != null && (_role == 'writer' || _role == 'admin')) {
        return const CreatePage();
      } else {
        return const Center(child: Text('Login required to play.'));
      }
    } else if (_selectedIndex == 3) {
      if (_jwt != null && _role == 'admin') {
        return const UsersPage();
      } else {
        return const Center(child: Text('Admin access required for user admin.'));
      }
    }
    return const SizedBox.shrink();
  }
}