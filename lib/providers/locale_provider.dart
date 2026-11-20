import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config_provider.dart';

/// Languages offered in Settings; `''` means follow the device.
const supportedLanguageCodes = ['en', 'fr', 'de'];

/// Locale taken from the Core config `language` key, `null` = device locale.
final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.watch(configProvider).value?['language'];
    if (code is String && supportedLanguageCodes.contains(code)) {
      return Locale(code);
    }
    return null;
  }

  /// Persists [code] (`''` for Auto) by saving the COMPLETE config.
  void set(String code) {
    final current = ref.read(configProvider).value ?? const {};
    final updated = Map<String, dynamic>.from(current)..['language'] = code;
    ref.read(configProvider.notifier).save(updated);
  }
}
