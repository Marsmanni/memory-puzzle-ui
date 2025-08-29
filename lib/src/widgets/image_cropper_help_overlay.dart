import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/image_transform_model.dart';

class ImageCropperHelpOverlay extends StatelessWidget {
  final ImageTransformModel transformModel;
  final Uint8List? croppedImageBytes;
  const ImageCropperHelpOverlay({
    super.key,
    required this.transformModel,
    this.croppedImageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'ENHANCED CONTROLS:\n'
              '🖱️ Mouse:\n'
              '  • Scroll = Zoom\n'
              '  • Shift+Scroll = Rotate\n'
              '  • Ctrl+Scroll = Precise Zoom\n'
              '  • Ctrl+Shift+Scroll = Precise Rotate\n'
              '  • Drag = Move\n'
              '  • Ctrl+Drag = Zoom\n'
              '  • Ctrl+Shift+Drag = Rotate\n'
              '⌨️ Keyboard:\n'
              '  • Arrow/WASD = Move\n'
              '  • Ctrl+Arrow/WASD = Precise Move\n'
              '  • Shift+Arrow/WASD = Fast Move\n'
              '  • Ctrl+Left/Right = Precise Rotate\n'
              '  • Q/E = Zoom\n'
              '  • Z/X = Rotate\n'
              '  • R = Reset',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current scale: ${transformModel.imageScale.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Current offset: (${transformModel.imagePosition.dx.toStringAsFixed(1)}, ${transformModel.imagePosition.dy.toStringAsFixed(1)})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                if (transformModel.originalImage != null)
                  Text(
                    'Image size: ${transformModel.originalImage!.width} x ${transformModel.originalImage!.height}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                // Cropped image preview under metrics
                if (croppedImageBytes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: [
                        const Text(
                          'Preview',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Image.memory(
                          croppedImageBytes!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}