import 'package:http/http.dart' as http;
import 'dart:convert';

import 'auth_helper.dart';

class AuthHttpService {
  /// Performs an authenticated GET request with JWT 
  static Future<http.Response> get(Uri url) async {
    final headers = <String, String>{};
    await AuthHelper.addAuthHeader(headers);
    return await http.get(url, headers: headers);
  }

  /// Performs an authenticated POST request with JWT
  static Future<http.Response> post(Uri url, Object payload) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    await AuthHelper.addAuthHeader(headers);
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );
  }

  /// Performs an authenticated PUT request with JWT 
  static Future<http.Response> put(Uri url, Object payload) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    await AuthHelper.addAuthHeader(headers);
    return await http.put(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );
  }

  /// You can add similar methods for DELETE if needed.
}