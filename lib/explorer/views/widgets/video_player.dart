import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:vix/explorer/controller/explorer_controller.dart';
import 'package:vix/log.dart';

class VideoPlayer extends ConsumerStatefulWidget {
  const VideoPlayer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends ConsumerState<VideoPlayer> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  String? currentPath;

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vp = ref.watch(explorerProvider.select((value) => value.videoPath));
    if (vp == "") {
      _dispose();
      return const SizedBox.shrink();
    }

    if (vp != currentPath) {
      // create new playing task
      _createController(vp);
      return const SizedBox.shrink();
    }

    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      final chewie = Chewie(controller: _chewieController!);
      // find a good timing to enter full screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setupPlayer(ref);
      });
      return SizedBox(width: 0, height: 0, child: chewie);
    }

    return const SizedBox.shrink();
  }

  _dispose() async {
    _chewieController?.dispose();
    await _controller?.dispose();

    _controller = null;
    _chewieController = null;
    currentPath = null;
  }

  _createController(String path) async {
    // distory previous controllers
    _dispose();

    log.info("video player start: $path");
    final controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        hideControlsTimer: const Duration(seconds: 2));

    setState(() {
      _controller = controller;
      _chewieController = chewieController;
      currentPath = path;
    });
  }

  _setupPlayer(WidgetRef ref) {
    _chewieController!.enterFullScreen();
    _chewieController!.addListener(() {
      if (!_chewieController!.isFullScreen) {
        ref.read(explorerProvider.notifier).stopPlayVideo();
      }
    });
  }
}
