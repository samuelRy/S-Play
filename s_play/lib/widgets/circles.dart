import 'dart:async';
import 'dart:ffi' hide Size;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:s_play/music_data.dart';
import '../cpp_import_playback.dart' as cpp;

class DeformedCirclePainter extends CustomPainter {
  late int points;
  late final String freq;

  DeformedCirclePainter(int? points, this.freq){
    this.points = points??256;
  }

  @override
  void paint(Canvas canvas, Size size) {
    inter(canvas, size);
  }
void inter(Canvas canvas, Size size){
  late Pointer<Float> array;
    late Color firstColor;
    if (freq=="l") {
      array = cpp.lowPtr;
      firstColor = const Color.fromARGB(255, 146, 78, 1);
    } else if(freq=="m"){
      array = cpp.midPtr;
      firstColor = const Color.fromARGB(255, 1, 59, 146);
    } else if(freq=="h"){
      array = cpp.highPtr;
      firstColor = const Color.fromARGB(255, 64, 1, 146);
    } else{
      array = cpp.ampPtr;
      firstColor = const Color.fromARGB(255, 97, 52, 0);
    }
    final paint = Paint()
      ..color = firstColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    
    //print(points);
      //print("points: $points ${(array+points).value}");

    for (int i = 0; i < points; i++) {
      final angle = (2 * pi * i) / points;
      var val = ((array+i).value+(array+(i+1)).value+(array+(i+2)).value)/3;
      final noise = cpp.libInitialized.last ? val : 0;

      final r = radius + noise;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
    if (cpp.libInitialized.last) {
      dynamic lastValue = cpp.ampPtr.value+1;
    Timer.periodic(Duration(milliseconds: 800), (timer) {
      if (lastValue!=cpp.ampPtr.value+1) {
        
        reVal.value = (reVal.value+1)%10;
        }
    },);
    }
}
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
