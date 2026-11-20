import 'package:flacidal_mobile/providers/download_options_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/container.dart';
import 'support/fake_core.dart';

void main() {
  test('build reads Core options', () async {
    final container = await containerWith(
      FakeTransport(
        responses: {
          'getDownloadOptions': {'Quality': 'LOSSLESS'},
        },
      ),
    );
    expect(container.read(downloadOptionsProvider), {'Quality': 'LOSSLESS'});
  });

  test('build falls back to defaults when Core fails', () async {
    final container = await containerWith(
      FakeTransport(
        responses: {'getDownloadOptions': const FakeError('X', 'down')},
      ),
    );
    expect(container.read(downloadOptionsProvider)['Quality'], 'HI_RES');
  });

  test(
    'update sends the full map without mutating the previous state',
    () async {
      final transport = FakeTransport(
        responses: {
          'getDownloadOptions': {'Quality': 'HI_RES', 'EmbedCover': true},
          'setDownloadOptions': null,
        },
      );
      final container = await containerWith(transport);
      final before = container.read(downloadOptionsProvider);

      container
          .read(downloadOptionsProvider.notifier)
          .update('Quality', 'LOSSLESS');

      expect(before['Quality'], 'HI_RES');
      final sent = transport.calls
          .lastWhere((c) => c.method == 'setDownloadOptions')
          .params;
      expect(sent, {'Quality': 'LOSSLESS', 'EmbedCover': true});
      expect(container.read(downloadOptionsProvider), sent);
    },
  );
}
