import 'dart:io';
import 'dart:math';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

/// Service class for handling image cropping operations
class ImageCropService {
  /// Helper to upload image and provide feedback
  static Future<Map<String, dynamic>> uploadImageToEndpoint(File imageFile) async {
    try {
      final uri = Uri.parse('https://azureapisample.azurewebsites.net/api/images/upload');
      final request = HttpClient();
      final httpRequest = await request.postUrl(uri);
      httpRequest.headers.set('authority', 'azureapisample.azurewebsites.net');
      httpRequest.headers.set('method', 'POST');
      httpRequest.headers.set('path', '/api/images/upload');
      httpRequest.headers.set('scheme', 'https');
      httpRequest.headers.set('accept', '*/*');
      httpRequest.headers.set('accept-encoding', 'gzip, deflate, br, zstd');
      httpRequest.headers.set('accept-language', 'de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7');
      httpRequest.headers.set('cache-control', 'no-cache');
      httpRequest.headers.set('origin', 'https://azureapisample.azurewebsites.net');
      httpRequest.headers.set('pragma', 'no-cache');
      httpRequest.headers.set('priority', 'u=1, i');
      httpRequest.headers.set('referer', 'https://azureapisample.azurewebsites.net/swagger/index.html');
      httpRequest.headers.set('sec-ch-ua', '"Not)A;Brand";v="8", "Chromium";v="138", "Google Chrome";v="138"');
      httpRequest.headers.set('sec-ch-ua-mobile', '?0');
      httpRequest.headers.set('sec-ch-ua-platform', '"Windows"');
      httpRequest.headers.set('sec-fetch-dest', 'empty');
      httpRequest.headers.set('sec-fetch-mode', 'cors');
      httpRequest.headers.set('sec-fetch-site', 'same-origin');
      httpRequest.headers.add('cookie', 'ARRAffinity=f4edef8e8ae33d792aa347f6380e743b9805a4dd08725995c30ae1f829052383; ARRAffinitySameSite=f4edef8e8ae33d792aa347f6380e743b9805a4dd08725995c30ae1f829052383');
      final boundary = '----WebKitFormBoundaryLWsMPjfxMuxE2n27';
      httpRequest.headers.set('content-type', 'multipart/form-data; boundary=$boundary');
      final fileBytes = await imageFile.readAsBytes();
      final filename = imageFile.path.split(Platform.pathSeparator).last;
      final body = <int>[];
      body.addAll(utf8.encode('--$boundary\r\n'));
      body.addAll(utf8.encode('Content-Disposition: form-data; name="file"; filename="$filename"\r\n'));
      body.addAll(utf8.encode('Content-Type: image/jpeg\r\n\r\n'));
      body.addAll(fileBytes);
      body.addAll(utf8.encode('\r\n--$boundary--\r\n'));
      httpRequest.add(body);
      final httpResponse = await httpRequest.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      return {
        'success': httpResponse.statusCode == 200,
        'statusCode': httpResponse.statusCode,
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
  
  /// Crop and save image based on transformation parameters
  static Future<File> cropAndSaveImage({
    required ui.Image originalImage,
    required Offset imagePosition,
    required double imageScale,
    required double imageRotation,
    required Size viewSize,
    required double cropSquareSize,
  }) async {
    try {
      print('DEBUG: Starting crop operation...');
      print('DEBUG: Original image size: ${originalImage.width}x${originalImage.height}');
      print('DEBUG: View size: ${viewSize.width}x${viewSize.height}');
      print('DEBUG: Crop square size: $cropSquareSize');
      print('DEBUG: Image position: $imagePosition');
      print('DEBUG: Image scale: $imageScale');
      print('DEBUG: Image rotation: $imageRotation');

      // Quality multiplier for internal rendering
      final double qualityMultiplier = 4.0;
      final double highResCropSize = cropSquareSize * qualityMultiplier;
      
      print('DEBUG: Quality multiplier: $qualityMultiplier');
      print('DEBUG: High-res crop size: $highResCropSize');

      // Calculate view and crop centers
      final viewCenter = Offset(viewSize.width / 2, viewSize.height / 2);
      final cropCenter = viewCenter; // Crop is centered in view
      
      print('DEBUG: View center: $viewCenter');
      print('DEBUG: Crop center: $cropCenter');

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
      
      print('DEBUG: Image center in view: $imageCenterInView');
      print('DEBUG: Offset from crop center: $offsetFromCropCenter');
      
      // Scale the offset for high-resolution rendering
      final scaledOffset = offsetFromCropCenter * qualityMultiplier;
      print('DEBUG: Scaled offset: $scaledOffset');
      
      // Apply image transformations
      canvas.translate(scaledOffset.dx, scaledOffset.dy);
      canvas.rotate(imageRotation);
      canvas.scale(imageScale * qualityMultiplier);
      
      // Draw the original image centered at its own center
      final imageSize = Size(originalImage.width.toDouble(), originalImage.height.toDouble());
      final imageDrawOffset = Offset(-imageSize.width / 2, -imageSize.height / 2);
      
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
      
      print('DEBUG: High-res cropped image: ${highResCroppedImage.width}x${highResCroppedImage.height}');
      
      // Step 4: Scale down to final size with high quality
      final ui.PictureRecorder finalRecorder = ui.PictureRecorder();
      final Canvas finalCanvas = Canvas(finalRecorder);
      
      final finalSize = cropSquareSize.toInt();
      final finalRect = Rect.fromLTWH(0, 0, finalSize.toDouble(), finalSize.toDouble());
      final sourceRect = Rect.fromLTWH(0, 0, highResCroppedImage.width.toDouble(), highResCroppedImage.height.toDouble());
      
      final Paint finalPaint = Paint()
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true;
      
      finalCanvas.drawImageRect(highResCroppedImage, sourceRect, finalRect, finalPaint);
      
      final ui.Picture finalPicture = finalRecorder.endRecording();
      final ui.Image finalImage = await finalPicture.toImage(finalSize, finalSize);
      
      print('DEBUG: Final image: ${finalImage.width}x${finalImage.height}');
      
      // Step 5: Convert to PNG and save
      final ByteData? pngBytes = await finalImage.toByteData(format: ui.ImageByteFormat.png);
      if (pngBytes == null) {
        throw Exception('Could not convert cropped image to PNG');
      }
      
      // Save the file
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String path = '${appDir.path}/cropped_${finalSize}x${finalSize}_$timestamp.png';
      final File newImageFile = File(path);
      
      await newImageFile.writeAsBytes(pngBytes.buffer.asUint8List());
      
      print('DEBUG: Image saved to: $path');
      print('DEBUG: File size: ${await newImageFile.length()} bytes');
      
      // Clean up
      highResCroppedImage.dispose();
      finalImage.dispose();
      
      return newImageFile;
      
    } catch (e, stackTrace) {
      print('ERROR: Crop operation failed: $e');
      print('STACK TRACE: $stackTrace');
      rethrow;
    }
  }

  /// Crop and save the exact visual representation from the cropping area 1:1
  /// This captures exactly what is visible in the crop area at the actual displayed size
  static Future<File> cropAndSaveImageFromScreen({
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
      print('DEBUG: Starting screen crop operation...');
      print('DEBUG: Original image size: ${originalImage.width}x${originalImage.height}');
      print('DEBUG: View size: ${viewSize.width}x${viewSize.height}');
      print('DEBUG: Crop square size: $cropSquareSize');
      print('DEBUG: Target size: $targetSize');
      print('DEBUG: Image position: $imagePosition');
      print('DEBUG: Image scale: $imageScale');
      print('DEBUG: Image rotation: $imageRotation');

      // Quality multiplier for better rendering
      final double qualityMultiplier = 4.0;
      final double highResTargetSize = targetSize * qualityMultiplier;
      
      print('DEBUG: Quality multiplier: $qualityMultiplier');
      print('DEBUG: High-res target size: $highResTargetSize');

      // Calculate view and crop centers
      final viewCenter = Offset(viewSize.width / 2, viewSize.height / 2);
      final cropCenter = viewCenter; // Crop is centered in view
      
      print('DEBUG: View center: $viewCenter');
      print('DEBUG: Crop center: $cropCenter');

      // Step 1: Create a high-resolution canvas for the target size
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      
      // Step 2: Set up coordinate system
      canvas.save();
      
      // Translate to center of the target canvas
      canvas.translate(highResTargetSize / 2, highResTargetSize / 2);
      
      // Calculate scaling factor from crop area to target size
      final cropToTargetScale = targetSize / cropSquareSize;
      print('DEBUG: Crop to target scale: $cropToTargetScale');
      
      // Scale for both target size and quality
      canvas.scale(qualityMultiplier * cropToTargetScale);
      
      // Calculate where the image center appears relative to the crop center
      final imageCenterInView = viewCenter + imagePosition;
      final offsetFromCropCenter = imageCenterInView - cropCenter;
      
      print('DEBUG: Image center in view: $imageCenterInView');
      print('DEBUG: Offset from crop center: $offsetFromCropCenter');
      
      // Apply image transformations
      canvas.translate(offsetFromCropCenter.dx, offsetFromCropCenter.dy);
      canvas.rotate(imageRotation);
      canvas.scale(imageScale);
      
      // Draw the original image centered at its own center
      final imageSize = Size(originalImage.width.toDouble(), originalImage.height.toDouble());
      final imageDrawOffset = Offset(-imageSize.width / 2, -imageSize.height / 2);
      
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
      
      print('DEBUG: High-res image created: ${highResImage.width}x${highResImage.height}');
      
      // Step 4: Scale down to final target size with high quality
      final ui.PictureRecorder finalRecorder = ui.PictureRecorder();
      final Canvas finalCanvas = Canvas(finalRecorder);
      
      final finalSize = targetSize.toInt();
      final finalRect = Rect.fromLTWH(0, 0, finalSize.toDouble(), finalSize.toDouble());
      final sourceRect = Rect.fromLTWH(0, 0, highResImage.width.toDouble(), highResImage.height.toDouble());
      
      final Paint finalPaint = Paint()
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true;
      
      finalCanvas.drawImageRect(highResImage, sourceRect, finalRect, finalPaint);
      
      final ui.Picture finalPicture = finalRecorder.endRecording();
      final ui.Image finalImage = await finalPicture.toImage(finalSize, finalSize);
      
      print('DEBUG: Final screen cropped image: ${finalImage.width}x${finalImage.height}');
      
      // Step 5: Convert to PNG and save
      final ByteData? pngBytes = await finalImage.toByteData(format: ui.ImageByteFormat.png);
      if (pngBytes == null) {
        throw Exception('Could not convert screen cropped image to PNG');
      }
      
      // Save the file
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String path = '${appDir.path}/screen_${finalSize}x${finalSize}_$timestamp.png';
      final File newImageFile = File(path);
      
      await newImageFile.writeAsBytes(pngBytes.buffer.asUint8List());
      
      print('DEBUG: Screen cropped image saved to: $path');
      print('DEBUG: File size: ${await newImageFile.length()} bytes');
      
      // Clean up
      highResImage.dispose();
      finalImage.dispose();

      // Upload the image in a separate future and provide UI feedback
      Future(() async {
        final result = await uploadImageToEndpoint(newImageFile);
        print('DEBUG: Upload result: $result');
        if (onUploadResult != null) {
          onUploadResult(result);
        }
      });

      return newImageFile;
    } catch (e, stackTrace) {
      print('ERROR: Screen crop operation failed: $e');
      print('STACK TRACE: $stackTrace');
      rethrow;
    }
  }
}