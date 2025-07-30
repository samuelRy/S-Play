import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackgroundWidget extends StatefulWidget {
  const BackgroundWidget({super.key});

  @override
  State<BackgroundWidget> createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(200),
          child: AppBar(
            titleSpacing:5,
            flexibleSpace: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 5,
              children: [
                SvgPicture.asset(
                  "assets/icons/SMusic_icon.svg",
                  width: 80,
                  height: 80,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
