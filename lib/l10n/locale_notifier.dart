import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocaleNotifier extends ChangeNotifier {
  static const String _boxName = 'app_prefs';
  static const String _key = 'localeCode';

  Locale? _locale;
  Locale? get locale => _locale;

  final List<Locale> supported = const [
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('it'),
    Locale('tr'),
    Locale('es'),
    Locale('de'),
  ];

  Future<void> load() async {
    try {
      final box = await Hive.openBox(_boxName);
      final saved = box.get(_key) as String?;
      if (saved != null) {
        _locale = _localeFromCode(saved);
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setLocale(Locale l) async {
    _locale = l;
    notifyListeners();
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_key, l.languageCode);
    } catch (_) {}
  }

  Locale? _localeFromCode(String code) {
    try {
      return supported.firstWhere((e) => e.languageCode == code);
    } catch (_) {
      return null;
    }
  }
}
