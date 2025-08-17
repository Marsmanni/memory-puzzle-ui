import 'package:flutter/foundation.dart';

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
  static const String appTitle = 'Wunderwelt Memory Game';
  // Use localhost for debug, Azure for release
  static const String apiBaseUrl = kReleaseMode
      ? 'https://memorypuzzleapi.azurewebsites.net'
      : 'http://localhost:5218';

    /// Replaces placeholders like {id} or {puzzleId} in endpoint strings.
    /// Usage: ApiEndpoints.replace(ApiEndpoints.imagesGetById, {'id': uid})
    static String replace(String endpoint, Map<String, String> args) {
      var url = endpoint;
      args.forEach((key, value) {
        url = url.replaceAll('{$key}', value);
      });
      return url;
    }
  }
