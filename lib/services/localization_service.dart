import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _systemLanguage = 'system';
  
  Locale? _currentLocale;
  bool _isSystemLanguage = true;
  
  Locale? get currentLocale => _currentLocale;
  bool get isSystemLanguage => _isSystemLanguage;
  
  // Поддерживаемые языки
  static const List<Locale> supportedLocales = [
    Locale('ru', 'RU'), // Русский
    Locale('uk', 'UA'), // Украинский
    Locale('en', 'US'), // Английский
    Locale('my', 'MM'), // Бирманский
    Locale('zh', 'CN'), // Китайский
    Locale('th', 'TH'), // Тайский
    Locale('hi', 'IN'), // Хинди
    Locale('ar', 'SA'), // Арабский
    Locale('de', 'DE'), // Немецкий
    Locale('km', 'KH'), // Кхмерский
    Locale('pl', 'PL'), // Польский
  ];
  
  // Получить системную локаль
  static Locale getSystemLocale() {
    try {
      final String systemLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      return supportedLocales.firstWhere(
        (locale) => locale.languageCode == systemLocale,
        orElse: () => const Locale('en', 'US'),
      );
    } catch (e) {
      // Fallback в случае ошибки
      print('Error getting system locale: $e');
      return const Locale('en', 'US');
    }
  }
  
  // Инициализация сервиса
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    
    if (savedLanguage == null || savedLanguage == _systemLanguage) {
      _isSystemLanguage = true;
      _currentLocale = getSystemLocale();
    } else {
      _isSystemLanguage = false;
      _currentLocale = Locale(savedLanguage);
    }
    
    notifyListeners();
  }
  
  // Установить язык
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (languageCode == _systemLanguage) {
      _isSystemLanguage = true;
      _currentLocale = getSystemLocale();
      await prefs.setString(_languageKey, _systemLanguage);
    } else {
      _isSystemLanguage = false;
      _currentLocale = Locale(languageCode);
      await prefs.setString(_languageKey, languageCode);
    }
    
    notifyListeners();
  }
  
  // Получить текущий язык
  String getCurrentLanguageCode() {
    if (_currentLocale == null) {
      return 'en'; // Fallback значение
    }
    return _currentLocale!.languageCode;
  }
  
  // Получить название языка
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return 'Русский';
      case 'uk':
        return 'Українська';
      case 'en':
        return 'English';
      case 'my':
        return 'မြန်မာ';
      case 'zh':
        return '中文';
      case 'th':
        return 'ไทย';
      case 'hi':
        return 'हिन्दी';
      case 'ar':
        return 'العربية';
      case 'de':
        return 'Deutsch';
      case 'km':
        return 'ខ្មែរ';
      case 'pl':
        return 'Polski';
      case _systemLanguage:
        return 'System';
      default:
        return 'English';
    }
  }
  
  // Получить список доступных языков
  List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': _systemLanguage, 'name': getLanguageName(_systemLanguage)},
      {'code': 'ru', 'name': getLanguageName('ru')},
      {'code': 'uk', 'name': getLanguageName('uk')},
      {'code': 'en', 'name': getLanguageName('en')},
      {'code': 'my', 'name': getLanguageName('my')},
      {'code': 'zh', 'name': getLanguageName('zh')},
      {'code': 'th', 'name': getLanguageName('th')},
      {'code': 'hi', 'name': getLanguageName('hi')},
      {'code': 'ar', 'name': getLanguageName('ar')},
      {'code': 'de', 'name': getLanguageName('de')},
      {'code': 'km', 'name': getLanguageName('km')},
      {'code': 'pl', 'name': getLanguageName('pl')},
    ];
  }
} 