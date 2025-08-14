import 'package:flutter/material.dart';
import '../models/image_transform_model.dart';

/// Widget for displaying and interacting with transformable image
class TransformableImageWidget extends StatelessWidget {
  final ImageTransformModel transformModel;
  final Function(ScaleStartDetails) onScaleStart;
  final Function(ScaleUpdateDetails) onScaleUpdate;

  const TransformableImageWidget({
    super.key,
    required this.transformModel,
    required this.onScaleStart,
    required this.onScaleUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (!transformModel.isImageLoaded || transformModel.originalImage == null) {
      return const Center(
        child: Text('Select an image to begin.'),
      );
    }

    return GestureDetector(
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      child: Center(
        child: Transform.translate(
          offset: transformModel.imagePosition,
          child: Transform.scale(
            scale: transformModel.imageScale,
            child: Transform.rotate(
              angle: transformModel.imageRotation,
              child: RawImage(
                image: transformModel.originalImage,
                fit: BoxFit.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
