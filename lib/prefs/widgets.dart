import "package:local_settings/local_settings.dart";
import "package:shared_preferences/shared_preferences.dart";

class WidgetsLocalPreferences {
  final SharedPreferencesWithCache _prefs;

  static WidgetsLocalPreferences? _instance;

  /// Button order for enter transaction widget.
  late final PrimitiveSettingsEntry<String> buttonOrder;

  factory WidgetsLocalPreferences() {
    if (_instance == null) {
      throw Exception("Failed to create WidgetsLocalPreferences");
    }

    return _instance!;
  }

  WidgetsLocalPreferences._internal(this._prefs) {
    SettingsEntry.defaultPrefix = "flow.widgets.";

    buttonOrder = PrimitiveSettingsEntry<String>(
      key: "buttonOrder",
      preferences: _prefs,
    );
  }

  static WidgetsLocalPreferences initialize(
    SharedPreferencesWithCache instance,
  ) => _instance ??= WidgetsLocalPreferences._internal(instance);
}
