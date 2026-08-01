import 'dart:ffi';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:s_play/cpp_import_playback.dart' as cpp;
import 'package:s_play/music_data.dart';

class EqualizerWidget extends StatefulWidget {
  const EqualizerWidget({super.key});

  @override
  State<EqualizerWidget> createState() => _EqualizerWidgetState();
}

bool eq = false;

class _EqualizerWidgetState extends State<EqualizerWidget> {
  late int overlayId;
  @override
  void initState() {
    super.initState();
    overlayId = -1;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: Colors.white, fontSize: 10);
    return ValueListenableBuilder(
      valueListenable: currentMusic,
      builder: (context, value, child) {
        return Positioned(
          bottom: MediaQuery.of(context).size.height * .28,
          right: 5,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(255, 165, 99, 45)),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            height: MediaQuery.of(context).size.height / 3,
            child: SizedBox(
              child: Column(
                children: [
                  Material(
                    surfaceTintColor: Colors.transparent,
                    color: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 10,
                      children: [
                        Text(
                          "Equalizer",
                          style: TextStyle(
                            color: Color.fromARGB(255, 205, 123, 56),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Row(
                          spacing: 3,
                          children: [
                            Text(eq ? "On" : "Off"),
                            Switch(
                              value: eq,
                              onChanged:
                                  (cpp.libInitialized.last &&
                                          currentMusic.value.$1 != -1)
                                      ? (value) {
                                        setState(() {
                                          eq = value;
                                          cpp.changeEq();
                                          // print(cpp.eq.value);
                                        });
                                      }
                                      : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      //                                               subBassGain slider
                      SizedBox(
                        width: 60,
                        // height: 150,
                        child: Material(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Text("<250 Hz", style: textStyle),
                              Transform.rotate(
                                angle: -math.pi / 2,
                                child: SizedBox(
                                  height: 170,
                                  width: 60,
                                  child: Slider(
                                    padding: EdgeInsets.zero,
                                    value: cpp.subBassGain.value,
                                    onChanged:
                                        eq
                                            ? (double newVal) {
                                              setState(() {
                                                // subBassGain = newVal;
                                                cpp.subBassGain.value = newVal;
                                                gainChanger();
                                              });
                                            }
                                            : null,
                                    max: 10,
                                    min: -10,
                                    label: cpp.subBassGain.value
                                        .toStringAsFixed(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // bassGain slider
                      SizedBox(
                        width: 60,
                        // height: 150,
                        child: Material(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Text("<500 Hz", style: textStyle),
                              Transform.rotate(
                                angle: -math.pi / 2,
                                child: SizedBox(
                                  height: 170,
                                  width: 60,
                                  child: Slider(
                                    padding: EdgeInsets.zero,
                                    value: cpp.bassGain.value,
                                    onChanged:
                                        eq
                                            ? (double newVal) {
                                              setState(() {
                                                // bassGain = newVal;
                                                cpp.bassGain.value = newVal;
                                                gainChanger();
                                              });
                                            }
                                            : null,
                                    max: 10,
                                    min: -10,
                                    label: cpp.bassGain.value.toStringAsFixed(
                                      3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // lowNidrangeGain slider
                      SizedBox(
                        width: 60,
                        // height: 150,
                        child: Material(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Text("<2000 Hz", style: textStyle),
                              Transform.rotate(
                                angle: -math.pi / 2,
                                child: SizedBox(
                                  height: 170,
                                  width: 60,
                                  child: Slider(
                                    padding: EdgeInsets.zero,
                                    value: cpp.lowMidrangeGain.value,
                                    onChanged:
                                        eq
                                            ? (double newVal) {
                                              setState(() {
                                                // lowMidrangeGain = newVal;
                                                cpp.lowMidrangeGain.value =
                                                    newVal;
                                                gainChanger();
                                              });
                                            }
                                            : null,
                                    max: 10,
                                    min: -10,
                                    label: cpp.lowMidrangeGain.value
                                        .toStringAsFixed(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // midrangeGain slider
                      SizedBox(
                        width: 60,
                        // height: 150,
                        child: Material(
                          surfaceTintColor: Colors.transparent,
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Text("<4000 Hz", style: textStyle),
                              Transform.rotate(
                                angle: -math.pi / 2,
                                child: SizedBox(
                                  height: 170,
                                  width: 60,
                                  child: Slider(
                                    padding: EdgeInsets.zero,
                                    value: cpp.midrangeGain.value,
                                    onChanged:
                                        eq
                                            ? (double newVal) {
                                              setState(() {
                                                // midrangeGain = newVal;
                                                cpp.midrangeGain.value = newVal;
                                                gainChanger();
                                              });
                                            }
                                            : null,
                                    max: 10,
                                    min: -10,
                                    label: cpp.midrangeGain.value
                                        .toStringAsFixed(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // upperMidsGain slider
                      SizedBox(
                        width: 60,
                        // height: 150,
                        child: Material(
                          surfaceTintColor: Colors.transparent,
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Text("<6000 Hz", style: textStyle),
                              Transform.rotate(
                                angle: -math.pi / 2,
                                child: SizedBox(
                                  height: 170,
                                  width: 60,
                                  child: Slider(
                                    padding: EdgeInsets.zero,
                                    value: cpp.upperMidsGain.value,
                                    onChanged:
                                        eq
                                            ? (double newVal) {
                                              setState(() {
                                                // upperMidsGain = newVal;
                                                cpp.upperMidsGain.value =
                                                    newVal;
                                                gainChanger();
                                              });
                                            }
                                            : null,
                                    max: 10,
                                    min: -10,
                                    label: cpp.upperMidsGain.value
                                        .toStringAsFixed(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // highMidsGain slider
                      SizedBox(
                        width: 60,
                        // height: 150,
                        child: Material(
                          surfaceTintColor: Colors.transparent,
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Text("<20000 Hz", style: textStyle),
                              Transform.rotate(
                                angle: -math.pi / 2,
                                child: SizedBox(
                                  height: 170,
                                  width: 60,
                                  child: Slider(
                                    padding: EdgeInsets.zero,
                                    value: cpp.highMidsGain.value,
                                    onChanged:
                                        eq
                                            ? (double newVal) {
                                              setState(() {
                                                // highMidsGain = newVal;
                                                cpp.highMidsGain.value = newVal;
                                                gainChanger();
                                              });
                                            }
                                            : null,
                                    max: 10,
                                    min: -10,
                                    label: cpp.highMidsGain.value
                                        .toStringAsFixed(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // trebleGain slider
                      SizedBox(
                        width: 60,
                        // height: 150,
                        child: Material(
                          color: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          child: Column(
                            children: [
                              Text(">20000 Hz", style: textStyle),
                              Transform.rotate(
                                angle: -math.pi / 2,
                                child: SizedBox(
                                  height: 170,
                                  width: 60,
                                  child: Slider(
                                    padding: EdgeInsets.zero,
                                    value: cpp.trebleGain.value,
                                    onChanged:
                                        eq
                                            ? (double newVal) {
                                              setState(() {
                                                // trebleGain = newVal;
                                                cpp.trebleGain.value = newVal;
                                                gainChanger();
                                              });
                                            }
                                            : null,
                                    max: 10,
                                    min: -10,
                                    label: cpp.trebleGain.value.toStringAsFixed(
                                      3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void gainChanger() {
  cpp.changeGains(
    cpp.subBassGain.value,
    cpp.bassGain.value,
    cpp.lowMidrangeGain.value,
    cpp.midrangeGain.value,
    cpp.upperMidsGain.value,
    cpp.highMidsGain.value,
    cpp.trebleGain.value,
  );
}
