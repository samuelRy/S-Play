import 'package:flutter/material.dart';
import 'package:s_play/cpp_import_playback.dart' as cpp;
import 'package:s_play/music_data.dart';
import 'package:s_play/widgets/music_card.dart';
import 'package:s_play/widgets/playbackwidget.dart';

class PlaybackSliderWidget extends StatefulWidget {
  const PlaybackSliderWidget({super.key});

  @override
  State<PlaybackSliderWidget> createState() => _PlaybackSliderWidgetState();
}

class _PlaybackSliderWidgetState extends State<PlaybackSliderWidget> {
  double? hoverValue;
  OverlayEntry? overlay;
  OverlayState? overlayState;
  bool isHovered = false;
  double playCursorValue = 0.0;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: playCursorNotifier,
      builder: (context, value, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 10,
          children: [
            Text(
              formatDuration(
                Duration(seconds: playCursorNotifier.value.round()),
              ),

              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              // constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .8, minWidth: MediaQuery.of(context).size.width * .5),
              // height: 50,
              width: MediaQuery.of(context).size.width * .8,
              child: Material(
                color: Colors.transparent,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    overlayState = Overlay.of(context);
                    // print(width);
                    return MouseRegion(
                      onHover: (event) {
                        final percent = event.localPosition.dx / width;
                        final newValue =
                            currentMeta.value.$5.toDouble() * percent;
                        isHovered = true;
                        Future.delayed(Duration(milliseconds: 200), () {
                          if (!isHovered) return;
                          if (overlay != null) {
                            Overlay.of(context).didChangeDependencies();
                            overlay?.remove();
                            overlay?.dispose();
                            overlay = null;
                          }
                          overlay = OverlayEntry(
                            builder: (context) {
                              return Positioned(
                                bottom: 20,
                                left: event.localPosition.dx+5,
                                child: Container(
                                  
                                  decoration: BoxDecoration(color: Color(0xff523116), borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    formatDuration(
                                      Duration(seconds: newValue.round()),
                                    ),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w100,

                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                          overlayState!.insert(overlay!);
                        });

                        // setState(() {
                        //   hoverValue = newValue.clamp(
                        //     0,
                        //     currentMeta.value.$5.toDouble(),
                        //   );
                        // });
                      },
                      onExit: (_) {
                        isHovered = false;
                        // setState(() {
                        //   hoverValue = null;
                        // });
                        if (overlay != null) {
                          Overlay.of(context).didChangeDependencies();
                          overlay?.remove();
                          overlay?.dispose();
                          overlay = null;
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Slider(
                            padding: EdgeInsets.all(0),
                            value:
                                playCursorValue =
                                    value > currentMeta.value.$5.toDouble()
                                        ? currentMeta.value.$5.toDouble()
                                        : value,
                            onChanged: (value) {
                              playCursorValue = value;
                              playCursorNotifier.value = value;
                            },
                            label: formatDuration(
                              Duration(
                                seconds: playCursorNotifier.value.round(),
                              ),
                            ),
                            max: currentMeta.value.$5.toDouble(),
                            showValueIndicator: ShowValueIndicator.onDrag,
                            activeColor: Color(0xff523116),
                            inactiveColor: Colors.white,
                            thumbColor: Color.fromARGB(155, 162, 97, 44),
                            onChangeEnd: (value) {
                              playCursorNotifier.value = value;
                              cpp.seekToFrames(value.toInt());
                              setState(() {
                                playCursorNotifier.value = value;
                              });
                              changing = false;
                            },
                            onChangeStart: (value) {
                              changing = true;
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              /*Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Divider(
                                            color: Colors.white,
                                            height: 5,
                                            thickness: 2,
                                            
                                          ),
                                        ),
                                        /* FractionallySizedBox(
                                                heightFactor: playCursor/currentMeta.value.duration!.inSeconds,
                                              )*/
                                        Positioned(
                                          right: double.minPositive,
                                          child: Padding(
                                            padding: const EdgeInsets.all(7.5),
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color.fromARGB(
                                                  167,
                                                  162,
                                                  97,
                                                  44,
                                                ),
                                                border: Border.all(
                                                  color: Color(0xff523116),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )*/
            ),
            Text(formatDuration(Duration(seconds: currentMeta.value.$5))),
          ],
        );
      },
    );
  }
}

bool changing = false;
