import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../models/image_transform_model.dart';
import '../services/image_service.dart';
import '../services/image_crop_service.dart';
import '../widgets/image_cropper_overlay.dart';
import '../widgets/transformable_image_widget.dart';
import '../utils/constants.dart';

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
  
  @override
  void initState() {
    super.initState();
    _transformModel = ImageTransformModel();
    _loadImageAsset();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  
  /// Load the default image from assets
  Future<void> _loadImageAsset() async {
    try {
      final image = await ImageService.loadImageFromAssets(AppConstants.defaultImageAsset);
      
      setState(() {
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
        
        setState(() {
          _transformModel = _transformModel.copyWith(
            imageFile: imageFile,
            originalImage: image,
            isImageLoaded: true,
            imagePosition: Offset.zero,
            imageScale: 1.0,
            imageRotation: 0.0,
          );
        });
      }
    } catch (e) {
      _showErrorMessage('Failed to pick image: $e');
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
          print('DEBUG: Ctrl+Shift+Scroll - Precise rotation: $newRotation');
          
          _transformModel.updateTransformations(
            position: _transformModel.imagePosition,
            scale: _transformModel.imageScale,
            rotation: newRotation,
          );
        } else if (isCtrlPressed) {
          // Ctrl + Scroll = Precise zoom
          double scaleDelta = event.scrollDelta.dy > 0 ? 0.95 : 1.05;
          double newScale = (_transformModel.imageScale * scaleDelta).clamp(0.1, 5.0);
          print('DEBUG: Ctrl+Scroll - Precise zoom: $newScale');
          
          _transformModel.updateTransformations(
            position: _transformModel.imagePosition,
            scale: newScale,
            rotation: _transformModel.imageRotation,
          );
        } else if (isShiftPressed) {
          // Shift + Scroll = Rotation
          double rotationDelta = event.scrollDelta.dy > 0 ? -0.1 : 0.1;
          double newRotation = _transformModel.imageRotation + rotationDelta;
          print('DEBUG: Shift+Scroll - Rotation: $newRotation');
          
          _transformModel.updateTransformations(
            position: _transformModel.imagePosition,
            scale: _transformModel.imageScale,
            rotation: newRotation,
          );
        } else {
          // Normal Scroll = Zoom
          double scaleDelta = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
          double newScale = (_transformModel.imageScale * scaleDelta).clamp(0.5, 3.0);
          print('DEBUG: Scroll - Zoom: $newScale');
          
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
    print('DEBUG: Pan start at: ${details.localPosition}');
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isMousePressed || _lastMousePosition == null) return;
    
    setState(() {
      bool isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
      bool isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
      
      if (isCtrlPressed && isShiftPressed) {
        // Ctrl + Shift + Drag = Rotate around center
        Offset delta = details.localPosition - _lastMousePosition!;
        double rotationDelta = delta.dx * 0.01; // Horizontal movement = rotation
        double newRotation = _transformModel.imageRotation + rotationDelta;
        print('DEBUG: Ctrl+Shift+Drag - Rotation: $newRotation');
        
        _transformModel.updateTransformations(
          position: _transformModel.imagePosition,
          scale: _transformModel.imageScale,
          rotation: newRotation,
        );
      } else if (isCtrlPressed) {
        // Ctrl + Drag = Zoom based on vertical movement
        Offset delta = details.localPosition - _lastMousePosition!;
        double scaleDelta = 1.0 + (delta.dy * -0.01); // Negative for intuitive direction
        double newScale = (_transformModel.imageScale * scaleDelta).clamp(0.1, 5.0);
        print('DEBUG: Ctrl+Drag - Scale: $newScale');
        
        _transformModel.updateTransformations(
          position: _transformModel.imagePosition,
          scale: newScale,
          rotation: _transformModel.imageRotation,
        );
      } else {
        // Normal Drag = Move
        Offset delta = details.localPosition - _lastMousePosition!;
        Offset newPosition = _transformModel.imagePosition + delta;
        print('DEBUG: Drag - Move to: $newPosition');
        
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
    print('DEBUG: Pan end');
  }

  /// Enhanced keyboard events with modifier keys
  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      setState(() {
        bool isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
        bool isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
        
        // Calculate step sizes based on modifiers
        double moveStep = isCtrlPressed ? 1.0 : (isShiftPressed ? 50.0 : 10.0);
        double scaleStep = isCtrlPressed ? 0.02 : (isShiftPressed ? 0.2 : 0.1);
        double rotationStep = isCtrlPressed ? 0.02 : (isShiftPressed ? 0.5 : 0.1);
        
        switch (event.logicalKey) {
          // Zoom controls
          case LogicalKeyboardKey.keyQ: // Scale down
            double scaleFactor = 1.0 - scaleStep;
            double newScale = (_transformModel.imageScale * scaleFactor).clamp(0.1, 5.0);
            print('DEBUG: Key Q (${isCtrlPressed ? 'precise' : isShiftPressed ? 'fast' : 'normal'}) - Scale: $newScale');
            _transformModel.updateTransformations(
              position: _transformModel.imagePosition,
              scale: newScale,
              rotation: _transformModel.imageRotation,
            );
            break;
            
          case LogicalKeyboardKey.keyE: // Scale up
            double scaleFactor = 1.0 + scaleStep;
            double newScale = (_transformModel.imageScale * scaleFactor).clamp(0.1, 5.0);
            print('DEBUG: Key E (${isCtrlPressed ? 'precise' : isShiftPressed ? 'fast' : 'normal'}) - Scale: $newScale');
            _transformModel.updateTransformations(
              position: _transformModel.imagePosition,
              scale: newScale,
              rotation: _transformModel.imageRotation,
            );
            break;

          // Movement controls - Arrow Keys
          case LogicalKeyboardKey.arrowUp:
            Offset newPosition = _transformModel.imagePosition + Offset(0, -moveStep);
            print('DEBUG: Arrow Up (${isCtrlPressed ? 'precise' : isShiftPressed ? 'fast' : 'normal'}) - Move: $newPosition');
            _transformModel.updateTransformations(
              position: newPosition,
              scale: _transformModel.imageScale,
              rotation: _transformModel.imageRotation,
            );
            break;
            
          case LogicalKeyboardKey.arrowDown:
            Offset newPosition = _transformModel.imagePosition + Offset(0, moveStep);
            print('DEBUG: Arrow Down (${isCtrlPressed ? 'precise' : isShiftPressed ? 'fast' : 'normal'}) - Move: $newPosition');
            _transformModel.updateTransformations(
              position: newPosition,
              scale: _transformModel.imageScale,
              rotation: _transformModel.imageRotation,
            );
            break;
            
          case LogicalKeyboardKey.arrowLeft:
            if (isCtrlPressed || isShiftPressed) {
              // Ctrl/Shift + Left Arrow = Rotate left
              double newRotation = _transformModel.imageRotation - rotationStep;
              print('DEBUG: Ctrl/Shift+Left - Rotate: $newRotation');
              _transformModel.updateTransformations(
                position: _transformModel.imagePosition,
                scale: _transformModel.imageScale,
                rotation: newRotation,
              );
            } else {
              // Normal Left Arrow = Move left
              Offset newPosition = _transformModel.imagePosition + Offset(-moveStep, 0);
              print('DEBUG: Arrow Left - Move: $newPosition');
              _transformModel.updateTransformations(
                position: newPosition,
                scale: _transformModel.imageScale,
                rotation: _transformModel.imageRotation,
              );
            }
            break;
            
          case LogicalKeyboardKey.arrowRight:
            if (isCtrlPressed || isShiftPressed) {
              // Ctrl/Shift + Right Arrow = Rotate right
              double newRotation = _transformModel.imageRotation + rotationStep;
              print('DEBUG: Ctrl/Shift+Right - Rotate: $newRotation');
              _transformModel.updateTransformations(
                position: _transformModel.imagePosition,
                scale: _transformModel.imageScale,
                rotation: newRotation,
              );
            } else {
              // Normal Right Arrow = Move right
              Offset newPosition = _transformModel.imagePosition + Offset(moveStep, 0);
              print('DEBUG: Arrow Right - Move: $newPosition');
              _transformModel.updateTransformations(
                position: newPosition,
                scale: _transformModel.imageScale,
                rotation: _transformModel.imageRotation,
              );
            }
            break;

          // WASD controls
          case LogicalKeyboardKey.keyW:
            Offset newPosition = _transformModel.imagePosition + Offset(0, -moveStep);
            print('DEBUG: W (${isCtrlPressed ? 'precise' : isShiftPressed ? 'fast' : 'normal'}) - Move up: $newPosition');
            _transformModel.updateTransformations(
              position: newPosition,
              scale: _transformModel.imageScale,
              rotation: _transformModel.imageRotation,
            );
            break;
            
          case LogicalKeyboardKey.keyS:
            Offset newPosition = _transformModel.imagePosition + Offset(0, moveStep);
            print('DEBUG: S (${isCtrlPressed ? 'precise' : isShiftPressed ? 'fast' : 'normal'}) - Move down: $newPosition');
            _transformModel.updateTransformations(
              position: newPosition,
              scale: _transformModel.imageScale,
              rotation: _transformModel.imageRotation,
            );
            break;
            
          case LogicalKeyboardKey.keyA:
            Offset newPosition = _transformModel.imagePosition + Offset(-moveStep, 0);
            print('DEBUG: A (${isCtrlPressed ? 'precise' : isShiftPressed ? 'fast' : 'normal'}) - Move left: $newPosition');
            _transformModel.updateTransformations(
              position: newPosition,
              scale: _transformModel.imageScale,
              rotation: _transformModel.imageRotation,
            );
            break;
            
          case LogicalKeyboardKey.keyD:
            Offset newPosition = _transformModel.imagePosition + Offset(moveStep, 0);
            print('DEBUG: D (${isCtrlPressed ? 'precise' : isShiftPressed ? 'fast' : 'normal'}) - Move right: $newPosition');
            _transformModel.updateTransformations(
              position: newPosition,
              scale: _transformModel.imageScale,
              rotation: _transformModel.imageRotation,
            );
            break;

          // Rotation controls
          case LogicalKeyboardKey.keyZ:
            double newRotation = _transformModel.imageRotation - rotationStep;
            print('DEBUG: Z (${isCtrlPressed ? 'precise' : isShiftPressed ? 'fast' : 'normal'}) - Rotate left: $newRotation');
            _transformModel.updateTransformations(
              position: _transformModel.imagePosition,
              scale: _transformModel.imageScale,
              rotation: newRotation,
            );
            break;
            
          case LogicalKeyboardKey.keyX:
            double newRotation = _transformModel.imageRotation + rotationStep;
            print('DEBUG: X (${isCtrlPressed ? 'precise' : isShiftPressed ? 'fast' : 'normal'}) - Rotate right: $newRotation');
            _transformModel.updateTransformations(
              position: _transformModel.imagePosition,
              scale: _transformModel.imageScale,
              rotation: newRotation,
            );
            break;

          // Reset
          case LogicalKeyboardKey.keyR:
            print('DEBUG: R - Reset transformations');
            _transformModel.resetTransformations();
            break;
        }
      });
    }
  }

  /// Handle scale update gesture
  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      double newScale = _transformModel.previousScale * details.scale;
      double newRotation = _transformModel.previousRotation;
      
      // Debug output
      print('DEBUG: newScale = ${_transformModel.previousScale} * ${details.scale} = $newScale');
      print('DEBUG: newRotation = $newRotation');
      
      if (details.rotation != 0.0) {
        newRotation = _transformModel.previousRotation + details.rotation;
        print('DEBUG: newRotation updated = ${_transformModel.previousRotation} + ${details.rotation} = $newRotation');
      }
      
      Offset newPosition = details.focalPoint - _transformModel.previousPosition;
      print('DEBUG: newPosition = ${details.focalPoint} - ${_transformModel.previousPosition} = $newPosition');

      _transformModel.updateTransformations(
        position: newPosition,
        scale: newScale,
        rotation: newRotation,
      );
    });
  }

  /// Crop and save the current image using both methods
  Future<void> _cropAndSaveImage() async {
    if (!_transformModel.isImageLoaded || _transformModel.originalImage == null) {
      _showErrorMessage('Please select an image first.');
      return;
    }

    try {
      // Get the render box for calculating view size
      final renderBox = _imageCropperKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        _showErrorMessage('Could not get view dimensions.');
        return;
      }

      final viewSize = renderBox.size;

      // Call both crop methods
      print('DEBUG: Starting both crop operations...');
      
      // Method 1: Original crop method
      final savedFile1 = await ImageCropService.cropAndSaveImage(
        originalImage: _transformModel.originalImage!,
        imagePosition: _transformModel.imagePosition,
        imageScale: _transformModel.imageScale,
        imageRotation: _transformModel.imageRotation,
        viewSize: viewSize,
        cropSquareSize: cropSquareSize,
      );
      
      print('DEBUG: Original crop method completed');

      // Method 2: Screen crop method (1:1 representation)
      final savedFile2 = await ImageCropService.cropAndSaveImageFromScreen(
        originalImage: _transformModel.originalImage!,
        imagePosition: _transformModel.imagePosition,
        imageScale: _transformModel.imageScale,
        imageRotation: _transformModel.imageRotation,
        viewSize: viewSize,
        cropSquareSize: cropSquareSize,
        targetSize: 300.0, // Fixed 350x350 output
      );
      
      print('DEBUG: Screen crop method completed');

      _showSuccessMessage(
        'Images saved:\n'
        '1. Standard crop: ${savedFile1.path.split('/').last}\n'
        '2. Screen crop (350x350): ${savedFile2.path.split('/').last}'
      );
      
    } catch (e) {
      _showErrorMessage('Failed to crop and save image: $e');
      print('ERROR: Crop operation failed: $e');
    }
  }

  /// Test function to save image in four parts
  Future<void> _testSaveImageInFourParts() async {
    if (!_transformModel.isImageLoaded || _transformModel.originalImage == null) {
      _showErrorMessage('Please select an image first.');
      return;
    }

    try {
      // Save the image in four parts
      final savedFiles = await ImageService.saveImageAsFourParts(
        _transformModel.originalImage!,
        'test_image_parts',
      );

      _showSuccessMessage('Image saved in ${savedFiles.length} parts successfully!');
    } catch (e) {
      _showErrorMessage('Failed to save image in four parts: $e');
    }
  }

  /// Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Cropper'),
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
                      
                      // Enhanced help overlay
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Select Photo'),
                    ),
                    ElevatedButton(
                      onPressed: _cropAndSaveImage,
                      child: const Text('Cut & Save'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _testSaveImageInFourParts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test - Save in 4 Parts'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
