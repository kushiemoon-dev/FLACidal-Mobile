import 'dart:ui';

import 'app_localizations.dart';

/// Localizations for code that runs without a BuildContext (notifications).
/// Uses the language chosen in Settings, else the device language, else English.
AppLocalizations currentL10n(Locale? chosen, {Locale? device}) {
  final wanted = chosen ?? device ?? PlatformDispatcher.instance.locale;
  final supported = AppLocalizations.supportedLocales.firstWhere(
    (l) => l.languageCode == wanted.languageCode,
    orElse: () => const Locale('en'),
  );
  return lookupAppLocalizations(supported);
}
