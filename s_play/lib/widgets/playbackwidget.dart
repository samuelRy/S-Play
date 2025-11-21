import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:s_play/music_data.dart';
import 'package:s_play/widgets/music_card.dart' hide playCurrent;
import 'package:s_play/widgets/settings.dart';
import 'package:s_play/widgets/sidepanel.dart';

import '../cpp_import_playback.dart' as cpp;

class PlaybackWidget extends StatefulWidget {
  const PlaybackWidget({super.key});

  @override
  State<PlaybackWidget> createState() => _PlaybackWidgetState();
}

double playCursor = 0;
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
    //cpp.disposeGlobal();
  }

  bool changing = false;
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
      valueListenable: currentMusic,
      builder: (context, value, child) {
        // print(currentMusic.value.$1);
        if (currentMusic.value.$1 != -1) {
          timerPlay = Timer.periodic(Duration(seconds: 1), (timer) {
            if (!changing) {
              playCursorNotifier.value = cpp.getElapsedTime().toDouble();
            }
          });
        }
        // print("${currentMusic.value.$2}  ${currentMeta.value.$1}");
        return ValueListenableBuilder(
          valueListenable: currentMeta,
          builder: (context, value, child) {
            return Container(
              color: Color(0xffcd7b38),
              height: MediaQuery.of(context).size.height * .20,
              child: Center(
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
                            width: MediaQuery.of(context).size.width / 3 - 150,
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
                                          int newVal =
                                              currentMusic.value.$1 - 1;
                                          String soundPath =
                                              musics[newVal >= 0 ? newVal : 0]
                                                  .soundPath;
                                          Metadata meta =
                                              await MetadataGod.readMetadata(
                                                file: soundPath,
                                              );
                                          ByteData bytesData = await rootBundle
                                              .load("assets/icons/music.png");
                                          playCurrent(
                                            newVal >= 0 ? newVal : 0,
                                            soundPath,
                                            meta.picture != null
                                                ? meta.picture!.data
                                                : bytesData.buffer
                                                    .asUint8List(),
                                          );
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
                                          Future.microtask(() => seek(false));
                                          playCursorNotifier.value -= 10;
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
                                          // print(notPlaying);
                                          notPlaying = !notPlaying;
                                          // print(notPlaying);
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
                                          Future.microtask(() => seek(true));
                                          playCursorNotifier.value =
                                              playCursorNotifier.value + 10 <
                                                      currentMeta.value.$6
                                                          .toDouble()
                                                  ? playCursorNotifier.value +
                                                      10
                                                  : currentMeta.value.$6
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
                          Row(
                            children: [
                              MaterialButton(
                                onPressed: () {
                                  // print("Pressed listening");
                                  // print("PageId ${pageIdNotifier.value}");
                                  pageIdNotifier.value =
                                      pageIdNotifier.value != -1
                                          ? (pageIdNotifier.value != 0 ? 0 : -1)
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
                                                  ? (pageIdNotifier.value != 1
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
                              MaterialButton(
                                onPressed:
                                    currentMusic.value.$1 == -1
                                        ? null
                                        : () {
                                          // print("Pressed Lyrics");
                                          // print("PageId ${pageIdNotifier.value}");
                                          pageIdNotifier.value =
                                              pageIdNotifier.value != -1
                                                  ? (pageIdNotifier.value != 2
                                                      ? 2
                                                      : -1)
                                                  : 2;
                                          // print("PageId ${pageIdNotifier.value}");
                                        },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child:
                                      currentMusic.value.$1 == -1
                                          ? Image.asset(
                                            "assets/icons/lyrics.png",
                                            color: const Color.fromARGB(
                                              148,
                                              82,
                                              49,
                                              22,
                                            ),
                                          )
                                          : Image.asset(
                                            "assets/icons/lyrics.png",
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      currentMeta.value.$5 != -1
                          ? ValueListenableBuilder(
                            valueListenable: playCursorNotifier,
                            builder: (context, value, child) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatDuration(
                                      Duration(
                                        seconds:
                                            playCursorNotifier.value.round(),
                                      ),
                                    ),

                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .8,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Slider(
                                        value: playCursorNotifier.value,
                                        onChanged: (value) {
                                          playCursorNotifier.value = value;
                                        },
                                        label:
                                            playCursorNotifier.value
                                                .round()
                                                .toString(),
                                        max: currentMeta.value.$6.toDouble(),
                                        activeColor: Color(0xff523116),
                                        inactiveColor: Colors.white,
                                        thumbColor: Color.fromARGB(
                                          155,
                                          162,
                                          97,
                                          44,
                                        ),
                                        onChangeEnd: (value) {
                                          playCursorNotifier.value = value;
                                          cpp.seekToFrames(value.toInt());
                                          setState(() {
                                            playCursorNotifier.value = value;
                                          });
                                          changing = false;
                                        },
                                        onChangeStart: (value) {
                                          changing = true;
                                        },
                                      ),
                                    ),

                                    /*Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Divider(
                                            color: Colors.white,
                                            height: 5,
                                            thickness: 2,
                                            
                                          ),
                                        ),
                                        /* FractionallySizedBox(
                                                heightFactor: playCursor/currentMeta.value.duration!.inSeconds,
                                              )*/
                                        Positioned(
                                          right: double.minPositive,
                                          child: Padding(
                                            padding: const EdgeInsets.all(7.5),
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color.fromARGB(
                                                  167,
                                                  162,
                                                  97,
                                                  44,
                                                ),
                                                border: Border.all(
                                                  color: Color(0xff523116),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )*/
                                  ),
                                  Text(
                                    formatDuration(
                                      Duration(seconds: currentMeta.value.$6),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                          : SizedBox(
                            width: MediaQuery.of(context).size.width * .8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [Text("--:--"), Text("--:--")],
                            ),
                          ),
                    ],
                  ),
                ),
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
}

void seek(bool increase) {
  cpp.seekFrames(increase);
}

void volume(bool increase) {
  cpp.modifyVolume(increase);
}
