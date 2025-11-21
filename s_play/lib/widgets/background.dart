import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s_play/music_data.dart';

class BackgroundWidget extends StatefulWidget {
  const BackgroundWidget({super.key});

  @override
  State<BackgroundWidget> createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget> {

  @override
  void initState() {
    super.initState();
    initBack();
  }

  void initBack() async {
     WidgetsBinding.instance.addPostFrameCallback((_) async {
    ByteData bytesData = await rootBundle.load("assets/icons/music.png");
      if (mounted){
        setState(() {
  backU8List.value = bytesData.buffer.asUint8List();
          
        });
      }
     });
  }

  @override
  Widget build(BuildContext context) {
    
    return ValueListenableBuilder(
      valueListenable: currentMusic,
      builder: (context, value, child) {
        return Stack(children: [
          Center(child: Opacity(opacity: 0.15, child: Container(child: currentMusic.value.$1==-1?Image.asset("assets/icons/music.png"):
          Center(
            child: Transform.scale(scale: 2,child: Image.memory(currentMusic.value.$3, fit: BoxFit.cover)),
          )
          ))),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaY: 5,
              sigmaX: 5,
            ),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ],);
      }
    );
  }
}
