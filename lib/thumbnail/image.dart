import 'dart:io';

import 'package:flutter/material.dart';

import 'base/index.dart';

class ImageThumbnail extends StatefulWidget {
  const ImageThumbnail(
      {super.key, this.index, required this.path, required this.size});

  // for debug purpose
  final int? index;

  // file path
  final String path;

  // how big should this widget be
  final double size;

  @override
  State<StatefulWidget> createState() {
    return _ImageThumbnailState();
  }
}

class _ImageThumbnailState extends State<ImageThumbnail> {
  @override
  Widget build(BuildContext context) {
    final ratio = MediaQuery.of(context).devicePixelRatio;

    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image(
                  fit: BoxFit.cover,
                  image: ThumbnailImage(FileImage(File(widget.path)),
                      width: widget.size.round(), ratio: ratio),
                ))));
  }
}
