import 'dart:typed_data';

import 'package:audiotags/audiotags.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s_play/cpp_import_playback.dart';
import 'package:s_play/widgets/music_card.dart';
import 'package:s_play/widgets/playbackwidget.dart';
import 'dart:io';

import 'music_listing.dart';

bool notPlaying = false;
bool started = false;
Uint8List? backImageDefault;

PlayList playListAll = PlayList(id: 0, name: "");

(int, String, Uint8List) current = (-1, "", Uint8List(0));
(String, String, String, String, int, Picture) metaC = (
  "",
  "",
  "",
  "",
  -1,
  Picture(
    bytes: Uint8List(0),
    pictureType: PictureType.coverBack,
    mimeType: MimeType.png,
  ),
);

ValueNotifier<(int, String, Uint8List)> currentMusic =
    ValueNotifier<(int, String, Uint8List)>(current);
ValueNotifier<(String, String, String, String, int, Picture)> currentMeta =
    ValueNotifier<(String, String, String, String, int, Picture)>(metaC);
ValueNotifier<Uint8List?> backU8List = ValueNotifier<Uint8List?>(
  backImageDefault,
);

List<String> folders = ["D:/Code/S-Play/Sounds Tests"];

List<PlayList> playLists = [];

List<MusicCardWidget> musics = [];

List<int> trackMusics = [];

Map<dynamic, List<dynamic>> mappedList = {};

class PlayList {
  PlayList({
    required this.id,
    required this.name,
    this.image,
    this.audios = const {},
  });
  final int id;
  String name;
  Image? image;
  Map<String, List<Map<String, String>>> audios = {};
}

bool playListInitialized = false;
ValueNotifier<bool> playListInitializedNotifier = ValueNotifier<bool>(
  playListInitialized,
);
Future<void> initializePlayList() async {
  // print("object");
  playListInitializedNotifier.value = false;
  List<String> sounds = [];
  for (var folder in folders) {
    await for (FileSystemEntity entity in Directory(
      folder,
    ).list(recursive: true, followLinks: false)) {
      //var ss = await entity.stat().then((s) => s.size);
      // print(getSoundPath(entity.path));
      String soundPath = getSoundPath(entity.path);
      if (soundPath != "The file isn't readable") {
        sounds.add(soundPath);
      }
    }
  }
  sounds.sort();

  // print("add");
  Map<String, List<Map<String, String>>> list = {};
  int it = sounds.length;
  for (var i = 0; i < it; i++) {
    list[sounds[i]] = [];
  }
  playListAll = (PlayList(audios: list, id: 0, name: "All"));
  for (var i = 0; i < it; i++) {
    MusicCardWidget(id: i, play: () {}, soundPath: sounds[i]);
    // print("${sounds[i]} ${playListAll.audios.length}");
  }
  playLists.add(playListAll);
  playListInitializedNotifier.value = true;
  //print("${playLists[0].audios.length}");
}

int rebuild = 0;

void playCurrent(int index, String soundPath, Uint8List img) {
  currentMusic.value = (index, soundPath, img);
  // /*setState(() {*/print("true Too ${musics.length} ${index + 1} $index");
  if (currentMusic.value.$1 != -1) {
    started = false;
    // print("Disposing");
    disposeSoundData();
    timerPlay?.cancel();
    timerPlay = null;
    // print("Dispose");
  }
  // print("initiaaaa ${currentMusic.value.$1} ${currentMusic.value.$2}");
  if (currentMusic.value.$1 != index) {
    // print(musics.length > index);
    if (musics.length > index) {
      // print("nexta");
    }
    //initA();
  }
  // print("Initializing ${soundPath.toNativeUtf16()}");
  initializeSoundData(soundPath.toNativeUtf16());
  // print("Initialized");
  Future.microtask(() async {
    startPlayBack();

    // print("qe");
    // print("qe");
  });
}
//}

ValueNotifier<int> reVal = ValueNotifier<int>(rebuild);
ValueNotifier<Map<dynamic, List<dynamic>>> mappedNotifier =
    ValueNotifier<Map<dynamic, List<dynamic>>>(mappedList);
