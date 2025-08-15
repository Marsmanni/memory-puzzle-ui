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
  static const String appTitle = 'Image Cropper App';
  // Use localhost for debug, Azure for release
  static const String apiBaseUrl = kReleaseMode
      ? 'https://memorypuzzleapi.azurewebsites.net/api/'
      : 'http://localhost:5218/api/';
  static const String loginEndpoint = '${apiBaseUrl}users/login';
  static const String registerEndpoint = '${apiBaseUrl}users/register';
  static const String userProfileEndpoint = '${apiBaseUrl}users/profile';
  static const String imageUploadEndpoint = '${apiBaseUrl}images/upload';
  static const String imageTestgroupEndpoint = '${apiBaseUrl}images/group/testgroup';
  static const String puzzleCreateEndpoint = '${apiBaseUrl}puzzles';
  }
