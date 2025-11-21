import 'package:flutter/material.dart';
import 'package:s_play/music_data.dart';

class ListeningWidget extends StatefulWidget {
  const ListeningWidget({super.key});

  @override
  State<ListeningWidget> createState() => _ListeningWidgetState();
}

class _ListeningWidgetState extends State<ListeningWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentMusic,
      builder: (context, value, child) {
        return Positioned(
          bottom: MediaQuery.of(context).size.height * .4,
          right: 5,
          child: Container(
            width: MediaQuery.of(context).size.width / 3,
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(255, 165, 99, 45)),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            height: MediaQuery.of(context).size.height / 4,
            child: ListView.builder(
              itemBuilder:
                  (context, index) =>
                      Transform.scale(scale: 0.8, child: musics[index]),
              itemCount: musics.length,
            ),
          ),
        );
      },
    );
  }
}
