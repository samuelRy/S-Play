import 'package:flutter/material.dart';
import 'package:s_play/cpp_import_playback.dart' as cpp;
import 'package:s_play/music_data.dart';

class UpdatingSliderWidget extends StatefulWidget {
  const UpdatingSliderWidget({super.key});

  @override
  State<UpdatingSliderWidget> createState() => _UpdatingSliderState();
}

class _UpdatingSliderState extends State<UpdatingSliderWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          volume < 0.25
              ? Icons.volume_mute
              : volume < 0.5
              ? Icons.volume_down
              : Icons.volume_up,
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            valueIndicatorTextStyle: TextStyle(color: Colors.white)
          ),
          child: Slider(
                                          // overlayColor: WidgetStateProperty.all(Colors.white),
            showValueIndicator: ShowValueIndicator.onDrag,
            value: volume,
            activeColor: Color(0xff523116),
                                          inactiveColor: Colors.white,
                                          thumbColor: Color.fromARGB(
                                            155,
                                            162,
                                            97,
                                            44,
                                          ),
            min: 0,
            max: 1,
            onChanged: (value) {
              setState(() {
                volume = value;
                modifyVolume(value);
                // _valueChange;
              });
            },
            onChangeEnd: (value) {
              volume = value;
              // print(volume);
          
              modifyVolume(value);
            },
            label: (volume*100).toStringAsFixed(0),
          ),
        ),
      ],
    );
  }
}

void modifyVolume(double value) {
  cpp.modifyVolume(volume);
}
