import 'dart:convert';
import 'package:http/http.dart' as http;
import '../dtos/api_dtos.dart';
import '../utils/api_endpoints.dart';

class ApiService {
  Future<List<PuzzleDto>> fetchPuzzlesDefaults() async {
    final response = await http.get(Uri.parse(ApiEndpoints.puzzlesDefaults));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => PuzzleDto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load puzzles: ${response.statusCode}');
    }
  }
}