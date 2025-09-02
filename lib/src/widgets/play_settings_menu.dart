import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';

class PlaySettingsMenu extends StatelessWidget {
  final int selectedPlaceholderIndex;
  final List<Map<String, String>> placeholders;
  final ValueChanged<int> onPlaceholderChanged;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;

  const PlaySettingsMenu({
    required this.selectedPlaceholderIndex,
    required this.placeholders,
    required this.onPlaceholderChanged,
    required this.languageCode,
    required this.onLanguageChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings),
      tooltip: AppLocalizations.get('playPage.settings'),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(AppLocalizations.get('playPage.selectPlaceholder')),
        ),
        ...List.generate(placeholders.length, (i) => PopupMenuItem<String>(
          value: 'placeholder_$i',
          child: Text(AppLocalizations.get('playPage.${placeholders[i]['key']}')),
        )),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          enabled: false,
          child: Text(AppLocalizations.get('playPage.language')),
        ),
        PopupMenuItem<String>(
          value: 'lang_de',
          child: Row(
            children: [
              const Text('🇩🇪 '),
              const SizedBox(width: 8),
              const Text('Deutsch'),
              if (languageCode == 'de') ...[
                const SizedBox(width: 8),
                const Icon(Icons.check, color: Colors.green, size: 18),
              ],
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'lang_en',
          child: Row(
            children: [
              const Text('🇬🇧 '),
              const SizedBox(width: 8),
              const Text('English'),
              if (languageCode == 'en') ...[
                const SizedBox(width: 8),
                const Icon(Icons.check, color: Colors.green, size: 18),
              ],
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value.startsWith('placeholder_')) {
          final index = int.parse(value.split('_')[1]);
          onPlaceholderChanged(index);
        } else if (value == 'lang_de') {
          onLanguageChanged('de');
        } else if (value == 'lang_en') {
          onLanguageChanged('en');
        }
      },
    );
  }
}