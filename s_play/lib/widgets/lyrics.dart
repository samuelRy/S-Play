import 'package:flutter/material.dart';
import 'package:s_play/music_data.dart';

class LyricsWidget extends StatefulWidget {
  const LyricsWidget({super.key});

  @override
  State<LyricsWidget> createState() => _LyricsWidgetState();
}

class _LyricsWidgetState extends State<LyricsWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentMusic,
      builder: (context, value, child) {
        return Positioned(
          bottom: MediaQuery.of(context).size.height * .20,
          right: 5,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(255, 165, 99, 45)),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.height / 3,
            child: Material(child: TextField(
              autofocus: true,
              maxLines: null,
              maxLength: TextField.noMaxLength,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Color(0xffcd7b38), offset: Offset(5, 3)), Shadow(color: Color.fromARGB(255, 131, 78, 36))],
              ),
            )),
          ),
        );
      },
    );
  }
}
