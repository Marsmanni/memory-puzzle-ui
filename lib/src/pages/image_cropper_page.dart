import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:convert';
import '../models/image_transform_model.dart';
import '../services/image_service.dart';
import '../services/image_crop_service.dart';
import '../widgets/image_cropper_overlay.dart';
import '../widgets/transformable_image_widget.dart';
import '../utils/constants.dart';
import '../utils/log.dart';
import '../dtos/api_dtos.dart';
import '../utils/api_endpoints.dart';
import '../services/auth_http_service.dart';
import '../utils/image_cropper_key_handler.dart';
import '../widgets/image_cropper_help_overlay.dart';

/// Main page for image cropping functionality
class ImageCropperPage extends StatefulWidget {
  const ImageCropperPage({super.key});

  @override
  State<ImageCropperPage> createState() => _ImageCropperPageState();
}

class _ImageCropperPageState extends State<ImageCropperPage> {
  late ImageTransformModel _transformModel;
  final GlobalKey _imageCropperKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  // Mouse interaction state
  bool _isMousePressed = false;
  Offset? _lastMousePosition;

  // The size of the square cropping area
  static const double cropSquareSize = AppConstants.cropSquareSize;

  Uint8List? _croppedImageBytes;

  List<FileGroupDto> _filegroups = [];
  String? _selectedFilegroupName;
  final TextEditingController _filegroupController = TextEditingController();
  bool _loadingFilegroups = true;

  @override
  void initState() {
    super.initState();
    _transformModel = ImageTransformModel();
    _loadImageAsset();
    _focusNode.requestFocus();
    _fetchFilegroups();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _filegroupController.dispose();
    super.dispose();
  }

  /// Load the default image from assets
  Future<void> _loadImageAsset() async {
    try {
      final image = await ImageService.loadImageFromAssets(
        AppConstants.defaultImageAsset,
      );

      setState(() {
        Log.d('SetState1');
        _transformModel = _transformModel.copyWith(
          originalImage: image,
          isImageLoaded: true,
        );
      });
    } catch (e) {
      _showErrorMessage('Failed to load asset image: $e');
    }
  }

  /// Pick an image from gallery
  Future<void> _pickImage() async {
    try {
      final imageFile = await ImageService.pickImageFromGallery();
      if (imageFile != null) {
        final image = await ImageService.xFileToUiImage(imageFile);

        // Calculate initial scale and position
        //final double cropSize = cropSquareSize;
        //final double scaleX = cropSize / image.width;
        //final double scaleY = cropSize / image.height;
        //final double initialScale = 1; // scaleX < scaleY ? scaleX : scaleY;

        setState(() {
          Log.d('SetState2');

          _transformModel = _transformModel.copyWith(
            imageFile: imageFile,
            originalImage: image,
            isImageLoaded: true,
            imagePosition: Offset.zero,
            imageScale: 1.0, // Temporary, will be updated
            imageRotation: 0.0,
          );
        });
        _setInitialScaleAfterLayout();
      }
    } catch (e) {
      _showErrorMessage('Failed to pick image: $e');
    }
  }

  // Helper function to convert Uint8List to ui.Image
  Future<ui.Image> uint8ListToUiImage(Uint8List bytes) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  Future<void> pickImageWeb() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        final bytes = result.files.first.bytes;
        if (bytes != null) {
          final image = await uint8ListToUiImage(bytes);

          setState(() {
            Log.d('SetState2 (Web)');
            _transformModel = _transformModel.copyWith(
              originalImage: image,
              isImageLoaded: true,
              imagePosition: Offset.zero,
              imageScale: 1.0, // Temporary, will be updated
              imageRotation: 0.0,
            );
          });
          _setInitialScaleAfterLayout();
        }
      }
    } catch (e) {
      _showErrorMessage('Failed to pick image (web): $e');
    }
  }

  /// Handle scale start gesture
  void _onScaleStart(ScaleStartDetails details) {
    _transformModel.updateGestureState(
      scale: _transformModel.imageScale,
      rotation: _transformModel.imageRotation,
      position: details.focalPoint - _transformModel.imagePosition,
    );
  }

  /// Enhanced mouse scroll for scaling and rotation
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      setState(() {
        // Check for modifier keys
        bool isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
        bool isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

        if (isCtrlPressed && isShiftPressed) {
          // Ctrl + Shift + Scroll = Precise rotation
          double rotationDelta = event.scrollDelta.dy > 0 ? -0.05 : 0.05;
          double newRotation = _transformModel.imageRotation + rotationDelta;
          Log.d('Ctrl+Shift+Scroll - Precise rotation: $newRotation');

          _transformModel.updateTransformations(
            position: _transformModel.imagePosition,
            scale: _transformModel.imageScale,
            rotation: newRotation,
          );
        } else if (isCtrlPressed) {
          // Ctrl + Scroll = Precise zoom
          double scaleDelta = event.scrollDelta.dy > 0 ? 0.95 : 1.05;
          double newScale = (_transformModel.imageScale * scaleDelta).clamp(
            0.1,
            5.0,
          );
          Log.d('Ctrl+Scroll - Precise zoom: $newScale');

          _transformModel.updateTransformations(
            position: _transformModel.imagePosition,
            scale: newScale,
            rotation: _transformModel.imageRotation,
          );
        } else if (isShiftPressed) {
          // Shift + Scroll = Rotation
          double rotationDelta = event.scrollDelta.dy > 0 ? -0.1 : 0.1;
          double newRotation = _transformModel.imageRotation + rotationDelta;
          Log.d('Shift+Scroll - Rotation: $newRotation');

          _transformModel.updateTransformations(
            position: _transformModel.imagePosition,
            scale: _transformModel.imageScale,
            rotation: newRotation,
          );
        } else {
          // Normal Scroll = Zoom
          double scaleDelta = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
          double newScale = (_transformModel.imageScale * scaleDelta).clamp(
            0.5,
            3.0,
          );
          Log.d('Scroll - Zoom: $newScale');

          _transformModel.updateTransformations(
            position: _transformModel.imagePosition,
            scale: newScale,
            rotation: _transformModel.imageRotation,
          );
        }
      });
    }
  }

  /// Handle mouse drag for movement and rotation
  void _onPanStart(DragStartDetails details) {
    _isMousePressed = true;
    _lastMousePosition = details.localPosition;
    Log.d('Pan start at: ${details.localPosition}');
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isMousePressed || _lastMousePosition == null) return;

    setState(() {
      bool isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
      bool isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

      if (isCtrlPressed && isShiftPressed) {
        // Ctrl + Shift + Drag = Rotate around center
        Offset delta = details.localPosition - _lastMousePosition!;
        double rotationDelta =
            delta.dx * 0.01; // Horizontal movement = rotation
        double newRotation = _transformModel.imageRotation + rotationDelta;
        Log.d('Ctrl+Shift+Drag - Rotation: $newRotation');

        _transformModel.updateTransformations(
          position: _transformModel.imagePosition,
          scale: _transformModel.imageScale,
          rotation: newRotation,
        );
      } else if (isCtrlPressed) {
        // Ctrl + Drag = Zoom based on vertical movement
        Offset delta = details.localPosition - _lastMousePosition!;
        double scaleDelta =
            1.0 + (delta.dy * -0.01); // Negative for intuitive direction
        double newScale = (_transformModel.imageScale * scaleDelta).clamp(
          0.1,
          5.0,
        );
        Log.d('Ctrl+Drag - Scale: $newScale');

        _transformModel.updateTransformations(
          position: _transformModel.imagePosition,
          scale: newScale,
          rotation: _transformModel.imageRotation,
        );
      } else {
        // Normal Drag = Move
        Offset delta = details.localPosition - _lastMousePosition!;
        Offset newPosition = _transformModel.imagePosition + delta;
        Log.d('Drag - Move to: $newPosition');

        _transformModel.updateTransformations(
          position: newPosition,
          scale: _transformModel.imageScale,
          rotation: _transformModel.imageRotation,
        );
      }

      _lastMousePosition = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isMousePressed = false;
    _lastMousePosition = null;
    Log.d('Pan end');
  }

  /// Enhanced keyboard events with modifier keys
  void _onKeyEvent(KeyEvent event) {
    setState(() {
      handleImageCropperKeyEvent(
        event: event,
        transformModel: _transformModel,
        updateModel: (model) => _transformModel = model,
        resetTransformations: () => _transformModel.resetTransformations(),
      );
    });
  }

  /// Handle scale update gesture
  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      Log.d('SetState3');

      double newScale = _transformModel.previousScale * details.scale;
      double newRotation = _transformModel.previousRotation;

      // Debug output
      Log.d(
        'newScale = ${_transformModel.previousScale} * ${details.scale} = $newScale',
      );
      Log.d('newRotation = $newRotation');

      if (details.rotation != 0.0) {
        newRotation = _transformModel.previousRotation + details.rotation;
        Log.d(
          'newRotation updated = ${_transformModel.previousRotation} + ${details.rotation} = $newRotation',
        );
      }

      Offset newPosition =
          details.focalPoint - _transformModel.previousPosition;
      Log.d(
        'newPosition = ${details.focalPoint} - ${_transformModel.previousPosition} = $newPosition',
      );

      _transformModel.updateTransformations(
        position: newPosition,
        scale: newScale,
        rotation: newRotation,
      );
    });
  }

  /// Crop and save the current image using both methods
  Future<void> _cropAndSaveImage() async {
    if (!_transformModel.isImageLoaded ||
        _transformModel.originalImage == null) {
      _showErrorMessage('Please select an image first.');
      return;
    }

    try {
      // Get the render box for calculating view size
      final renderBox =
          _imageCropperKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        _showErrorMessage('Could not get view dimensions.');
        return;
      }

      final viewSize = renderBox.size;

      // Crop image to PNG bytes
      final pngData = await ImageCropService.cropImage(
        originalImage: _transformModel.originalImage!,
        imagePosition: _transformModel.imagePosition,
        imageScale: _transformModel.imageScale,
        imageRotation: _transformModel.imageRotation,
        viewSize: viewSize,
        cropSquareSize: cropSquareSize,
        targetSize: 300.0,
      );

      setState(() {
        _croppedImageBytes = pngData;
      });

      // Save image (non-web platforms)
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filename = 'cropped_${timestamp}_300x300.png';
      final savedFile = await ImageCropService.saveImage(
        filename: filename,
        pngData: pngData,
      );

      // Upload image
      final uploadResult = await ImageCropService.uploadImageBytesToEndpoint(
        filegroup: _selectedFilegroupName ?? '', // Use selected filegroup id
        imageBytes: pngData,
      );

      Log.d('Crop, save, and upload completed');

      String savedMsg = '';
      // Only show 'Saved' for Windows app
      if (!kIsWeb) {
        savedMsg = 'Saved: ${savedFile?.path ?? ""}\n';
      }
      _showSuccessMessage(
        'Image processed:\n'
        '$savedMsg'
        'Upload: ${uploadResult['success'] == true ? "Success" : "Failed"}',
      );
    } catch (e) {
      _showErrorMessage('Failed to crop, save, or upload image: $e');
      Log.e('Crop operation failed: $e');
    }
  }

  /// Test function to save image in four parts
  Future<void> _testSaveImageInFourParts() async {
    if (!_transformModel.isImageLoaded ||
        _transformModel.originalImage == null) {
      _showErrorMessage('Please select an image first.');
      return;
    }

    try {
      // Save the image in four parts
      final savedFiles = await ImageService.saveImageAsFourParts(
        _transformModel.originalImage!,
        'test_image_parts',
      );

      _showSuccessMessage(
        'Image saved in ${savedFiles.length} parts successfully!',
      );
    } catch (e) {
      _showErrorMessage('Failed to save image in four parts: $e');
    }
  }

  /// Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _setInitialScaleAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _imageCropperKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && _transformModel.originalImage != null) {
        final viewSize = renderBox.size;
        final image = _transformModel.originalImage!;
        final double scaleX = viewSize.width / image.width;
        final double scaleY = viewSize.height / image.height;
        //final double scaleX = cropSquareSize / image.width;
        //final double scaleY = cropSquareSize / image.height;
        final double initialScale = scaleX < scaleY ? scaleX : scaleY;
        setState(() {
          _transformModel = _transformModel.copyWith(
            imageScale: initialScale,
            imagePosition: Offset.zero,
          );
          Log.d('Initial scale set: $initialScale');
        });
      }
    });
  }

  Future<void> _fetchFilegroups() async {
    setState(() {
      _loadingFilegroups = true;
    });
    try {
      final response = await AuthHttpService.get(
        Uri.parse(ApiEndpoints.imagesFilegroups),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _filegroups = data
              .map<FileGroupDto>((e) => FileGroupDto.fromJson(e))
              .toList();
          _selectedFilegroupName = _filegroups.isNotEmpty
              ? _filegroups[0].groupName
              : "";
          _loadingFilegroups = false;
        });
      } else {
        setState(() {
          _filegroups = [];
          _selectedFilegroupName = null;
          _loadingFilegroups = false;
        });
      }
    } catch (e) {
      setState(() {
        _filegroups = [];
        _selectedFilegroupName = null;
        _loadingFilegroups = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Image Cropper'),
            const SizedBox(width: 16),
            // Label for filegroup selector
            const Text(
              'Filegroup:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            // Filegroup selector
            SizedBox(
              width: 220,
              child: _loadingFilegroups
                  ? const CircularProgressIndicator()
                  : DropdownButton<String>(
                      value: _selectedFilegroupName,
                      isExpanded: true,
                      items: _filegroups
                          .map(
                            (fg) => DropdownMenuItem(
                              value: fg.groupName,
                              child: Text('${fg.groupName} (${fg.imageCount})'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedFilegroupName = value;
                          });
                        }
                      },
                    ),
            ),
            const SizedBox(width: 16),
            // New filegroup input
            SizedBox(
              width: 120,
              child: TextField(
                controller: _filegroupController,
                decoration: const InputDecoration(
                  labelText: 'New filegroup',
                  hintText: 'Add filegroup',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 8,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty &&
                      !_filegroups.any((fg) => fg.groupName == value)) {
                    setState(() {
                      final newGroup = FileGroupDto(
                        groupName: value,
                        imageCount: 0,
                      );
                      _filegroups.add(newGroup);
                      _selectedFilegroupName = newGroup.groupName;
                      _filegroupController.clear();
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: pickImageWeb,
              child: const Text('Select Photo Web'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _cropAndSaveImage,
              child: const Text('Cut & Save'),
            ),
            const SizedBox(width: 16),
            Text(
              'kIsWeb: ${kIsWeb ? "true" : "false"}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Listener(
              onPointerSignal: _onPointerSignal,
              child: KeyboardListener(
                focusNode: _focusNode,
                onKeyEvent: _onKeyEvent,
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Stack(
                    key: _imageCropperKey,
                    children: [
                      // Transformable image widget
                      TransformableImageWidget(
                        transformModel: _transformModel,
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                      ),

                      // Crop overlay
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: ImageCropperOverlayPainter(
                            cropSquareSize: cropSquareSize,
                          ),
                        ),
                      ),

                      // Help overlay
                      ImageCropperHelpOverlay(
                        transformModel: _transformModel,
                        croppedImageBytes: _croppedImageBytes,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
