import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';

/// Model class to hold image transformation state
class ImageTransformModel {
  ui.Image? originalImage;
  XFile? imageFile;
  bool isImageLoaded;
  
  // Transformation values
  Offset imagePosition;
  double imageScale;
  double imageRotation;

  // Gesture state
  double previousScale;
  double previousRotation;
  Offset previousPosition;

  ImageTransformModel({
    this.originalImage,
    this.imageFile,
    this.isImageLoaded = false,
    this.imagePosition = Offset.zero,
    this.imageScale = AppConstants.defaultScale,
    this.imageRotation = AppConstants.defaultRotation,
    this.previousScale = AppConstants.defaultScale,
    this.previousRotation = AppConstants.defaultRotation,
    this.previousPosition = Offset.zero,
  });

  /// Reset all transformations
  void resetTransformations() {
    imagePosition = Offset.zero;
    imageScale = AppConstants.defaultScale;
    imageRotation = AppConstants.defaultRotation;
  }

  /// Update gesture state
  void updateGestureState({
    required double scale,
    required double rotation,
    required Offset position,
  }) {
    previousScale = scale;
    previousRotation = rotation;
    previousPosition = position;
  }

  /// Update transformations
  void updateTransformations({
    required Offset position,
    required double scale,
    required double rotation,
  }) {
    imagePosition = position;
    imageScale = scale;
    imageRotation = rotation;
  }

  /// Copy with new values
  ImageTransformModel copyWith({
    ui.Image? originalImage,
    XFile? imageFile,
    bool? isImageLoaded,
    Offset? imagePosition,
    double? imageScale,
    double? imageRotation,
    double? previousScale,
    double? previousRotation,
    Offset? previousPosition,
  }) {
    return ImageTransformModel(
      originalImage: originalImage ?? this.originalImage,
      imageFile: imageFile ?? this.imageFile,
      isImageLoaded: isImageLoaded ?? this.isImageLoaded,
      imagePosition: imagePosition ?? this.imagePosition,
      imageScale: imageScale ?? this.imageScale,
      imageRotation: imageRotation ?? this.imageRotation,
      previousScale: previousScale ?? this.previousScale,
      previousRotation: previousRotation ?? this.previousRotation,
      previousPosition: previousPosition ?? this.previousPosition,
    );
  }
}
