import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _load(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  final en = _load('en');
  final fr = _load('fr');
  final de = _load('de');

  test('EN, FR and DE define exactly the same keys', () {
    expect(_keys(fr), _keys(en));
    expect(_keys(de), _keys(en));
  });

  test('no empty translation', () {
    for (final arb in [en, fr, de]) {
      for (final key in _keys(arb).where((k) => k != '@@locale')) {
        expect((arb[key] as String).trim(), isNotEmpty, reason: key);
      }
    }
  });

  test('FR and DE are not copies of the key name', () {
    for (final arb in [fr, de]) {
      for (final key in _keys(arb).where((k) => k != '@@locale')) {
        expect(arb[key], isNot(key), reason: key);
      }
    }
  });

  test('placeholders match between languages', () {
    final ph = RegExp(r'\{(\w+)[,}]');
    for (final key in _keys(en).where((k) => k != '@@locale')) {
      final expected = ph
          .allMatches(en[key] as String)
          .map((m) => m[1])
          .toSet();
      for (final arb in [fr, de]) {
        final got = ph.allMatches(arb[key] as String).map((m) => m[1]).toSet();
        expect(got, expected, reason: key);
      }
    }
  });

  test('no em dash or spaced en dash in any language', () {
    for (final arb in [en, fr, de]) {
      for (final v in arb.values.whereType<String>()) {
        expect(v.contains('—'), isFalse, reason: v);
        expect(v.contains(' – '), isFalse, reason: v);
      }
    }
  });
}
