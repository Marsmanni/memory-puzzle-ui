import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../models/settings.dart'; // Import your settings class

class PlaySettingsMenu extends StatelessWidget {
  final GameSettings settings;
  
  const PlaySettingsMenu({
    required this.settings,
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
        ...List.generate(settings.placeholders.length, (i) => PopupMenuItem<String>(
          value: 'placeholder_$i',
          child: Text(AppLocalizations.get('playPage.${settings.placeholders[i]['key']}')),
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
              if (settings.languageCode == 'de') ...[
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
              if (settings.languageCode == 'en') ...[
                const SizedBox(width: 8),
                const Icon(Icons.check, color: Colors.green, size: 18),
              ],
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'toggle_sound',
          child: Row(
            children: [
              Icon(settings.isSoundMuted ? Icons.volume_off : Icons.volume_up, color: Colors.blue),
              const SizedBox(width: 8),
              Text(AppLocalizations.get('playPage.sound')),
              const Spacer(),
              Switch(
                value: !settings.isSoundMuted,
                onChanged: (value) {
                  settings.isSoundMuted = !value;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value.startsWith('placeholder_')) {
          final index = int.parse(value.split('_')[1]);
          settings.selectedPlaceholderIndex = index;
        } else if (value == 'lang_de') {
          settings.languageCode = 'de';
        } else if (value == 'lang_en') {
          settings.languageCode = 'en';
        } else if (value == 'toggle_sound') {
          settings.isSoundMuted = !settings.isSoundMuted;
        }
      },
    );
  }
}