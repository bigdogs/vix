import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:vix/explorer/views/widgets/drawer.dart';
import 'package:vix/utils.dart';

import 'explorer/views/widgets/explorer_page.dart';

void main() {
  hierarchicalLoggingEnabled = true;

  beforeRun();
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("VIX"),
          elevation: 0.0,
        ),
        body: const ExplorerPage(),
        drawer: const VixDrawer(),
      ),
    );
  }
}

beforeRun() async {
  WidgetsFlutterBinding.ensureInitialized();
  // https://github.com/flutter/flutter/issues/68700
  //
  // seems like a photo can takes 100M ?, so we increase image cache size to 1G
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 1024;

  if (Platform.isAndroid || Platform.isIOS) {
    await Future.delayed(const Duration(milliseconds: 300));
    requestPermission();
  }
}
