import 'package:flutter/material.dart';
import 'package:s_play/cpp_import_playback.dart' as cpp;
import 'package:s_play/music_data.dart';
import 'package:s_play/widgets/settings.dart';
import 'widgets/content.dart';
import 'widgets/sidepanel.dart';
import 'widgets/playbackwidget.dart';
import 'dart:ffi' as d_ffi;
import 'package:ffi/ffi.dart';
import 'widgets/background.dart';

void main() {
  ini();
  bytesDataInitialize();
  runApp(const MainApp());

  if (cpp.libInitialized.last) {
    cpp.disposeSoundData();
  }
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
      home: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(90),
            child: AppBar(
              titleSpacing: 5,
              flexibleSpace: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 5,
                children: [
                  Image.asset("assets/icons/SMusic_icon.png", height: 80),
                ],
              ),
            ),
          ),
          body: const Stack(
            children: [
              BackgroundWidget(),
              ContentWidget(),
              Flex(
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(flex:5,child: SidePanelWidget()),
              Flexible(flex:2,child: PlaybackWidget()),
                ],
              ),
              SettingsWidget(),
            ],
          ),
        ),
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

typedef InitializeSoundDataC = d_ffi.Int32 Function(d_ffi.Pointer<Utf8>);

typedef InitializeSoundDataDart = int Function(d_ffi.Pointer<Utf8>);

typedef DisposeSoundDataC = d_ffi.Void Function();

typedef DisposeSoundDataDart = void Function();

typedef StartPlayBackC = d_ffi.Int32 Function();

typedef StartPlayBackDart = int Function();

typedef TestC = d_ffi.Int32 Function(d_ffi.Pointer<Utf8>);

typedef TestDart = int Function(d_ffi.Pointer<Utf8>);
late dynamic initializeSoundData;
late dynamic disposeSoundData;
late dynamic startPlayBack;
late dynamic test;
void ini() {
  final d_ffi.DynamicLibrary dyLib = d_ffi.DynamicLibrary.open(
    "D:/Code/S-Play/miniaudioTest/soundlib.dll",
  );

  initializeSoundData = dyLib
      .lookupFunction<InitializeSoundDataC, InitializeSoundDataDart>(
        "initializeSoundData",
      );
  disposeSoundData = dyLib
      .lookupFunction<DisposeSoundDataC, DisposeSoundDataDart>(
        "disposeSoundData",
      );
  startPlayBack = dyLib.lookupFunction<StartPlayBackC, StartPlayBackDart>(
    "startPlayback",
  );
  test = dyLib.lookupFunction<TestC, TestDart>("initializeSoundData");
}
