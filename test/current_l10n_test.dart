import 'dart:ui';

import 'package:flacidal_mobile/l10n/current_l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chosen language wins over the device', () {
    expect(
      currentL10n(const Locale('fr'), device: const Locale('de')).localeName,
      'fr',
    );
  });

  test('device language is used when none is chosen', () {
    expect(
      currentL10n(null, device: const Locale('de', 'CH')).localeName,
      'de',
    );
  });

  test('unsupported language falls back to English', () {
    expect(currentL10n(null, device: const Locale('ja')).localeName, 'en');
  });

  test('notification text is translated', () {
    expect(
      currentL10n(const Locale('fr')).notifGrabbing(3),
      'Récupération de 3 pistes...',
    );
  });
}
