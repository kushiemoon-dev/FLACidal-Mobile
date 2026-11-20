import 'package:flacidal_mobile/providers/shared_url_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts empty, set stores and clear resets', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(sharedUrlProvider), isNull);
    c.read(sharedUrlProvider.notifier).set('https://tidal.com/track/1');
    expect(c.read(sharedUrlProvider), 'https://tidal.com/track/1');
    c.read(sharedUrlProvider.notifier).clear();
    expect(c.read(sharedUrlProvider), isNull);
  });
}
