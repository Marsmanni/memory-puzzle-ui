import 'package:flutter/material.dart';
import '../dtos/api_dtos.dart';
import '../utils/app_localizations.dart';

class ImageCropperAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<FileGroupDto> filegroups;
  final String? selectedFilegroupName;
  final bool loadingFilegroups;
  final TextEditingController filegroupController;
  final ValueChanged<String?> onFilegroupChanged;
  final ValueChanged<String> onNewFilegroup;
  final VoidCallback onPickImageWeb;
  final VoidCallback onCropAndSaveImage;

  const ImageCropperAppBar({
    super.key,
    required this.filegroups,
    required this.selectedFilegroupName,
    required this.loadingFilegroups,
    required this.filegroupController,
    required this.onFilegroupChanged,
    required this.onNewFilegroup,
    required this.onPickImageWeb,
    required this.onCropAndSaveImage,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Text(AppLocalizations.get('cropperPage.title')),
          const SizedBox(width: 16),
          // Neue Dateigruppe zuerst
          SizedBox(
            width: 120,
            child: TextField(
              controller: filegroupController,
              decoration: InputDecoration(
                labelText: AppLocalizations.get('cropperPage.newFilegroupLabel'),
                hintText: AppLocalizations.get('cropperPage.newFilegroupHint'),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 8,
                ),
              ),
              onSubmitted: onNewFilegroup,
            ),
          ),
          const SizedBox(width: 16),
          // Dateigruppe Dropdown
          Text(AppLocalizations.get('cropperPage.filegroupLabel')),
          const SizedBox(width: 8),
          SizedBox(
            width: 220,
            child: loadingFilegroups
                ? const CircularProgressIndicator()
                : DropdownButton<String>(
                    value: selectedFilegroupName,
                    isExpanded: true,
                    items: filegroups
                        .map(
                          (fg) => DropdownMenuItem(
                            value: fg.groupName,
                            child: Text('${fg.groupName} (${fg.imageCount})'),
                          ),
                        )
                        .toList(),
                    onChanged: onFilegroupChanged,
                  ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: onPickImageWeb,
            child: Text(AppLocalizations.get('cropperPage.selectPhotoWeb')),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onCropAndSaveImage,
            child: Text(AppLocalizations.get('cropperPage.cutAndSave')),
          ),
        ],
      ),
      centerTitle: true,
      // Remove custom background color
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}