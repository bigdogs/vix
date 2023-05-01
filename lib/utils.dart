import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_storage/saf.dart';
import 'package:vix/log.dart';

requestPermission() async {
  // maybe more on future
  await Permission.manageExternalStorage.request();
  await Permission.storage.request();
  // await requestAppDataAccessIntent();
}

requestAppDataAccessIntent() async {
  // https://www.zhihu.com/question/420023759
  //
  // 好好研究下这个demo

  final d = await getExternalStorageDirectory();
  d!.createSync();

  const packageName = "com.example.flutter_rust_bridge_template";
  // the path of uri must exists, otherwise, we can't assign permission
  const initUrl =
      "content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fdata/document/primary%3AAndroid%2Fdata%2F$packageName";

  /// If the folder don't exist, the OS will ignore the initial directory
  await openDocumentTree(initialUri: Uri.parse(initUrl));
  await persistedUriPermissions();
}

showImageCachePressure() {
  log.info(
      'image caches: ${PaintingBinding.instance.imageCache.currentSizeBytes}/${PaintingBinding.instance.imageCache.maximumSizeBytes}');
}

class FileType {
  final bool _isDir;
  // "video/mp4"
  final String? _mime;
  // only the first part of mime, e.g "video/mp4" => "video"
  final String? _first;

  FileType({required bool isDir, required String? mime})
      : _isDir = isDir,
        _mime = mime,
        _first = mime?.split('/')[0];

  String? get mime => _mime;

  bool get isDir => _isDir;
  bool get isImage => !_isDir && _first == "image";
  bool get isVideo => !_isDir && _first == "video";

  static FileType from(String path, bool isDir) {
    if (isDir) {
      return FileType(isDir: true, mime: null);
    }

    final mime = lookupMimeType(path);
    return FileType(isDir: false, mime: mime);
  }
}
