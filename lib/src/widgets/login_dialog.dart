import 'package:flutter/material.dart';
import 'package:flutter_application_2/src/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_localizations.dart';

// Helper to decode JWT and extract claims
Map<String, dynamic> parseJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('Invalid JWT');
  }
  final payload = base64Url.normalize(parts[1]);
  final decoded = utf8.decode(base64Url.decode(payload));
  return jsonDecode(decoded);
}

class LoginDialog extends StatefulWidget {
  final void Function(String jwt, String role, String user)? onLoginSuccess;
  const LoginDialog({Key? key, this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final url = Uri.parse(ApiEndpoints.usersLogin);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final jwt = data['token'] ?? data['jwt'] ?? '';
      final claims = parseJwt(jwt);
      // After parsing claims
      debugPrint('JWT claims: $claims'); // Add this for debugging

      final role = claims['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? data['role'] ?? 'user';
      final user = claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ?? data['user'] ?? _usernameController.text;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', jwt);
      await prefs.setString('role', role);
      await prefs.setString('user', user);
      if (widget.onLoginSuccess != null) widget.onLoginSuccess!(jwt, role, user);
      Navigator.of(context).pop();
    } else {
      setState(() {
        _error = 'Login failed: ${response.statusCode}';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.get('login')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: AppLocalizations.get('username')),
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _login,
          child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(AppLocalizations.get('login')),
        ),
      ],
    );
  }
}
