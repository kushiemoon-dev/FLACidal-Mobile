import 'package:flacidal_mobile/l10n/app_localizations.dart';
import 'package:flacidal_mobile/pages/extensions_page.dart';
import 'package:flacidal_mobile/providers/core_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_core.dart';

Map<String, dynamic> _ext({
  bool enabled = false,
  Map<String, bool> authSet = const {},
}) => {
  'manifest': {
    'id': 'cool',
    'name': 'Cool Ext',
    'version': '1.0.0',
    'author': 'me',
    'capabilities': ['source'],
    'permissions': ['network'],
    'authFields': [
      {'key': 'token', 'label': 'API token', 'type': 'password'},
    ],
  },
  'enabled': enabled,
  'hosts': ['api.cool.example'],
  'authSet': authSet,
};

FakeTransport _transport({List<dynamic> installed = const []}) {
  return FakeTransport(
    responses: {
      'getExtensions': (_) => installed,
      'getExtensionSources': ['https://github.com/me/mine'],
      'getExtensionRegistry': (p) => p!['url'] == ''
          ? [
              {
                'id': 'cool',
                'name': 'Cool Ext',
                'latestVersion': '1.0.0',
                'downloadURL': 'https://x/cool.zip',
                'permissions': ['network'],
              },
            ]
          : const FakeError('METHOD_ERROR', '[extension.registry] bad repo'),
      'installExtension': {'id': 'cool'},
      'enableExtension': null,
      'setExtensionAuth': null,
    },
  )..autoAsync = true;
}

Future<Widget> _app(FakeTransport t) async {
  final core = await initializedCore(t);
  return ProviderScope(
    overrides: [flacCoreProvider.overrideWithValue(core)],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ExtensionsPage(),
    ),
  );
}

Future<void> _openBrowse(WidgetTester tester) async {
  await tester.tap(find.text('Browse'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('browse queries the default registry and every added source', (
    tester,
  ) async {
    final t = _transport();
    await tester.pumpWidget(await _app(t));
    await tester.pumpAndSettle();
    await _openBrowse(tester);

    final urls = t.asyncCalls
        .where((c) => c.request.contains('getExtensionRegistry'))
        .map((c) => c.request)
        .toList();
    expect(urls, hasLength(2));
    expect(urls.first, contains('"url":""'));
    expect(urls.last, contains('github.com/me/mine'));
    // default registry still shown, failing source reported in translated form
    expect(find.text('Cool Ext'), findsOneWidget);
    expect(
      find.textContaining('The extension registry could not be read.'),
      findsOneWidget,
    );
  });

  testWidgets('prompt lists hosts and permissions; Later does not enable', (
    tester,
  ) async {
    final t = _transport();
    // installed list is empty at first load, then contains the new extension
    var installedNow = <dynamic>[];
    t.responses['getExtensions'] = (_) => installedNow;
    await tester.pumpWidget(await _app(t));
    await tester.pumpAndSettle();
    await _openBrowse(tester);

    installedNow = [_ext()];
    await tester.tap(find.text('Install'));
    await tester.pumpAndSettle();

    expect(find.text('Enable Cool Ext?'), findsOneWidget);
    expect(find.text('• api.cool.example'), findsOneWidget);
    expect(find.text('• network'), findsOneWidget);

    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(t.calls.where((c) => c.method == 'enableExtension'), isEmpty);
  });

  testWidgets('Enable in the prompt calls enableExtension', (tester) async {
    final t = _transport();
    var installedNow = <dynamic>[];
    t.responses['getExtensions'] = (_) => installedNow;
    await tester.pumpWidget(await _app(t));
    await tester.pumpAndSettle();
    await _openBrowse(tester);

    installedNow = [_ext()];
    await tester.tap(find.text('Install'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enable'));
    await tester.pumpAndSettle();

    final call = t.calls.lastWhere((c) => c.method == 'enableExtension');
    expect(call.params, {'id': 'cool', 'enabled': true});
  });

  testWidgets('configure sends only typed fields and shows Configured hint', (
    tester,
  ) async {
    final t = _transport(
      installed: [
        _ext(authSet: {'token': true}),
      ],
    );
    await tester.pumpWidget(await _app(t));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configure'));
    await tester.pumpAndSettle();

    expect(find.text('Configured'), findsOneWidget); // hint, not a value
    // leaving the field empty and saving makes no call
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(t.calls.where((c) => c.method == 'setExtensionAuth'), isEmpty);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configure'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'secret',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(t.calls.lastWhere((c) => c.method == 'setExtensionAuth').params, {
      'id': 'cool',
      'data': {'token': 'secret'},
    });
  });

  testWidgets('non GitHub source URL is rejected before reaching Core', (
    tester,
  ) async {
    final t = _transport();
    await tester.pumpWidget(await _app(t));
    await tester.pumpAndSettle();
    await _openBrowse(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'http://example.com/a/b',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter an address like https://github.com/owner/repo'),
      findsOneWidget,
    );
    expect(t.calls.where((c) => c.method == 'addExtensionSource'), isEmpty);
  });
}
