import 'dart:ui';

import 'package:flutter/material.dart';

class MusicCardWidget extends StatefulWidget {
  const MusicCardWidget({super.key});

  @override
  State<MusicCardWidget> createState() => _MusicCardWidgetState();
}

class _MusicCardWidgetState extends State<MusicCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          // Blured music's image
          /*Opacity(
            opacity: 0.3,
            child: Stack(
              children: [Image.asset(""),
              BackdropFilter(filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0))]),
          ),*/
          Column(
            spacing: 7,
            children: [
              Container(
                    color: Color.fromARGB(26, 205, 123, 56),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Le Roi",
                              style: TextStyle(
                                fontSize: 42,
                                fontFamily: "Merienda",
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              "S Ryan - Rêveries",
                              style: TextStyle(fontSize: 25, fontFamily: "Merienda"),
                            ),
                          ],
                        ),
                        SizedBox(width: 100,),
                        Text(
                          "09:57",
                          style: TextStyle(fontSize: 20, fontFamily: "Fasthand"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 400, child: Divider(color: Colors.white,thickness: 1.5,)),
            ],
          ),
        ],
      ),
    );
  }
}
