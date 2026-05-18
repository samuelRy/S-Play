import 'package:audiotags/audiotags.dart';
import 'package:flutter/material.dart';
import 'package:s_play/music_data.dart' hide playCurrent;
import 'package:collection/collection.dart';
import 'package:s_play/widgets/music_card.dart';

class TextButtonWidget extends StatefulWidget {
  const TextButtonWidget({
    super.key,
    required this.label,
    required this.iconPath,
    required this.disable,
    required this.index,
    required this.updateSelected,
    required this.sortList,
    required this.sortLabel,
  });
  final Function(int) updateSelected;
  final String label;
  final String iconPath;
  final List<String>? sortList;
  final String? sortLabel;
  final bool disable;
  final int index;

  @override
  State<TextButtonWidget> createState() => _TextButtonWidgetState();
}

class _TextButtonWidgetState extends State<TextButtonWidget> {
  late bool selected;
  late int ndex;

  @override
  void initState() {
    selected = widget.disable;
    ii();
    super.initState();
  }

  void ii() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (var k = 0; k < playListAll.audios.length; k++) {
        // print(playListAll.audios.keys.elementAt(k));
        final String soundPath = playListAll.audios.keys.elementAt(k);
        String album = "Unknown";
        String genre = "Unknown";
        String artist = "Unknown";

        debugPrint("gg$soundPath");
        Tag? tag = await AudioTags.read(soundPath);

        debugPrint(tag?.year.toString());
        // print("mm ${meta.title.toString()}");
        if (mounted) {
          setState(() {
            // print(soundPath);
            album = tag?.album.toString()??"";
            artist = tag?.trackArtist ?? "Unknown";
            genre = tag?.genre.toString()??"";
            playListAll.audios[soundPath] = [
              {"artist": artist, "album": album, "genre": genre},
            ];
            //currentMeta.value = (title, artist, album, genre, (metaD.durationMs??-1.0).toInt(), duration, img??Uint8List(0));

            // print("all $album $artist $title $genre $year $duration");

            // print(playListAll.audios.values.elementAt(k));
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    selected = widget.disable;
    Color selectedColor = selected ? Color(0xFF754014) : Color(0xFF5D3D23);
    return ValueListenableBuilder(
      valueListenable: playListInitializedNotifier,
      builder: (context, value, child) {
        return Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: selectedColor,
              shape: BeveledRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
            ),
            onPressed:
                widget.sortList != null
                    ? () async {
                      trackMusics = [];
                      selected = widget.updateSelected(widget.index);
                      if (widget.sortLabel == "all") {
                        mappedNotifier.value = {};
                      } else if (widget.sortLabel == "playlist") {
                        mappedNotifier.value = {};
                        musics = [];
                        for (var playlist in playLists) {
                          for (var song in playlist.audios.entries) {
                            // print(playlist.audios.entries.length);
                            for (var i = 0; i < song.value.length; i++) {
                              if (song.value.isNotEmpty) {
                                song.value[i]["soundPath"] = song.key;
                                // print(song.value[i]["soundPath"]);
                              } else {
                                song.value.add({"soundPath": song.key});
                                // print(song.value[i]["soundPath"]);
                              }
                              musics.add(
                                MusicCardWidget(
                                  soundPath: song.key,
                                  id: i,
                                  play: playCurrent,
                                ),
                              );
                            }
                          }
                          List l = [];
                          Map<String, String> mapYh = {};
                          for (var mapY in playlist.audios.values) {
                            // print(mapY);
                            l.add(mapY.first);
                            for (var element in mapY) {
                              mapYh.addEntries(element.entries);
                            }
                          }
                          mappedNotifier.value[playlist.name] = l;
                          // print(playlist.name);
                          // print(mapYh);
                        }
                      } else {
                        if (playListAll.audios.isNotEmpty &&
                            playListInitializedNotifier.value) {
                          int i = 0;
                          musics = [];
                          // print(playListAll.audios.length);
                          // print(playListAll.audios.keys.length);
                          // print(playListAll.audios.values.length);
                          for (var k = 0; k < playListAll.audios.length; k++) {
                            // print(playListAll.audios.keys.elementAt(k));
                            final String soundPath = playListAll.audios.keys
                                .elementAt(k);
                            String album = "Unknown";
                            String genre = "Unknown";
                            String artist = "Unknown";
                            Future.sync(() async {
                              debugPrint("gg$soundPath");
                              Tag? tag = await AudioTags.read(soundPath);

                              debugPrint(tag?.year.toString());
                              // print("mm ${tag?.title.toString()}");

                              // print(soundPath);
                              album = tag?.album.toString()??"";
                              artist = tag?.trackArtist ?? "Unknown";
                              genre = tag?.genre.toString()??"";
                              playListAll.audios[soundPath] = [
                                {
                                  "artist": artist,
                                  "album": album,
                                  "genre": genre,
                                },
                              ];
                              //currentMeta.value = (title, artist, album, genre, (metaD.durationMs??-1.0).toInt(), duration, img??Uint8List(0));

                              // print("all $album $artist $title $genre $year $duration");
                            }).then((onValue) {
                              // print(playListAll.audios.values.elementAt(k));
                            });
                          }

                          List expand =
                              playListAll.audios.values.expand((element) {
                                // print("element $element");
                                return element;
                              }).toList();
                          // print("expand : ${expand.length}  $expand");
                          mappedNotifier.value = groupBy(expand, (item) {
                            // print("item $item");
                            item["soundPath"] = playListAll.audios.keys
                                .elementAt(i);
                            musics.add(
                              MusicCardWidget(
                                soundPath: playListAll.audios.keys.elementAt(i),
                                id: i,
                                play: playCurrent,
                              ),
                            );
                            i++;
                            // print(i);
                            // print("item sortLabel ${item[widget.sortLabel]}");
                            return item[widget.sortLabel];
                          });
                        }
                      }

                      setState(() {
                        // print(selected);
                      });
                    }
                    : () {
                      trackMusics = [];
                    },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              spacing: 10,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    height: -0.25,
                  ),
                ),
                Image.asset(widget.iconPath, width: 20, height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
