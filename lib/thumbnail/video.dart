import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import 'package:vix/thumbnail/image.dart';

class VideoThumbnail extends StatefulWidget {
  final String path;
  final double size;

  const VideoThumbnail({required this.path, required this.size, super.key});

  @override
  State<StatefulWidget> createState() {
    return _VideoThumbnailState();
  }
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: _loadTumbnailImage(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return ImageThumbnail(path: snapshot.data!, size: widget.size);
          } else {
            return Container();
          }
        });
  }

  Future<String?> _loadTumbnailImage() async {
    final fileName = await vt.VideoThumbnail.thumbnailFile(
      video: widget.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: vt.ImageFormat.WEBP,
      maxWidth: widget.size
          .round(), // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    );
    return fileName;
  }
}
