import "dart:ui";

/// Locale - (English name, Endonym)
///
/// * You have to include a country if the [Locale.countryCode] is not null.
/// * Your file name must match `languageCode_scriptCode_countryCode` format. But both `scriptCode` and `countryCode` is optional.
final Map<Locale, (String, String)> supportedLanguages = {
  const Locale("mn", "MN"): ("Mongolian (Mongolia)", "Монгол (Монгол)"),
  const Locale("en", "US"): ("English (US)", "English (US)"),
  const Locale("en", "IN"): ("English (India)", "English (India)"),
  const Locale("it", "IT"): ("Italian (Italy)", "Italiano (Italia)"),
  const Locale("tr", "TR"): ("Turkish (Turkey)", "Türkçe (Türkiye)"),
  const Locale("fr", "FR"): ("French (France)", "Français (France)"),
  const Locale("de", "DE"): ("German (Germany)", "Deutsch (Deutschland)"),
  const Locale("ar"): ("Arabic", "العربية"),
};
