import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/download_service.dart';
import 'theme/flacidal_theme.dart';
import 'core/flac_core.dart';
import 'providers/shared_url_provider.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  if (Platform.isAndroid) {
    final status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  final appDir = await getApplicationDocumentsDirectory();
  try {
    await FlacCore.instance.init(appDir.path);
  } catch (e) {
    debugPrint('FlacCore failed to initialize: $e');
  }

  try {
    FlacCore.instance.callSync('restoreQueue');
  } catch (e) {
    debugPrint('Failed to restore the queue: $e');
  }

  await DownloadService.init();

  const musicPath = '/storage/emulated/0/Music/FLACidal';
  if (Platform.isAndroid) {
    final musicDir = Directory(musicPath);
    if (!musicDir.existsSync()) {
      try {
        musicDir.createSync(recursive: true);
      } catch (e) {
        debugPrint('Unable to create the Music directory: $e');
      }
    }
    FlacCore.instance.downloadDir = musicPath;
  } else {
    FlacCore.instance.downloadDir = appDir.path;
  }

  final container = ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );

  if (Platform.isAndroid || Platform.isIOS) {
    // Cover the case where a share arrives while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((
      List<SharedMediaFile> files,
    ) {
      if (files.isNotEmpty) {
        final text = files.first.path;
        if (text.isNotEmpty) {
          container.read(sharedUrlProvider.notifier).set(text);
          appRouter.go('/');
        }
      }
    });

    // Cover shares that come in while the app is already running
    ReceiveSharingIntent.instance.getMediaStream().listen((
      List<SharedMediaFile> files,
    ) {
      if (files.isNotEmpty) {
        final text = files.first.path;
        if (text.isNotEmpty) {
          container.read(sharedUrlProvider.notifier).set(text);
          appRouter.go('/');
        }
      }
    });
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const FlacApp()),
  );
}

class FlacApp extends ConsumerStatefulWidget {
  const FlacApp({super.key});

  @override
  ConsumerState<FlacApp> createState() => _FlacAppState();
}

class _FlacAppState extends ConsumerState<FlacApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      try {
        FlacCore.instance.callSync('persistQueue');
      } catch (e) {
        debugPrint('Failed to persist the queue: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);

    return MaterialApp.router(
      title: 'FLACidal',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: FlacTheme.light(accentColor: accentColor),
      darkTheme: FlacTheme.dark(accentColor: accentColor),
      routerConfig: appRouter,
    );
  }
}
