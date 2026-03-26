import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

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

  static const _qualities = ['HI_RES_LOSSLESS', 'LOSSLESS', 'HIGH'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Download ──────────────────────────
          _SectionHeader('Download'),
          ListTile(
            leading: const Icon(Icons.high_quality),
            title: const Text('Quality'),
            subtitle: const Text('LOSSLESS'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showQualityPicker(context),
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Download folder'),
            subtitle: const Text('~/Music/FLACidal'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.create_new_folder),
            title: const Text('Organize by folders'),
            subtitle: const Text('Create Artist/Album subfolders'),
            value: false,
            onChanged: (_) {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.image),
            title: const Text('Embed cover art'),
            value: true,
            onChanged: (_) {},
          ),

          // ── Appearance ────────────────────────
          _SectionHeader('Appearance'),
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
            leading: const Icon(Icons.palette),
            title: const Text('Accent color'),
            trailing: CircleAvatar(
              backgroundColor: accentColor,
              radius: 14,
            ),
            onTap: () => _showColorPicker(context, ref),
          ),

          // ── About ─────────────────────────────
          _SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('FLACidal Mobile'),
            subtitle: Text('v0.1.0 — Flutter + Go FFI'),
          ),
        ],
      ),
    );
  }

  void _showQualityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _qualities
            .map((q) => ListTile(
                  title: Text(q),
                  onTap: () => Navigator.pop(ctx),
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
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
