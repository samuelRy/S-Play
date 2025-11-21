import 'dart:ui';
import 'dart:async';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:metadata_god/metadata_god.dart';

import 'package:flutter/material.dart';
import 'package:s_play/cpp_import_playback.dart';
import 'package:s_play/music_data.dart';
import 'package:s_play/widgets/playbackwidget.dart';
import 'package:s_play/widgets/sidepanel.dart';

class MusicCardWidget extends StatefulWidget {
  const MusicCardWidget({
    super.key,
    required this.soundPath,
    required this.id,
    required this.play,
  });
  final String soundPath;
  final int id;
  final Function play;

  @override
  State<MusicCardWidget> createState() => _MusicCardWidgetState();
}

class _MusicCardWidgetState extends State<MusicCardWidget> {
  late final String path;
  String album = "Unknown";
  String genre = "Unknown";
  String title = "Unknown";
  String artist = "Unknown";
  int year = -1;
  int duration = 00;
  Uint8List? img;

  /*assetToUint8List('assets/images/image.png').then((
                            imageBytes,
                          ) {
                            img = Picture(data: imageBytes, mimeType: "image/png");
                          });*/
  late Metadata metaD;

  @override
  void initState() {
    super.initState();
    path = widget.soundPath;
    // print(
    //   "${widget.id}",
    // );

    initA(widget.soundPath);
  }

  Future<void> initA(String soundPath) async {
    // debugPrint("INIT");

    return WidgetsBinding.instance.addPostFrameCallback((_) async {
      // debugPrint("gg$soundPath");
      Metadata meta = await MetadataGod.readMetadata(file: soundPath);
      ByteData bytesData = await rootBundle.load("assets/icons/music.png");

      if (mounted) {
        setState(() {
          metaD = meta;
          if (metaD.picture != null) {
            img = metaD.picture!.data;
          } else {
            img = bytesData.buffer.asUint8List();
          }
          // debugPrint(metaD.year.toString());
          // print("mm ${metaD.title.toString()}");

          // print(soundPath);
          album = metaD.album.toString();
          artist = metaD.artist ?? "Unknown";
          if (metaD.year != null) {
            year = metaD.year!.toInt();
          }
          genre = metaD.genre.toString();
          title =
              metaD.title.toString() == "" ? "Unknown" : metaD.title.toString();
          duration = metaD.duration!.inSeconds;

          playListAll.audios[soundPath] = [
            {"artist": artist, "album": album, "genre": genre},
          ];
          //currentMeta.value = (title, artist, album, genre, (metaD.durationMs??-1.0).toInt(), duration, img??Uint8List(0));
          if (!artists.contains(artist)) {
            artists.add(artist);
          }
          if (!albums.contains(album)) {
            albums.add(album);
          }
          if (!artists.contains(genre)) {
            genres.add(genre);
          }
          // print("all $album $artist $title $genre $year $duration");
        });
      }
    });
    //
  }

  OverlayEntry? overlay;
  Timer? timer;
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    // print("building");
    MemoryImage imageMemory = MemoryImage(img??Uint8List(0), scale: 3);
    return Flex(
      direction: Axis.horizontal,

      children: [
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(
              children: [
                // Blured music's image
                SizedBox(
                  width: double.maxFinite,
                  height: 70,
                  child: Opacity(
                    opacity: 0.6,
                    child: Stack(
                      children: [
                        Center(
                          child:
                              img == null
                                  ? SizedBox()
                                  : ClipRRect(
                                    clipBehavior: Clip.hardEdge,
                                    child: Image(
                                      image: imageMemory,
                                      fit: BoxFit.none,
                                      width: double.infinity,
                                      height: 400,
                                      filterQuality: FilterQuality.low,
                                    ),
                                  ),
                        ),
                        Center(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                            child: Container(
                              width: double.maxFinite,
                              height: double.maxFinite,
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  spacing: 10,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      child: MaterialButton(
                        onPressed: () {
                          currentMusic.value = (
                            widget.id,
                            widget.soundPath,
                            img!,
                          );
                          widget.play(
                            widget.id,
                            widget.soundPath,
                            img ?? Uint8List(0),
                          );
                        },
                        child: ValueListenableBuilder(
                          valueListenable: currentMusic,
                          builder: (context, value, child) {
                            return Container(
                              height: 70,
                              color:
                                  currentMusic.value.$2 == widget.soundPath
                                      ? Color.fromARGB(83, 205, 123, 56)
                                      : Color.fromARGB(26, 205, 123, 56),
                              padding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 5,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 5.0,
                                          children: [
                                            MouseRegion(
                                              onHover: (event) {
                                                isHovered = true;
                                                RenderBox box =
                                                    context.findRenderObject()
                                                        as RenderBox;
                                                // print(
                                                //   "hover browww ${event.delta.dy} ${event.localPosition.dy} ${event.position.dy} ${box.localToGlobal(event.localPosition).dx}",
                                                // );

                                                if (overlay == null) {
                                                  Offset mouseOffset = box
                                                      .localToGlobal(
                                                        event.localPosition,
                                                      );
                                                  Future.microtask(() async {
                                                    timer = Timer(
                                                      Duration(seconds: 1),
                                                      () {
                                                        if (overlay != null ||
                                                            !isHovered) {
                                                          return;
                                                        }
                                                        //print("hover pop browww");
                                                        overlay = getOverlay(
                                                          title,
                                                          mouseOffset,
                                                        );
                                                        Overlay.of(
                                                          context,
                                                        ).insert(overlay!);
                                                      },
                                                    );
                                                  });
                                                }
                                              },
                                              onExit: (event) {
                                                isHovered = false;
                                                if (overlay != null) {
                                                  // print("disapear");
                                                  overlay?.remove();
                                                  Overlay.of(
                                                    context,
                                                  ).didChangeDependencies();
                                                  overlay?.dispose();
                                                  timer?.cancel();
                                                }
                                                overlay = null;
                                                timer = null;
                                              },

                                              child: Text(
                                                title,
                                                style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 24,
                                                  fontFamily: "Merienda",
                                                  fontWeight: FontWeight.w900,
                                                ),
                                                maxLines: 1,
                                              ),
                                            ),
                                            MouseRegion(
                                              onHover: (event) {
                                                isHovered = true;
                                                RenderBox box =
                                                    context.findRenderObject()
                                                        as RenderBox;
                                                // print(
                                                //   "hover browww ${event.delta.dy} ${event.localPosition.dy} ${event.position.dy} ${box.localToGlobal(event.localPosition).dx}",
                                                // );

                                                if (overlay == null) {
                                                  Offset mouseOffset = box
                                                      .localToGlobal(
                                                        event.localPosition,
                                                      );
                                                  Future.microtask(() async {
                                                    timer = Timer(
                                                      Duration(seconds: 1),
                                                      () {
                                                        if (overlay != null ||
                                                            !isHovered) {
                                                          return;
                                                        }
                                                        //print("hover pop browww");
                                                        overlay = getOverlay(
                                                          [
                                                            artist,
                                                            album,
                                                          ].join(" - "),
                                                          mouseOffset,
                                                        );
                                                        Overlay.of(
                                                          context,
                                                        ).insert(overlay!);
                                                      },
                                                    );
                                                  });
                                                }
                                              },
                                              onExit: (event) {
                                                isHovered = false;
                                                if (overlay != null) {
                                                  // print("disapear");
                                                  overlay?.remove();
                                                  Overlay.of(
                                                    context,
                                                  ).didChangeDependencies();
                                                  overlay?.dispose();
                                                  timer?.cancel();
                                                }
                                                overlay = null;
                                                timer = null;
                                              },
                                              child: Text(
                                                maxLines: 1,
                                                [artist, album].join(" - "),
                                                style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 12,
                                                  fontFamily: "Merienda",
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 100),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        spacing: 5.0,
                                        children: [
                                          Text(
                                            genre,
                                            style: TextStyle(
                                              overflow: TextOverflow.clip,
                                              fontSize: 13,
                                              fontFamily: "Fasthand",
                                            ),
                                          ),
                                          Text(
                                            formatDuration(
                                              Duration(seconds: duration),
                                            ),
                                            style: TextStyle(
                                              overflow: TextOverflow.clip,
                                              fontSize: 13,
                                              fontFamily: "Fasthand",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$minutes:$seconds';
}

Future<Uint8List> assetToUint8List(String assetPath) {
  return rootBundle.load(assetPath).then((byteData) {
    return byteData.buffer.asUint8List();
  });
}


class PlaybackController extends ChangeNotifier {
  int currentIndex = -1;
}

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

OverlayEntry getOverlay(String label, Offset offset) {
  return OverlayEntry(
    builder: (context) {
      return Positioned(
        left: offset.dx + 15,
        top: offset.dy + 25,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 100, 49, 8)),
            color: Color.fromARGB(118, 165, 99, 45),
          ),
          padding: EdgeInsets.all(1.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: const Color.fromARGB(255, 255, 196, 128),
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );
    },
  );
}
