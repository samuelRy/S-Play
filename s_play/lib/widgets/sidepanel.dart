import 'package:flutter/material.dart';
import 'package:s_play/widgets/text_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'music_Card.dart';

class SidePanelWidget extends StatefulWidget {
  const SidePanelWidget({super.key});

  @override
  State<SidePanelWidget> createState() => _SidePanelWidgetState();
}

class _SidePanelWidgetState extends State<SidePanelWidget> {
  List<bool> selected = [true, false, false, false];
  List<bool> isSelected = [true, false];

  bool update(int index) {
    for (var i = 1; i < 4; i++) {
      selected[i] = false;
      setState(() {});
    }
    selected[index] = true;
    print(selected);
    return selected[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        spacing: 0,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Color.fromARGB(17, 205, 123, 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 7),
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      spacing: 10,
                      children: [
                        TextButtonWidget(
                          label: "All",
                          iconPath: "assets/icons/list_all.svg",
                          disable: selected[0],
                          index: 0,
                          updateSelected: update,
                        ),

                        TextButtonWidget(
                          label: "Artists",
                          iconPath: "assets/icons/artists.svg",
                          disable: selected[1],
                          index: 1,
                          updateSelected: update,
                        ),

                        TextButtonWidget(
                          label: "Albums",
                          iconPath: "assets/icons/albums.svg",
                          disable: selected[2],
                          index: 2,
                          updateSelected: update,
                        ),

                        TextButtonWidget(
                          label: "Playlists",
                          iconPath: "assets/icons/playlist.svg",
                          disable: selected[3],
                          index: 3,
                          updateSelected: update,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 340,
                  height: 20,
                  child: Divider(color: Colors.white),
                ),
                SizedBox(
                  width: 400,
                  child: ListView(
                    shrinkWrap: true,
                    children: [MusicCardWidget()],
                  ),
                ),
              ],
            ),
          ),
          Column(
            spacing: 7,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                      print(isSelected);
                      print(isSelected[0]
                          ? Color.fromARGB(40, 205, 123, 56)
                          : Color.fromARGB(27, 205, 123, 56));
                    });
                  },
                  splashRadius: 1,
                  constraints: BoxConstraints(),
                  icon: SvgPicture.asset("assets/icons/list_expand.svg"),
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
                  onPressed: () {
                    isSelected[1] = true;
                    isSelected[0] = false;
                    setState(() {
                      print(isSelected);
                      print(isSelected[1]
                          ? Color.fromARGB(40, 205, 123, 56)
                          : Color.fromARGB(27, 205, 123, 56));
                    });
                  },
                  splashRadius: 1,
                  constraints: BoxConstraints(),
                  icon: SvgPicture.asset("assets/icons/filter.svg"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
