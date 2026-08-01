import 'dart:async';
import 'dart:ffi' hide Size;
import 'package:flutter/material.dart';
import 'package:s_play/cpp_import_playback.dart' as cpp;
import 'package:s_play/music_data.dart';
import 'package:s_play/widgets/circles.dart';

class ContentWidget extends StatefulWidget {
  const ContentWidget({super.key});

  @override
  State<ContentWidget> createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  double _currentAngle = 0.0;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(_controller);

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentMusic.value.$1 != -1 && !notPlaying) {
        setState(() {
          _currentAngle += 0.15;
          _rotationAnimation = Tween<double>(
            begin: _rotationAnimation.value,
            end: _currentAngle,
          ).animate(_controller);
          _controller.forward(from: 0.0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("reval: ${reVal.value}");
    if (cpp.libInitialized.last) {
      dynamic lastValue = cpp.ampPtr.value + 1;
      Timer.periodic(Duration(milliseconds: 800), (timer) {
        if (lastValue != cpp.ampPtr.value + 1) {
          reVal.value = (reVal.value + 1) % 10;
          // print(reVal.value);
        }
      });
    }
    return ValueListenableBuilder(
      valueListenable: reVal,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -MediaQuery.of(context).size.height * .1),
          child: Stack(
            children: [
              Center(
                child: CustomPaint(
                  painter: DeformedCirclePainter(
                    cpp.libInitialized[1] ? (cpp.freqReadPtr + 0).value : 512,
                    "l",
                  ),
                  size: Size(400, 400),
                ),
              ),
              Center(
                child: CustomPaint(
                  painter: DeformedCirclePainter(
                    cpp.libInitialized[1] ? (cpp.freqReadPtr + 1).value : 512,
                    "m",
                  ),
                  size: Size(420, 420),
                ),
              ),
              Center(
                child: CustomPaint(
                  painter: DeformedCirclePainter(
                    cpp.libInitialized[1] ? (cpp.freqReadPtr + 2).value : 512,
                    "h",
                  ),
                  size: Size(440, 440),
                ),
              ),
              Center(
                child: ValueListenableBuilder(
                  valueListenable: currentMeta,

                  builder: (context, value, child) {
                    return Container(
                      height: 380,
                      width: 380,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          // print("tata ${currentMeta.value.$6.bytes.isNotEmpty}");
                          return Transform.rotate(
                            angle: _rotationAnimation.value,
                            child:
                                currentMusic.value.$1 != -1
                                    ? currentMeta.value.$6.bytes.isNotEmpty
                                        ? Image.memory(
                                          currentMeta.value.$6.bytes,
                                          fit: BoxFit.fill,
                                        )
                                        : Image.asset(
                                          "assets/icons/music.png",
                                          fit: BoxFit.fill,
                                        )
                                    : Image.asset(
                                          "assets/icons/music.png",
                                          fit: BoxFit.fill,
                                        ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
