import 'package:flutter/material.dart';
import 'package:sepesha_app/services/preferences.dart';

class LocalizationProvider extends ChangeNotifier {
  Locale _locale = const Locale('sw'); // Default to Swahili

  Locale get locale => _locale;

  LocalizationProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLanguage = await Preferences.instance.getString('app_language');
    if (savedLanguage != null) {
      _locale = Locale(savedLanguage);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    Preferences.instance.save('app_language', locale.languageCode);
    notifyListeners();
  }

  bool get isSwahili => _locale.languageCode == 'sw';
  bool get isEnglish => _locale.languageCode == 'en';
}
