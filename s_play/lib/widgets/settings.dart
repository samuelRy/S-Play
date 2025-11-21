import 'package:flutter/material.dart';
import 'package:s_play/widgets/equalizer.dart';
import 'package:s_play/widgets/listening.dart';
import 'package:s_play/widgets/lyrics.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  Widget? page;
  final eqKey = GlobalKey();
  final listeningKey = GlobalKey();
  final lyricsKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    // print("Settings pageId: ${pageIdNotifier.value}");
    return ValueListenableBuilder(
      valueListenable: pageIdNotifier,
      builder: (context, value, child) {
    if (pageIdNotifier.value == 0) {
      page = ListeningWidget(key: listeningKey,);
    } else if(pageIdNotifier.value == 1){
      page = EqualizerWidget(key: eqKey);
    } else if (pageIdNotifier.value == 2){
      page = LyricsWidget(key: lyricsKey,);
    } else{
      page = null;
    }
    // print("Settings pageId: ${pageIdNotifier.value}");
        return Container(
          child: page,
        );
      }
    );
  }
}
  int pageId = -1;
  ValueNotifier<int> pageIdNotifier = ValueNotifier(pageId);