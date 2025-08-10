// Implementation for non-web platforms
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
Future<File> saveImageFile(String filename, Uint8List bytes) async {
  final appDir = await getApplicationDocumentsDirectory();
  final path = '${appDir.path}/$filename';
  final file = File(path);
  await file.writeAsBytes(bytes);
  return file;
}
