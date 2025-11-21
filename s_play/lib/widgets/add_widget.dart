import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:s_play/music_data.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key, required this.add});
  final int add;


  @override
  Widget build(BuildContext context) {
    TextEditingController tController = TextEditingController();
    return Center(
      child: IconButton(onPressed: () async {
        String? folder = await FilePicker.platform.getDirectoryPath(dialogTitle: add == 0 ? "Add a PLaylist" : "Add a folder");
        if (folder != null) {
          if (add==1) {
            folders.add(folder);
          } else if(add==0){
            AlertDialog(
              title: Text("Name your playlist"),
              content: TextField(
                controller: tController,
              ),
            );
            playLists.add(PlayList(id: playLists.length, name: tController.text));
          }
        }
      }, icon: Icon(Icons.add)),
    );
  }
}