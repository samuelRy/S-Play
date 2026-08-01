import 'dart:ffi' hide Size;

import 'package:audiotags/audiotags.dart';
import 'package:ffi/ffi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

  List<String> listAll = [];
  Map<int, int> listShuffled = {};
List<String> artists = [];
List<String> albums = [];
List<String> genres = [];
bool shuffled = false;
bool initialized = false;
  bool hidden = true;
ValueNotifier shuffleNotifier = ValueNotifier(shuffled);
ValueNotifier hiddenNotifier = ValueNotifier(hidden);

List<bool> selected = [true, false, false, false, false, false];
List<bool> isSelected = [true, false];


class _SidePanelWidgetState extends State<SidePanelWidget> {
  // double width = 0;

  bool update(int index) {
    for (var i = 0; i < 4; i++) {
      // print("$i $index");
      if (i == index) {
        // print("change ${selected[index]}");
        if (!selected[index]) {
          selected[index] = true;
        }
        // print("change ${selected[index]}");
      } else {
        selected[i] = false;
      }
    }

    selected.last = index != 1 ? true : false;
    // print("selected.last ${selected.last}");

    setState(() {});
    // print(selected);
    return selected[index];
  }

  void playCurrent(int index, String soundPath, List<Picture> img) async {
    currentMusic.value = (index, soundPath, img.first.bytes);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // print("$index, $soundPath, ${img.first.bytes.length}");
      // debugPrint("gg$soundPath");
      Tag? tag = await AudioTags.read(soundPath);

      if (mounted) {
        if (tag?.pictures != null) {
          img = tag!.pictures;
        } else {
          img = [
            Picture(
              pictureType: PictureType.coverBack,
              mimeType: MimeType.png,
              bytes: bytesData.buffer.asUint8List(),
            ),
          ];
        }
        // print("mm ${tag?.pictures != null}");

        // print(soundPath);
        String? album = tag?.album.toString();
        String? artist = tag?.trackArtist ?? "Unknown";
        String? genre = tag?.genre.toString();
        String? title =
            tag?.title.toString() == "" ? "Unknown" : tag?.title.toString();
        int? duration = tag?.duration;

        playListAll.audios[soundPath] = [
          {"artist": artist, "album": album ?? "", "genre": genre ?? ""},
        ];
        currentMeta.value = (
          title ?? "",
          artist,
          album ?? "",
          genre ?? "",
          duration ?? -1,
          img.first,
        );

        //print("all $album $artist $title $genre ${meta.year!.toInt()} $duration");
      }
    });

    // pause(false);
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
    initializeSoundData(soundPath.toNativeUtf16());
    initialized = true;
    // print("Initialized");
    startPlayBack();
    started = true;
    // print("qe");
    // print("qa");

    // print("true Too ${musics.length} ${index + 1} $index");

    // print("initiaaaa ${currentMusic.value.$1} ${currentMusic.value.$2}");
    // if (currentMusic.value.$1 != index) {
    //   // print(musics.length > index);
    //   if (musics.length > index) {
    //     // print("nexta");
    //   }
    //   //initA();
    // }
    // print("Initializing ${soundPath.toNativeUtf16()}");
  }

  void timerRunning(int i, String path, List<Picture> img) {
    // listAll = mapList(playListAll.audios.keys);

    //  print("${currentMusic.value.$1}    ${currentMusic.value.$2}");
    // playCurrent(i, path, img);
    // print(
    //   "true Too ${listAll.length} ${currentMusic.value.$1 + 1} ${listAll[currentMusic.value.$1+1]}",
    // );
    // Timer.periodic(Duration(milliseconds: 800), (timer) {
    //   // print("nextaar ${running.value}   ${currentMusic.value.$1}");

    //   if (!running.value) {
    //     // print(
    //     //   "true Too ${listAll.length} ${currentMusic.value.$1 + 1} ${listAll[currentMusic.value.$1+1]}",
    //     // );
    //     // currentMeta.value = (
    //     //   "",
    //     //   "",
    //     //   "",
    //     //   "",
    //     //   0,
    //     //   Picture(
    //     //     bytes: Uint8List(0),
    //     //     pictureType: PictureType.coverBack,
    //     //     mimeType: MimeType.png,
    //     //   ),
    //     // );
    //   }
    // });
  }

  bool dnStart = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializePlayList();

      if (mounted) {
        setState(() {
          // final box = context.findRenderObject() as RenderBox;

          // width = box.size.width;
          // print("set");
        }); // Triggers rebuild with updated playlist
      }
    });
  }

  // Clean list creation process's map
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: playerRefresher,
      builder: (context2, value2, child2) {
        // print("Build finished xx ${currentMusic.value.$1} $started $dnStart");

        if ((currentMusic.value.$1 != -1) && !started && !dnStart) {
          // print(dnStart);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // print("Build finished yy");
            playCurrent(currentMusic.value.$1, currentMusic.value.$2, [
              Picture(
                pictureType: PictureType.coverBack,
                mimeType: MimeType.png,
                bytes: currentMusic.value.$3,
              ),
            ]);
          });
        }
            dnStart = false;
        return ValueListenableBuilder(
          valueListenable: mappedNotifier,
          builder: (context1, value1, child1) {
            // print(mappedNotifier.value);
            return ValueListenableBuilder(
              valueListenable: shuffleNotifier,
              builder: (context, value, child) {
                // print("gh${playListAll.audios.length}");
                listAll =
                    mappedNotifier.value.isEmpty
                        ? mapList(playListAll.audios.keys)
                        : [];
                
                int k = listAll.isNotEmpty ? listAll.length : 0;
                void musicsInitD() {
                  for (var i = 0; i < listAll.length; i++) {
                    musics.add(
                      MusicCardWidget(
                        key: ValueKey(
                          shuffleNotifier.value ? listShuffled[i] : listAll[i],
                        ),
                        soundPath:
                            shuffleNotifier.value
                                ? listAll[listShuffled[i]??0]
                                : listAll[i],
                        id: i,
                        // play: timerRunning,
                      ),
                    );
                    // print("$i ${listAll.length}");
                  }
                }

                void musicsInitM() {
                  for (var j = 0; j < playListAll.audios.length; j++) {
                    musics.add(
                      MusicCardWidget(
                        soundPath: playListAll.audios.keys.elementAt(j),
                        id: j,
                        // play: timerRunning,
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
                          hiddenNotifier.value = !hiddenNotifier.value;
                          dnStart = true;
                          // print(hiddenNotifier.value);
                        });
                      },
                      splashRadius: 1,
                      constraints: BoxConstraints(),
                      icon: Image.asset("assets/icons/list_expand.png"),
                    ),
                  ),
                ];
                children_.addAll([
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
                        String? directory = await FilePicker.getDirectoryPath();
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
                ]);
                // print("width $width");
                return Stack(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 + 50,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              AnimatedPositioned(
                                duration: Duration(milliseconds: 500),
                                left:
                                    hiddenNotifier.value
                                        ? -MediaQuery.of(context).size.width / 3
                                        : 0,
                                child: Row(
                                  spacing: 2,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LayoutBuilder(
                                      builder: (context, constraints1) {
                                        final width =
                                            MediaQuery.of(context).size.width /
                                            3;
                                        // print(constraints.maxHeight);
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: BoxBorder.all(
                                              color: Color(0xffcd7b38),
                                              width: 1,
                                            ),
                                          ),
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height,
                                          width: width,
                                          child: Stack(
                                            children: [
                                              AnimatedPositioned(
                                                duration: Duration(
                                                  milliseconds: 700,
                                                ),
                                                left: hiddenNotifier.value ? -width : 0,
                                                child: SizedBox(
                                                  // decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                                                  height: constraints.maxHeight,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 5,
                                                            ),
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                                maxWidth:
                                                                    MediaQuery.of(
                                                                      context,
                                                                    ).size.width /
                                                                    3,
                                                                maxHeight: 40,
                                                              ),
                                                          child: Listener(
                                                            onPointerSignal: (
                                                              event,
                                                            ) {
                                                              if (event
                                                                  is PointerScrollEvent) {
                                                                scrollController.jumpTo(
                                                                  (scrollController
                                                                              .offset +
                                                                          event.scrollDelta.dy /
                                                                              2)
                                                                      .clamp(
                                                                        scrollController
                                                                            .position
                                                                            .minScrollExtent,
                                                                        scrollController
                                                                            .position
                                                                            .maxScrollExtent,
                                                                      ),
                                                                );
                                                              }
                                                            },
                                                            child: ListView(
                                                              controller:
                                                                  scrollController,
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    5,
                                                                  ),
                                                              semanticChildCount:
                                                                  3,
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              physics:
                                                                  BouncingScrollPhysics(),
                                                              children: [
                                                                TextButtonWidget(
                                                                  label: "All",
                                                                  iconPath:
                                                                      "assets/icons/list_all.png",
                                                                  disable:
                                                                      selected[0],
                                                                  index: 0,
                                                                  updateSelected:
                                                                      update,
                                                                  sortList: [],
                                                                  sortLabel:
                                                                      "all",
                                                                ),

                                                                TextButtonWidget(
                                                                  label:
                                                                      "Artists",
                                                                  iconPath:
                                                                      "assets/icons/artists.png",
                                                                  disable:
                                                                      selected[1],
                                                                  index: 1,
                                                                  updateSelected:
                                                                      update,
                                                                  sortList:
                                                                      artists,
                                                                  sortLabel:
                                                                      "artist",
                                                                ),

                                                                TextButtonWidget(
                                                                  label:
                                                                      "Albums",
                                                                  iconPath:
                                                                      "assets/icons/albums.png",
                                                                  disable:
                                                                      selected[2],
                                                                  index: 2,
                                                                  updateSelected:
                                                                      update,
                                                                  sortList:
                                                                      albums,
                                                                  sortLabel:
                                                                      "album",
                                                                ),

                                                                TextButtonWidget(
                                                                  label:
                                                                      "Genre",
                                                                  iconPath:
                                                                      "assets/icons/genres.png",
                                                                  disable:
                                                                      selected[3],
                                                                  index: 3,
                                                                  updateSelected:
                                                                      update,
                                                                  sortList:
                                                                      genres,
                                                                  sortLabel:
                                                                      "genre",
                                                                ),

                                                                TextButtonWidget(
                                                                  label:
                                                                      "Playlists",
                                                                  iconPath:
                                                                      "assets/icons/playlist.png",
                                                                  disable:
                                                                      selected[4],
                                                                  index: 4,
                                                                  updateSelected:
                                                                      update,
                                                                  sortList: [],
                                                                  sortLabel:
                                                                      "playlist",
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: width - 10,
                                                        child: Divider(
                                                          thickness: 2,
                                                          height: 2,
                                                          color: Color(
                                                            0xffcd7b38,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: SizedBox(
                                                          width: width,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  4.5,
                                                                ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                    Radius.circular(
                                                                      5.0,
                                                                    ),
                                                                  ),
                                                              child: ScrollConfiguration(
                                                                behavior:
                                                                    ScrollConfiguration.of(
                                                                      context,
                                                                    ).copyWith(
                                                                      scrollbars:
                                                                          false,
                                                                    ),
                                                                child: Scrollbar(
                                                                  controller:
                                                                      scrollMController,
                                                                  thickness: 6,
                                                                  child: ListView.separated(
                                                                    controller:
                                                                        scrollMController,

                                                                    separatorBuilder: (
                                                                      context,
                                                                      index,
                                                                    ) {
                                                                      if (listAll
                                                                          .isNotEmpty) {
                                                                        return Padding(
                                                                          padding: EdgeInsetsGeometry.symmetric(
                                                                            horizontal:
                                                                                10,
                                                                          ),
                                                                          child: Flex(
                                                                            direction:
                                                                                Axis.horizontal,

                                                                            children: [
                                                                              Flexible(
                                                                                child: Divider(
                                                                                  color: const Color.fromARGB(
                                                                                    108,
                                                                                    255,
                                                                                    255,
                                                                                    255,
                                                                                  ),
                                                                                  thickness:
                                                                                      1,
                                                                                  height:
                                                                                      1,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return SizedBox.shrink();
                                                                      }
                                                                    },
                                                                    itemBuilder: (
                                                                      context,
                                                                      index,
                                                                    ) {
                                                                      musicsInitD();
                                                                      if (mappedNotifier
                                                                          .value
                                                                          .isNotEmpty) {
                                                                        musicsInitM();
                                                                      }
                                                                      // print(
                                                                      //   "${listAll.isNotEmpty}",
                                                                      // );
                                                                      // print(mappedNotifier.value.keys);
                                                                      // print(mappedNotifier.value.keys.elementAt(index)??0);
                                                                      // print(mappedNotifier.value.keys.isNotEmpty?mappedNotifier.value:null);
                                                                      return Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                              8.0,
                                                                            ),
                                                                        child:
                                                                            listAll.isNotEmpty
                                                                                ? musics[index]
                                                                                : ListView.builder(
                                                                                  shrinkWrap:
                                                                                      true,
                                                                                  physics:
                                                                                      const NeverScrollableScrollPhysics(),
                                                                                  itemBuilder: (
                                                                                    context,
                                                                                    index1,
                                                                                  ) {
                                                                                    // print(
                                                                                    //   "lah",
                                                                                    // );
                                                                                    // print(
                                                                                    //   index,
                                                                                    // );
                                                                                    // print(
                                                                                    //   mappedNotifier.value.keys.length,
                                                                                    // );
                                                                                    // print(
                                                                                    //   index1,
                                                                                    // );
                                                                                    // print(
                                                                                    //   mappedNotifier.value.keys
                                                                                    //       .elementAt(
                                                                                    //         index,
                                                                                    //       )
                                                                                    //       .length,
                                                                                    // );
                                                                                    return Column(
                                                                                      children: [
                                                                                        (index1 ==
                                                                                                0)
                                                                                            ? Column(
                                                                                              spacing:
                                                                                                  5,
                                                                                              children: [
                                                                                                Text(
                                                                                                  (mappedNotifier.value.keys.isNotEmpty
                                                                                                      ? mappedNotifier.value.keys.elementAt(
                                                                                                        index,
                                                                                                      )
                                                                                                      : "Unknown"),
                                                                                                ),
                                                                                                Divider(
                                                                                                  color: const Color.fromARGB(
                                                                                                    108,
                                                                                                    255,
                                                                                                    255,
                                                                                                    255,
                                                                                                  ),
                                                                                                  thickness:
                                                                                                      1,
                                                                                                  height:
                                                                                                      1,
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  height:
                                                                                                      5,
                                                                                                ),
                                                                                              ],
                                                                                            )
                                                                                            : SizedBox(
                                                                                              height:
                                                                                                  15,
                                                                                              child:
                                                                                                  Divider(),
                                                                                            ),

                                                                                        MusicCardWidget(
                                                                                          id:
                                                                                              index +
                                                                                              index1 +
                                                                                              1,
                                                                                          soundPath:
                                                                                              mappedNotifier
                                                                                                  .value[mappedNotifier.value.keys.elementAt(
                                                                                                    index,
                                                                                                  )]
                                                                                                  ?.elementAt(
                                                                                                    index1,
                                                                                                  )["soundPath"],
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  },
                                                                                  itemCount:
                                                                                      mappedNotifier.value[mappedNotifier.value.keys.elementAt(
                                                                                                index,
                                                                                              )] !=
                                                                                              null
                                                                                          ? mappedNotifier
                                                                                              .value[mappedNotifier.value.keys.elementAt(
                                                                                                index,
                                                                                              )]!
                                                                                              .length
                                                                                          : 0,
                                                                                ),
                                                                      );
                                                                    },
                                                                    itemCount:
                                                                        listAll.isEmpty
                                                                            ? mappedNotifier.value.keys.length
                                                                            : k,
                                                                    // shrinkWrap:
                                                                    //     true,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    Column(
                                      spacing: 7,
                                      mainAxisSize: MainAxisSize.min,
                                      children: children_,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
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
