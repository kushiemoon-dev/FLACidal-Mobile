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

  // Initialize SharedPreferences for theme persistence
  final prefs = await SharedPreferences.getInstance();

  // Request storage permission for public Music folder
  if (Platform.isAndroid) {
    final status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  // Initialize Go backend with app's documents directory
  final appDir = await getApplicationDocumentsDirectory();
  try {
    await FlacCore.instance.init(appDir.path);
  } catch (e) {
    debugPrint('FlacCore init failed: $e');
  }

  // Restore any previously persisted queue (failed jobs from last session)
  try {
    FlacCore.instance.callSync('restoreQueue');
  } catch (e) {
    debugPrint('Queue restore failed: $e');
  }

  // Initialize foreground service for background downloads
  await DownloadService.init();

  // Set download dir to public Music folder
  const musicPath = '/storage/emulated/0/Music/FLACidal';
  if (Platform.isAndroid) {
    final musicDir = Directory(musicPath);
    if (!musicDir.existsSync()) {
      try {
        musicDir.createSync(recursive: true);
      } catch (e) {
        debugPrint('Could not create Music dir: $e');
      }
    }
    FlacCore.instance.downloadDir = musicPath;
  } else {
    FlacCore.instance.downloadDir = appDir.path;
  }

  final container = ProviderContainer(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
    ],
  );

  // Listen for shared URLs from other apps
  if (Platform.isAndroid || Platform.isIOS) {
    // Handle initial share (app was closed)
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> files) {
      if (files.isNotEmpty) {
        final text = files.first.path;
        if (text.isNotEmpty) {
          container.read(sharedUrlProvider.notifier).set(text);
          appRouter.go('/');
        }
      }
    });

    // Handle shares while app is running
    ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> files) {
        if (files.isNotEmpty) {
          final text = files.first.path;
          if (text.isNotEmpty) {
            container.read(sharedUrlProvider.notifier).set(text);
            appRouter.go('/');
          }
        }
      },
    );
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FlacApp(),
    ),
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
        debugPrint('Queue persist failed: $e');
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
