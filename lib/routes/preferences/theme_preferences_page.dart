import "package:flow/l10n/extensions.dart";
import "package:flow/main.dart";
import "package:flow/prefs.dart";
import "package:flow/routes/preferences/theme_preferences/theme_entry.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flutter/material.dart" hide Flow;

class ThemePreferencesPage extends StatefulWidget {
  const ThemePreferencesPage({super.key});

  @override
  State<ThemePreferencesPage> createState() => _ThemePreferencesPageState();
}

class _ThemePreferencesPageState extends State<ThemePreferencesPage> {
  int activeIndex = 0;

  bool busy = false;

  bool get dynamicThemeSupported => Flow.of(context).dynamicThemeSupported;

  @override
  Widget build(BuildContext context) {
    final String? preferencesTheme = LocalPreferences().themeName.get();
    final String currentTheme = validateThemeName(preferencesTheme)
        ? preferencesTheme!
        : lightThemes.keys.first;
    final bool usingDynamicTheme = LocalPreferences().useDynamicTheme.get();

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.theme.choose".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (dynamicThemeSupported) ...[
                CheckboxListTile.adaptive(
                  value: usingDynamicTheme,
                  onChanged: handleDynamicThemeChange,
                ),
                const SizedBox(height: 16.0),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 8.0,
                  children: [
                    FilterChip(
                        label: Text("preferences.theme.light".t(context)),
                        onSelected: (_) => setState(() => activeIndex = 0),
                        selected: activeIndex == 0),
                    FilterChip(
                        label: Text("preferences.theme.dark".t(context)),
                        onSelected: (_) => setState(() => activeIndex = 1),
                        selected: activeIndex == 1),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: (activeIndex == 0 ? lightThemes : darkThemes)
                    .entries
                    .map((entry) => ThemeEntry(
                          entry: entry,
                          currentTheme: currentTheme,
                          handleChange: handleChange,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleChange(String? name) async {
    if (name == null) return;
    if (busy) return;

    try {
      await LocalPreferences().themeName.set(name);
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void handleDynamicThemeChange(bool? checked) async {
    if (checked == null) return;
    if (busy) return;

    try {
      await LocalPreferences().useDynamicTheme.set(checked);
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }
}
