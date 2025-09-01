import 'dart:io';

// Replace these with your actual old and new translation maps
final Map<String, String> oldKeys = {
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
};

final Map<String, String> newKeys = {
 'usersPage.title': 'Alle Benutzer',
      'usersPage.table': 'Benutzer (Tabelle)',
      'usersPage.list': 'Benutzerliste',
      'usersPage.noUsers': 'Keine Benutzer gefunden',

      // Puzzle Page
      'puzzlePage.title': 'Alle Puzzles',
      'puzzlePage.noPuzzles': 'Keine Puzzles gefunden',

      // Play Page
      'playPage.settings': 'Einstellungen',
      'playPage.selectPlaceholder': 'Platzhalter auswählen',
      'playPage.language': 'Sprache',

      // Widgets
      'userAdminCard.puzzles': 'Puzzles',
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
};

final Map<String, String> oldToNewKey = {};
void buildOldToNewKey() {
  oldKeys.forEach((oldKey, oldValue) {
    final newKey = newKeys.entries
        .firstWhere((entry) => entry.value == oldValue, orElse: () => const MapEntry('', ''))
        .key;
    if (newKey.isNotEmpty) {
      oldToNewKey[oldKey] = newKey;
    }
  });
}
void main() async {
  final directory = Directory('c:/Sources/Flutter/MemoryPuzzleUI/lib');

  await for (var entity in directory.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      bool changed = false;

      oldToNewKey.forEach((oldKey, newKey) {
        final oldCall = "AppLocalizations.get('$oldKey')";
        final newCall = "AppLocalizations.get('$newKey')";
        if (content.contains(oldCall)) {
          content = content.replaceAll(oldCall, newCall);
          changed = true;
        }
      });

      if (changed) {
        await entity.writeAsString(content);
        print('Updated: ${entity.path}');
      }
    }
  }
  print('Migration complete.');
}