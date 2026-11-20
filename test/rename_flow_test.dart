import 'package:flacidal_mobile/pages/library/rename_plan.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_core.dart';

final _preview = [
  {
    'oldPath': '/m/a.flac',
    'oldName': 'a.flac',
    'newName': 'X - A.flac',
    'newPath': '/m/X - A.flac',
    'hasError': false,
  },
  {
    'oldPath': '/m/b.flac',
    'oldName': 'b.flac',
    'newName': '',
    'newPath': '',
    'hasError': true,
    'error': 'missing tag',
  },
];

void main() {
  test('error rows are never applicable, even when forced', () {
    final plan = RenamePlan.fromCore('{title}', _preview);
    expect(plan.rows[1].checked, isFalse);
    final forced = plan.rows[1].withChecked(true);
    expect(forced.checked, isFalse);
    expect(plan.applicablePaths, ['/m/a.flac']);
  });

  test('unchecking a row removes it from the files sent to Core', () {
    final plan = RenamePlan.fromCore('{title}', _preview).toggle(0);
    expect(plan.applicablePaths, isEmpty);
    expect(plan.canApply, isFalse);
    expect(plan.toggle(0).applicablePaths, ['/m/a.flac']);
  });

  test('toggle does not mutate the previous plan', () {
    final plan = RenamePlan.fromCore('{title}', _preview);
    plan.toggle(0);
    expect(plan.rows[0].checked, isTrue);
  });

  test('a plan is only valid for the template it was computed with', () {
    final plan = RenamePlan.fromCore('{title}', _preview);
    expect(plan.isFor('{title}'), isTrue);
    expect(plan.isFor('{artist} - {title}'), isFalse);
  });

  test('junk or missing result gives an empty plan that cannot apply', () {
    expect(RenamePlan.fromCore('t', null).canApply, isFalse);
    expect(RenamePlan.fromCore('t', 'oops').rows, isEmpty);
  });

  test('outcome counts successes and failures', () {
    final o = RenameOutcome.fromCore([
      {'success': true},
      {'success': false, 'error': 'x'},
      {'success': true},
    ]);
    expect((o.ok, o.failed), (2, 1));
  });

  test(
    'end to end through the fake Core: only checked files are sent',
    () async {
      final t = FakeTransport(
        responses: {'previewRename': _preview, 'renameFiles': []},
      );
      final core = await initializedCore(t);
      final plan = RenamePlan.fromCore(
        '{title}',
        core.callResult('previewRename', {
          'files': ['/m/a.flac', '/m/b.flac'],
          'template': '{title}',
        }),
      );
      core.callResult('renameFiles', {
        'files': plan.applicablePaths,
        'template': plan.template,
      });
      expect(t.calls.last.params, {
        'files': ['/m/a.flac'],
        'template': '{title}',
      });
    },
  );
}
