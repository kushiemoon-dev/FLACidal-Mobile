import 'package:flacidal_mobile/l10n/app_localizations.dart';
import 'package:flacidal_mobile/pages/settings_page.dart';
import 'package:flacidal_mobile/providers/core_provider.dart';
import 'package:flacidal_mobile/providers/locale_provider.dart';
import 'package:flacidal_mobile/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_core.dart';

Future<(FakeTransport, Widget)> _app(String language) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final transport = FakeTransport(
    responses: {
      'getConfig': {'language': language},
      'saveConfig': null,
      'getDownloadOptions': {'Quality': 'HI_RES', 'FirstArtistOnly': false},
      'setDownloadOptions': null,
    },
  );
  final core = await initializedCore(transport);
  return (
    transport,
    ProviderScope(
      overrides: [
        flacCoreProvider.overrideWithValue(core),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: Consumer(
        builder: (context, ref, _) => MaterialApp(
          locale: ref.watch(localeProvider),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsPage(),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders French when the Core language is fr', (tester) async {
    final (_, app) = await _app('fr');
    await tester.pumpWidget(app);
    await tester.pump();
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.text('Téléchargement'), findsOneWidget);
  });

  testWidgets('renders German when the Core language is de', (tester) async {
    final (_, app) = await _app('de');
    await tester.pumpWidget(app);
    await tester.pump();
    expect(find.text('Einstellungen'), findsOneWidget);
  });

  testWidgets('first artist switch sends the full options map', (tester) async {
    final (transport, app) = await _app('');
    await tester.pumpWidget(app);
    await tester.pump();
    final tile = find.text('First artist only');
    await tester.scrollUntilVisible(tile, 200);
    await tester.tap(tile);
    await tester.pump();
    final sent = transport.calls
        .lastWhere((c) => c.method == 'setDownloadOptions')
        .params;
    expect(sent, {'Quality': 'HI_RES', 'FirstArtistOnly': true});
  });

  testWidgets('language picker saves the full config', (tester) async {
    final (transport, app) = await _app('');
    await tester.pumpWidget(app);
    await tester.pump();
    final tile = find.text('Language');
    await tester.scrollUntilVisible(tile, 200);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français').last);
    await tester.pumpAndSettle();
    final sent = transport.calls.lastWhere((c) => c.method == 'saveConfig');
    expect(sent.params, {'language': 'fr'});
    expect(find.text('Paramètres'), findsOneWidget);
  });
}
