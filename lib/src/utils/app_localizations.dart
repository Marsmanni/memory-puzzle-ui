class AppLocalizations {
  static String languageCode = 'de'; // default to German

  static final Map<String, Map<String, String>> _localizedValues = {
    'de': {
      // Main
      'main.loginRequiredUpload': 'Login erforderlich zum Hochladen.',
      'main.loginRequiredCompose': 'Login erforderlich zum Erstellen von Erinnerungen.',
      'main.adminRequiredUserAdmin': 'Admin-Zugriff für Benutzerverwaltung erforderlich.',
      'main.failedToLoadSystemInfo': 'Systeminfo konnte nicht geladen werden: {error},',
      'app.title': 'Wunderwelt Memory',

      // Users Page
      'usersPage.title': 'Administrator-Übersicht ',
      'usersPage.puzzles': 'Puzzles',
      'usersPage.table': 'Benutzer (Tabelle)',
      'usersPage.list': 'Benutzerliste',
      'usersPage.noUsers': 'Keine Benutzer gefunden',

      // Puzzle Page
      'puzzlePage.title': 'Alle Puzzles',
      'puzzlePage.noPuzzles': 'Keine Puzzles gefunden',

      // Play Page
      'playPage.title': 'Spielen',
      'playPage.reset': 'Zurücksetzen',
      'playPage.player': 'Spieler',
      'playPage.players': 'Spieler',
      'playPage.moves': 'Daneben',
      'playPage.matches': 'Treffer',
      'playPage.introLoading': 'Spieldaten werden geladen...',
      'playPage.settings': 'Einstellungen',
      'playPage.selectPlaceholder': 'Platzhalter auswählen',
      'playPage.language': 'Sprache',
      'playPage.backendNotAvailable': 'Backend nicht verfügbar.',
      'playPage.congratulations': 'Herzlichen Glückwunsch! Du hast das Puzzle gelöst!',
      'playPage.sound': 'Sound',
      'playPage.soundOff': 'Ton aus',
      'playPage.soundOn': 'Ton an',

      // Widgets
      'userAdminCard.puzzles': 'Puzzles',
      'userAdminCard.username': 'Benutzername',
      'userAdminCard.roles': 'Rollen',
      'userAdminCard.lastLogin': 'Letzter Login',
      'userAdminCard.neverLoggedIn': 'Nie eingeloggt',

      'puzzleAdminCard.author': 'Autor',
      'puzzleAdminCard.images': 'Bilder',
      'puzzleAdminCard.public': 'Öffentlich',
      'puzzleAdminCard.id': 'ID',

      // General
      'login': 'Login',
      'logout': 'Logout',
      'play': 'Spielen',
      'crop': 'Zuschneiden',
      'create': 'Erstellen',
      'users': 'Benutzer',
      'systemInfo': 'Systeminfo',

      // Create Page
      'createPage.title': 'Puzzle erstellen',
      'selectAll': 'Alle auswählen',
      'deselectAll': 'Auswahl aufheben',
      'saveTo': 'Speichern unter',
      'saveSuccess': 'Puzzle-Einstellungen erfolgreich gespeichert!',
      'saveFailed': 'Fehler beim Speichern der Puzzle-Einstellungen',

      // Play Page Placeholders
      'playPage.placeholder_himmel': 'Himmel',
      'playPage.placeholder_puzzle': 'Puzzle',
      'playPage.placeholder_wiese': 'Wiese',
      'playPage.placeholder_smiley': 'Smiley',

      // Cropper Page
      'cropperPage.title': 'Bildbeschneider',
      'cropperPage.filegroupLabel': 'Dateigruppe:',
      'cropperPage.newFilegroupLabel': 'Neue Dateigruppe',
      'cropperPage.newFilegroupHint': 'Dateigruppe hinzufügen',
      'cropperPage.selectPhotoWeb': 'Foto-Web auswählen',
      'cropperPage.cutAndSave': 'Zuschneiden & Speichern',
      'cropperPage.errorLoadAsset': 'Fehler beim Laden des Asset-Bildes',
      'cropperPage.errorPickImage': 'Fehler beim Auswählen des Bildes',
      'cropperPage.errorPickImageWeb': 'Fehler beim Auswählen des Bildes (Web)',
      'cropperPage.errorNoImage': 'Bitte wählen Sie zuerst ein Bild aus.',
      'cropperPage.errorViewDimensions': 'Konnte die Ansichtsdimensionen nicht abrufen.',
      'cropperPage.successProcessed': 'Bild verarbeitet:',
      'cropperPage.successSaved': 'Gespeichert: {path}',
      'cropperPage.errorCropSaveUpload': 'Fehler beim Zuschneiden, Speichern oder Hochladen des Bildes: {error}',
      'cropperPage.errorSaveParts': 'Fehler beim Speichern des Bildes in vier Teilen',

      'cropperPage.helpText': '''
ERWEITERTE STEUERUNG:
🖱️ Maus:
  • Scrollen = Zoom
  • Shift+Scrollen = Drehen
  • Strg+Scrollen = Präziser Zoom
  • Strg+Shift+Scrollen = Präzises Drehen
  • Ziehen = Bewegen
  • Strg+Ziehen = Zoom
  • Strg+Shift+Ziehen = Drehen
⌨️ Tastatur:
  • Pfeiltasten/WASD = Bewegen
  • Strg+Pfeiltasten/WASD = Präzises Bewegen
  • Shift+Pfeiltasten/WASD = Schnelles Bewegen
  • Strg+Links/Rechts = Präzises Drehen
  • Q/E = Zoom
  • Z/X = Drehen
  • R = Zurücksetzen
''',
      // Login Page
      'login.username': 'Benutzername',
      'login.password': 'Passwort',

      // Cropper additional info
      'cropperPage.currentScale': 'Aktueller Maßstab: {scale}',
      'cropperPage.currentOffset': 'Aktuelle Position: ({dx}, {dy})',
      'cropperPage.imageSize': 'Bildgröße: {width} x {height}',
      'cropperPage.errorLoadAssetImage': 'Asset-Bild konnte nicht geladen werden: {error}',
      'cropperPage.errorSaveImageParts': 'Bild konnte nicht in vier Teilen gespeichert werden: {error}',
    },
    'en': {
      // Main
      'main.loginRequiredUpload': 'Login required to upload.',
      'main.loginRequiredCompose': 'Login required to compose memories.',
      'main.adminRequiredUserAdmin': 'Admin access required for user admin.',
      'main.failedToLoadSystemInfo': 'Failed to load system info: {error},',
      'app.title': 'Wunderwelt Memory',

      // Users Page
      'usersPage.title': 'All Users',
      'usersPage.puzzles': 'Puzzles',
      'usersPage.table': 'Users (Table)',
      'usersPage.list': 'User List',
      'usersPage.noUsers': 'No users found',

      // Puzzle Page
      'puzzlePage.title': 'All Puzzles',
      'puzzlePage.noPuzzles': 'No puzzles found',

      // Play Page
      'playPage.title': 'Play',
      'playPage.reset': 'Reset',
      'playPage.player': 'Player',
      'playPage.players': 'Players',
      'playPage.moves': 'Fails',
      'playPage.matches': 'Hits',
      'playPage.introLoading': 'Loading game data...',
      'playPage.settings': 'Settings',
      'playPage.selectPlaceholder': 'Select Placeholder',
      'playPage.language': 'Language',
      'playPage.backendNotAvailable': 'Backend not available.',
      'playPage.congratulations': 'Congratulations! You solved the puzzle!',
      'playPage.sound': 'Sound',
      'playPage.soundOff': 'Sound Off',
      'playPage.soundOn': 'Sound On',

      // Widgets
      'userAdminCard.puzzles': 'Puzzles',
      'userAdminCard.roles': 'Roles',
      'userAdminCard.username': 'Username',
      'userAdminCard.lastLogin': 'Last login',
      'userAdminCard.neverLoggedIn': 'Never logged in',

      'puzzleAdminCard.author': 'Author',
      'puzzleAdminCard.images': 'Images',
      'puzzleAdminCard.public': 'Public',
      'puzzleAdminCard.id': 'ID',

      // General
      'login': 'Login',
      'logout': 'Logout',
      'play': 'Play',
      'crop': 'Crop',
      'create': 'Create',
      'users': 'Users',
      'systemInfo': 'System Info',

      // Create Page
      'createPage.title': 'Create the puzzle',
      'selectAll': 'Select All',
      'deselectAll': 'Deselect All',
      'saveTo': 'Save To',
      'saveSuccess': 'Puzzle setup saved successfully!',
      'saveFailed': 'Failed to save puzzle setup',

      // Play Page Placeholders
      'playPage.placeholder_himmel': 'Sky',
      'playPage.placeholder_puzzle': 'Puzzle',
      'playPage.placeholder_wiese': 'Meadow',
      'playPage.placeholder_smiley': 'Smiley',

      // Cropper Page
      'cropperPage.title': 'Image Cropper',
      'cropperPage.filegroupLabel': 'Filegroup:',
      'cropperPage.newFilegroupLabel': 'New filegroup',
      'cropperPage.newFilegroupHint': 'Add filegroup',
      'cropperPage.selectPhotoWeb': 'Select Photo Web',
      'cropperPage.cutAndSave': 'Cut & Save',
      'cropperPage.errorLoadAsset': 'Failed to load asset image',
      'cropperPage.errorPickImage': 'Failed to pick image',
      'cropperPage.errorPickImageWeb': 'Failed to pick image (web)',
      'cropperPage.errorNoImage': 'Please select an image first.',
      'cropperPage.errorViewDimensions': 'Could not get view dimensions.',
      'cropperPage.successProcessed': 'Image processed:',
      'cropperPage.successSaved': 'Saved: {path}',
      'cropperPage.errorCropSaveUpload': 'Failed to crop, save, or upload image: {error}',
      'cropperPage.errorSaveParts': 'Failed to save image in four parts',
      'cropperPage.uploadSuccess': 'Upload: Success',
      'cropperPage.uploadFailed': 'Upload: Failed',

      'cropperPage.helpText': '''
ENHANCED CONTROLS:
🖱️ Mouse:
  • Scroll = Zoom
  • Shift+Scroll = Rotate
  • Ctrl+Scroll = Precise Zoom
  • Ctrl+Shift+Scroll = Precise Rotate
  • Drag = Move
  • Ctrl+Drag = Zoom
  • Ctrl+Shift+Drag = Rotate
⌨️ Keyboard:
  • Arrow/WASD = Move
  • Ctrl+Arrow/WASD = Precise Move
  • Shift+Arrow/WASD = Fast Move
  • Ctrl+Left/Right = Precise Rotate
  • Q/E = Zoom
  • Z/X = Rotate
  • R = Reset
''',
      // Login Page
      'login.username': 'Username',
      'login.password': 'Password',

      // Cropper additional info
      'cropperPage.currentScale': 'Current scale: {scale}',
      'cropperPage.currentOffset': 'Current offset: ({dx}, {dy})',
      'cropperPage.imageSize': 'Image size: {width} x {height}',
      'cropperPage.errorLoadAssetImage': 'Failed to load asset image: {error}',
      'cropperPage.errorSaveImageParts': 'Failed to save image in four parts: {error}',
    },
  };

  static String get(String key) {
    return _localizedValues[languageCode]?[key] ?? "MISSING KEY {$key}";
  }

  static void setLanguage(String code) {
    languageCode = code;
  }

  static String format(String key, Map<String, String> params) {
    String template = get(key);
    params.forEach((k, v) {
      template = template.replaceAll('{$k}', v);
    });
    return template;
  }
}