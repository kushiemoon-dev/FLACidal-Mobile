import 'package:flutter/material.dart';

import '../core/update_service.dart';

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
      await downloadAndInstallUpdate(
        widget.status,
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

  @override
  Widget build(BuildContext context) {
    final progress = _total > 0 ? _received / _total : 0.0;

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
                  'Update Required',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'This version (${widget.status.currentVersion}) is '
                  '${widget.status.versionsBehind} versions behind the '
                  'latest release (${widget.status.latestVersion}). Update '
                  'now to keep using the app.',
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
                        : 'Downloading update...',
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
                FilledButton(
                  onPressed: _downloading ? null : _handleUpdate,
                  child: Text(_downloading ? 'Downloading...' : 'Update Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
