class AppLocalizations {
  static String languageCode = 'de'; // default to German

  static final Map<String, Map<String, String>> _localizedValues = {
    'de': {
      'adminOverview': 'Admin Übersicht',
      'allPuzzles': 'Alle Puzzles',
      'allUsers': 'Alle Benutzer',
      'usersTable': 'Benutzer (Tabelle)',
      'placeholder_himmel': 'Himmel',
      'placeholder_puzzle': 'Puzzle',
      'placeholder_wiese': 'Wiese',
      'placeholder_smiley': 'Smiley',
      'puzzles': 'Puzzles',
      'roles': 'Rollen',
      'lastLogin': 'Letzter Login',
      'neverLoggedIn': 'Nie eingeloggt',
      'author': 'Autor',
      'images': 'Bilder',
      'public': 'Öffentlich',
      'id': 'ID',
      'noPuzzlesFound': 'Keine Puzzles gefunden',
      'updateError': 'Fehler beim Aktualisieren!',
      'username': 'Benutzername',
      'login': 'Login',
      'logout': 'Logout',
      'play': 'Spielen',
      'crop': 'Zuschneiden',
      'create': 'Erstellen',
      'users': 'Benutzer',
      'systemInfo': 'Systeminfo',
      'settings': 'Einstellungen',
      'selectPlaceholder': 'Platzhalter auswählen',
      'language': 'Sprache',
    },
    'en': {
      'adminOverview': 'Admin Overview',
      'allPuzzles': 'All Puzzles',
      'allUsers': 'All Users',
      'usersTable': 'Users (Table)',
      'placeholder_himmel': 'Sky',
      'placeholder_puzzle': 'Puzzle',
      'placeholder_wiese': 'Meadow',
      'placeholder_smiley': 'Smiley',
      'puzzles': 'Puzzles',
      'roles': 'Roles',
      'lastLogin': 'Last login',
      'neverLoggedIn': 'Never logged in',
      'author': 'Author',
      'images': 'Images',
      'public': 'Public',
      'id': 'ID',
      'noPuzzlesFound': 'No puzzles found',
      'updateError': 'Error updating!',
      'username': 'Username',
      'login': 'Login',
      'logout': 'Logout',
      'play': 'Play',
      'crop': 'Crop',
      'create': 'Create',
      'users': 'Users',
      'systemInfo': 'System Info',
      'settings': 'Settings',
      'selectPlaceholder': 'Select Placeholder',
      'language': 'Language',
    },
  };

  static String get(String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }

  static void setLanguage(String code) {
    languageCode = code;
  }
}