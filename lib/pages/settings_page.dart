import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/core_errors.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_info_provider.dart';
import '../providers/config_provider.dart';
import '../providers/core_provider.dart';
import '../providers/download_options_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/section_header.dart';

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
    '',
    '{artist}/{album}',
    '{playlist}',
    '{artist}/{album|Singles}',
  ];

  static String _folderLabel(AppLocalizations l, String template) =>
      switch (template) {
        '' => l.folderFlat,
        '{artist}/{album}' => l.folderByArtistAlbum,
        '{playlist}' => l.folderByPlaylist,
        '{artist}/{album|Singles}' => l.folderArtistSingles,
        _ => template,
      };

  static const _qualities = ['HI_RES', 'LOSSLESS', 'HIGH'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);
    final downloadDir = ref.watch(downloadDirProvider);
    final dlOptions = ref.watch(downloadOptionsProvider);
    final config = ref.watch(configProvider).value ?? {};
    final l = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          SectionHeader(title: l.sectionDownload),
          ListTile(
            leading: const Icon(Icons.high_quality),
            title: Text(l.settingsQuality),
            subtitle: Text(dlOptions['Quality'] as String? ?? 'LOSSLESS'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showQualityPicker(context, ref, dlOptions),
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: Text(l.settingsDownloadFolder),
            subtitle: Text(downloadDir),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickDownloadFolder(context, ref),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.create_new_folder),
            title: Text(l.settingsOrganizeFolders),
            subtitle: Text(l.settingsOrganizeFoldersHint),
            value: dlOptions['OrganizeFolders'] as bool? ?? false,
            onChanged: (v) => ref
                .read(downloadOptionsProvider.notifier)
                .update('OrganizeFolders', v),
          ),
          ListTile(
            leading: const Icon(Icons.account_tree),
            title: Text(l.settingsFolderStructure),
            subtitle: Text(
              _folderLabel(l, dlOptions['FolderTemplate'] as String? ?? ''),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFolderTemplatePicker(context, ref, dlOptions),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.image),
            title: Text(l.settingsEmbedCover),
            value: dlOptions['EmbedCover'] as bool? ?? true,
            onChanged: (v) => ref
                .read(downloadOptionsProvider.notifier)
                .update('EmbedCover', v),
          ),
          ListTile(
            leading: const Icon(Icons.audio_file),
            title: Text(l.settingsDownloadFormat),
            subtitle: Text(dlOptions['DownloadFormat'] as String? ?? 'FLAC'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFormatPicker(context, ref, dlOptions),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.person),
            title: Text(l.settingsFirstArtistOnly),
            subtitle: Text(l.settingsFirstArtistOnlyHint),
            value: dlOptions['FirstArtistOnly'] as bool? ?? false,
            onChanged: (v) => ref
                .read(downloadOptionsProvider.notifier)
                .update('FirstArtistOnly', v),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(l.settingsArtistSeparator),
            subtitle: Text(
              '"${dlOptions['ArtistSeparator'] as String? ?? '; '}"',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSeparatorDialog(context, ref, dlOptions),
          ),

          SectionHeader(title: l.sectionSources),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: Text(l.settingsMusicSources),
            subtitle: Text(l.settingsMusicSourcesHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/sources'),
          ),
          ListTile(
            leading: const Icon(Icons.swap_vert),
            title: Text(l.settingsPreferredSource),
            subtitle: Text(dlOptions['PreferredSource'] as String? ?? 'Tidal'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPreferredSourcePicker(context, ref, dlOptions),
          ),

          SectionHeader(title: l.sectionEndpoints),
          ListTile(
            leading: const Icon(Icons.dns),
            title: Text(l.endpointsTitle('Tidal')),
            subtitle: Text(
              _endpointsSubtitle(l, config['tidalPriorityEndpoints']),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEndpointsManager(
              context,
              ref,
              'tidalPriorityEndpoints',
              l.endpointsTitle('Tidal'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dns),
            title: Text(l.endpointsTitle('Qobuz')),
            subtitle: Text(
              _endpointsSubtitle(l, config['qobuzPriorityEndpoints']),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEndpointsManager(
              context,
              ref,
              'qobuzPriorityEndpoints',
              l.endpointsTitle('Qobuz'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dns),
            title: Text(l.endpointsTitle('Amazon')),
            subtitle: Text(
              _endpointsSubtitle(l, config['amazonPriorityEndpoints']),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEndpointsManager(
              context,
              ref,
              'amazonPriorityEndpoints',
              l.endpointsTitle('Amazon'),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.extension),
            title: Text(l.settingsExtensions),
            subtitle: Text(l.settingsExtensionsHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/extensions'),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: Text(l.settingsExtensionRepos),
            subtitle: Text(l.settingsExtensionReposHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRepoManager(context, ref),
          ),

          SectionHeader(title: l.sectionHistory),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(l.settingsDownloadHistory),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/history'),
          ),

          SectionHeader(title: l.sectionAppearance),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(l.settingsTheme),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.settings_brightness),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (v) =>
                  ref.read(themeModeProvider.notifier).set(v.first),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.font_download),
            title: Text(l.settingsFont),
            subtitle: Text(
              ref.watch(fontFamilyProvider) ?? l.fontSystemDefault,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFontPicker(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l.settingsAccent),
            trailing: CircleAvatar(backgroundColor: accentColor, radius: 14),
            onTap: () => _showColorPicker(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.settingsLanguage),
            subtitle: Text(_languageLabel(l, locale?.languageCode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context, ref, locale),
          ),

          SectionHeader(title: l.sectionAbout),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(l.settingsAppName),
            subtitle: Text(
              '${ref.watch(appVersionProvider).value ?? '…'} · Flutter + Go FFI',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(l.settingsExport),
            onTap: () => _exportConfig(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.download_for_offline),
            title: Text(l.settingsImport),
            onTap: () => _importConfig(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDownloadFolder(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: AppLocalizations.of(context).settingsPickFolder,
    );
    if (result != null) {
      ref.read(downloadDirProvider.notifier).set(result);
    }
  }

  Future<void> _exportConfig(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: l.settingsChooseExportLocation,
    );
    if (dir == null) return;
    final path = '$dir/flacidal-config-export.json';
    try {
      ref.read(flacCoreProvider).callSync('exportConfig', {'path': path});
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.settingsConfigExported(path))));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.settingsExportFailed(describeCoreError(l, e))),
          ),
        );
      }
    }
  }

  Future<void> _importConfig(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return;
    if (!context.mounted) return;
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsImportTitle),
        content: Text(l.settingsImportWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.settingsImportAnyway),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      ref.read(flacCoreProvider).callSync('importConfig', {'path': path});
      ref.invalidate(configProvider);
      ref.invalidate(downloadOptionsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.settingsConfigImported)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.settingsImportFailed(describeCoreError(l, e))),
          ),
        );
      }
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
              title: Text(
                f ?? AppLocalizations.of(context).fontSystemDefault,
                style: f != null ? TextStyle(fontFamily: f) : null,
              ),
              leading: selected
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
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

  void _showQualityPicker(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> opts,
  ) {
    final current = opts['Quality'] as String? ?? 'LOSSLESS';
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _qualities
            .map(
              (q) => ListTile(
                title: Text(q),
                leading: q == current
                    ? const Icon(Icons.check)
                    : const SizedBox(width: 24),
                onTap: () {
                  ref
                      .read(downloadOptionsProvider.notifier)
                      .update('Quality', q);
                  Navigator.pop(ctx);
                },
              ),
            )
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

  static const _formats = ['FLAC'];

  void _showFormatPicker(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> opts,
  ) {
    final current = opts['DownloadFormat'] as String? ?? 'FLAC';
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _formats
            .map(
              (f) => ListTile(
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
              ),
            )
            .toList(),
      ),
    );
  }

  static const _sources = ['Tidal', 'Qobuz'];

  void _showPreferredSourcePicker(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> opts,
  ) {
    final current = opts['PreferredSource'] as String? ?? 'Tidal';
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _sources
            .map(
              (s) => ListTile(
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
              ),
            )
            .toList(),
      ),
    );
  }

  void _showRepoManager(BuildContext context, WidgetRef ref) {
    final dlOptions = ref.read(downloadOptionsProvider);
    final repos = List<String>.from(
      dlOptions['ExtensionRepos'] as List<dynamic>? ??
          [
            'https://raw.githubusercontent.com/kushiemoon-dev/flacidal-extensions/main/index.json',
          ],
    );

    showDialog(
      context: context,
      builder: (ctx) => _RepoManagerDialog(
        title: AppLocalizations.of(context).settingsExtensionRepos,
        initialRepos: repos,
        onSave: (updated) {
          ref
              .read(downloadOptionsProvider.notifier)
              .update('ExtensionRepos', updated);
        },
      ),
    );
  }

  static String _endpointsSubtitle(AppLocalizations l, dynamic list) {
    final count = list is List ? list.length : 0;
    return count == 0 ? l.endpointsPublicOnly : l.endpointsCount(count);
  }

  void _showEndpointsManager(
    BuildContext context,
    WidgetRef ref,
    String configKey,
    String title,
  ) {
    final config = ref.read(configProvider).value ?? {};
    final endpoints = List<String>.from(
      config[configKey] as List<dynamic>? ?? [],
    );

    showDialog(
      context: context,
      builder: (ctx) => _RepoManagerDialog(
        title: title,
        initialRepos: endpoints,
        onSave: (updated) {
          try {
            final current = ref.read(configProvider).value ?? {};
            final newConfig = Map<String, dynamic>.from(current)
              ..[configKey] = updated;
            ref.read(configProvider.notifier).save(newConfig);
          } catch (e) {
            if (!context.mounted) return;
            final l = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l.endpointsSaveFailed(describeCoreError(l, e))),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
      ),
    );
  }

  static String _languageLabel(AppLocalizations l, String? code) =>
      switch (code) {
        'en' => 'English',
        'fr' => 'Français',
        'de' => 'Deutsch',
        _ => l.languageAuto,
      };

  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    Locale? current,
  ) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['', ...supportedLanguageCodes].map((code) {
          return ListTile(
            title: Text(_languageLabel(l, code.isEmpty ? null : code)),
            leading: (current?.languageCode ?? '') == code
                ? const Icon(Icons.check)
                : const SizedBox(width: 24),
            onTap: () {
              ref.read(localeProvider.notifier).set(code);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showSeparatorDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> opts,
  ) async {
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) =>
          _SeparatorDialog(initial: opts['ArtistSeparator'] as String? ?? '; '),
    );
    if (value == null) return;
    ref.read(downloadOptionsProvider.notifier).update('ArtistSeparator', value);
  }

  void _showFolderTemplatePicker(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> opts,
  ) {
    final current = opts['FolderTemplate'] as String? ?? '';
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _folderTemplates.map((value) {
          return ListTile(
            title: Text(_folderLabel(AppLocalizations.of(context), value)),
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
        }).toList(),
      ),
    );
  }
}

class _RepoManagerDialog extends StatefulWidget {
  final String title;
  final List<String> initialRepos;
  final ValueChanged<List<String>> onSave;

  const _RepoManagerDialog({
    required this.title,
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
      title: Text(widget.title),
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
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).repoManagerHint,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addRepo(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addRepo),
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
          child: Text(AppLocalizations.of(context).cancel),
        ),
        FilledButton(
          onPressed: () {
            widget.onSave(_repos);
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context).save),
        ),
      ],
    );
  }
}

class _SeparatorDialog extends StatefulWidget {
  const _SeparatorDialog({required this.initial});

  final String initial;

  @override
  State<_SeparatorDialog> createState() => _SeparatorDialogState();
}

class _SeparatorDialogState extends State<_SeparatorDialog> {
  late final _controller = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text;
    if (value.isEmpty || value.length > 8) {
      setState(
        () => _error = AppLocalizations.of(context).artistSeparatorInvalid,
      );
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.settingsArtistSeparator),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          helperText: l.settingsArtistSeparatorHint,
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l.save)),
      ],
    );
  }
}
