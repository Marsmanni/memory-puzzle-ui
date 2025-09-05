import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';

import '../dtos/api_dtos.dart';
import '../services/auth_http_service.dart';
import '../utils/api_endpoints.dart';
import '../utils/log.dart';

Future<String> decryptDeploymentText(String encryptedText, String key) async {
  final keyBytes = encrypt.Key.fromUtf8(key.padRight(32).substring(0, 32));
  final iv = encrypt.IV(Uint8List.fromList(List.generate(16, (i) => i + 1)));
  final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));
  return encrypter.decrypt64(encryptedText, iv: iv);
}

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
    final map = Map.fromEntries(
      text.trim().split('\n').map((line) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts.first.trim();
          final value = parts.sublist(1).join(':').trim();
          return MapEntry(key, value);
        }
        return const MapEntry('', '');
      }).where((entry) => entry.key.isNotEmpty),
    );

    final deploymentTimeRaw = map['deploymentTime'] ?? '';
    DateTime? deploymentTime;
    if (deploymentTimeRaw.length == 14) {
      deploymentTime = DateTime.tryParse(
        '${deploymentTimeRaw.substring(0, 4)}-'
        '${deploymentTimeRaw.substring(4, 6)}-'
        '${deploymentTimeRaw.substring(6, 8)}T'
        '${deploymentTimeRaw.substring(8, 10)}:'
        '${deploymentTimeRaw.substring(10, 12)}:'
        '${deploymentTimeRaw.substring(12, 14)}',
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

class SystemInfoException implements Exception {
  final String message;
  SystemInfoException(this.message);
}

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
      Log.e("Failed to get system info: $e");
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
    final ClientDeploymentInfo clientDeploymentInfoMissing = ClientDeploymentInfo(
      version: 'missing',
      deploymentTime: DateTime.now(),
      gitCommit: 'missing',
    );

    String encryptedText;
    try {
      encryptedText = (await rootBundle.loadString('assets/deployment.txt')).trim();
    } catch (e) {
      Log.e('Could not load deployment.txt, using fallback.');
      return clientDeploymentInfoMissing;
    }

    String decryptedText;
    try {
      decryptedText = await decryptDeploymentText(encryptedText, decryptionKey);
    } catch (e) {
      Log.e("Decryption failed, using fallback decrypted text: $e");
      return clientDeploymentInfoMissing;
    }

    return ClientDeploymentInfo.fromDecryptedText(decryptedText);
  }
}
