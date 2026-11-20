import 'package:flacidal_mobile/core/core_errors.dart';
import 'package:flacidal_mobile/core/exceptions.dart';
import 'package:flacidal_mobile/l10n/app_localizations_en.dart';
import 'package:flacidal_mobile/l10n/app_localizations_fr.dart';
import 'package:flutter_test/flutter_test.dart';

FlacCoreException _err(String message, [String code = 'METHOD_ERROR']) =>
    FlacCoreException(code: code, message: message);

void main() {
  group('parseCoreError', () {
    test('extracts the stable code and the detail', () {
      final info = parseCoreError(_err('[extension.invalid_id] bad id "x"'));
      expect(info.code, 'extension.invalid_id');
      expect(info.detail, 'bad id "x"');
    });

    test('accepts a code without detail', () {
      final info = parseCoreError(_err('[extension.registry]'));
      expect(info.code, 'extension.registry');
      expect(info.detail, isEmpty);
    });

    test('message without brackets keeps the transport code', () {
      final info = parseCoreError(_err('disk full'));
      expect(info.code, 'METHOD_ERROR');
      expect(info.detail, 'disk full');
    });

    test('brackets that are not a code are ignored', () {
      expect(parseCoreError(_err('[oops] x')).code, 'METHOD_ERROR');
    });

    test('non Core exception maps to UNKNOWN', () {
      expect(parseCoreError(StateError('x')).code, 'UNKNOWN');
    });
  });

  group('describeCoreError', () {
    final en = AppLocalizationsEn();

    test('translates every extension code', () {
      final expected = {
        'extension.invalid_id': en.extensionErrorInvalidId,
        'extension.reserved_id': en.extensionErrorReservedId,
        'extension.insecure_url': en.extensionErrorInsecureUrl,
        'extension.too_large': en.extensionErrorTooLarge,
        'extension.invalid_zip': en.extensionErrorInvalidZip,
        'extension.invalid_manifest': en.extensionErrorInvalidManifest,
        'extension.not_found': en.extensionErrorNotFound,
        'extension.invalid_auth_field': en.extensionErrorInvalidAuthField,
        'extension.registry': en.extensionErrorRegistry,
      };
      expected.forEach((code, text) {
        expect(describeCoreError(en, _err('[$code] detail')), text);
      });
    });

    test('follows the locale', () {
      final fr = AppLocalizationsFr();
      expect(
        describeCoreError(fr, _err('[extension.not_found] x')),
        fr.extensionErrorNotFound,
      );
    });

    test('unknown error shows generic text plus raw detail', () {
      expect(
        describeCoreError(en, _err('disk full')),
        'Something went wrong. (disk full)',
      );
    });

    test('never leaks toString of a foreign exception', () {
      expect(describeCoreError(en, StateError('secret')), en.coreErrorGeneric);
    });

    test('NOT_INITIALIZED is translated', () {
      expect(
        describeCoreError(en, _err('init', 'NOT_INITIALIZED')),
        en.coreErrorNotInitialized,
      );
    });
  });
}
