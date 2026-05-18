import 'dart:async';
import 'dart:ffi' hide Size;

import 'package:audiotags/audiotags.dart';
import 'package:ffi/ffi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s_play/cpp_import_playback.dart';
import 'package:s_play/music_data.dart';
import 'package:s_play/widgets/playbackwidget.dart';
import 'package:s_play/widgets/text_button.dart';

import 'music_card.dart';

class SidePanelWidget extends StatefulWidget {
  const SidePanelWidget({super.key});

  @override
  State<SidePanelWidget> createState() => _SidePanelWidgetState();
}

List<String> artists = [];
List<String> albums = [];
List<String> genres = [];
bool shuffled = false;
ValueNotifier shuffleNotifier = ValueNotifier(shuffled);

class _SidePanelWidgetState extends State<SidePanelWidget> {
  List<bool> selected = [true, false, false, false, false];
  List<bool> isSelected = [true, false];

  bool update(int index) {
    for (var i = 1; i < 4; i++) {
      // print("$i $index");
      if (i == index) {
        // print("change ${selected[index]}");
        selected[index] = !selected[index];
        // print("change ${selected[index]}");
      } else {
        selected[i] = false;
      }
    }
    setState(() {});
    // print(selected);
    return selected[index];
  }

  void playCurrent(int index, String soundPath, List<Picture> img) {
    currentMusic.value = (index, soundPath, img.first.bytes);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //debugPrint("gg$soundPath");
      Tag? tag = await AudioTags.read(soundPath);
      ByteData bytesData = await rootBundle.load("assets/icons/music.png");

      if (mounted) {
        setState(() {
          
          if (tag?.pictures != null) {
            img = tag!.pictures;
          } else {
            img = [Picture(pictureType: PictureType.coverBack, mimeType: MimeType.png, bytes:bytesData.buffer.asUint8List())];
          }
          // print("mm ${meta.title.toString()}");

          // print(soundPath);
          var album = tag?.album.toString();
          var artist = tag?.trackArtist ?? "Unknown";
          var genre = tag?.genre.toString();
          var title =
              tag?.title.toString() == "" ? "Unknown" : tag?.title.toString();
          var duration = tag?.duration;

          playListAll.audios[soundPath] = [
            {"artist": artist, "album": album??"", "genre": genre??""},
          ];
          currentMeta.value = (
            title??"",
            artist,
            album??"",
            genre??"",
            duration??-1,
            img.first,
          );

          //print("all $album $artist $title $genre ${meta.year!.toInt()} $duration");
        });
      }
    });
    setState(() {
      // print("true Too ${musics.length} ${index + 1} $index");
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
      });
    });
  }

  List<String> listAll = [];
  void timerRunning(int i, String path, List<Picture> img) {
    listAll = mapList(playListAll.audios.keys);

    //  print("${currentMusic.value.$1}    ${currentMusic.value.$2}");
    playCurrent(i, path, img);
    // print(
    //   "true Too ${listAll.length} ${currentMusic.value.$1 + 1} ${listAll[currentMusic.value.$1+1]}",
    // );
    Timer.periodic(Duration(milliseconds: 800), (timer) {
      // print("nextaar ${running.value}   ${currentMusic.value.$1}");

      if (!running.value) {
        // print(
        //   "true Too ${listAll.length} ${currentMusic.value.$1 + 1} ${listAll[currentMusic.value.$1+1]}",
        // );
        playCurrent(
          currentMusic.value.$1 + 1,
          listAll[currentMusic.value.$1 + 1 < listAll.length
              ? currentMusic.value.$1 + 1
              : 0],
          img,
        );
      }
    });
  }

  bool hidden = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializePlayList();

      if (mounted) {
        setState(() {
          // print("set");
        }); // Triggers rebuild with updated playlist
      }
    });
  }

  // Clean list creation process's map
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: mappedNotifier,
      builder: (context, value, child) {
        // print(mappedNotifier.value);
        return ValueListenableBuilder(
          valueListenable: shuffleNotifier,
          builder: (context, value, child) {
            // print("gh${playListAll.audios.length}");
            List<String> listAll =
                mappedNotifier.value.isEmpty
                    ? mapList(playListAll.audios.keys)
                    : [];
            List<String> listShuffled = [];
            listAll.sort();
            if (shuffleNotifier.value) {
              listShuffled = listAll;
              listShuffled.shuffle();
            }
            int k = listAll.isNotEmpty ? listAll.length : 0;
            void musicsInitD() {
              for (var i = 0; i < listAll.length; i++) {
                musics.add(
                  MusicCardWidget(
                    key: ValueKey(
                      shuffleNotifier.value ? listShuffled[i] : listAll[i],
                    ),
                    soundPath:
                        shuffleNotifier.value ? listShuffled[i] : listAll[i],
                    id: i,
                    play: timerRunning,
                  ),
                );
              }
            }

            void musicsInitM() {
              for (var j = 0; j < playListAll.audios.length; j++) {
                musics.add(
                  MusicCardWidget(
                    soundPath: playListAll.audios.keys.elementAt(j),
                    id: j,
                    play: timerRunning,
                  ),
                );
              }
            }

            ScrollController scrollController = ScrollController();
            ScrollController scrollMController = ScrollController();
            // scrollController.attach(ScrollPositionWithSingleContext(physics: BouncingScrollPhysics(), context: ScrollContext));
            List<Widget> children_ = [
              Container(
                decoration: BoxDecoration(
                  color:
                      isSelected[0]
                          ? Color.fromARGB(104, 205, 123, 56)
                          : Color.fromARGB(27, 205, 123, 56),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
                child: IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(side: BorderSide.none),
                    ),
                  ),
                  isSelected: isSelected[0],
                  onPressed: () {
                    isSelected[0] = true;
                    isSelected[1] = false;
                    setState(() {
                      // print(isSelected);
                      // print(
                      //   isSelected[0]
                      //       ? Color.fromARGB(40, 205, 123, 56)
                      //       : Color.fromARGB(27, 205, 123, 56),
                      // );
                      hidden = !hidden;
                      print(hidden);
                    });
                  },
                  splashRadius: 1,
                  constraints: BoxConstraints(),
                  icon: Image.asset("assets/icons/list_expand.png"),
                ),
              ),
            ];
            children_.addAll(
              hidden
                  ? []
                  : [
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isSelected[1]
                                ? Color.fromARGB(104, 205, 123, 56)
                                : Color.fromARGB(27, 205, 123, 56),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      child: IconButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(side: BorderSide.none),
                          ),
                        ),
                        isSelected: isSelected[1],
                        onPressed: () {
                          isSelected[1] = true;
                          isSelected[0] = false;
                          setState(() {
                            // print(isSelected);
                            // print(
                            //   isSelected[1]
                            //       ? Color.fromARGB(40, 205, 123, 56)
                            //       : Color.fromARGB(27, 205, 123, 56),
                            // );
                          });
                        },
                        splashRadius: 1,
                        constraints: BoxConstraints(),
                        icon: Image.asset("assets/icons/filter.png"),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isSelected[1]
                                ? Color.fromARGB(104, 205, 123, 56)
                                : Color.fromARGB(27, 205, 123, 56),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      child: IconButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(side: BorderSide.none),
                          ),
                        ),
                        isSelected: isSelected[1],
                        onPressed: () async {
                          String? directory =
                              await FilePicker.getDirectoryPath();
                          // print(directory ?? "");
                          if (directory != null &&
                              directory != "" &&
                              !(folders.contains(directory))) {
                            if (folders.isEmpty) {
                              folders = [directory];
                            } else {
                              folders.add(directory);
                            }
                            initializePlayList().then((value) {
                              setState(() {});
                            });
                          }
                        },
                        splashRadius: 1,
                        constraints: BoxConstraints(),
                        icon: Icon(Icons.add, color: Color(0xffa2602a)),
                      ),
                    ),
                  ],
            );
            return Stack(
              children: [
                Positioned(
                  left: hidden ? -MediaQuery.of(context).size.width / 3 : 0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 3 + 150,
                    height: MediaQuery.of(context).size.height * 3 / 5,
                    child: Row(
                      spacing: 0,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 7, top: 15),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width / 3,
                                  maxHeight: 40,
                                ),
                                child: Listener(
                                  onPointerSignal: (event) {
                                    if (event is PointerScrollEvent) {
                                      scrollController.jumpTo(
                                        scrollController.offset +
                                            event.scrollDelta.dy / 2,
                                      );
                                    }
                                  },
                                  child: ListView(
                                    controller: scrollController,
                                    padding: EdgeInsets.all(5),
                                    semanticChildCount: 3,
                                    scrollDirection: Axis.horizontal,
                                    physics: BouncingScrollPhysics(),
                                    children: [
                                      TextButtonWidget(
                                        label: "All",
                                        iconPath: "assets/icons/list_all.png",
                                        disable: selected[0],
                                        index: 0,
                                        updateSelected: update,
                                        sortList: [],
                                        sortLabel: "all",
                                      ),
            
                                      TextButtonWidget(
                                        label: "Artists",
                                        iconPath: "assets/icons/artists.png",
                                        disable: selected[1],
                                        index: 1,
                                        updateSelected: update,
                                        sortList: artists,
                                        sortLabel: "artist",
                                      ),
            
                                      TextButtonWidget(
                                        label: "Albums",
                                        iconPath: "assets/icons/albums.png",
                                        disable: selected[2],
                                        index: 2,
                                        updateSelected: update,
                                        sortList: albums,
                                        sortLabel: "album",
                                      ),
            
                                      TextButtonWidget(
                                        label: "Genre",
                                        iconPath: "assets/icons/genres.png",
                                        disable: selected[3],
                                        index: 3,
                                        updateSelected: update,
                                        sortList: genres,
                                        sortLabel: "genre",
                                      ),
            
                                      TextButtonWidget(
                                        label: "Playlists",
                                        iconPath: "assets/icons/playlist.png",
                                        disable: selected[4],
                                        index: 4,
                                        updateSelected: update,
                                        sortList: [],
                                        sortLabel: "playlist",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 340,
                              height: 20,
                              child: Divider(color: Colors.white),
                            ),
                            SizedBox(width: 0, height: 7),
                            Expanded(
                              child: SizedBox(
                                child: SizedBox(
                                  width: 450,
                                  height: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.5),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                      child: ScrollConfiguration(
                                        behavior: ScrollConfiguration.of(
                                          context,
                                        ).copyWith(scrollbars: false),
                                        child: Scrollbar(
                                          controller: scrollMController,
                                          thickness: 6,
                                          child: ListView.separated(
                                            controller: scrollMController,
            
                                            separatorBuilder: (
                                              context,
                                              index,
                                            ) {
                                              return Padding(
                                                padding:
                                                    EdgeInsetsGeometry.symmetric(
                                                      horizontal: 10,
                                                    ),
                                                child: Flex(
                                                  direction: Axis.horizontal,
            
                                                  children: [
                                                    Flexible(
                                                      child: Divider(
                                                        color:
                                                            const Color.fromARGB(
                                                              108,
                                                              255,
                                                              255,
                                                              255,
                                                            ),
                                                        thickness: 1,
                                                        height: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            itemBuilder: (context, index) {
                                              musicsInitD();
                                              if (mappedNotifier
                                                  .value
                                                  .isNotEmpty) {
                                                musicsInitM();
                                              }
                                              // print("ttetgfhgjgj");
                                              // print(mappedNotifier.value.keys);
                                              // print(mappedNotifier.value.keys.elementAt(index)??0);
                                              // print(mappedNotifier.value.keys.isNotEmpty?mappedNotifier.value:null);
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 3.0,
                                                    ),
                                                child:
                                                    listAll.isNotEmpty
                                                        ? musics[index]
                                                        : Column(
                                                          spacing: 5,
                                                          children: [
                                                            Text(
                                                              (mappedNotifier
                                                                      .value
                                                                      .keys
                                                                      .isNotEmpty
                                                                  ? mappedNotifier
                                                                      .value
                                                                      .keys
                                                                      .elementAt(
                                                                        index,
                                                                      )
                                                                  : "Unknown"),
                                                            ),
                                                            for (
                                                              int i = 0;
                                                              i <
                                                                  mappedNotifier
                                                                      .value[mappedNotifier
                                                                          .value
                                                                          .keys
                                                                          .elementAt(
                                                                            index,
                                                                          )]!
                                                                      .length;
                                                              i++
                                                            )
                                                              MusicCardWidget(
                                                                id: index * i,
                                                                soundPath:
                                                                    mappedNotifier
                                                                        .value[mappedNotifier
                                                                            .value
                                                                            .keys
                                                                            .elementAt(
                                                                              index,
                                                                            )]
                                                                        ?.elementAt(
                                                                          i,
                                                                        )["soundPath"],
                                                                play:
                                                                    playCurrent,
                                                              ),
                                                          ],
                                                        ),
                                              );
                                            },
                                            itemCount:
                                                listAll.isEmpty
                                                    ? mappedNotifier
                                                        .value
                                                        .keys
                                                        .length
                                                    : k,
                                            shrinkWrap: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          spacing: 7,
                          mainAxisSize: MainAxisSize.min,
                          children: children_,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

List<String> mapList(Iterable<String> it) {
  List<String> list = [];
  for (var i = 0; i < it.length; i++) {
    list.add(it.elementAt(i));
  }
  return list;
}
