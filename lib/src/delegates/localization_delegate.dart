import 'package:flutter/widgets.dart';
import 'package:flutter_translate_fix/flutter_translate_fix.dart';
import 'package:flutter_translate_fix/src/constants/constants.dart';
import 'package:flutter_translate_fix/src/services/locale_service.dart';
import 'package:flutter_translate_fix/src/validators/configuration_validator.dart';
import 'package:intl/intl.dart';

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  final Locale fallbackLocale;

  final List<Locale> supportedLocales;

  final Map<Locale, String> supportedLocalesMap;

  LocaleChangedCallback? onLocaleChanged;

  LocalizationDelegate._(
    this.fallbackLocale,
    this.supportedLocales,
    this.supportedLocalesMap,
  );

  static late Locale _currentLocale;

  Locale get currentLocale => _currentLocale;

  Future<void> changeLocale(Locale newLocale) async {
    final locale =
        LocaleService.findLocale(newLocale, supportedLocales) ?? fallbackLocale;

    if (_currentLocale == locale) return;

    final localizedContent = await LocaleService.getLocaleContent(
      locale,
      supportedLocalesMap,
    );

    Localization.load(localizedContent);

    _currentLocale = locale;

    Intl.defaultLocale = _currentLocale.languageCode;

    if (onLocaleChanged != null) {
      await onLocaleChanged!(locale);
    }
  }

  static Future<LocalizationDelegate> create({
    required String fallbackLocale,
    required List<String> supportedLocales,
    String basePath = Constants.localizedAssetsPath,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    final fallback = localeFromString(fallbackLocale);

    final localesMap = await LocaleService.getLocalesMap(
      supportedLocales,
      basePath,
    );
    final locales = localesMap.keys.toList();

    ConfigurationValidator.validate(fallback, locales);

    _currentLocale = LocaleService.loadDeviceLocale() ?? fallback;

    return LocalizationDelegate._(fallback, locales, localesMap);
  }

  @override
  Future<Localization> load(Locale newLocale) async {
    if (currentLocale != newLocale) {
      await changeLocale(newLocale);
    }

    return Localization.instance;
  }

  @override
  bool isSupported(Locale? locale) => locale != null;

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => true;
}
