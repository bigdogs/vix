import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vix/explorer/controller/explorer_controller.dart';
import 'package:vix/explorer/views/widgets/directory_entry_item.dart';
import 'package:vix/explorer/views/widgets/path_navigator_item.dart';
import 'package:vix/explorer/views/widgets/video_player.dart';

@immutable
class ExplorerUiState {
  final List<PathNavigatorUiState> navigators;
  final List<DirectoryEntryItemUiState> entries;
  final bool isFirstLoading;
  final String error;
  final String videoPath;

  const ExplorerUiState(
      {this.navigators = const [],
      this.entries = const [],
      this.isFirstLoading = false,
      this.error = "",
      this.videoPath = ""});

  ExplorerUiState copy({
    List<PathNavigatorUiState>? navigators,
    List<DirectoryEntryItemUiState>? entries,
    bool? isFirstLoading,
    String? error,
    String? videoPath,
  }) {
    return ExplorerUiState(
        navigators: navigators ?? this.navigators,
        entries: entries ?? this.entries,
        isFirstLoading: isFirstLoading ?? this.isFirstLoading,
        error: error ?? this.error,
        videoPath: videoPath ?? this.videoPath);
  }
}

class ExplorerPage extends ConsumerWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Column(
          children: [
            _buildPathNavigator(context, ref),
            Expanded(
                child: LayoutBuilder(
                    builder: (context, constraints) =>
                        _buildBody(context, constraints, ref)))
          ],
        ),
        _ErrorIndicator(),
        const VideoPlayer(),
      ],
    );
  }

  _buildPathNavigator(BuildContext context, WidgetRef ref) {
    final nv = ref.watch(explorerProvider.select((value) => value.navigators));
    return Container(
      height: 40,
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: nv.map(
            (e) {
              return PathNavigatorItem(e);
            },
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, BoxConstraints constraints, WidgetRef ref) {
    final state = ref.watch(explorerProvider);

    if (state.isFirstLoading) {
      return Container();
    }

    Widget child;

    if (state.entries.isEmpty) {
      // Need wrap widget to Listview to make refresh indicator work,
      // (SingleScrollView/PageView will not trigger refresh indicator?)
      child = ListView(
        children: [
          ConstrainedBox(
            // by defualt, ListView will apply infinite height to child, which is not we want.
            constraints: constraints,
            child: _EmptyDirectory(),
          )
        ],
      );
    } else {
      child = NotificationListener(
          onNotification: (notification) {
            // showImageCachePressure();
            return false;
          },
          child: ListView.separated(
            itemBuilder: (context, index) {
              return DirectoryEntryItem(state.entries[index]);
            },
            separatorBuilder: (_, __) => const Divider(
              height: 1,
            ),
            itemCount: state.entries.length,
            cacheExtent: 750,
          ));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(explorerProvider.notifier).refresh();
      },
      child: child,
    );
  }
}

class _EmptyDirectory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).hintColor;
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.folder_outlined,
          size: 120,
          color: hint,
        ),
        Text(
          "Empty",
          style:
              TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: hint),
        )
      ],
    ));
  }
}

class _ErrorIndicator extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ErrorIndicatorState();
  }
}

class _ErrorIndicatorState extends ConsumerState<_ErrorIndicator> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    final error = ref.watch(explorerProvider.select((value) => value.error));
    count += 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (error.isNotEmpty) {
        _showError(context, error);
      } else {
        _dismissError(context);
      }
    });

    return const SizedBox.shrink();
  }

  void _dismissError(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  // the behavior of snackbar may confuse user
  // a modal toast seems better, but toast seems complicated
  //
  void _showError(BuildContext context, String msg) {
    _dismissError(context);

    final bar = SnackBar(content: Text(msg));
    int current = count;
    ScaffoldMessenger.of(context).showSnackBar(bar).closed.then((value) {
      if (current == count) {
        // state is not change during the snakbar showing, then we are responsible for consuming the error
        ref.read(explorerProvider.notifier).consumeError();
      }
    });
  }
}
