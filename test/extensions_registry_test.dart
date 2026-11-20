import 'package:flacidal_mobile/pages/extensions/registry_merge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> e(String id, [String v = '1']) => {
    'id': id,
    'latestVersion': v,
  };

  test('default registry wins on duplicate ids', () {
    final merged = mergeRegistries([
      [e('a', 'default')],
      [e('a', 'custom'), e('b')],
    ]);
    expect(merged.map((m) => m['id']), ['a', 'b']);
    expect(merged.first['latestVersion'], 'default');
  });

  test('keeps source order and drops entries without id', () {
    final merged = mergeRegistries([
      [e('a')],
      [
        {'name': 'no id'},
      ],
      [e('c'), e('b')],
    ]);
    expect(merged.map((m) => m['id']), ['a', 'c', 'b']);
  });

  test('empty input gives empty output', () {
    expect(mergeRegistries([]), isEmpty);
  });

  test('registryEntries copies maps and ignores junk', () {
    final raw = [
      {'id': 'a'},
      'junk',
      3,
    ];
    final out = registryEntries(raw);
    expect(out, [
      {'id': 'a'},
    ]);
    out.first['x'] = 1;
    expect((raw.first as Map).containsKey('x'), isFalse);
    expect(registryEntries(null), isEmpty);
  });
}
