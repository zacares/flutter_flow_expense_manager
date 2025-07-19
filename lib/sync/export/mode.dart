enum ExportMode {
  /// Cannot be recovered from
  ///
  /// Intended for using in more complex software like Google Sheets
  csv(fileExt: "csv"),

  /// Can be fully recovered from
  ///
  /// Intended for full backups. Will be versioned, we plan to support
  /// importing older backups to newer versions.
  json(fileExt: "json"),

  /// Can be fully recovered from
  ///
  /// Includes [json] inside it, plus other files like images that cannot be
  /// fit into a JSON file.
  zip(fileExt: "zip"),

  /// Cannot be recovered from
  ///
  /// A non-official statement (kinda like bank statements)
  pdf(fileExt: "pdf");

  final String fileExt;

  const ExportMode({required this.fileExt});

  static ExportMode? tryParse(String value) {
    switch (value.toLowerCase()) {
      case "csv":
        return ExportMode.csv;
      case "json":
        return ExportMode.json;
      case "zip":
        return ExportMode.zip;
      case "pdf":
        return ExportMode.pdf;
      default:
        return null;
    }
  }
}
