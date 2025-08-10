# 📊 Flutter Image Cropper - Klassendiagramm

<div style="zoom: 0.7;">

```mermaid
classDiagram
    %% Main App Entry Point
    class MyApp {
        +Widget build(BuildContext context)
    }

    %% Pages
    class ImageCropperPage {
        -ImageTransformModel _transformModel
        -GlobalKey _imageCropperKey
        -double cropSquareSize
        +initState()
        +_loadImageAsset() Future~void~
        +_pickImage() Future~void~
        +_onScaleStart(ScaleStartDetails details) void
        +_onScaleUpdate(ScaleUpdateDetails details) void
        +_cropAndSaveImage() Future~void~
        +_showErrorMessage(String message) void
        +_showSuccessMessage(String message) void
        +build(BuildContext context) Widget
    }

    %% Models
    class ImageTransformModel {
        +ui.Image? originalImage
        +XFile? imageFile
        +bool isImageLoaded
        +Offset imagePosition
        +double imageScale
        +double imageRotation
        +double previousScale
        +double previousRotation
        +Offset previousPosition
        +resetTransformations() void
        +updateGestureState(double scale, double rotation, Offset position) void
        +updateTransformations(Offset position, double scale, double rotation) void
        +copyWith(...) ImageTransformModel
    }

    %% Services
    class ImageService {
        -ImagePicker _picker$
        +loadImageFromAssets(String assetPath)$ Future~ui.Image~
        +pickImageFromGallery()$ Future~XFile?~
        +xFileToUiImage(XFile imageFile)$ Future~ui.Image~
        +saveImageToFile(ui.Image image, String filename)$ Future~File~
        +saveImageAsFourParts(ui.Image image, String filenamePrefix)$ Future~List~File~~
    }

    class ImageCropService {
        +cropAndSaveImage(ui.Image originalImage, Offset imagePosition, double imageScale, double imageRotation, Size viewSize, double cropSquareSize)$ Future~File~
    }

    %% Widgets
    class TransformableImageWidget {
        +ImageTransformModel transformModel
        +Function(ScaleStartDetails) onScaleStart
        +Function(ScaleUpdateDetails) onScaleUpdate
        +build(BuildContext context) Widget
    }

    class ImageCropperOverlayPainter {
        +double cropSquareSize
        +paint(Canvas canvas, Size size) void
        +shouldRepaint(ImageCropperOverlayPainter oldDelegate) bool
    }

    %% Utils
    class AppConstants {
        +double cropSquareSize$
        +double overlayOpacity$
        +double borderWidth$
        +double borderRadius$
        +double defaultScale$
        +double defaultRotation$
        +String defaultImageAsset$
        +String appTitle$
    }

    %% Relationships
    MyApp --> ImageCropperPage : navigates to
    ImageCropperPage --> ImageTransformModel : uses
    ImageCropperPage --> ImageService : calls
    ImageCropperPage --> ImageCropService : calls
    ImageCropperPage --> TransformableImageWidget : contains
    ImageCropperPage --> ImageCropperOverlayPainter : uses
    ImageCropperPage --> AppConstants : uses
    TransformableImageWidget --> ImageTransformModel : displays
    ImageTransformModel --> AppConstants : uses default values
    ImageCropperOverlayPainter --> AppConstants : uses constants

    %% Flutter Framework Dependencies
    ImageCropperPage --|> StatefulWidget : extends
    TransformableImageWidget --|> StatelessWidget : extends
    ImageCropperOverlayPainter --|> CustomPainter : extends
    MyApp --|> StatelessWidget : extends

    %% External Dependencies
    ImageService ..> ImagePicker : uses
    ImageService ..> ui : uses
    ImageService ..> path_provider : uses
    ImageCropService ..> img : uses "image package"
    ImageCropService ..> vmath : uses "vector_math"
    ImageTransformModel ..> XFile : uses
```

</div>

## 🏗️ **Architektur-Übersicht**

### **📱 Presentation Layer (UI)**
- **MyApp**: Root-Widget der Anwendung
- **ImageCropperPage**: Hauptseite mit der Cropping-Funktionalität
- **TransformableImageWidget**: Widget für interaktive Bildtransformationen
- **ImageCropperOverlayPainter**: Custom Painter für das Crop-Overlay

### **🧠 Business Logic Layer**
- **ImageService**: Behandelt alle Image-Loading und -Saving Operationen
- **ImageCropService**: Spezialisiert auf komplexe Crop-Operationen

### **📊 Data Layer**
- **ImageTransformModel**: Verwaltet den State der Bildtransformationen

### **🔧 Utilities**
- **AppConstants**: Zentrale Konstanten-Verwaltung

## 🔗 **Abhängigkeiten & Beziehungen**

### **Composition Relationships (uses/contains)**
- `ImageCropperPage` **verwendet** `ImageTransformModel` für State-Management
- `ImageCropperPage` **enthält** `TransformableImageWidget` als Child-Widget
- `TransformableImageWidget` **zeigt** Daten aus `ImageTransformModel` an

### **Service Dependencies (calls)**
- `ImageCropperPage` **ruft auf** `ImageService` für Image-Operations
- `ImageCropperPage` **ruft auf** `ImageCropService` für Crop-Operations

### **Configuration Dependencies**
- Mehrere Klassen **verwenden** `AppConstants` für Konfigurationswerte

### **External Package Dependencies**
- `ImageService` nutzt `image_picker`, `path_provider`, `dart:ui`
- `ImageCropService` nutzt `image` package, `vector_math`
- `ImageTransformModel` nutzt `image_picker` für `XFile`

## 📈 **Vorteile dieser Struktur**

1. **Trennung der Verantwortlichkeiten**: Jede Klasse hat eine klare Aufgabe
2. **Lose Kopplung**: Services sind unabhängig von UI-Komponenten
3. **Hohe Kohäsion**: Verwandte Funktionalitäten sind zusammengefasst
4. **Testbarkeit**: Services können isoliert getestet werden
5. **Wiederverwendbarkeit**: Widgets und Services können in anderen Projekten verwendet werden
6. **Skalierbarkeit**: Neue Features können einfach hinzugefügt werden
