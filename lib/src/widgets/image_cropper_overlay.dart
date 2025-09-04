import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A custom painter that draws a semi-transparent overlay
/// with a transparent square in the center
class ImageCropperOverlayPainter extends CustomPainter {
  /// The size of the square cutout
  final double cropSquareSize;

  const ImageCropperOverlayPainter({required this.cropSquareSize});

  @override
  void paint(Canvas canvas, Size size) {
    // Define the overall semi-transparent background paint
    final backgroundPaint = Paint()
      ..color = Color.fromRGBO(0, 0, 0, AppConstants.overlayOpacity);

    // Define the border paint for the crop square
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppConstants.borderWidth;

    // Calculate the position and size of the square cutout
    final double left = (size.width - cropSquareSize) / 2;
    final double top = (size.height - cropSquareSize) / 2;
    final Rect cropRect = Rect.fromLTWH(left, top, cropSquareSize, cropSquareSize);
    
    // Create a rounded rectangle for the cutout and border
    final RRect cropRRect = RRect.fromRectAndRadius(
      cropRect, 
      const Radius.circular(AppConstants.borderRadius)
    );

    // Create a Path that represents the entire screen with a "hole" in the middle
    final Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cropRRect)
      ..fillType = PathFillType.evenOdd;

    // Draw the semi-transparent overlay using the new Path
    canvas.drawPath(path, backgroundPaint);

    // Draw the white rounded border around the square
    canvas.drawRRect(cropRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant ImageCropperOverlayPainter oldDelegate) {
    // Only repaint if the crop square size changes
    return oldDelegate.cropSquareSize != cropSquareSize;
  }
}
