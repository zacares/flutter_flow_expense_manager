import "dart:io";

import "package:flow/entity/backup_entry.dart";
import "package:path/path.dart";

class SyncerItem {
  final String path;
  final DateTime? updatedAt;

  DateTime? get inferredbackupDate {
    try {
      final [...rest, date, time] = basename(path).split("_");

      final [year, month, day] = date
          .split("-")
          .map((x) => int.parse(x, radix: 10))
          .toList();
      final [hour, minute, second] = time
          .split("-")
          .map((x) => int.parse(x, radix: 10))
          .toList();

      return DateTime(year, month, day, hour, minute, second);
    } catch (e) {
      return null;
    }
  }

  const SyncerItem({required this.path, required this.updatedAt});
}

abstract class Syncer {
  /// Returns whether the file was uploaded
  Future<bool> put(BackupEntry entry, {Function(double)? onProgress});

  /// Returns the count of files deleted
  Future<int> purge(Duration maxAge);

  /// Returns whether the file was deleted
  Future<bool> delete(String name);
  Future<List<SyncerItem>> list();
  Future<SyncerItem?> get(String name);
  Future<File?> download(SyncerItem item);

  bool get syncing;
}
