import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TextButtonWidget extends StatefulWidget {
  final Function(int) updateSelected;
  const TextButtonWidget({
    super.key,
    required this.label,
    required this.iconPath,
    required this.disable,
    required this.index,
    required this.updateSelected,
  });
  final String label;
  final String iconPath;
  final bool disable;
  final int index;

  @override
  State<TextButtonWidget> createState() => _TextButtonWidgetState();
}

class _TextButtonWidgetState extends State<TextButtonWidget> {
  late bool selected;
  late int ndex;

  @override
  void initState() {
    // TODO: implement initState
    selected = widget.disable;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    selected = widget.disable;
    Color selectedColor = selected ? Color(0xFF754014) : Color(0xFF5D3D23);
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: selectedColor,
        shape: BeveledRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        spacing: 10,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 20,
              height: -0.25,
            ),
          ),
          SvgPicture.asset(widget.iconPath),
        ],
      ),
      onPressed: () {
          if (widget.disable) {
          } else {
            selected = widget.updateSelected(widget.index);

          }
        setState(() {
    print(selected);
        });
      },
    );
  }
}
