import 'package:flutter/material.dart';
import 'src/pages/image_cropper_page.dart';
import 'src/utils/constants.dart';

/// Entry point of the application
void main() {
  runApp(const MyApp());
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: true,
      home: ImageCropperPage(),
    );
  }
}