import 'dart:typed_data';
// Stub for web: does nothing and returns null
class WebImageFile {
  final String filename;
  final int length;
  WebImageFile(this.filename, this.length);
}

Future<dynamic> saveImageFile(String filename, Uint8List bytes) async {
  // Simulate a file object for web
  return WebImageFile(filename, bytes.length);
}
