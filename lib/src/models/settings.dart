import '../utils/constants.dart';

class GameSettings {
  static final List<Map<String, String>> defaultPlaceholders = [
    {'key': 'placeholder_himmel', 'asset': '${AppConstants.imagePrefix}placeholder1.png'},
    {'key': 'placeholder_puzzle', 'asset': '${AppConstants.imagePrefix}placeholder2.png'},
    {'key': 'placeholder_wiese', 'asset': '${AppConstants.imagePrefix}placeholder3.png'},
    {'key': 'placeholder_smiley', 'asset': '${AppConstants.imagePrefix}placeholder0.png'},
  ];

  int _selectedPlaceholderIndex;
  String _languageCode;
  bool _isSoundMuted;

  void Function(String key, dynamic value)? onSettingChanged;

  GameSettings({
    int selectedPlaceholderIndex = 0,
    String languageCode = 'en',
    bool isSoundMuted = false,
    this.onSettingChanged,
  })  : _selectedPlaceholderIndex = selectedPlaceholderIndex,
        _languageCode = languageCode,
        _isSoundMuted = isSoundMuted;

  List<Map<String, String>> get placeholders => defaultPlaceholders;

  int get selectedPlaceholderIndex => _selectedPlaceholderIndex;
  set selectedPlaceholderIndex(int value) {
    _selectedPlaceholderIndex = value;
    updateSetting('placeholderChanged', value);
  }

  String get languageCode => _languageCode;
  set languageCode(String value) {
    _languageCode = value;
    updateSetting('languageChanged', value);
  }

  bool get isSoundMuted => _isSoundMuted;
  set isSoundMuted(bool value) {
    _isSoundMuted = value;
    updateSetting('soundChanged', value);
  }

  void updateSetting(String key, dynamic value) {
    if (onSettingChanged != null) {
      onSettingChanged!(key, value);
    }
  }
}