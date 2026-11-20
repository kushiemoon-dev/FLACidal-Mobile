import 'package:flacidal_mobile/providers/core_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_core.dart';

/// Builds a [ProviderContainer] whose Core is backed by [transport].
Future<ProviderContainer> containerWith(FakeTransport transport) async {
  final core = await initializedCore(transport);
  final container = ProviderContainer(
    overrides: [flacCoreProvider.overrideWithValue(core)],
  );
  addTearDown(container.dispose);
  return container;
}
