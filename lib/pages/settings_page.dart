import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/flac_core.dart';
import '../providers/core_provider.dart';
import '../providers/download_options_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/section_header.dart';

/// Settings page — download quality, folder, theme, accent color.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _accentColors = [
    ('Pink', Colors.pinkAccent),
    ('Purple', Colors.purpleAccent),
    ('Deep Purple', Colors.deepPurpleAccent),
    ('Indigo', Colors.indigoAccent),
    ('Blue', Colors.blueAccent),
    ('Cyan', Colors.cyanAccent),
    ('Teal', Colors.tealAccent),
    ('Green', Colors.greenAccent),
    ('Amber', Colors.amberAccent),
    ('Orange', Colors.orangeAccent),
    ('Red', Colors.redAccent),
    ('White', Colors.white),
  ];

  static const _folderTemplates = [
    ('Flat', ''),
    ('By Artist/Album', '{artist}/{album}'),
    ('By Playlist', '{playlist}'),
    ('Artist + Singles', '{artist}/{album|Singles}'),
  ];

  static const _qualities = ['HI_RES_MAX', 'HI_RES_LOSSLESS', 'LOSSLESS', 'HIGH'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);
    final downloadDir = ref.watch(downloadDirProvider);
    final dlOptions = ref.watch(downloadOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Download ──────────────────────────
          SectionHeader(title:'Download'),
          ListTile(
            leading: const Icon(Icons.high_quality),
            title: const Text('Quality'),
            subtitle: Text(dlOptions['Quality'] as String? ?? 'LOSSLESS'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showQualityPicker(context, ref, dlOptions),
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Download folder'),
            subtitle: Text(downloadDir),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickDownloadFolder(context, ref),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.create_new_folder),
            title: const Text('Organize by folders'),
            subtitle: const Text('Create Artist/Album subfolders'),
            value: dlOptions['OrganizeFolders'] as bool? ?? false,
            onChanged: (v) =>
                ref.read(downloadOptionsProvider.notifier).update('OrganizeFolders', v),
          ),
          ListTile(
            leading: const Icon(Icons.account_tree),
            title: const Text('Folder structure'),
            subtitle: Text(_folderTemplateLabel(
                dlOptions['FolderTemplate'] as String? ?? '')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFolderTemplatePicker(context, ref, dlOptions),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.image),
            title: const Text('Embed cover art'),
            value: dlOptions['EmbedCover'] as bool? ?? true,
            onChanged: (v) =>
                ref.read(downloadOptionsProvider.notifier).update('EmbedCover', v),
          ),
          ListTile(
            leading: const Icon(Icons.audio_file),
            title: const Text('Download format'),
            subtitle: Text(dlOptions['DownloadFormat'] as String? ?? 'FLAC'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFormatPicker(context, ref, dlOptions),
          ),

          // ── Sources ─────────────────────────────
          SectionHeader(title:'Sources'),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('Music sources'),
            subtitle: const Text('Tidal, Qobuz configuration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/sources'),
          ),
          ListTile(
            leading: const Icon(Icons.swap_vert),
            title: const Text('Preferred source'),
            subtitle: Text(dlOptions['PreferredSource'] as String? ?? 'Tidal'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPreferredSourcePicker(context, ref, dlOptions),
          ),

          ListTile(
            leading: const Icon(Icons.extension),
            title: const Text('Extensions'),
            subtitle: const Text('Browse and install plugins'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/extensions'),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text('Extension repositories'),
            subtitle: const Text('Add custom extension sources'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRepoManager(context, ref),
          ),

          // ── History ───────────────────────────
          SectionHeader(title:'History'),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Download history'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/history'),
          ),

          // ── Appearance ────────────────────────
          SectionHeader(title:'Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_brightness)),
              ],
              selected: {themeMode},
              onSelectionChanged: (v) =>
                  ref.read(themeModeProvider.notifier).set(v.first),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.font_download),
            title: const Text('Font'),
            subtitle: Text(ref.watch(fontFamilyProvider) ?? 'System default'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFontPicker(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Accent color'),
            trailing: CircleAvatar(
              backgroundColor: accentColor,
              radius: 14,
            ),
            onTap: () => _showColorPicker(context, ref),
          ),

          // ── About ─────────────────────────────
          SectionHeader(title:'About'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('FLACidal Mobile'),
            subtitle: Text('v0.2.1 — Flutter + Go FFI'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDownloadFolder(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose download folder',
    );
    if (result != null) {
      ref.read(downloadDirProvider.notifier).set(result);
    }
  }

  static const _fonts = [
    null, // System default
    'Roboto', 'Noto Sans', 'Inter', 'Poppins', 'Montserrat',
    'Open Sans', 'Lato', 'Raleway', 'Ubuntu', 'Nunito',
    'Source Sans Pro', 'PT Sans', 'Merriweather', 'Fira Sans', 'Quicksand',
  ];

  void _showFontPicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(fontFamilyProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (ctx, scrollCtrl) => ListView(
          controller: scrollCtrl,
          children: _fonts.map((f) {
            final selected = f == current;
            return ListTile(
              title: Text(f ?? 'System default',
                  style: f != null ? TextStyle(fontFamily: f) : null),
              leading: selected ? const Icon(Icons.check) : const SizedBox(width: 24),
              onTap: () {
                ref.read(fontFamilyProvider.notifier).set(f);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showQualityPicker(BuildContext context, WidgetRef ref, Map<String, dynamic> opts) {
    final current = opts['Quality'] as String? ?? 'LOSSLESS';
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _qualities
            .map((q) => ListTile(
                  title: Text(q),
                  leading: q == current ? const Icon(Icons.check) : const SizedBox(width: 24),
                  onTap: () {
                    ref.read(downloadOptionsProvider.notifier).update('Quality', q);
                    Navigator.pop(ctx);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _showColorPicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(accentColorProvider);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _accentColors.map((entry) {
            final (name, color) = entry;
            final selected = color.toARGB32() == current.toARGB32();
            return GestureDetector(
              onTap: () {
                ref.read(accentColorProvider.notifier).set(color);
                Navigator.pop(ctx);
              },
              child: CircleAvatar(
                backgroundColor: color,
                radius: 22,
                child: selected
                    ? const Icon(Icons.check, color: Colors.black)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  static const _formats = ['FLAC', 'M4A', 'ALAC'];

  void _showFormatPicker(
      BuildContext context, WidgetRef ref, Map<String, dynamic> opts) {
    final current = opts['DownloadFormat'] as String? ?? 'FLAC';
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _formats
            .map((f) => ListTile(
                  title: Text(f),
                  leading: f == current
                      ? const Icon(Icons.check)
                      : const SizedBox(width: 24),
                  onTap: () {
                    ref
                        .read(downloadOptionsProvider.notifier)
                        .update('DownloadFormat', f);
                    Navigator.pop(ctx);
                  },
                ))
            .toList(),
      ),
    );
  }

  static const _sources = ['Tidal', 'Qobuz'];

  void _showPreferredSourcePicker(
      BuildContext context, WidgetRef ref, Map<String, dynamic> opts) {
    final current = opts['PreferredSource'] as String? ?? 'Tidal';
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _sources
            .map((s) => ListTile(
                  title: Text(s),
                  leading: s == current
                      ? const Icon(Icons.check)
                      : const SizedBox(width: 24),
                  onTap: () {
                    ref
                        .read(downloadOptionsProvider.notifier)
                        .update('PreferredSource', s);
                    final core = ref.read(flacCoreProvider);
                    core.callSync('setPreferredSource', {'source': s});
                    Navigator.pop(ctx);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _showRepoManager(BuildContext context, WidgetRef ref) {
    final dlOptions = ref.read(downloadOptionsProvider);
    final repos = List<String>.from(
      dlOptions['ExtensionRepos'] as List<dynamic>? ??
          [
            'https://raw.githubusercontent.com/kushiemoon-dev/flacidal-extensions/main/index.json'
          ],
    );

    showDialog(
      context: context,
      builder: (ctx) => _RepoManagerDialog(
        initialRepos: repos,
        onSave: (updated) {
          ref
              .read(downloadOptionsProvider.notifier)
              .update('ExtensionRepos', updated);
        },
      ),
    );
  }

  static String _folderTemplateLabel(String template) {
    for (final (label, value) in _folderTemplates) {
      if (value == template) return label;
    }
    return template.isEmpty ? 'Flat' : template;
  }

  void _showFolderTemplatePicker(
      BuildContext context, WidgetRef ref, Map<String, dynamic> opts) {
    final current = opts['FolderTemplate'] as String? ?? '';
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _folderTemplates
            .map((entry) {
              final (label, value) = entry;
              return ListTile(
                title: Text(label),
                subtitle: value.isNotEmpty ? Text(value) : null,
                leading: value == current
                    ? const Icon(Icons.check)
                    : const SizedBox(width: 24),
                onTap: () {
                  ref
                      .read(downloadOptionsProvider.notifier)
                      .update('FolderTemplate', value);
                  Navigator.pop(ctx);
                },
              );
            })
            .toList(),
      ),
    );
  }
}

class _RepoManagerDialog extends StatefulWidget {
  final List<String> initialRepos;
  final ValueChanged<List<String>> onSave;

  const _RepoManagerDialog({
    required this.initialRepos,
    required this.onSave,
  });

  @override
  State<_RepoManagerDialog> createState() => _RepoManagerDialogState();
}

class _RepoManagerDialogState extends State<_RepoManagerDialog> {
  late final List<String> _repos;
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repos = List.from(widget.initialRepos);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _addRepo() {
    final url = _urlController.text.trim();
    if (url.isEmpty || _repos.contains(url)) return;
    setState(() => _repos.add(url));
    _urlController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Extension Repositories'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: 'https://...',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addRepo(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addRepo,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _repos.length,
                itemBuilder: (ctx, i) => ListTile(
                  dense: true,
                  title: Text(
                    _repos[i],
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    onPressed: () => setState(() => _repos.removeAt(i)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSave(_repos);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
