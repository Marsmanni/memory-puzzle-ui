import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../utils/api_endpoints.dart';
import '../utils/log.dart';
import 'auth_helper.dart'; 

// Only import dart:io on non-web platforms
// ignore: avoid_web_libraries_in_flutter
// Use conditional import for file saving
import 'file_saver_stub.dart' if (dart.library.io) 'file_saver_io.dart';

/// Service class for handling image cropping operations
class ImageCropService {
  /// Helper to upload image bytes (Uint8List) to endpoint for web
  static Future<dynamic> uploadImageBytesToEndpoint({
    required String filegroup,
    required Uint8List imageBytes,
  }) async {
    try {
      final uri = Uri.parse(ApiEndpoints.imagesUpload);
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'image.png',
          contentType: MediaType('image', 'png'),
        ),
      );
      request.fields['filegroup'] = filegroup;
      // Use AuthHelper to add JWT header
      await AuthHelper.addAuthHeader(request.headers);
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      return {
        'success': streamedResponse.statusCode == 200,
        'statusCode': streamedResponse.statusCode,
        'body': responseBody,
      };
    } catch (e, st) {
      return {
        'success': false,
        'error': '$e',
        'stackTrace': st.toString(),
      };
    }
  }

  /// Crop the image and return PNG bytes
  static Future<Uint8List> cropImage({
    required ui.Image originalImage,
    required Offset imagePosition,
    required double imageScale,
    required double imageRotation,
    required Size viewSize,
    required double cropSquareSize,
    double targetSize = 200.0,
  }) async {
    Log.d('Starting cropImage...');
    final double qualityMultiplier = 4.0;
    final double highResTargetSize = targetSize * qualityMultiplier;
    final viewCenter = Offset(viewSize.width / 2, viewSize.height / 2);
    final cropCenter = viewCenter;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.save();
    canvas.translate(highResTargetSize / 2, highResTargetSize / 2);
    final cropToTargetScale = targetSize / cropSquareSize;
    canvas.scale(qualityMultiplier * cropToTargetScale);
    final imageCenterInView = viewCenter + imagePosition;
    final offsetFromCropCenter = imageCenterInView - cropCenter;
    canvas.translate(offsetFromCropCenter.dx, offsetFromCropCenter.dy);
    canvas.rotate(imageRotation);
    canvas.scale(imageScale);
    final imageSize = Size(
      originalImage.width.toDouble(),
      originalImage.height.toDouble(),
    );
    final imageDrawOffset = Offset(
      -imageSize.width / 2,
      -imageSize.height / 2,
    );
    final Paint highQualityPaint = Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true;
    canvas.drawImage(originalImage, imageDrawOffset, highQualityPaint);
    canvas.restore();
    final ui.Picture picture = recorder.endRecording();
    final ui.Image highResImage = await picture.toImage(
      highResTargetSize.toInt(),
      highResTargetSize.toInt(),
    );
    final ui.PictureRecorder finalRecorder = ui.PictureRecorder();
    final Canvas finalCanvas = Canvas(finalRecorder);
    final finalSize = targetSize.toInt();
    final finalRect = Rect.fromLTWH(
      0,
      0,
      finalSize.toDouble(),
      finalSize.toDouble(),
    );
    final sourceRect = Rect.fromLTWH(
      0,
      0,
      highResImage.width.toDouble(),
      highResImage.height.toDouble(),
    );
    final Paint finalPaint = Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true;
    finalCanvas.drawImageRect(
      highResImage,
      sourceRect,
      finalRect,
      finalPaint,
    );
    final ui.Picture finalPicture = finalRecorder.endRecording();
    final ui.Image finalImage = await finalPicture.toImage(
      finalSize,
      finalSize,
    );
    final ByteData? pngBytes = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    highResImage.dispose();
    finalImage.dispose();
    if (pngBytes == null) {
      throw Exception('Could not convert cropped image to PNG');
    }
    return pngBytes.buffer.asUint8List();
  }

  /// Save PNG bytes to disk (non-web platforms)
  static Future<dynamic> saveImage({
    required String filename,
    required Uint8List pngData,
  }) async {
    final file = await saveImageFile(filename, pngData);
    if (file != null) {
      Log.d('Image saved to: $filename');
      try {
        if (file.length is int) {
          Log.d('File size: (real file) ${await file.length()} bytes');
        }
      } catch (_) {}
    } else {
      Log.d('Skipping local image save (web platform)');
    }
    return file;
  }
}
