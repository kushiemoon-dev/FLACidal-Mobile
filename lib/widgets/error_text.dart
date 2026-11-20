import 'package:flutter/widgets.dart';

import '../core/core_errors.dart';
import '../l10n/app_localizations.dart';

/// Translated "Something went wrong: ..." line for a failure raised by Core.
String genericErrorText(BuildContext context, Object error) {
  final l = AppLocalizations.of(context);
  return l.errorGeneric(describeCoreError(l, error));
}
