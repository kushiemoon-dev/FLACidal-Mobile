import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/analyzer_page.dart';
import '../pages/content_detail_page.dart';
import '../pages/conversion_page.dart';
import '../pages/csv_import_page.dart';
import '../pages/extensions_page.dart';
import '../pages/history_page.dart';
import '../pages/home_page.dart';
import '../pages/lyrics_page.dart';
import '../pages/search_page.dart';
import '../pages/queue_page.dart';
import '../pages/rename_page.dart';
import '../pages/library_page.dart';
import '../pages/settings_page.dart';
import '../pages/sources_page.dart';
import '../providers/queue_provider.dart';
import '../l10n/app_localizations.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Detail screens that live outside the shell (no bottom nav)
    GoRoute(
      path: '/content/:type/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: ContentDetailPage(
          type: state.pathParameters['type']!,
          id: state.pathParameters['id']!,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/history',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HistoryPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/lyrics',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return CustomTransitionPage(
          key: state.pageKey,
          child: LyricsPage(
            filePath: extra['filePath'] as String?,
            title: extra['title'] as String?,
            artist: extra['artist'] as String?,
            duration: extra['duration'] as int?,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/convert',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final files = state.extra as List<String>? ?? [];
        return CustomTransitionPage(
          key: state.pageKey,
          child: ConversionPage(filePaths: files),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/analyze',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: AnalyzerPage(filePaths: state.extra as List<String>? ?? []),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/rename',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: RenamePage(filePaths: state.extra as List<String>? ?? []),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/sources',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SourcesPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/extensions',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ExtensionsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/csv-import',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CSVImportPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomePage()),
        GoRoute(path: '/search', builder: (_, _) => const SearchPage()),
        GoRoute(path: '/queue', builder: (_, _) => const QueuePage()),
        GoRoute(path: '/library', builder: (_, _) => const LibraryPage()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
      ],
    ),
  ],
);

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = ['/', '/search', '/queue', '/library', '/settings'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize the download-tracks accumulator right away so no events slip through.
    ref.watch(downloadTracksProvider);

    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t));

    final l = AppLocalizations.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        onDestinationSelected: (i) => context.go(_tabs[i]),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home), label: l.navHome),
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: l.navSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.download),
            label: l.navQueue,
          ),
          NavigationDestination(
            icon: const Icon(Icons.library_music),
            label: l.navLibrary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l.navSettings,
          ),
        ],
      ),
    );
  }
}
