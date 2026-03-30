import 'package:flutter_riverpod/flutter_riverpod.dart';

final sharedUrlProvider =
    NotifierProvider<SharedUrlNotifier, String?>(SharedUrlNotifier.new);

class SharedUrlNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? url) => state = url;
  void clear() => state = null;
}
