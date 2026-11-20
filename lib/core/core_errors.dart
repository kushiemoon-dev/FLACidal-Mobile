import '../l10n/app_localizations.dart';
import 'exceptions.dart';

/// Stable code and raw detail extracted from a failure raised by Core.
///
/// Typed Core errors cross the RPC boundary as `"[extension.invalid_id] x"`
/// in `message`; anything else keeps the transport code (`METHOD_ERROR`...).
class CoreErrorInfo {
  const CoreErrorInfo({required this.code, this.detail = ''});

  final String code;
  final String detail;
}

final _codedMessage = RegExp(r'^\[([a-z_]+\.[a-z_]+)\]\s*(.*)$', dotAll: true);

CoreErrorInfo parseCoreError(Object error) {
  if (error is! FlacCoreException) {
    return const CoreErrorInfo(code: 'UNKNOWN');
  }
  final match = _codedMessage.firstMatch(error.message.trim());
  if (match == null) {
    return CoreErrorInfo(code: error.code, detail: error.message);
  }
  return CoreErrorInfo(code: match.group(1)!, detail: match.group(2)!.trim());
}

/// Translated, user-facing text for [error]. Never prints `toString()`.
String describeCoreError(AppLocalizations l, Object error) {
  final info = parseCoreError(error);
  final known = switch (info.code) {
    'extension.invalid_id' => l.extensionErrorInvalidId,
    'extension.reserved_id' => l.extensionErrorReservedId,
    'extension.insecure_url' => l.extensionErrorInsecureUrl,
    'extension.too_large' => l.extensionErrorTooLarge,
    'extension.invalid_zip' => l.extensionErrorInvalidZip,
    'extension.invalid_manifest' => l.extensionErrorInvalidManifest,
    'extension.not_found' => l.extensionErrorNotFound,
    'extension.invalid_auth_field' => l.extensionErrorInvalidAuthField,
    'extension.registry' => l.extensionErrorRegistry,
    'NOT_INITIALIZED' => l.coreErrorNotInitialized,
    _ => null,
  };
  if (known != null) return known;
  if (info.detail.isEmpty) return l.coreErrorGeneric;
  return l.coreErrorDetail(l.coreErrorGeneric, info.detail);
}
