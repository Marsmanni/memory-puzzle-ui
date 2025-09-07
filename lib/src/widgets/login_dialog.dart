import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/api_endpoints.dart';
import '../utils/app_localizations.dart';
import '../services/auth_helper.dart'; 

// Helper to decode JWT and extract claims
Map<String, dynamic> parseJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) throw Exception('Invalid JWT');
  final payload = base64Url.normalize(parts[1]);
  final decoded = utf8.decode(base64Url.decode(payload));
  return jsonDecode(decoded);
}

class LoginDialog extends StatefulWidget {
  final void Function(AuthInfo auth)? onLoginSuccess;
  const LoginDialog({super.key, this.onLoginSuccess});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login(BuildContext context) async {
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

    if (!context.mounted) return;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final jwt = data['token'] ?? data['jwt'] ?? '';
      final claims = parseJwt(jwt);
      final role = claims['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? data['role'] ?? 'user';
      final user = claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ?? data['user'] ?? _usernameController.text;

      // Use AuthHelper to save auth info
      final authInfo = AuthInfo(jwt: jwt, role: role, user: user);
      await AuthHelper.saveAuthInfo(authInfo);

      widget.onLoginSuccess?.call(authInfo);

      if (!context.mounted) return;
      if (Navigator.canPop(context)) Navigator.of(context).pop();
    } else {
      setState(() {
        _error = 'Login failed: ${response.statusCode}';
      });
    }

    if (!context.mounted) return;
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
            decoration: InputDecoration(
              labelText: AppLocalizations.get('login.username'),
            ),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: AppLocalizations.get('login.password'),
            ),
            obscureText: true,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : () => _login(context),
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(AppLocalizations.get('login')),
        ),
      ],
    );
  }
}
