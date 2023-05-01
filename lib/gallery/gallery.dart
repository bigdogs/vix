import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:vix/log.dart';
import 'package:vix/utils.dart';

class ImageBean {
  final String path;
  final int index;

  ImageBean({required this.path, required this.index});

  static List<ImageBean> list(List<String> files) {
    return files
        .mapIndexed((key, value) => ImageBean(path: value, index: key))
        .toList();
  }
}

class GalleryImageViewer extends StatefulWidget {
  GalleryImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  }) : pageController = PageController(initialPage: initialIndex);

  final List<ImageBean> images;
  final int initialIndex;
  final PageController pageController;

  @override
  State<StatefulWidget> createState() {
    return _GalleryImageViewerState();
  }
}

class _GalleryImageViewerState extends State<GalleryImageViewer> {
  late int currentIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    int len = widget.images.length;
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          PhotoViewGallery.builder(
            itemCount: widget.images.length,
            builder: _buildImageItem,
            scrollPhysics: const BouncingScrollPhysics(),
            onPageChanged: _onPageChanged,
            pageController: widget.pageController,
            wantKeepAlive: false,
            allowImplicitScrolling: true,
          ),
          Container(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "$currentIndex / $len",
                style: const TextStyle(
                    color: Colors.white, fontSize: 17, decoration: null),
              ))
        ],
      ),
    ));
  }

  // there is no `svg` in our use case
  PhotoViewGalleryPageOptions _buildImageItem(BuildContext context, int index) {
    final ImageBean data = widget.images[index];
    return PhotoViewGalleryPageOptions(
        imageProvider: Image.file(File(data.path)).image);
  }

  _onPageChanged(int index) {
    showImageCachePressure();
    _maintanceImageCaches(index);
    setState(() {
      currentIndex = index;
    });
  }

  bool _clearCache(int index) {
    // image provider use FileImage as `key`
    final key = FileImage(File(widget.images[index].path));
    if (PaintingBinding.instance.imageCache.containsKey(key)) {
      log.info("clear gallery image cache of $index");
      PaintingBinding.instance.imageCache.evict(key);
      return true;
    }
    return false;
  }

  /// one image can takes 100m, need to clear inactive images
  ///
  /// we keeps five images at most
  /// cur - 2, cur - 1, cur, cur + 1, cur + 2
  _maintanceImageCaches(int cur) {
    if (cur - 3 >= 0) {
      for (var i = cur - 3; i >= 0; i -= 1) {
        if (!_clearCache(i)) {
          break;
        }
      }
    }

    if (cur + 3 < widget.images.length) {
      for (var i = cur + 3; i < widget.images.length; i += 1) {
        if (!_clearCache(i)) {
          break;
        }
      }
    }
  }
}

openGallery(BuildContext context, List<String> files, int initialIndex) {
  log.info("open Gallery navigator");
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GalleryImageViewer(
              images: ImageBean.list(files), initialIndex: initialIndex)));
}
