import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Service class for handling image operations
class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Load an image from assets
  static Future<ui.Image> loadImageFromAssets(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  /// Pick an image from gallery
  static Future<XFile?> pickImageFromGallery() async {
    return await _picker.pickImage(source: ImageSource.gallery);
  }

  /// Convert XFile to ui.Image
  static Future<ui.Image> xFileToUiImage(XFile imageFile) async {
    final data = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Save a ui.Image to file
  static Future<File> saveImageToFile(ui.Image image, String filename) async {
    try {
      // Convert the image to a byte format
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Could not convert image to byte data.');
      }

      // Get a suitable directory to save the file
      final directory = await getTemporaryDirectory();

      // Create a File object with the specified filename
      final file = File('${directory.path}/$filename');

      // Write the byte data to the file
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      return file;
    } catch (e) {
      throw Exception('Error saving image: $e');
    }
  }

  /// Save image as four parts
  static Future<List<File>> saveImageAsFourParts(ui.Image image, String filenamePrefix) async {
    try {
      // Calculate the dimensions for each of the four parts
      final int halfWidth = image.width ~/ 2;
      final int halfHeight = image.height ~/ 2;

      final List<File> savedFiles = [];

      // Define the source rectangles for each quadrant of the original image
      final List<Rect> sourceRects = [
        Rect.fromLTWH(0, 0, halfWidth.toDouble(), halfHeight.toDouble()), // Top-left
        Rect.fromLTWH(halfWidth.toDouble(), 0, halfWidth.toDouble(), halfHeight.toDouble()), // Top-right
        Rect.fromLTWH(0, halfHeight.toDouble(), halfWidth.toDouble(), halfHeight.toDouble()), // Bottom-left
        Rect.fromLTWH(halfWidth.toDouble(), halfHeight.toDouble(), halfWidth.toDouble(), halfHeight.toDouble()), // Bottom-right
      ];

      // Define the destination rectangle for each new image
      final Rect destRect = Rect.fromLTWH(0, 0, halfWidth.toDouble(), halfHeight.toDouble());
      
      final directory = await getTemporaryDirectory();

      for (int i = 0; i < sourceRects.length; i++) {
        // Create a new PictureRecorder and Canvas for each part
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder, destRect);

        // Draw the specific quadrant of the original image onto the new canvas
        canvas.drawImageRect(image, sourceRects[i], destRect, Paint());

        // Finalize the recording and convert it to a new image
        final ui.Picture picture = recorder.endRecording();
        final ui.Image partImage = await picture.toImage(halfWidth, halfHeight);

        // Convert the new image part to PNG bytes
        final ByteData? byteData = await partImage.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          throw Exception('Could not convert image part $i to byte data.');
        }

        // Create a filename for the part and save it
        final filename = '${filenamePrefix}_part${i + 1}.png';
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        savedFiles.add(file);
      }
      
      return savedFiles;
    } catch (e) {
      throw Exception('Error saving image parts: $e');
    }
  }
}
