import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vix/explorer/controller/explorer_controller.dart';

class VixDrawer extends ConsumerWidget {
  const VixDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Center(
                  child: Text(
                "VIX",
                style:
                    TextStyle(fontSize: 24, color: Theme.of(context).cardColor),
              )),
            ),
          ),
          DrawerTile(
            icon: Icons.home,
            text: "VIX",
            onTap: () => ref.read(explorerProvider.notifier).gotoVIX(),
          ),
          DrawerTile(
            icon: Icons.download,
            text: "下载",
            onTap: () => ref.read(explorerProvider.notifier).gotoDownload(),
          ),
          const Divider(
            height: 4,
          ),
          DrawerTile(
            icon: Icons.movie,
            text: "视频",
            onTap: () {},
          ),
          DrawerTile(
            icon: Icons.image,
            text: "图片",
            onTap: () {},
          ),
          const Divider(
            height: 4,
          ),
          DrawerTile(
            icon: Icons.settings,
            text: "设置",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final GestureTapCallback? onTap;

  const DrawerTile(
      {super.key, required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(text),
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
        Navigator.of(context).pop();
      },
    );
  }
}
