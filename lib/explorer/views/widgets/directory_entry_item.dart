import 'dart:io';

import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:vix/explorer/controller/explorer_controller.dart';
import 'package:vix/gallery/gallery.dart';
import 'package:vix/thumbnail/index.dart';
import 'package:vix/utils.dart';

import '../../../log.dart';
import '../../models/service.dart';

class DirectoryEntryItemUiState {
  final int index;
  final String path;
  final FileType type;
  final int size;
  final String modified;
  final int? subCount;

  DirectoryEntryItemUiState(DirectoryEntry m, this.index)
      : path = m.path,
        type = FileType.from(
            m.path, m.type == FileSystemEntityType.directory.toString()),
        size = m.size,
        modified = m.modified,
        subCount = m.subCount;
}

enum _MoreAction {
  unzipToDefaultLocation,
}

class DirectoryEntryItem extends ConsumerWidget {
  final DirectoryEntryItemUiState data;

  const DirectoryEntryItem(this.data, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // if we lift up InkWell to parent, then the button action may have slow response on PC?,
    return InkWell(
        onTap: () => _onFileOrDirectoryClick(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          child: Row(
            children: <Widget>[
              _buildThumbnail(),
              Expanded(
                child: Center(child: _buildDetails(context)),
              ),
              _buildMoreButton(context, ref)
            ],
          ),
        ));
  }

  _onFileOrDirectoryClick(BuildContext context, WidgetRef ref) {
    log.info('${data.path} clicked, type=${data.type}');
    if (data.type.isDir) {
      // folder
      ref.read(explorerProvider.notifier).gotoDirectory(data.path);
    } else if (data.type.isImage) {
      // image
      //
      // controller should not access `BuildContext`, we just open navigator here directly
      final images = ref.read(explorerProvider.notifier).imageFiles();
      int index = images.indexOf(data.path);
      openGallery(context, images, index);
    } else if (data.type.isVideo) {
      // video
      //
      ref.read(explorerProvider.notifier).startPlayVideo(data.path);
    }
  }

  _buildMoreButton(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_MoreAction>(onSelected: (value) {
      switch (value) {
        case _MoreAction.unzipToDefaultLocation:
          ref.read(explorerProvider.notifier).unzipFileToHome(data.path);
          break;
      }
    }, itemBuilder: (context) {
      // TODO: `unzip` apply only on file type
      return <PopupMenuEntry<_MoreAction>>[
        const PopupMenuItem<_MoreAction>(
          value: _MoreAction.unzipToDefaultLocation,
          child: Text('Unzip To Home'),
        )
      ];
    });
  }

  _buildDetails(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: weightText(
              basename(data.path),
            )),
            if (data.type.isDir)
              Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: lightText('${data.subCount}'))
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: lightText(_fileTypeOrSize())),
            lightText(data.modified)
          ],
        )
      ],
    );
  }

  Text lightText(String s) {
    return Text(
      s,
      style:
          const TextStyle(fontWeight: FontWeight.w400, color: Colors.black45),
    );
  }

  Text weightText(String s) {
    return Text(
      s,
      style: const TextStyle(
          fontWeight: FontWeight.w400, color: Colors.black87, fontSize: 17),
    );
  }

  String _fileTypeOrSize() {
    if (data.type.isDir) {
      return "Directory";
    } else {
      return filesize(data.size);
    }
  }

  Widget _buildThumbnail() {
    // fix thumbail size:
    const double iconSize = 64;

    return SizedBox(
        width: iconSize,
        height: iconSize,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: Center(
                child: FileThumbnail(
              index: data.index,
              path: data.path,
              size: iconSize,
              fileType: data.type,
            ))));
  }
}
