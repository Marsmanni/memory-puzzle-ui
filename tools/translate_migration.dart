import 'dart:io';

final Map<String, Map<String, String>> localizedValues = {
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

void main() async {
  final directory = Directory('c:/Sources/Flutter/MemoryPuzzleUI/lib');
  final keys = localizedValues['de']!.keys.toList();
  final values = localizedValues['de']!.values.toList();

  await for (var entity in directory.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      bool changed = false;

      for (int i = 0; i < values.length; i++) {
        final value = values[i];
        final key = keys[i];
        // Replace only if not already using AppLocalizations.get
        final regex = RegExp('([\'"])$value\\1');
        if (regex.hasMatch(content)) {
          content = content.replaceAllMapped(regex, (match) {
            changed = true;
            return "AppLocalizations.get('$key')";
          });
        }
      }

      if (changed) {
        await entity.writeAsString(content);
        print('Updated: ${entity.path}');
      }
    }
  }
  print('Migration complete.');
}