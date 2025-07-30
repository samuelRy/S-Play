import 'package:flutter/material.dart';
import 'package:s_play/widgets/content.dart';
import 'package:s_play/widgets/music_control_panal.dart';
import 'package:s_play/widgets/music_visualizer.dart';
import 'package:s_play/widgets/sidepanel.dart';

import 'widgets/background.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF795548),
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      title: 'S Play',
      home: const Stack(
        children: [
          MusicControlPanalWidget()
        ],
      ),
      
    );
  }
}
/*
Scaffold(
        body: const Stack(
          children: [
            ContentWidget()
          ],
        ),
      ),
      */