import 'dart:async';
import 'dart:io';

import 'package:mime/mime.dart';

import '../../log.dart';

class DirectoryEntry {
  final String path;
  final String type;
  final int size;
  final String modified;
  final int? subCount;

  DirectoryEntry(
      {required this.path,
      required this.type,
      required this.size,
      required this.modified,
      required this.subCount});
}

Future<List<DirectoryEntry>> listDirectory(String dirPath) async {
  final entries = <DirectoryEntry>[];
  await for (final value in Directory(dirPath).list()) {
    final stat = await value.stat();

    int? count;
    if (stat.type == FileSystemEntityType.directory) {
      try {
        int c = 0;
        await for (final _ in Directory(value.path).list()) {
          c += 1;
        }
        count = c;
      } catch (e) {
        log.severe('$e');
      }
    }

    entries.add(
      DirectoryEntry(
          path: value.path,
          type: stat.type.toString(),
          size: stat.size,
          modified: stat.modified.toLocal().toString(),
          subCount: count),
    );
  }
  return entries;
}

// test if we have permission to list directory,
//
//is there any other solution?
tryListDirectory(String dirPath) async {
  await for (final _ in Directory(dirPath).list()) {
    return;
  }
}

// create directory recursive ?
ensureDirectory(String path) async {
  final dir = Directory(path);
  if (await dir.exists()) {
    return;
  }
  try {
    await dir.create(recursive: true);
  } catch (e) {
    log.severe('dir "$path" create error: $e');
  }
}

// hardcode the path to make life simpler
// we will not acce
List<String> vixRootDirectory() {
  if (Platform.isAndroid) {
    return ["/storage/emulated/0", "Download"];
  } else if (Platform.isWindows) {
    return ["C:\\Users"];
  }
  throw UnimplementedError();
}

enum MimeType {
  image,
  video,
  unknown;

  static MimeType from(String path) {
    final mime = lookupMimeType(path);
    switch (mime?.split('/')[0]) {
      case "image":
        return image;
      case "video":
        return video;
      default:
        return unknown;
    }
  }
}
