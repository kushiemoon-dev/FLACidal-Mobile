/// One line of a `previewRename` answer plus the user's checkbox.
class RenameRow {
  const RenameRow({
    required this.oldPath,
    required this.oldName,
    required this.newName,
    required this.hasError,
    required this.error,
    required this.checked,
  });

  factory RenameRow.fromCore(Map<dynamic, dynamic> json) {
    final hasError = json['hasError'] as bool? ?? false;
    return RenameRow(
      oldPath: json['oldPath'] as String? ?? '',
      oldName: json['oldName'] as String? ?? '',
      newName: json['newName'] as String? ?? '',
      hasError: hasError,
      error: json['error'] as String? ?? '',
      checked: !hasError,
    );
  }

  final String oldPath;
  final String oldName;
  final String newName;
  final bool hasError;
  final String error;
  final bool checked;

  /// A row can only be renamed if Core found no error for it.
  bool get applicable => !hasError && checked;

  RenameRow withChecked(bool value) => RenameRow(
    oldPath: oldPath,
    oldName: oldName,
    newName: newName,
    hasError: hasError,
    error: error,
    checked: hasError ? false : value,
  );
}

/// Immutable preview of a rename, tied to the template it was computed for.
/// Changing the template makes the plan stale: [isFor] turns false and the
/// UI must preview again before it can apply anything.
class RenamePlan {
  const RenamePlan({required this.template, required this.rows});

  factory RenamePlan.fromCore(String template, Object? result) => RenamePlan(
    template: template,
    rows: [
      if (result is List)
        for (final r in result.whereType<Map>()) RenameRow.fromCore(r),
    ],
  );

  final String template;
  final List<RenameRow> rows;

  bool isFor(String currentTemplate) => template == currentTemplate;

  /// Paths to hand to `renameFiles`: checked and error free only.
  List<String> get applicablePaths => [
    for (final r in rows)
      if (r.applicable) r.oldPath,
  ];

  bool get canApply => applicablePaths.isNotEmpty;

  RenamePlan toggle(int index) => RenamePlan(
    template: template,
    rows: [
      for (var i = 0; i < rows.length; i++)
        i == index ? rows[i].withChecked(!rows[i].checked) : rows[i],
    ],
  );
}

class RenameOutcome {
  const RenameOutcome({required this.ok, required this.failed});

  factory RenameOutcome.fromCore(Object? result) {
    var ok = 0;
    var failed = 0;
    if (result is List) {
      for (final r in result.whereType<Map>()) {
        if (r['success'] == true) {
          ok++;
        } else {
          failed++;
        }
      }
    }
    return RenameOutcome(ok: ok, failed: failed);
  }

  final int ok;
  final int failed;
}
