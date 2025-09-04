import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthInfo {
  final String? jwt;
  final String? role;
  final String? user;

  AuthInfo({this.jwt, this.role, this.user});
}

class AuthHelper {
  /// Adds JWT auth header to a request headers map if JWT exists.
  static Future<void> addAuthHeader(Map<String, String> headers) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');
    if (jwt != null && jwt.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwt';
    }
  }

  /// Gets the JWT string from SharedPreferences.
  static Future<String?> getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  /// Loads AuthInfo from SharedPreferences and sets it in state.
  static Future<void> setAuthState(State state, void Function(AuthInfo) setter) async {
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthInfo(
      jwt: prefs.getString('jwt'),
      role: prefs.getString('role'),
      user: prefs.getString('user'),
    );
    if (state.mounted) {
      state.setState(() => setter(auth));
    }
  }

  /// Saves AuthInfo to SharedPreferences.
  static Future<void> saveAuthInfo(AuthInfo auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', auth.jwt ?? '');
    await prefs.setString('role', auth.role ?? '');
    await prefs.setString('user', auth.user ?? '');
  }

  /// Removes AuthInfo from SharedPreferences and resets state.
  static Future<void> clearAuthInfo(State state, void Function(AuthInfo) setter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('role');
    await prefs.remove('user');
    if (state.mounted) {
      state.setState(() => setter(AuthInfo()));
    }
  }
}