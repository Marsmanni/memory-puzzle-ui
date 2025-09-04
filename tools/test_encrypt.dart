import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

void main() {
  // Example key (32 bytes)
  final key = encrypt.Key.fromUtf8('ThisIsMySuperSecretKeyLOL1234567');
  final iv = encrypt.IV(Uint8List.fromList(List.generate(16, (i) => i + 1)));
  final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc ));

  // Example plaintext
  String plainText = '''
Decrypted info:
version: 1.2.3
deploymentTime: 20250904175634
gitCommit: d4a6624 15:06 04.09.2025 refatoring, client info
''';

  plainText ="version:1234";

  // Encrypt the plaintext
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  String encryptedText = encrypted.base64;

  print('Key length: ${key.length}');
  print('IV bytes: ${iv.bytes}');
  print('Encrypted text length: ${encryptedText.length}');
  print('Encrypted text real: $encryptedText');

  encryptedText = "TDtRQkJyZ83lwRGS1f3ODuNotSUwZ0wecndNJW+qFk3GJoZDT/hnqDORAtJiWGugukypjCwJ3IZnPqGiAnDW8P48C2ovc0o42ySg9vyUIXnQcFaUiwWfwdqY7IuumDdnFzOmBJzkP6I/M2Bmttp32w==";
  
  // Decrypt the encrypted text
  try {
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    print('Decryption succeeded:');
    print(decrypted);
  } catch (e) {
    print('Decryption failed: $e');
  }
}