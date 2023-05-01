import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vix/thumbnail/image.dart';
import 'package:vix/thumbnail/video.dart';
import 'package:vix/utils.dart';

class FileThumbnail extends StatelessWidget {
  static final Map<String, IconData> _mimeTypeToIconDataMap =
      <String, IconData>{
    'image': FontAwesomeIcons.image,
    'application/pdf': FontAwesomeIcons.filePdf,
    'application/msword': FontAwesomeIcons.fileWord,
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        FontAwesomeIcons.fileWord,
    'application/vnd.oasis.opendocument.text': FontAwesomeIcons.fileWord,
    'application/vnd.ms-excel': FontAwesomeIcons.fileExcel,
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        FontAwesomeIcons.fileExcel,
    'application/vnd.oasis.opendocument.spreadsheet':
        FontAwesomeIcons.fileExcel,
    'application/vnd.ms-powerpoint': FontAwesomeIcons.filePowerpoint,
    'application/vnd.openxmlformats-officedocument.presentationml.presentation':
        FontAwesomeIcons.filePowerpoint,
    'application/vnd.oasis.opendocument.presentation':
        FontAwesomeIcons.filePowerpoint,
    'text/plain': FontAwesomeIcons.fileLines,
    'text/csv': FontAwesomeIcons.fileCsv,
    'application/x-archive': FontAwesomeIcons.fileZipper,
    'application/x-cpio': FontAwesomeIcons.fileZipper,
    'application/x-shar': FontAwesomeIcons.fileZipper,
    'application/x-iso9660-image': FontAwesomeIcons.fileZipper,
    'application/x-sbx': FontAwesomeIcons.fileZipper,
    'application/x-tar': FontAwesomeIcons.fileZipper,
    'application/x-bzip2': FontAwesomeIcons.fileZipper,
    'application/gzip': FontAwesomeIcons.fileZipper,
    'application/x-lzip': FontAwesomeIcons.fileZipper,
    'application/x-lzma': FontAwesomeIcons.fileZipper,
    'application/x-lzop': FontAwesomeIcons.fileZipper,
    'application/x-snappy-framed': FontAwesomeIcons.fileZipper,
    'application/x-xz': FontAwesomeIcons.fileZipper,
    'application/x-compress': FontAwesomeIcons.fileZipper,
    'application/zstd': FontAwesomeIcons.fileZipper,
    'application/java-archive': FontAwesomeIcons.fileZipper,
    'application/octet-stream': FontAwesomeIcons.fileZipper,
    'application/vnd.android.package-archive': FontAwesomeIcons.fileZipper,
    'application/vnd.ms-cab-compressed': FontAwesomeIcons.fileZipper,
    'application/x-7z-compressed': FontAwesomeIcons.fileZipper,
    'application/x-ace-compressed': FontAwesomeIcons.fileZipper,
    'application/x-alz-compressed': FontAwesomeIcons.fileZipper,
    'application/x-apple-diskimage': FontAwesomeIcons.fileZipper,
    'application/x-arj': FontAwesomeIcons.fileZipper,
    'application/x-astrotite-afa': FontAwesomeIcons.fileZipper,
    'application/x-b1': FontAwesomeIcons.fileZipper,
    'application/x-cfs-compressed': FontAwesomeIcons.fileZipper,
    'application/x-dar': FontAwesomeIcons.fileZipper,
    'application/x-dgc-compressed': FontAwesomeIcons.fileZipper,
    'application/x-freearc': FontAwesomeIcons.fileZipper,
    'application/x-gca-compressed': FontAwesomeIcons.fileZipper,
    'application/x-gtar': FontAwesomeIcons.fileZipper,
    'application/x-lzh': FontAwesomeIcons.fileZipper,
    'application/x-lzx': FontAwesomeIcons.fileZipper,
    'application/x-ms-wim': FontAwesomeIcons.fileZipper,
    'application/x-rar-compressed': FontAwesomeIcons.fileZipper,
    'application/x-stuffit': FontAwesomeIcons.fileZipper,
    'application/x-stuffitx': FontAwesomeIcons.fileZipper,
    'application/x-xar': FontAwesomeIcons.fileZipper,
    'application/x-zoo': FontAwesomeIcons.fileZipper,
    'application/zip': FontAwesomeIcons.fileZipper,
    'text/html': FontAwesomeIcons.code,
    'text/javascript': FontAwesomeIcons.code,
    'text/css': FontAwesomeIcons.code,
    'text/x-python': FontAwesomeIcons.code,
    'application/x-python-code': FontAwesomeIcons.code,
    'text/xml': FontAwesomeIcons.code,
    'application/xml': FontAwesomeIcons.code,
    'text/x-c': FontAwesomeIcons.code,
    'application/java': FontAwesomeIcons.code,
    'application/java-byte-code': FontAwesomeIcons.code,
    'application/x-java-class': FontAwesomeIcons.code,
    'application/x-csh': FontAwesomeIcons.code,
    'text/x-script.csh': FontAwesomeIcons.code,
    'text/x-fortran': FontAwesomeIcons.code,
    'text/x-h': FontAwesomeIcons.code,
    'application/x-ksh': FontAwesomeIcons.code,
    'text/x-script.ksh': FontAwesomeIcons.code,
    'application/x-latex': FontAwesomeIcons.code,
    'application/x-lisp': FontAwesomeIcons.code,
    'text/x-script.lisp': FontAwesomeIcons.code,
    'text/x-m': FontAwesomeIcons.code,
    'text/x-pascal': FontAwesomeIcons.code,
    'text/x-script.perl': FontAwesomeIcons.code,
    'application/postscript': FontAwesomeIcons.code,
    'text/x-script.phyton': FontAwesomeIcons.code,
    'application/x-bytecode.python': FontAwesomeIcons.code,
    'text/x-asm': FontAwesomeIcons.code,
    'application/x-bsh': FontAwesomeIcons.code,
    'application/x-sh': FontAwesomeIcons.code,
    'text/x-script.sh': FontAwesomeIcons.code,
    'text/x-script.zsh': FontAwesomeIcons.code,
    'default': FontAwesomeIcons.file,
  };

  const FileThumbnail(
      {super.key,
      this.index,
      required this.path,
      required this.size,
      required this.fileType});

  // for debug purpose
  final int? index;

  // file path
  final String path;

  // file type
  final FileType fileType;

  // how big should this widget be
  final double size;

  @override
  Widget build(BuildContext context) {
    if (fileType.isDir) {
      // folder icon
      return Icon(
        Icons.folder,
        size: size * 0.8,
        color: const Color.fromRGBO(255, 210, 81, 1),
      );
    } else if (fileType.isImage) {
      return ImageThumbnail(path: path, size: size, index: index);
    } else if (fileType.isVideo) {
      return VideoThumbnail(path: path, size: size);
    } else {
      return Icon(
        _getIconByMime(fileType.mime),
        color: Colors.black87,
        size: size * 0.6,
      );
    }
  }

  IconData _getIconByMime(String? mime) {
    if (mime == null) {
      return FontAwesomeIcons.file;
    }

    if (_mimeTypeToIconDataMap.containsKey(mime)) {
      return _mimeTypeToIconDataMap[mime]!;
    }

    String mimeTypePart = mime;
    while (mimeTypePart.contains('/')) {
      mimeTypePart = mimeTypePart.substring(
        0,
        mimeTypePart.lastIndexOf('/'),
      );
      if (_mimeTypeToIconDataMap.containsKey(mimeTypePart)) {
        return _mimeTypeToIconDataMap[mimeTypePart]!;
      }
    }
    return FontAwesomeIcons.file;
  }
}
