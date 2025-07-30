import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MusicControlPanalWidget extends StatefulWidget {
  const MusicControlPanalWidget({super.key});

  @override
  State<MusicControlPanalWidget> createState() =>
      _MusicControlPanalWidgetState();
}

class _MusicControlPanalWidgetState extends State<MusicControlPanalWidget> {
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
                            icon: SvgPicture.asset("assets/icons/shuffle.svg"),
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
                            icon: SvgPicture.asset("assets/icons/arrow-up.svg", width: 10, height: 20),
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
                        icon: SvgPicture.asset("assets/icons/previous.svg"),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset("assets/icons/backward.svg"),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset("assets/icons/play.svg"),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset("assets/icons/forward.svg"),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset("assets/icons/next.svg"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset("assets/icons/listening_play.svg"),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset("assets/icons/settings.svg"),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset("assets/icons/lyrics.svg"),
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
