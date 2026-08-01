import 'package:flutter/material.dart';

class MusicControlpanelWidget extends StatefulWidget {
  const MusicControlpanelWidget({super.key});

  @override
  State<MusicControlpanelWidget> createState() =>
      _MusicControlpanelWidgetState();
}

class _MusicControlpanelWidgetState extends State<MusicControlpanelWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 180,
        color: Color(0xFFCD7B38),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "Le Roi",
                        style: TextStyle(fontFamily: "Merienda", fontSize: 42),
                      ),
                      Text(
                        "S Ryan - Rêveries",
                        style: TextStyle(fontFamily: "Merienda", fontSize: 25),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF523116),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(6),
                    ),

                    child: Row(
                      spacing: 3,
                      children: [
                        SizedBox(
                          width: 50,
                          child: IconButton(
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(side: BorderSide.none),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 5,
                            ),
                            icon: Image.asset("assets/icons/shuffle.png"),
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(
                          width: .1,
                          height: 40, // match the size of your IconButtons
                          child: VerticalDivider(
                            thickness: 1.0,
                            width: 10,
                            color: Color(0xFFCD7B38),
                          ),
                        ),

                        SizedBox(
                          width: 15,
                          child: IconButton(
                            padding: EdgeInsets.symmetric(horizontal: 1),
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(side: BorderSide.none),
                              ),
                            ),
                            constraints: BoxConstraints(),
                            icon: Image.asset(
                              "assets/icons/arrow-up.png",
                              width: 10,
                              height: 20,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset("assets/icons/previous.png"),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset("assets/icons/backward.png"),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset("assets/icons/play.png"),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset("assets/icons/forward.png"),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset("assets/icons/next.png"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset("assets/icons/listening_play.png"),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset("assets/icons/settings.png"),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset("assets/icons/lyrics.png"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("04:24"),
                  // Slider
                  Text("09:57"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
