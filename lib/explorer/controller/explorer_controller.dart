import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vix/explorer/models/service.dart';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

import '../../log.dart';
import '../views/widgets/directory_entry_item.dart';
import '../views/widgets/explorer_page.dart';
import '../views/widgets/path_navigator_item.dart';

// Not allowed to go to parent folder of `root`
final vixRoot = vixRootDirectory();

class ExplorerProvider extends Notifier<ExplorerUiState> {
  /// maybe this vairable should be in `repository`
  List<String> _activePath;

  ExplorerProvider(this._activePath);

  String get activePath => _activePath.join(Platform.pathSeparator);

  @override
  ExplorerUiState build() {
    // seems wired, why need to return `state`
    state = _createEmptyState();
    _firstLoading();
    return state;
  }

  consumeError() {
    state = state.copy(error: "");
  }

  refresh() async {
    log.info("refresh start: $_activePath");

    try {
      final files = await listDirectory(activePath);
      state = state.copy(
          isFirstLoading: false,
          entries: files
              .mapIndexed((idx, e) => DirectoryEntryItemUiState(e, idx))
              .toList());
    } catch (e) {
      log.severe("$e");
    }
    log.info("refresh finished");
  }

  gotoIndex(int index) async {
    log.info("gotoIndex: $index");
    if (index >= 0 && index < _activePath.length - 1) {
      _setNewRoot(_activePath.sublist(0, index + 1));
    }
  }

  gotoDirectory(String target) async {
    final r = path.relative(target, from: vixRoot[0]);
    List<String> result;
    if (r == target) {
      // we are not relative to root
      result = path.split(target);
    } else {
      result = [vixRoot[0], ...path.split(r)];
    }
    _setNewRoot(result);
  }

  // `vix` home
  gotoVIX() async {
    const vix = "/storage/emulated/0/vix";
    await ensureDirectory(vix);
    return await gotoDirectory(vix);
  }

  gotoDownload() async {
    return await gotoDirectory("/storage/emulated/0/Download");
  }

  unzipFileToHome(String file) async {
    //TODO:
  }

  startPlayVideo(String path) {
    state = state.copy(videoPath: path);
  }

  stopPlayVideo() {
    state = state.copy(videoPath: "");
  }

  List<String> imageFiles() {
    return state.entries
        .where((e) => e.type.isImage)
        .toList()
        .map((e) => e.path)
        .toList();
  }

  ExplorerUiState _createEmptyState() {
    final navigators = _activePath
        .mapIndexed((idx, e) => PathNavigatorUiState(
            index: idx,
            name: _activePath[idx],
            isFirst: idx == 0,
            isLast: idx == _activePath.length - 1))
        .toList();

    return ExplorerUiState(navigators: navigators);
  }

  _firstLoading() async {
    state = state.copy(isFirstLoading: true, error: "");
    try {
      final files = await listDirectory(activePath);

      state = state.copy(
          error: "",
          isFirstLoading: false,
          entries: files
              .mapIndexed((idx, e) => DirectoryEntryItemUiState(e, idx))
              .toList());
    } catch (e) {
      log.info("$e");
      state = state.copy(isFirstLoading: false, error: '$e');
    }
  }

  _setNewRoot(List<String> newRoot) async {
    // clear previous error as we have trigger a new action
    consumeError();

    // first check if we have permission to read the new root
    try {
      await tryListDirectory(newRoot.join(Platform.pathSeparator));
    } catch (e) {
      log.warning(e);
      state = state.copy(error: '$e');
      return;
    }

    _activePath = newRoot;
    state = _createEmptyState();

    await _firstLoading();

    // once we are navigate to a new location, clear image cache to reduce memory pressuse?
    // Not sure if this is necessary ?
    //
    // PaintingBinding.instance.imageCache.clear();
  }
}

// provider => controller
final explorerProvider = NotifierProvider<ExplorerProvider, ExplorerUiState>(
    () => ExplorerProvider(vixRoot));
