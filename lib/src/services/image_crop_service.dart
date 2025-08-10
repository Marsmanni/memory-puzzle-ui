import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
// Only import dart:io on non-web platforms
// ignore: avoid_web_libraries_in_flutter
// Use conditional import for file saving
import 'file_saver_stub.dart' if (dart.library.io) 'file_saver_io.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/log.dart';

/// Service class for handling image cropping operations
class ImageCropService {
  /// Helper to upload image bytes (Uint8List) to endpoint for web
  static Future<Map<String, dynamic>> uploadImageBytesToEndpoint(
    Uint8List imageBytes,
  ) async {
    try {
      final uri = Uri.parse(
        'https://memorypuzzleapi.azurewebsites.net/api/images/upload',
      );
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'image.png',
          contentType: MediaType('image', 'png'),
        ),
      );
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
        'error': e.toString(),
        'stackTrace': st.toString(),
      };
    }
  }

  /// Helper to upload image and provide feedback
  static Future<Map<String, dynamic>> uploadImageToEndpoint(
    dynamic imageFile,
  ) async {
    // On web, imageFile should be Uint8List; on non-web, it's File
    try {
      final uri = Uri.parse(
        'https://memorypuzzleapi.azurewebsites.net/api/images/upload',
      );
      Log.d('uploadImageToEndpoint called');
      Log.d('kIsWeb = $kIsWeb');
      Log.d('imageFile runtimeType = ${imageFile.runtimeType}');
      if (kIsWeb && imageFile is Uint8List) {
        Log.d('Detected web platform and Uint8List imageFile');
        return await uploadImageBytesToEndpoint(imageFile);
      } else if (!kIsWeb) {
        Log.d('Detected non-web platform, assuming imageFile is File');
        final request = http.MultipartRequest('POST', uri);
        // We assume imageFile has .readAsBytes and .path
        final fileBytes = await imageFile.readAsBytes();
        final filename = imageFile.path.split('/').last;
        Log.d('File path: ${imageFile.path}');
        Log.d('Filename: $filename');
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: filename,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
        final streamedResponse = await request.send();
        final responseBody = await streamedResponse.stream.bytesToString();
        Log.d('Response status code: ${streamedResponse.statusCode}');
        Log.d('Response body: $responseBody');
        return {
          'success': streamedResponse.statusCode == 200,
          'statusCode': streamedResponse.statusCode,
          'body': responseBody,
        };
      } else {
        Log.e('Invalid imageFile type or platform');
        return {
          'success': false,
          'error': 'Invalid imageFile type or platform',
          'platform': kIsWeb ? 'web' : 'non-web',
          'type': imageFile.runtimeType.toString(),
        };
      }
    } catch (e, st) {
      Log.e('Exception in uploadImageToEndpoint: $e');
      Log.e('STACK TRACE: $st');
      return {
        'success': false,
        'error': e.toString(),
        'stackTrace': st.toString(),
      };
    }
  }

  /// Crop and save image based on transformation parameters
  static Future<dynamic> cropAndSaveImage({
    required ui.Image originalImage,
    required Offset imagePosition,
    required double imageScale,
    required double imageRotation,
    required Size viewSize,
    required double cropSquareSize,
  }) async {
    try {
      Log.d('Starting crop operation...');
      Log.d(
        'Original image size: ${originalImage.width}x${originalImage.height}',
      );
      Log.d('View size: ${viewSize.width}x${viewSize.height}');
      Log.d('Crop square size: $cropSquareSize');
      Log.d('Image position: $imagePosition');
      Log.d('Image scale: $imageScale');
      Log.d('Image rotation: $imageRotation');

      // Quality multiplier for internal rendering
      final double qualityMultiplier = 4.0;
      final double highResCropSize = cropSquareSize * qualityMultiplier;

      Log.d('Quality multiplier: $qualityMultiplier');
      Log.d('High-res crop size: $highResCropSize');

      // Calculate view and crop centers
      final viewCenter = Offset(viewSize.width / 2, viewSize.height / 2);
      final cropCenter = viewCenter; // Crop is centered in view

      Log.d('View center: $viewCenter');
      Log.d('Crop center: $cropCenter');

      // Step 1: Create a high-resolution canvas for the crop area only
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Step 2: Set up coordinate system for crop area
      canvas.save();

      // Translate to center of the crop canvas
      canvas.translate(highResCropSize / 2, highResCropSize / 2);

      // Calculate where the image center appears relative to the crop center
      final imageCenterInView = viewCenter + imagePosition;
      final offsetFromCropCenter = imageCenterInView - cropCenter;

      Log.d('Image center in view: $imageCenterInView');
      Log.d('Offset from crop center: $offsetFromCropCenter');

      // Scale the offset for high-resolution rendering
      final scaledOffset = offsetFromCropCenter * qualityMultiplier;
      Log.d('Scaled offset: $scaledOffset');

      // Apply image transformations
      canvas.translate(scaledOffset.dx, scaledOffset.dy);
      canvas.rotate(imageRotation);
      canvas.scale(imageScale * qualityMultiplier);

      // Draw the original image centered at its own center
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

      // Step 3: Create the high-resolution cropped image
      final ui.Picture picture = recorder.endRecording();
      final ui.Image highResCroppedImage = await picture.toImage(
        highResCropSize.toInt(),
        highResCropSize.toInt(),
      );

      Log.d(
        'High-res cropped image: ${highResCroppedImage.width}x${highResCroppedImage.height}',
      );

      // Step 4: Scale down to final size with high quality
      final ui.PictureRecorder finalRecorder = ui.PictureRecorder();
      final Canvas finalCanvas = Canvas(finalRecorder);

      final finalSize = cropSquareSize.toInt();
      final finalRect = Rect.fromLTWH(
        0,
        0,
        finalSize.toDouble(),
        finalSize.toDouble(),
      );
      final sourceRect = Rect.fromLTWH(
        0,
        0,
        highResCroppedImage.width.toDouble(),
        highResCroppedImage.height.toDouble(),
      );

      final Paint finalPaint = Paint()
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true;

      finalCanvas.drawImageRect(
        highResCroppedImage,
        sourceRect,
        finalRect,
        finalPaint,
      );

      final ui.Picture finalPicture = finalRecorder.endRecording();
      final ui.Image finalImage = await finalPicture.toImage(
        finalSize,
        finalSize,
      );

      Log.d('Final image: ${finalImage.width}x${finalImage.height}');

      // Step 5: Convert to PNG and save
      final ByteData? pngBytes = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (pngBytes == null) {
        throw Exception('Could not convert cropped image to PNG');
      }

      dynamic newImageFile;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filename =
          'cropped_${finalSize}x${finalSize}_$timestamp.png';
      newImageFile = await saveImageFile(
        filename,
        pngBytes.buffer.asUint8List(),
      );
      if (newImageFile != null) {
        Log.d('Image saved to: $filename');
        // Print file size for both platforms
        if (newImageFile is WebImageFile) {
          Log.d('File size: ${newImageFile.length} bytes');
        } else if (newImageFile.length is int) {
          Log.d('File size: ${await newImageFile.length()} bytes');
        }
      } else {
        Log.d('Skipping local image save (web platform)');
      }
      // Clean up
      highResCroppedImage.dispose();
      finalImage.dispose();
      // On web, cannot return File; return null
      return newImageFile;
    } catch (e, stackTrace) {
      Log.e('Crop operation failed: $e');
      Log.e('STACK TRACE: $stackTrace');
      rethrow;
    }
  }

  /// Crop and save the exact visual representation from the cropping area 1:1
  /// This captures exactly what is visible in the crop area at the actual displayed size
  static Future<dynamic> cropAndSaveImageFromScreen({
    required ui.Image originalImage,
    required Offset imagePosition,
    required double imageScale,
    required double imageRotation,
    required Size viewSize,
    required double cropSquareSize,
    double targetSize = 200.0, // Keep at 200 pixels,
    void Function(Map<String, dynamic> uploadResult)? onUploadResult,
  }) async {
    try {
      Log.d('Starting screen crop operation...');
      Log.d(
        'Original image size: ${originalImage.width}x${originalImage.height}',
      );
      Log.d('View size: ${viewSize.width}x${viewSize.height}');
      Log.d('Crop square size: $cropSquareSize');
      Log.d('Target size: $targetSize');
      Log.d('Image position: $imagePosition');
      Log.d('Image scale: $imageScale');
      Log.d('Image rotation: $imageRotation');

      // Quality multiplier for better rendering
      final double qualityMultiplier = 4.0;
      final double highResTargetSize = targetSize * qualityMultiplier;

      Log.d('Quality multiplier: $qualityMultiplier');
      Log.d('High-res target size: $highResTargetSize');

      // Calculate view and crop centers
      final viewCenter = Offset(viewSize.width / 2, viewSize.height / 2);
      final cropCenter = viewCenter; // Crop is centered in view

      Log.d('View center: $viewCenter');
      Log.d('Crop center: $cropCenter');

      // Step 1: Create a high-resolution canvas for the target size
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Step 2: Set up coordinate system
      canvas.save();

      // Translate to center of the target canvas
      canvas.translate(highResTargetSize / 2, highResTargetSize / 2);

      // Calculate scaling factor from crop area to target size
      final cropToTargetScale = targetSize / cropSquareSize;
      Log.d('Crop to target scale: $cropToTargetScale');

      // Scale for both target size and quality
      canvas.scale(qualityMultiplier * cropToTargetScale);

      // Calculate where the image center appears relative to the crop center
      final imageCenterInView = viewCenter + imagePosition;
      final offsetFromCropCenter = imageCenterInView - cropCenter;

      Log.d('Image center in view: $imageCenterInView');
      Log.d('Offset from crop center: $offsetFromCropCenter');

      // Apply image transformations
      canvas.translate(offsetFromCropCenter.dx, offsetFromCropCenter.dy);
      canvas.rotate(imageRotation);
      canvas.scale(imageScale);

      // Draw the original image centered at its own center
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

      // Step 3: Create the high-resolution image
      final ui.Picture picture = recorder.endRecording();
      final ui.Image highResImage = await picture.toImage(
        highResTargetSize.toInt(),
        highResTargetSize.toInt(),
      );

      Log.d(
        'High-res image created: ${highResImage.width}x${highResImage.height}',
      );

      // Step 4: Scale down to final target size with high quality
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

      Log.d(
        'Final screen cropped image: ${finalImage.width}x${finalImage.height}',
      );

      // Step 5: Convert to PNG and save
      final ByteData? pngBytes = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (pngBytes == null) {
        throw Exception('Could not convert screen cropped image to PNG');
      }

      dynamic newImageFile;
      Uint8List pngData = pngBytes.buffer.asUint8List();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filename = 'screen_${finalSize}x${finalSize}_$timestamp.png';
      newImageFile = await saveImageFile(filename, pngData);
      if (newImageFile != null) {
        Log.d('Screen cropped image saved to: $filename');
        // Print file size for both platforms
        if (newImageFile is WebImageFile) {
          Log.d('File size (WebImageFile): ${newImageFile.length} bytes');
        } else if (newImageFile.length is int) {
          Log.d('File size: (real file) ${await newImageFile.length()} bytes');
        }
        // Upload the image in a separate future and provide UI feedback
        Future(() async {
          final result = await uploadImageToEndpoint(
            kIsWeb ? pngData : newImageFile!,
          );
          Log.d('Upload result: $result');
          if (onUploadResult != null) {
            onUploadResult(result);
          }
        });
      } else {
        Log.d('Web platform detected, uploading using byte array');
        Future(() async {
          final result = await uploadImageBytesToEndpoint(pngData);
          Log.d('Upload result: $result');
          if (onUploadResult != null) {
            onUploadResult(result);
          }
        });
      }
      // Clean up
      highResImage.dispose();
      finalImage.dispose();
      // On web, cannot return File; return null
      return newImageFile;
    } catch (e, stackTrace) {
      Log.e('Screen crop operation failed: $e');
      Log.e('STACK TRACE: $stackTrace');
      rethrow;
    }
  }
}
