import 'dart:ui';
import 'dart:async';
import 'package:audiotags/audiotags.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s_play/cpp_import_playback.dart';
import 'package:s_play/music_data.dart';
import 'package:s_play/widgets/playbackwidget.dart';
import 'package:s_play/widgets/sidepanel.dart';

class MusicCardWidget extends StatefulWidget {
  const MusicCardWidget({super.key, required this.soundPath, required this.id});
  final String soundPath;
  final int id;

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
  List<Picture>? img;

  /*assetToUint8List('assets/images/image.png').then((
                            imageBytes,
                          ) {
                            img = Picture(data: imageBytes, mimeType: "image/png");
                          });*/
  late Tag? tagD;

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
      Tag? tag = await AudioTags.read(soundPath);

      if (mounted) {
        setState(() {
          tagD = tag;
          if (tagD?.pictures != null) {
            img = tagD?.pictures;
          } else {
            img = [
              Picture(
                pictureType: PictureType.coverBack,
                mimeType: MimeType.png,
                bytes: bytesData.buffer.asUint8List(),
              ),
            ];
          }
          // debugPrint(metaD.year.toString());
          // print("mm ${metaD.title.toString()}");

          // print(soundPath);
          album = tagD?.album.toString() ?? "";
          artist = tagD?.trackArtist ?? "Unknown";
          if (tagD?.year != null) {
            year = tagD?.year!.toInt() ?? -1;
          }
          genre = tagD?.genre.toString() ?? "";
          title =
              tagD?.title.toString() == ""
                  ? "Unknown"
                  : tagD?.title.toString() ?? "";
          duration = tagD?.duration ?? -1;

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

  @override
  Widget build(BuildContext context) {
    // print("building");
    MemoryImage imageMemory = MemoryImage(
      img?.first.bytes ?? Uint8List(0),
      scale: 3,
    );
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
                          // print("faaaah");
                          changeMusic = true;
                          started = false;
                          currentMusic.value = (
                            widget.id,
                            widget.soundPath,
                            img?.first.bytes ?? Uint8List(0),
                          );
                          if (shuffleNotifier.value) {
                            listShuffled.forEach((key, value){
                              if (value==widget.id) {
                                listShuffled[-1] = key;
                              }
                            });
                          }
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
                                horizontal: 7,
                                vertical: 5,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    // spacing: 20,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 5.0,
                                          children: [
                                            Tooltip(
                                              message: title,
                                              textStyle: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                                decoration:
                                                    TextDecoration.none,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                    255,
                                                    100,
                                                    49,
                                                    8,
                                                  ),
                                                ),
                                                color: Color.fromARGB(
                                                  118,
                                                  165,
                                                  99,
                                                  45,
                                                ),
                                              ),
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
                                            Tooltip(
                                              message: [
                                                artist,
                                                album,
                                              ].join(" - "),
                                              textStyle: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                                decoration:
                                                    TextDecoration.none,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                    255,
                                                    100,
                                                    49,
                                                    8,
                                                  ),
                                                ),
                                                color: Color.fromARGB(
                                                  118,
                                                  165,
                                                  99,
                                                  45,
                                                ),
                                              ),
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
                                      Expanded(
                                        flex: 1,
                                        child: Column(
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
    // started = false;
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