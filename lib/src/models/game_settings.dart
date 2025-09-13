import '../utils/constants.dart';

class GameSettings {
  static const String keyPlaceholderChanged = 'placeholderChanged';
  static const String keyLanguageChanged = 'languageChanged';
  static const String keySoundChanged = 'soundChanged';

  static final List<Map<String, String>> defaultPlaceholders = [
    {'key': 'placeholder_himmel', 'asset': '${AppConstants.imagePrefix}placeholder1.png'},
    {'key': 'placeholder_puzzle', 'asset': '${AppConstants.imagePrefix}placeholder2.png'},
    {'key': 'placeholder_wiese', 'asset': '${AppConstants.imagePrefix}placeholder3.png'},
    {'key': 'placeholder_smiley', 'asset': '${AppConstants.imagePrefix}placeholder0.png'},
  ];

  int _selectedPlaceholderIndex;
  String _languageCode;
  bool _isSoundMuted;
  Function(String key, dynamic value)? _onSettingChanged;

  GameSettings({
    int selectedPlaceholderIndex = 0,
    String languageCode = 'en',
    bool isSoundMuted = false,
    Function(String key, dynamic value)? onSettingChanged,
  })  : _selectedPlaceholderIndex = selectedPlaceholderIndex,
        _languageCode = languageCode,
        _isSoundMuted = isSoundMuted,
        _onSettingChanged = onSettingChanged;

  List<Map<String, String>> get placeholders => defaultPlaceholders;

  String get selectedAsset =>
      placeholders[selectedPlaceholderIndex]['asset'] ?? '';

  set onSettingChanged(Function(String key, dynamic value)? callback) {
    _onSettingChanged = callback;
  }

  int get selectedPlaceholderIndex => _selectedPlaceholderIndex;
  set selectedPlaceholderIndex(int value) {
    _selectedPlaceholderIndex = value;
    updateSetting(keyPlaceholderChanged, value);
  }

  String get languageCode => _languageCode;
  set languageCode(String value) {
    _languageCode = value;
    updateSetting(keyLanguageChanged, value);
  }

  bool get isSoundMuted => _isSoundMuted;
  set isSoundMuted(bool value) {
    _isSoundMuted = value;
    updateSetting(keySoundChanged, value);
  }

  void updateSetting(String key, dynamic value) {
    if (_onSettingChanged != null) {
      _onSettingChanged!(key, value);
    }
  }
}