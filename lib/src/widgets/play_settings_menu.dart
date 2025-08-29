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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings),
      tooltip: AppLocalizations.get('settings'),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(AppLocalizations.get('selectPlaceholder')),
        ),
        ...List.generate(placeholders.length, (i) => PopupMenuItem<String>(
          value: 'placeholder_$i',
          child: Text(AppLocalizations.get(placeholders[i]['key']!)),
        )),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          enabled: false,
          child: Text(AppLocalizations.get('language')),
        ),
        PopupMenuItem<String>(
          value: 'lang_de',
          child: Row(
            children: const [
              Text('🇩🇪 '),
              SizedBox(width: 8),
              Text('Deutsch'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'lang_en',
          child: Row(
            children: const [
              Text('🇬🇧 '),
              SizedBox(width: 8),
              Text('English'),
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