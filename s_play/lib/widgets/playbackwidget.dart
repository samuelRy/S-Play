import 'dart:async';
import 'dart:ffi';

import 'package:audiotags/audiotags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s_play/cpp_import_playback.dart';
import 'package:s_play/music_data.dart';
import 'package:s_play/widgets/music_card.dart' hide playCurrent;
import 'package:s_play/widgets/playbackSliderWidget.dart';
import 'package:s_play/widgets/settings.dart';
import 'package:s_play/widgets/sidepanel.dart';
import 'package:s_play/widgets/text_button.dart';
import 'package:s_play/widgets/updatingSliderWidget.dart';

import '../cpp_import_playback.dart' as cpp;

class PlaybackWidget extends StatefulWidget {
  const PlaybackWidget({super.key});

  @override
  State<PlaybackWidget> createState() => _PlaybackWidgetState();
}

double playCursor = 0;
bool change_music = false;
ValueNotifier<double> playCursorNotifier = ValueNotifier<double>(playCursor);
Timer? timerPlay;

class _PlaybackWidgetState extends State<PlaybackWidget> {
  late int overlayId;
  @override
  void initState() {
    super.initState();
    notPlaying = false;
    cpp.loadLibrary();
    cpp.initializeLibraryFunctions();
    //cpp.initializ
    //if(overlayId != 1)eGlobal();
    overlayId = -1;
  }

  double pl = 50.0;

  @override
  void dispose() {
    super.dispose();
    cpp.disposeSoundData();

    // initialized = false;
    //cpp.disposeGlobal();
  }

  // bool changing = false;
  bool eq = false;
  //                                             double subBassGain = cpp.subBassGain.value;
  //  double bassGain = cpp.bassGain.value;
  //         double lowMidrangeGain = cpp.lowMidrangeGain.value;
  //         double midrangeGain = cpp.midrangeGain.value;
  //         double upperMidsGain = cpp.upperMidsGain.value;
  //         double highMidsGain = cpp.highMidsGain.value;
  //         double trebleGain = cpp.trebleGain.value;
  @override
  Widget build(BuildContext context) {
    playCursorNotifier.value = 0;
    return ValueListenableBuilder(
      valueListenable: currentMeta,
      builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: currentMusic,
          builder: (context, value, child) {
            // print("${currentMusic.value.$1} ${!running.value || change_music}");
            if (currentMusic.value.$1 != -1) {
              if ((!running.value) || change_music) {
                // debugPrint(started.toString());
                started = started ? !started : started;
                // debugPrint(running.value.toString());
                // print("Before Build finished");
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  playerRefresher.value = !playerRefresher.value;
                });
                // print("Build finished");
                // initialized = change_music ? true : false;
                change_music = false;
              }
              // cpp.getElapsedTime().toDouble();
              timerPlay = Timer.periodic(Duration(seconds: 1), (timer) async {
                if (!changing) {
                  if (initialized) {
                    double time = cpp.getElapsedTime().toDouble();
                    playCursorNotifier.value = time;
                  } else {
                    playCursorNotifier.value = .0;
                  }
                }
                if ((playCursorNotifier.value ==
                        currentMeta.value.$5.toDouble()) &&
                    started) {
                  // print(
                  // '${playCursorNotifier.value} ${currentMeta.value.$5} yo yo',
                  // );

                  started = false;
                  // timerPlay?.cancel();
                  // timerPlay = null;
                  // print(running.value);
                  // print("length ${musics.length}");
                  if (musics.isNotEmpty) {
                    // print(musics.length);
                    String tag = '';
                    for (var i = 0; i < 3; i++) {
                      // print("man ahhh ${selected[i + 1]}");
                      if (selected[i + 1] == true) {
                        switch (i) {
                          case 0:
                            tag = currentMeta.value.$2;
                            break;
                          case 1:
                            tag = currentMeta.value.$3;
                            break;
                          case 2:
                            tag = currentMeta.value.$4;
                            break;
                          default:
                        }
                        // print(
                        //   "mapped $tag ${currentMusic.value.$1}",
                        // );
                        // print(
                        //   "mapped aa ${}",
                        // );
                        // mappedNotifier
                        //     .value[mappedNotifier.value.keys.elementAt(currentMusic.value.$1)]
                        //     ?.elementAt(i);
                      }
                    }
                    // print("tag ${mapIndexes[tag]}");
                    // print(mapIndexes[tag]!.firstWhere(
                    //           (index) => index > currentMusic.value.$1,
                    //           orElse: () => mapIndexes[tag]!.first,
                    //         ));
                    late MusicCardWidget music;
                    if (shuffleNotifier.value) {
                      print(listShuffled[-1]);
                      music =
                          musics[(listShuffled[listShuffled[-1]! + 1]) ??
                              0.clamp(0, musics.length)];
                      listShuffled[-1] = listShuffled[-1]! + 1;
                      // int i = (listShuffled.indexWhere(
                      //       (path) => path == currentMusic.value.$2,
                      //     ) +
                      //     1).clamp(0, musics.length);
                      //     print(listShuffled[i]);
                      //     print(listShuffled[i+1]);
                      //     print(listShuffled[i-1]);
                    } else {
                      music =
                          musics[(selected.last
                                  ? mapIndexes[tag]!.firstWhere(
                                    (index) => index > currentMusic.value.$1,
                                    orElse: () => mapIndexes[tag]!.first,
                                  )
                                  : currentMusic.value.$1 + 1)
                              .clamp(0, musics.length)];
                    }
                    // print("ids ${music.id} ");
                    List<String> tagList = ["artist", "album", "genre"];
                    // for (var i = 0; i < 3; i++) {
                    //   if (selected[i + 1] == true) {
                    //     print(
                    //       "mapped ${mappedNotifier.value[tagList[i]]?.elementAt(currentMusic.value.$1 % (i))['soundPath']}",
                    //     );
                    //     // mappedNotifier
                    //     //     .value[mappedNotifier.value.keys.elementAt(currentMusic.value.$1)]
                    //     //     ?.elementAt(i);
                    //   }
                    // }
                    currentMusic.value = (
                      music.id,
                      music.soundPath,
                      bytesData.buffer.asUint8List(),
                    );
                    // print(
                    // "true Too ${currentMusic.value.$1 + 1} ${music.soundPath}",
                    // );
                  }
                  notPlaying = false;
                  playerRefresher.value = !playerRefresher.value;
                }
              });
            }
            // MusicCardWidget music = musics[currentMusic.value.$1 + 1];
            Timer.periodic(Duration(seconds: 2), (_) {
              List<String> tagList = ["artist", "album", "genre"];
              String tag = '';
              for (var i = 0; i < 3; i++) {
                // print("man ahhh ${selected[i + 1]}");
                if (selected[i + 1] == true) {
                  switch (i) {
                    case 0:
                      tag = currentMeta.value.$2;
                      break;
                    case 1:
                      tag = currentMeta.value.$3;
                      break;
                    case 2:
                      tag = currentMeta.value.$4;
                      break;
                    default:
                  }
                  // print(
                  //   "mapped $tag ${currentMusic.value.$1}",
                  // );
                  // print(
                  //   "mapped aa ${}",
                  // );
                  // mappedNotifier
                  //     .value[mappedNotifier.value.keys.elementAt(currentMusic.value.$1)]
                  //     ?.elementAt(i);
                }
              }
            });

            // print("${currentMusic.value.$2}  ${currentMeta.value.$1}");
            return Container(
              color: Color(0xffcd7b38),
              // height: MediaQuery.of(context).size.height * .23,
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Column(
                        spacing: 0,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width / 3 - 150,
                                child: Column(
                                  spacing: 10,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currentMeta.value.$1 == ""
                                          ? "--"
                                          : currentMeta.value.$1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      [
                                        currentMeta.value.$2 == ""
                                            ? "—"
                                            : currentMeta.value.$2,
                                        currentMeta.value.$3 == ""
                                            ? "—"
                                            : currentMeta.value.$3,
                                      ].join(" - "),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(7.0),
                                ),
                                child: Container(
                                  color: Color(0xff523116),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: MaterialButton(
                                      onPressed: () {
                                        shuffleNotifier.value =
                                            !shuffleNotifier.value;
                                        List<int> indexed =
                                            listAll
                                                .asMap()
                                                .entries
                                                .map((e) => e.key)
                                                .toList();
                                        indexed.shuffle();
                                        for (
                                          var i = 0;
                                          i < indexed.length;
                                          i++
                                        ) {
                                          listShuffled[i] = indexed[i];
                                        }
                                        listShuffled[-1] = -1;
                                      },
                                      child: Row(
                                        spacing: 5,
                                        children: [
                                          Center(
                                            child: Image.asset(
                                              "assets/icons/shuffle.png",
                                              height: 40,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 30,
                                            child: VerticalDivider(
                                              thickness: 2,
                                              width: 2,
                                              color: Color(0xffcd7b38),
                                            ),
                                          ),
                                          Center(
                                            child: Image.asset(
                                              "assets/icons/arrow-up.png",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  MaterialButton(
                                    onPressed:
                                        currentMusic.value.$1 == -1
                                            ? null
                                            : () async {
                                              started = false;
                                              timerPlay?.cancel();
                                              // timerPlay = null;
                                              // print(running.value);
                                              // print(musics.length);
                                              if (musics.isNotEmpty) {
                                                // print(musics.length);
                                                String tag = '';
                                                for (var i = 0; i < 3; i++) {
                                                  // print("man ahhh ${selected[i + 1]}");
                                                  if (selected[i + 1] == true) {
                                                    switch (i) {
                                                      case 0:
                                                        tag =
                                                            currentMeta
                                                                .value
                                                                .$2;
                                                        break;
                                                      case 1:
                                                        tag =
                                                            currentMeta
                                                                .value
                                                                .$3;
                                                        break;
                                                      case 2:
                                                        tag =
                                                            currentMeta
                                                                .value
                                                                .$4;
                                                        break;
                                                      default:
                                                    }
                                                    // print(
                                                    //   "mapped $tag ${currentMusic.value.$1}",
                                                    // );
                                                    // print(
                                                    //   "mapped aa ${}",
                                                    // );
                                                    // mappedNotifier
                                                    //     .value[mappedNotifier.value.keys.elementAt(currentMusic.value.$1)]
                                                    //     ?.elementAt(i);
                                                  }
                                                }
                                                late MusicCardWidget music;
                                                if (shuffleNotifier.value) {
                                                  music =
                                                      musics[(listShuffled[listShuffled[-1]! -
                                                              1]) ??
                                                          0.clamp(
                                                            0,
                                                            musics.length,
                                                          )];
                                                  listShuffled[-1] =
                                                      listShuffled[-1]! - 1;
                                                } else {
                                                  music =
                                                      musics[(selected.last
                                                              ? mapIndexes[tag]!.lastWhere(
                                                                (index) =>
                                                                    index <
                                                                    currentMusic
                                                                        .value
                                                                        .$1,
                                                                orElse:
                                                                    () =>
                                                                        mapIndexes[tag]!
                                                                            .first,
                                                              )
                                                              : currentMusic
                                                                      .value
                                                                      .$1 -
                                                                  1)
                                                          .clamp(
                                                            0,
                                                            musics.length,
                                                          )];
                                                }
                                                //                         MusicCardWidget music =
                                                //                             musics[currentMusic.value.$1 > 0
                                                //                                 ? currentMusic.value.$1 - 1
                                                //                                 : 0];
                                                currentMusic.value = (
                                                  music.id,
                                                  music.soundPath,
                                                  bytesData.buffer
                                                      .asUint8List(),
                                                );
                                                print(
                                                  "true Too ${currentMusic.value.$1} ${music.soundPath}",
                                                );
                                              }
                                              playerRefresher.value =
                                                  !playerRefresher.value;
                                            },
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child:
                                            currentMusic.value.$1 == -1
                                                ? Image.asset(
                                                  color: const Color.fromARGB(
                                                    148,
                                                    82,
                                                    49,
                                                    22,
                                                  ),
                                                  "assets/icons/previous.png",
                                                )
                                                : Image.asset(
                                                  "assets/icons/previous.png",
                                                ),
                                      ),
                                    ),
                                  ),
                                  MaterialButton(
                                    onPressed:
                                        currentMusic.value.$1 == -1
                                            ? null
                                            : () {
                                              Future.microtask(
                                                () => seek(false),
                                              );
                                              playCursorNotifier.value =
                                                  playCursorNotifier.value -
                                                              10 <
                                                          0.0
                                                      ? 0.0
                                                      : playCursorNotifier
                                                              .value -
                                                          10.0;
                                              // print(playCursorNotifier.value);
                                            },
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child:
                                            currentMusic.value.$1 == -1
                                                ? Image.asset(
                                                  "assets/icons/backward.png",
                                                  color: const Color.fromARGB(
                                                    148,
                                                    82,
                                                    49,
                                                    22,
                                                  ),
                                                )
                                                : Image.asset(
                                                  "assets/icons/backward.png",
                                                ),
                                      ),
                                    ),
                                  ),
                                  MaterialButton(
                                    onPressed:
                                        currentMusic.value.$1 == -1
                                            ? null
                                            : () {
                                              if (started = false) {
                                                started = true;
                                              }
                                              pause(notPlaying);
                                            },
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child:
                                            currentMusic.value.$1 == -1
                                                ? Image.asset(
                                                  "assets/icons/play.png",
                                                  color: const Color.fromARGB(
                                                    148,
                                                    82,
                                                    49,
                                                    22,
                                                  ),
                                                  height: 70,
                                                )
                                                : Image.asset(
                                                  "assets/icons/play.png",
                                                  height: 70,
                                                ),
                                      ),
                                    ),
                                  ),
                                  MaterialButton(
                                    onPressed:
                                        currentMusic.value.$1 == -1
                                            ? null
                                            : () {
                                              Future.microtask(
                                                () => seek(true),
                                              );
                                              playCursorNotifier.value =
                                                  playCursorNotifier.value +
                                                              10 <
                                                          currentMeta.value.$5
                                                              .toDouble()
                                                      ? playCursorNotifier
                                                              .value +
                                                          10
                                                      : currentMeta.value.$5
                                                          .toDouble();
                                            },
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child:
                                            currentMusic.value.$1 == -1
                                                ? Image.asset(
                                                  "assets/icons/forward.png",
                                                  color: const Color.fromARGB(
                                                    148,
                                                    82,
                                                    49,
                                                    22,
                                                  ),
                                                )
                                                : Image.asset(
                                                  "assets/icons/forward.png",
                                                ),
                                      ),
                                    ),
                                  ),
                                  MaterialButton(
                                    onPressed:
                                        currentMusic.value.$1 == -1
                                            ? null
                                            : () {
                                              Future.microtask(() {
                                                cpp.seekToEnd();
                                              });
                                            },
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child:
                                            currentMusic.value.$1 == -1
                                                ? Image.asset(
                                                  "assets/icons/next.png",
                                                  color: const Color.fromARGB(
                                                    148,
                                                    82,
                                                    49,
                                                    22,
                                                  ),
                                                )
                                                : Image.asset(
                                                  "assets/icons/next.png",
                                                ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      MaterialButton(
                                        onPressed: () {
                                          // print("Pressed listening");
                                          // print("PageId ${pageIdNotifier.value}");
                                          pageIdNotifier.value =
                                              pageIdNotifier.value != -1
                                                  ? (pageIdNotifier.value != 0
                                                      ? 0
                                                      : -1)
                                                  : 0;
                                          // print("PageId ${pageIdNotifier.value}");
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Image.asset(
                                            "assets/icons/listening_play.png",
                                          ),
                                        ),
                                      ),
                                      MaterialButton(
                                        onPressed:
                                            currentMusic.value.$1 == -1
                                                ? null
                                                : () {
                                                  // print("Pressed eq");
                                                  // print("PageId ${pageIdNotifier.value}");
                                                  pageIdNotifier.value =
                                                      pageIdNotifier.value != -1
                                                          ? (pageIdNotifier
                                                                      .value !=
                                                                  1
                                                              ? 1
                                                              : -1)
                                                          : 1;
                                                  // print("PageId ${pageIdNotifier.value}");
                                                },
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child:
                                              currentMusic.value.$1 == -1
                                                  ? Image.asset(
                                                    "assets/icons/settings.png",
                                                    color: const Color.fromARGB(
                                                      148,
                                                      82,
                                                      49,
                                                      22,
                                                    ),
                                                  )
                                                  : Image.asset(
                                                    "assets/icons/settings.png",
                                                  ),
                                        ),
                                      ),
                                      // MaterialButton(
                                      //   onPressed:
                                      //       currentMusic.value.$1 == -1
                                      //           ? null
                                      //           : () {
                                      //             // print("Pressed Lyrics");
                                      //             // print("PageId ${pageIdNotifier.value}");
                                      //             pageIdNotifier.value =
                                      //                 pageIdNotifier.value != -1
                                      //                     ? (pageIdNotifier.value !=
                                      //                             2
                                      //                         ? 2
                                      //                         : -1)
                                      //                     : 2;
                                      //             // print("PageId ${pageIdNotifier.value}");
                                      //           },
                                      //   child: Padding(
                                      //     padding: const EdgeInsets.all(5.0),
                                      //     child:
                                      //         currentMusic.value.$1 == -1
                                      //             ? Image.asset(
                                      //               "assets/icons/lyrics.png",
                                      //               color: const Color.fromARGB(
                                      //                 148,
                                      //                 82,
                                      //                 49,
                                      //                 22,
                                      //               ),
                                      //             )
                                      //             : Image.asset(
                                      //               "assets/icons/lyrics.png",
                                      //             ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  UpdatingSliderWidget(),
                                ],
                              ),
                            ],
                          ),

                          currentMeta.value.$5 != -1
                              ? PlaybackSliderWidget()
                              : SizedBox(
                                width: MediaQuery.of(context).size.width * .8,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [Text("--:--"), Text("--:--")],
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    width: 35,
                    height: 35,
                    child: Tooltip(
                      message: "Stop music",
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (initialized) {
                            started = false;
                            // print("Disposing");
                            running.value = false;
                            // await Future.delayed(Duration(milliseconds: 500));
                            disposeSoundData();
                            // running.value = false;
                            initialized = false;
                            timerPlay?.cancel();
                            // timerPlay = null;
                            // print("Dispose");
                          }
                          currentMusic.value = (-1, "", Uint8List(0));
                          currentMeta.value=(
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
                        },
                        icon: Icon(Icons.close_rounded, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Color(0x88523116),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

void pause(bool isnotPlaying) {
  cpp.pauseSound(isnotPlaying);

  // print(notPlaying);
  notPlaying = !notPlaying;
  // print(notPlaying);
}

void seek(bool frame) {
  cpp.seekFrames(frame);
}

bool started = false;
