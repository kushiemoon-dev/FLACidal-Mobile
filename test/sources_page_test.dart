import 'package:flacidal_mobile/l10n/app_localizations.dart';
import 'package:flacidal_mobile/pages/sources_page.dart';
import 'package:flacidal_mobile/providers/core_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_core.dart';

Future<Widget> _app(FakeTransport t) async {
  final core = await initializedCore(t);
  return ProviderScope(
    overrides: [flacCoreProvider.overrideWithValue(core)],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SourcesPage(),
    ),
  );
}

FakeTransport _transport({Object? order}) => FakeTransport(
  responses: {
    'getAvailableSources': [
      {'name': 'tidal', 'displayName': 'Tidal', 'available': true},
      {'name': 'ext-x', 'displayName': 'Cool Ext', 'available': false},
    ],
    'getPreferredSource': 'tidal',
    'getSourceOrder': order ?? ['ext-x', 'tidal'],
    'getConfig': {
      'qobuzAppId': 'APPID',
      'autoQualityFallback': true,
      'soulseekUsername': 'bob',
    },
    'getExtensions': [],
    'setPreferredSource': null,
    'saveConfig': null,
    'setSourceOrder': null,
    'testQobuzConnection': {'success': false, 'error': 'Qobuz not configured'},
  },
);

void main() {
  testWidgets('shows Core order, labels and honest status', (tester) async {
    await tester.pumpWidget(await _app(_transport()));
    await tester.pump();

    expect(find.text('Cool Ext'), findsWidgets);
    expect(find.text('Configured'), findsOneWidget);
    expect(find.text('Not configured'), findsOneWidget);
    expect(find.text('OK'), findsNothing);
    expect(find.text('Quality fallback'), findsOneWidget);
    // order comes from Core: ext-x is row 1, tidal row 2
    final first = tester.getTopLeft(find.text('Cool Ext').first);
    final second = tester.getTopLeft(find.text('Tidal').first);
    expect(first.dy, lessThan(second.dy));

    // credentials are prefilled from getConfig().result
    final appId = find.widgetWithText(TextField, 'APPID');
    await tester.scrollUntilVisible(
      appId,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(appId, findsOneWidget);
  });

  testWidgets('quality fallback switch writes via setPreferredSource', (
    tester,
  ) async {
    final t = _transport();
    await tester.pumpWidget(await _app(t));
    await tester.pump();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    final call = t.calls.lastWhere((c) => c.method == 'setPreferredSource');
    expect(call.params, {'source': 'tidal', 'fallback': false});
  });

  testWidgets('load failure shows a translated error and Retry', (
    tester,
  ) async {
    final t = _transport(order: const FakeError('METHOD_ERROR', 'boom'));
    await tester.pumpWidget(await _app(t));
    await tester.pump();
    expect(find.textContaining('Could not load sources'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    // no invented default order is shown
    expect(find.text('Soulseek'), findsNothing);
  });

  testWidgets('test connection surfaces the Core error text', (tester) async {
    await tester.pumpWidget(await _app(_transport()));
    await tester.pump();
    final button = find.text('Test connection');
    await tester.scrollUntilVisible(
      button,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Could not connect: Qobuz not configured'),
      findsOneWidget,
    );
  });
}
