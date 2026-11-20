import 'package:flacidal_mobile/core/update_service.dart';
import 'package:flacidal_mobile/l10n/app_localizations.dart';
import 'package:flacidal_mobile/widgets/update_required_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(UpdateStatus status, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: UpdateRequiredScreen(status: status),
    );

UpdateStatus _status(String current, String latest) => UpdateStatus(
  hasUpdate: true,
  currentVersion: current,
  latestVersion: latest,
  versionsBehind: 3,
  blocked: true,
  releaseUrl: 'https://example.test/release',
);

void main() {
  testWidgets('beta to 1.0 shows the migration steps, not an install button', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_status('0.8.0-beta.13', '1.0.0')));
    expect(find.textContaining('new signing key'), findsOneWidget);
    expect(find.text('Open the release page'), findsOneWidget);
    expect(find.text('Update now'), findsNothing);
  });

  testWidgets('regular update keeps the install flow', (tester) async {
    await tester.pumpWidget(_app(_status('1.0.0', '1.0.4')));
    expect(find.text('Update now'), findsOneWidget);
    expect(find.text('Open the release page'), findsNothing);
  });

  testWidgets('migration message is translated', (tester) async {
    await tester.pumpWidget(
      _app(_status('0.8.0-beta.13', '1.0.0'), locale: const Locale('fr')),
    );
    expect(find.textContaining('nouvelle clé de signature'), findsOneWidget);
  });
}
