import "package:flow/entity/backup_entry.dart";
import "package:flow/services/sync/icloud_syncer.dart";
import "package:flow/utils/utils.dart";
import "package:icloud_storage/icloud_storage.dart";

extension BackupEntryExtension on BackupEntry {
  ICloudFile? get correspondingFile {
    try {
      final List<ICloudFile> files = ICloudSyncer().filesCache.value;

      return files.firstWhereOrNull(
        (file) => file.relativePath == ICloudSyncer().resolvePath(filePath),
      );
    } catch (e) {
      return null;
    }
  }

  /// Whether the file can be uploaded to iCloud.
  bool get canUploadToCloud {
    if (correspondingFile != null) return false;
    if (!ICloudSyncer.supported || !ICloudSyncer().syncing) return false;

    try {
      return correspondingFile == null;
    } catch (e) {
      return true;
    }
  }
}
