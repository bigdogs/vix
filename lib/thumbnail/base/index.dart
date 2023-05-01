// https://stackoverflow.com/questions/44665955/how-do-i-determine-the-width-and-height-of-an-image-in-flutter
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ThumbnailImage extends ImageProvider<ThumbnailImage> {
  const ThumbnailImage(this.imageProvider,
      {required this.width, required this.ratio});

  final FileImage imageProvider;
  final int width;
  final double ratio;

  @override
  ImageStreamCompleter loadBuffer(
      ThumbnailImage key, DecoderBufferCallback decode) {
    Future<ui.Codec> decodeResize(ui.ImmutableBuffer buffer,
        {int? cacheWidth, int? cacheHeight, bool? allowUpscaling}) {
      return _getHeight(buffer).then((h) {
        return decode(buffer,
            cacheWidth: (width * ratio).round(),
            cacheHeight: (h * ratio).round(),
            allowUpscaling: false);
      });
    }

    final ImageStreamCompleter completer =
        imageProvider.loadBuffer(imageProvider, decodeResize);

    return completer;
  }

  @override
  Future<ThumbnailImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<ThumbnailImage>(this);
  }

  Future<int> _getHeight(ui.ImmutableBuffer buffer) {
    return ui.ImageDescriptor.encoded(buffer).then((value) {
      final ratio = value.height.toDouble() / value.width.toDouble();
      return (width * ratio).round();
    });
  }

  @override
  int get hashCode => Object.hash(imageProvider, width);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ThumbnailImage &&
        other.imageProvider == imageProvider &&
        other.width == width;
  }
}
