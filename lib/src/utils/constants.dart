/// App-wide constants
class AppConstants {
  // Configuration: Enable/disable local image saving
  static const bool saveImagesLocally = false;
  // Image cropping
  static const double cropSquareSize = 200.0;
  static const double overlayOpacity = 0.75;
  static const double borderWidth = 1.0;
  static const double borderRadius = 8.0;

  // Default transformation values
  static const double defaultScale = 1.0;
  static const double defaultRotation = 0.0;

  // Asset paths
  static const String defaultImageAsset = 'assets/sample.png';

  // App metadata
  static const String appTitle = 'Image Cropper App';
}
