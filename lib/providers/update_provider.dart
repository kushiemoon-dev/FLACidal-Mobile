import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/update_service.dart';
import 'app_info_provider.dart';

final updateStatusProvider =
    AsyncNotifierProvider<UpdateStatusNotifier, UpdateStatus>(
      UpdateStatusNotifier.new,
    );

class UpdateStatusNotifier extends AsyncNotifier<UpdateStatus> {
  @override
  Future<UpdateStatus> build() async {
    final version = await ref.watch(appVersionProvider.future);
    return fetchUpdateStatus(version);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
