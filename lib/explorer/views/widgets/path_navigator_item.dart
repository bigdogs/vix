import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vix/explorer/controller/explorer_controller.dart';

@immutable
class PathNavigatorUiState {
  final int index;
  final String name;
  final bool isFirst;
  final bool isLast;

  const PathNavigatorUiState(
      {required this.index,
      required this.name,
      required this.isFirst,
      required this.isLast});
}

@immutable
class PathNavigatorItem extends ConsumerWidget {
  final PathNavigatorUiState data;

  const PathNavigatorItem(this.data, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(explorerProvider.notifier).gotoIndex(data.index);
      },
      child: Row(
        children: [
          if (!data.isFirst)
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  ">",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )),
          Text(
            data.name,
            style: TextStyle(
                color: data.isLast ? Colors.white : Colors.white54,
                fontSize: 16),
          )
        ],
      ),
    );
  }
}
