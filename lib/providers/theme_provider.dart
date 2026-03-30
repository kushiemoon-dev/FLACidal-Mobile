import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences instance — initialized before runApp.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

/// Theme mode provider (dark/light/system) with persistence.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'themeMode';

  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPrefsProvider);
    final index = prefs.getInt(_key);
    if (index != null && index < ThemeMode.values.length) {
      return ThemeMode.values[index];
    }
    return ThemeMode.dark;
  }

  void set(ThemeMode mode) {
    state = mode;
    ref.read(sharedPrefsProvider).setInt(_key, mode.index);
  }
}

/// Accent color provider with persistence.
final accentColorProvider =
    NotifierProvider<AccentColorNotifier, Color>(AccentColorNotifier.new);

class AccentColorNotifier extends Notifier<Color> {
  static const _key = 'accentColor';

  @override
  Color build() {
    final prefs = ref.read(sharedPrefsProvider);
    final value = prefs.getInt(_key);
    if (value != null) return Color(value);
    return const Color(0xFFF472B6);
  }

  void set(Color color) {
    state = color;
    ref.read(sharedPrefsProvider).setInt(_key, color.toARGB32());
  }
}

/// Font family provider with persistence.
final fontFamilyProvider =
    NotifierProvider<FontFamilyNotifier, String?>(FontFamilyNotifier.new);

class FontFamilyNotifier extends Notifier<String?> {
  static const _key = 'fontFamily';

  @override
  String? build() {
    return ref.read(sharedPrefsProvider).getString(_key) ?? 'Outfit';
  }

  void set(String? family) {
    state = family;
    final prefs = ref.read(sharedPrefsProvider);
    if (family == null) {
      prefs.remove(_key);
    } else {
      prefs.setString(_key, family);
    }
  }
}
