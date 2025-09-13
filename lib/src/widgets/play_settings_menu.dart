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
          onTap: () => settings.selectedPlaceholderIndex = i,
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
          onTap: () => settings.languageCode = 'de',
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
          onTap: () => settings.languageCode = 'en',
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
          onTap: () => settings.isSoundMuted = !settings.isSoundMuted,
        ),
      ]
    );
  }
}