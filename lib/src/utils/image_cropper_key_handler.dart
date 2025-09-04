import 'package:flutter/services.dart';
import '../models/image_transform_model.dart';
import '../utils/log.dart';

/// Handles keyboard events for image cropping controls.
/// Returns true if the event was handled.
bool handleImageCropperKeyEvent({
  required KeyEvent event,
  required ImageTransformModel transformModel,
  required void Function(ImageTransformModel) updateModel,
  required void Function() resetTransformations,
}) {
  if (event is! KeyDownEvent) return false;

  bool isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
  bool isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

  // Step sizes based on modifiers
  double moveStep = isCtrlPressed ? 1.0 : (isShiftPressed ? 50.0 : 10.0);
  double scaleStep = isCtrlPressed ? 0.02 : (isShiftPressed ? 0.2 : 0.1);
  double rotationStep = isCtrlPressed ? 0.02 : (isShiftPressed ? 0.5 : 0.1);

  // Helper to update model
  void update({Offset? position, double? scale, double? rotation}) {
    updateModel(
      transformModel.copyWith(
        imagePosition: position ?? transformModel.imagePosition,
        imageScale: scale ?? transformModel.imageScale,
        imageRotation: rotation ?? transformModel.imageRotation,
      ),
    );
  }

  switch (event.logicalKey) {
    // Zoom controls
    case LogicalKeyboardKey.keyQ: // Scale down
      double scaleFactor = 1.0 - scaleStep;
      double newScale = (transformModel.imageScale * scaleFactor).clamp(0.1, 5.0);
      Log.d('Key Q - Scale: $newScale');
      update(scale: newScale);
      return true;

    case LogicalKeyboardKey.keyE: // Scale up
      double scaleFactor = 1.0 + scaleStep;
      double newScale = (transformModel.imageScale * scaleFactor).clamp(0.1, 5.0);
      Log.d('Key E - Scale: $newScale');
      update(scale: newScale);
      return true;

    // Movement controls - Arrow Keys
    case LogicalKeyboardKey.arrowUp:
      Offset newPosition = transformModel.imagePosition + Offset(0, -moveStep);
      Log.d('Arrow Up - Move: $newPosition');
      update(position: newPosition);
      return true;

    case LogicalKeyboardKey.arrowDown:
      Offset newPosition = transformModel.imagePosition + Offset(0, moveStep);
      Log.d('Arrow Down - Move: $newPosition');
      update(position: newPosition);
      return true;

    case LogicalKeyboardKey.arrowLeft:
      if (isCtrlPressed || isShiftPressed) {
        double newRotation = transformModel.imageRotation - rotationStep;
        Log.d('Ctrl/Shift+Left - Rotate: $newRotation');
        update(rotation: newRotation);
      } else {
        Offset newPosition = transformModel.imagePosition + Offset(-moveStep, 0);
        Log.d('Arrow Left - Move: $newPosition');
        update(position: newPosition);
      }
      return true;

    case LogicalKeyboardKey.arrowRight:
      if (isCtrlPressed || isShiftPressed) {
        double newRotation = transformModel.imageRotation + rotationStep;
        Log.d('Ctrl/Shift+Right - Rotate: $newRotation');
        update(rotation: newRotation);
      } else {
        Offset newPosition = transformModel.imagePosition + Offset(moveStep, 0);
        Log.d('Arrow Right - Move: $newPosition');
        update(position: newPosition);
      }
      return true;

    // WASD controls
    case LogicalKeyboardKey.keyW:
      Offset newPosition = transformModel.imagePosition + Offset(0, -moveStep);
      Log.d('W - Move up: $newPosition');
      update(position: newPosition);
      return true;

    case LogicalKeyboardKey.keyS:
      Offset newPosition = transformModel.imagePosition + Offset(0, moveStep);
      Log.d('S - Move down: $newPosition');
      update(position: newPosition);
      return true;

    case LogicalKeyboardKey.keyA:
      Offset newPosition = transformModel.imagePosition + Offset(-moveStep, 0);
      Log.d('A - Move left: $newPosition');
      update(position: newPosition);
      return true;

    case LogicalKeyboardKey.keyD:
      Offset newPosition = transformModel.imagePosition + Offset(moveStep, 0);
      Log.d('D - Move right: $newPosition');
      update(position: newPosition);
      return true;

    // Rotation controls
    case LogicalKeyboardKey.keyZ:
      double newRotation = transformModel.imageRotation - rotationStep;
      Log.d('Z - Rotate left: $newRotation');
      update(rotation: newRotation);
      return true;

    case LogicalKeyboardKey.keyX:
      double newRotation = transformModel.imageRotation + rotationStep;
      Log.d('X - Rotate right: $newRotation');
      update(rotation: newRotation);
      return true;

    // Reset
    case LogicalKeyboardKey.keyR:
      Log.d('R - Reset transformations');
      resetTransformations();
      return true;
  }

  return false;
}