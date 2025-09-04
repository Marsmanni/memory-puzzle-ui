import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../dtos/api_dtos.dart';
import '../services/auth_http_service.dart';
import '../utils/api_endpoints.dart';

Future<String> decryptDeploymentText(String encryptedText, String key) async {
  final keyBytes = encrypt.Key.fromUtf8(key.padRight(32).substring(0,32));
  final iv = encrypt.IV.fromLength(16); // Must match PowerShell IV
  final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
  final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
  return decrypted;
}

/// Data model for the parsed client deployment information.
class ClientDeploymentInfo {
  final String version;
  final DateTime? deploymentTime;
  final String gitCommit;

  ClientDeploymentInfo({
    required this.version,
    this.deploymentTime,
    required this.gitCommit,
  });

  factory ClientDeploymentInfo.fromDecryptedText(String text) {
    final map = Map.fromEntries(text.trim().split('\n').map((line) {
      final parts = line.split(':');
      if (parts.length >= 2) {
        final key = parts.first.trim();
        final value = parts.sublist(1).join(':').trim();
        return MapEntry(key, value);
      }
      return const MapEntry('', '');
    }).where((entry) => entry.key.isNotEmpty));

    String deploymentTimeRaw = map['deploymentTime'] ?? '';
    DateTime? deploymentTime;
    if (deploymentTimeRaw.length == 14) {
      deploymentTime = DateTime.tryParse(
        '${deploymentTimeRaw.substring(0,4)}-'
        '${deploymentTimeRaw.substring(4,6)}-'
        '${deploymentTimeRaw.substring(6,8)}T'
        '${deploymentTimeRaw.substring(8,10)}:'
        '${deploymentTimeRaw.substring(10,12)}:'
        '${deploymentTimeRaw.substring(12,14)}'
      );
    } else {
      deploymentTime = DateTime.tryParse(deploymentTimeRaw);
    }

    return ClientDeploymentInfo(
      version: map['version'] ?? '',
      gitCommit: map['gitCommit'] ?? '',
      deploymentTime: deploymentTime,
    );
  }
}

/// A custom exception for better error handling.
class SystemInfoException implements Exception {
  final String message;
  SystemInfoException(this.message);
}

/// Service responsible for fetching and processing system information.
class SystemInfoService {
  Future<SystemInfoDto> getCombinedSystemInfo() async {
    try {
      final serverInfo = await _fetchServerInfo();
      final clientInfo = await _getClientDeploymentInfo(serverInfo.adminDecryptionKeyClient);
      serverInfo.clientVersion = clientInfo.version;
      serverInfo.clientDeploymentTime = clientInfo.deploymentTime;
      serverInfo.clientGitVersion = clientInfo.gitCommit;
      return serverInfo;
    } on Exception catch (e) {
      debugPrint("Failed to get system info: $e");
      throw SystemInfoException('Could not retrieve system information. Please try again.');
    }
  }
  
  Future<SystemInfoDto> _fetchServerInfo() async {
    final response = await AuthHttpService.get(Uri.parse(ApiEndpoints.adminInfo));
    if (response.statusCode == 200) {
      return SystemInfoDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Server returned error: ${response.statusCode}');
    }
  }

  Future<ClientDeploymentInfo> _getClientDeploymentInfo(String decryptionKey) async {
    String encryptedText;
    try {
      encryptedText = await rootBundle.loadString('assets/deployment.txt');
    } catch (e) {
      debugPrint('Could not load deployment.txt, using fallback.');
      encryptedText = 'y5y5EwPM6E8okvCpgVkFGb0UUIePRWxhzA0SSxVGenLKPwPxFiw4O3Njhf55m68UpKnI6Vej1HEZ92ZXh3nC/O0StAUYEpgzAfFfWq+14Vt3/BivxHHv4bOds32ug9elCpur6PMerUZBsIo1SL4DrA==';
    }

    debugPrint("--> Step 1: About to decrypt text...");
    String decryptedText;
    try {
      decryptedText = await decryptDeploymentText(encryptedText, decryptionKey);
    } catch (e) {
      debugPrint('Decryption failed, using fallback decrypted text.');
      decryptedText = '''
version: debug
deploymentTime: 20250312231111
gitCommit: debug-local
''';
    }

    return ClientDeploymentInfo.fromDecryptedText(decryptedText);
  }
}