import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthHttpService {
  /// Performs an authenticated GET request with JWT from SharedPreferences.
  static Future<http.Response> get(Uri url) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');
    return await http.get(
      url,
      headers: {
        if (jwt != null) 'Authorization': 'Bearer $jwt',
      },
    );
  }

  /// Performs an authenticated GET request with JWT from SharedPreferences.
  static Future<http.Response> post(Uri url, Object payload) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
         if (jwt != null) 'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode(payload),
    );
  }

   static Future<http.Response> put(Uri url, Object payload) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');
    return await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
         if (jwt != null) 'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode(payload),
    );
  }

  /// You can add similar methods for DELETE if needed.
}