import 'package:flutter/material.dart';

/// Controller for a batch download progress dialog.
///
/// Returned by [ProgressDialog.show]. Call [update] to advance progress,
/// and [close] to dismiss.
class ProgressDialogController {
  final _ProgressDialogState _state;
  final BuildContext _dialogContext;

  ProgressDialogController._(this._state, this._dialogContext);

  /// Update the dialog with current completion count and track name.
  void update(int completed, String currentTrack) {
    if (_state.mounted) {
      _state._update(completed, currentTrack);
    }
  }

  /// Dismiss the dialog.
  void close() {
    if (Navigator.of(_dialogContext).canPop()) {
      Navigator.of(_dialogContext).pop();
    }
  }
}

/// Modal batch download progress dialog.
///
/// Use the static [show] method to display and receive a controller,
/// or embed [ProgressDialogContent] directly as a standalone widget.
class ProgressDialog {
  ProgressDialog._();

  /// Show a modal progress dialog and return a controller.
  ///
  /// [total] is the total number of items to process.
  /// [onCancel] is called when the user taps Cancel.
  static Future<ProgressDialogController> show(
    BuildContext context, {
    required int total,
    VoidCallback? onCancel,
  }) async {
    late ProgressDialogController controller;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _ProgressDialogWidget(
          total: total,
          onCancel: () {
            onCancel?.call();
            controller.close();
          },
          onStateReady: (state) {
            controller = ProgressDialogController._(state, dialogContext);
          },
        );
      },
    );

    return controller;
  }
}

class _ProgressDialogWidget extends StatefulWidget {
  final int total;
  final VoidCallback onCancel;
  final void Function(_ProgressDialogState state) onStateReady;

  const _ProgressDialogWidget({
    required this.total,
    required this.onCancel,
    required this.onStateReady,
  });

  @override
  _ProgressDialogState createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<_ProgressDialogWidget> {
  int _completed = 0;
  String _currentTrack = '';

  @override
  void initState() {
    super.initState();
    widget.onStateReady(this);
  }

  void _update(int completed, String currentTrack) {
    setState(() {
      _completed = completed;
      _currentTrack = currentTrack;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.total > 0 ? _completed / widget.total : 0.0;

    return AlertDialog(
      title: const Text('Downloading'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                borderRadius: BorderRadius.circular(4),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Downloading $_completed of ${widget.total}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (_currentTrack.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _currentTrack,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Standalone progress widget for embedding in custom layouts.
///
/// Unlike [ProgressDialog.show], this does not manage its own dialog.
class ProgressDialogContent extends StatelessWidget {
  final int completed;
  final int total;
  final String currentTrack;
  final VoidCallback? onCancel;

  const ProgressDialogContent({
    super.key,
    required this.completed,
    required this.total,
    this.currentTrack = '',
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              borderRadius: BorderRadius.circular(4),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Downloading $completed of $total',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (currentTrack.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            currentTrack,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (onCancel != null) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
          ),
        ],
      ],
    );
  }
}
