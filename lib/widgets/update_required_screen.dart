import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/update_service.dart';
import '../l10n/app_localizations.dart';

/// Full-screen, non-dismissible: no close button, no back-navigation escape
/// hatch beyond Android's own system back button (unlike the desktop
/// counterpart, no in-app Quit control is needed here).
class UpdateRequiredScreen extends StatefulWidget {
  final UpdateStatus status;

  const UpdateRequiredScreen({super.key, required this.status});

  @override
  State<UpdateRequiredScreen> createState() => _UpdateRequiredScreenState();
}

class _UpdateRequiredScreenState extends State<UpdateRequiredScreen> {
  bool _downloading = false;
  int _received = 0;
  int _total = 0;
  String? _error;

  Future<void> _handleUpdate() async {
    setState(() {
      _downloading = true;
      _error = null;
      _received = 0;
      _total = 0;
    });

    try {
      final l = AppLocalizations.of(context);
      await downloadAndInstallUpdate(
        widget.status,
        startText: l.notifUpdateDownloading,
        progressText: l.notifUpdateProgress,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _received = received;
            _total = total;
          });
        },
      );
      if (mounted) setState(() => _downloading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _openRelease() async {
    final url = Uri.tryParse(widget.status.releaseUrl);
    if (url == null) return;
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = _total > 0 ? _received / _total : 0.0;
    final migration = widget.status.requiresKeyMigration;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.updateRequiredTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  migration
                      ? l.updateMigrationBody(widget.status.latestVersion)
                      : l.updateRequiredBody(
                          widget.status.currentVersion,
                          widget.status.versionsBehind,
                          widget.status.latestVersion,
                        ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (_downloading) ...[
                  const SizedBox(height: 24),
                  LinearProgressIndicator(
                    value: _total > 0 ? progress : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _total > 0
                        ? '${(progress * 100).toStringAsFixed(0)}%'
                        : l.updateDownloadingLong,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                if (migration)
                  FilledButton(
                    onPressed: _openRelease,
                    child: Text(l.updateOpenRelease),
                  )
                else
                  FilledButton(
                    onPressed: _downloading ? null : _handleUpdate,
                    child: Text(
                      _downloading ? l.updateDownloading : l.updateNow,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
