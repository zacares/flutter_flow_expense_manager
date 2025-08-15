import "dart:async";
import "dart:io";

import "package:flow/constants.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/services/sync/syncer.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/foundation.dart";
import "package:icloud_storage/icloud_storage.dart";
import "package:logging/logging.dart";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:uuid/uuid.dart";

final Logger _log = Logger("ICloudSyncer");

class ICloudSyncer implements Syncer {
  static ICloudSyncer? _instance;

  static const String containerId = "iCloud.mn.flow.flow";

  static bool get supported => Platform.isIOS || Platform.isMacOS;

  bool _listeningToMetadataChanges = false;

  dynamic lastError;

  final ValueNotifier<List<ICloudFile>> _filesCache =
      ValueNotifier<List<ICloudFile>>([]);
  ValueListenable<List<ICloudFile>> get filesCache => _filesCache;

  ICloudSyncer._internal() {
    _listenToMetadataChanges();
  }

  factory ICloudSyncer() => _instance ??= ICloudSyncer._internal();

  /// Updates the cache also
  void _listenToMetadataChanges() async {
    if (!supported) return;

    late final StreamSubscription<List<ICloudFile>> subscription;

    final List<ICloudFile> files =
        await ICloudStorage.gather(
          containerId: containerId,
          onUpdate: (Stream<List<ICloudFile>> stream) {
            _listeningToMetadataChanges = true;
            subscription = stream.listen(
              (data) => _filesCache.value = data,
              onDone: () {
                _log.info("ICloud metadata stream closed");
                subscription.cancel();
                _listeningToMetadataChanges = false;
              },
              onError: (error) {
                _log.severe("ICloud metadata stream error", error);
                subscription.cancel();
                _listeningToMetadataChanges = false;
              },
            );
          },
        ).catchError((e, stackTrace) {
          lastError = e;
          _log.warning("Error gathering iCloud files", e, stackTrace);
          return <ICloudFile>[];
        });

    _log.fine("Gathered iCloud files: ${files.length}");

    _filesCache.value = files;
    lastError = null;
    _listeningToMetadataChanges = true;
  }

  String resolvePath(String path) {
    final String file = basename(path);

    return ["backups", if (flowDebugMode) "debug", file].join("/");
  }

  @override
  bool get syncing => true;

  @override
  Future<bool> delete(String path) async {
    try {
      await ICloudStorage.delete(
        containerId: containerId,
        relativePath: resolvePath(path),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<File?> download(SyncerItem item) async {
    if (!supported) throw UnimplementedError();

    StreamSubscription<double>? subscription;

    final Completer<File?> completer = Completer<File?>();

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String tempFile = join(
        tempDir.path,
        basename("${Uuid().v4()}.tmp"),
      );

      await ICloudStorage.download(
        containerId: containerId,
        relativePath: resolvePath(item.path),
        destinationFilePath: tempFile,
        onProgress: (progressStream) => {
          subscription = progressStream.listen(
            (value) {
              _log.fine("ICloud download progress: $value");
              if (value >= 100.0) {
                completer.complete(File(tempFile));
              }
            },
            onDone: () {
              completer.complete(File(tempFile));
            },
            cancelOnError: true,
            onError: (error) {
              completer.completeError("Failed to download iCloud file: $error");
            },
          ),
        },
      );

      return await completer.future;
    } catch (e) {
      _log.severe("Failed to download iCloud file", e);
      rethrow;
    } finally {
      unawaited(
        subscription?.cancel().catchError((error) {
          _log.warning(
            "Failed to cancel iCloud download progress subscription",
            error,
          );
        }),
      );
    }
  }

  @override
  Future<SyncerItem?> get(String name) async {
    if (!supported) return null;

    if (_listeningToMetadataChanges) {
      try {
        final ICloudFile? file = _filesCache.value.firstWhereOrNull(
          (file) => file.relativePath == resolvePath(name),
        );

        if (file == null) {
          throw StateError("File not found");
        }

        return SyncerItem(
          path: file.relativePath,
          updatedAt: file.contentChangeDate,
        );
      } catch (e) {
        _log.warning("Unable to find the file from the cache", e);
      }
    }
    return null;
  }

  @override
  Future<List<SyncerItem>> list() async {
    if (!supported) return <SyncerItem>[];

    if (_listeningToMetadataChanges) {
      try {
        return _filesCache.value
            .map(
              (file) => SyncerItem(
                path: file.relativePath,
                updatedAt: file.contentChangeDate,
              ),
            )
            .toList();
      } catch (e) {
        _log.warning("Error putting iCloud files into cache", e);
      }
    }

    try {
      final List<ICloudFile> files = await ICloudStorage.gather(
        containerId: containerId,
      );

      try {
        _filesCache.value = files;
      } catch (e) {
        _log.warning("Error putting iCloud files into cache", e);
      }

      return files
          .map(
            (file) => SyncerItem(
              path: file.relativePath,
              updatedAt: file.contentChangeDate,
            ),
          )
          .toList();
    } catch (e) {
      _log.warning("Error gathering iCloud files", e);

      return <SyncerItem>[];
    }
  }

  @override
  Future<int> purge(Duration maxAge) async {
    try {
      final List<SyncerItem> items = await list();

      int success = 0;

      await Future.wait(
        items
            .where(
              (item) =>
                  item.inferredbackupDate != null &&
                  DateTime.now().difference(item.inferredbackupDate!) > maxAge,
            )
            .map((item) => delete(item.path).then((_) => success++)),
      );
      return success;
    } catch (e) {
      _log.warning("Error listing iCloud files", e);
    }

    return 0;
  }

  @override
  Future<bool> put(BackupEntry entry, {Function(double p1)? onProgress}) async {
    StreamSubscription<double>? subscription;
    try {
      await ICloudStorage.upload(
        containerId: containerId,
        filePath: entry.filePath,
        destinationRelativePath: resolvePath(entry.filePath),
        onProgress: (progressStream) => {
          subscription = progressStream.listen((value) {
            if (onProgress != null) {
              onProgress(value);
            } else {}
            _log.fine("ICloud upload progress: $value");
          }),
        },
      );
      return true;
    } catch (e) {
      _log.severe("Failed to upload iCloud file", e);

      return false;
    } finally {
      unawaited(
        subscription?.cancel().catchError(
          (error) => _log.warning(
            "Failed to cancel iCloud upload progress subscription",
            error,
          ),
        ),
      );
    }
  }
}
