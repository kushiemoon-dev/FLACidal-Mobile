import 'package:flacidal_mobile/l10n/app_localizations.dart';
import 'package:flacidal_mobile/pages/rename_page.dart';
import 'package:flacidal_mobile/providers/core_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_core.dart';

FakeTransport _transport() => FakeTransport(
  responses: {
    'getRenameTemplates': [
      {'name': 'Title', 'template': '{title}'},
      {'name': 'Artist - Title', 'template': '{artist} - {title}'},
    ],
    'previewRename': (Map<String, dynamic>? p) => [
      {
        'oldPath': '/m/a.flac',
        'oldName': 'a.flac',
        'newName': 'A.flac',
        'hasError': false,
      },
      {
        'oldPath': '/m/b.flac',
        'oldName': 'b.flac',
        'newName': '',
        'hasError': true,
        'error': 'missing tag',
      },
    ],
    'renameFiles': [
      {'oldPath': '/m/a.flac', 'newPath': '/m/A.flac', 'success': true},
    ],
  },
)..autoAsync = true;

Future<Widget> _app(FakeTransport t) async {
  final core = await initializedCore(t);
  return ProviderScope(
    overrides: [flacCoreProvider.overrideWithValue(core)],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RenamePage(filePaths: ['/m/a.flac', '/m/b.flac']),
    ),
  );
}

void main() {
  testWidgets('Apply stays disabled until a preview exists', (tester) async {
    final t = _transport();
    await tester.pumpWidget(await _app(t));
    await tester.pump();

    final apply = find.widgetWithText(FilledButton, 'Rename 0 file(s)');
    expect(tester.widget<FilledButton>(apply).onPressed, isNull);
    expect(t.calls.where((c) => c.method == 'renameFiles'), isEmpty);
  });

  testWidgets('preview shows errors, apply sends only valid checked files', (
    tester,
  ) async {
    final t = _transport();
    await tester.pumpWidget(await _app(t));
    await tester.pump();

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();
    expect(find.text('A.flac'), findsOneWidget);
    expect(find.text('Cannot rename: missing tag'), findsOneWidget);

    await tester.tap(find.text('Rename 1 file(s)'));
    await tester.pumpAndSettle();
    final call = t.calls.lastWhere((c) => c.method == 'renameFiles');
    expect(call.params, {
      'files': ['/m/a.flac'],
      'template': '{title}',
    });
  });

  testWidgets('changing the template invalidates the preview', (tester) async {
    final t = _transport();
    await tester.pumpWidget(await _app(t));
    await tester.pump();
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();
    expect(find.text('A.flac'), findsOneWidget);

    await tester.tap(find.text('{artist} - {title}').first);
    await tester.pump();

    expect(find.text('A.flac'), findsNothing);
    final apply = find.widgetWithText(FilledButton, 'Rename 0 file(s)');
    expect(tester.widget<FilledButton>(apply).onPressed, isNull);
  });
}
