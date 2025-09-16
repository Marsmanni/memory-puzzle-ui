import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/pages/create_page.dart';
import 'src/pages/image_cropper_page.dart';
import 'src/pages/play_page.dart';
import 'src/pages/users_page.dart';
import 'src/services/auth_helper.dart';
import 'src/services/game_manager.dart';
import 'src/services/system_info_service.dart';
import 'src/utils/app_localizations.dart';
import 'src/utils/constants.dart';
import 'src/widgets/app_bar_actions.dart';
import 'src/widgets/login_dialog.dart';
import 'src/widgets/system_info_dialog.dart';

/// Entry point of the application
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final gameManager = GameManager(); 

  runApp(
    ChangeNotifierProvider<GameManager>.value(
      value: gameManager,
      child: const MemoryApp(),
    ),
  );
}

/// Root widget of the application
class MemoryApp extends StatefulWidget {
  const MemoryApp({super.key});

  @override
  State<MemoryApp> createState() => _MemoryAppState();
}

class _MemoryAppState extends State<MemoryApp> {
  AuthInfo _authInfo = AuthInfo();
  final GlobalKey<PlayPageState> playPageKey = GlobalKey<PlayPageState>();

  @override
  void initState() {
    super.initState();
    _loadJwt();
  }

  Future<void> _loadJwt() async {
    final auth = await AuthHelper.getAuthInfo();
    if (mounted) setState(() => _authInfo = auth);
  }

  Future<void> _showLoginDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => LoginDialog(
        onLoginSuccess: (authInfo) async {
          await AuthHelper.saveAuthInfo(authInfo);
          // reload puzzles for the new user
          setState(() {
            _authInfo = authInfo;
          });
          // After successful login
          _loadPuzzles();
          final playPageState = playPageKey.currentState;
          playPageState?.fetchGroupsAndImages();
        },
      ),
    );
  }

  void _loadPuzzles() {
    final playPageState = playPageKey.currentState;
    playPageState?.fetchGroupsAndImages();
  }

  void _logout() async {
    await AuthHelper.clearAuthInfo();
    _selectedIndex = 0;
    _loadPuzzles();
    if (mounted) setState(() => _authInfo = AuthInfo());
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
      ).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.format('main.failedToLoadSystemInfo', { 'error': '$e'}),
          ),
        ),
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
          title: Text(AppLocalizations.get('app.title')),
          actions: [
            AppBarActions(
              auth: _authInfo,
              showLoginDialog: (context) => _showLoginDialog(context),
              logout: _logout,
              showSystemInfoDialog: (context) => _showInfoDialog(context),
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
    if (_selectedIndex == 0) {
      return PlayPage(key: playPageKey);
    }

    if (_selectedIndex == 1) {
      if (_authInfo.jwt != null &&
          (_authInfo.role == 'writer' || _authInfo.role == 'admin')) {
        return const ImageCropperPage();
      }
      return Center(child: Text(AppLocalizations.get('main.loginRequiredUpload')));
    }

    if (_selectedIndex == 2) {
      if (_authInfo.jwt != null &&
          (_authInfo.role == 'writer' || _authInfo.role == 'admin')) {
        return const CreatePage();
      }
      return Center(child: Text(AppLocalizations.get('main.loginRequiredCompose')));
    }

    if (_selectedIndex == 3) {
      if (_authInfo.jwt != null && _authInfo.role == 'admin') {
        return const UsersPage();
      }
      return Center(child: Text(AppLocalizations.get('main.adminRequiredUserAdmin')));
    }

    return const SizedBox.shrink();
  }
}
