import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/image_transform_model.dart';
import '../utils/app_localizations.dart';

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
            child: Text(
              AppLocalizations.get('cropperPage.helpText'),
              style: const TextStyle(
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
                  AppLocalizations.format(
                    'cropperPage.currentScale',
                    {'scale': transformModel.imageScale.toStringAsFixed(2)},
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                Text(
                  AppLocalizations.format(
                    'cropperPage.currentOffset',
                    {
                      'dx': transformModel.imagePosition.dx.toStringAsFixed(1),
                      'dy': transformModel.imagePosition.dy.toStringAsFixed(1),
                    },
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                if (transformModel.originalImage != null)
                  Text(
                    AppLocalizations.format(
                      'cropperPage.imageSize',
                      {
                        'width': transformModel.originalImage!.width.toString(),
                        'height': transformModel.originalImage!.height.toString(),
                      },
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                if (croppedImageBytes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.get('cropperPage.preview'),
                          style: const TextStyle(
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