import 'package:flutter/material.dart';

class RowLogo extends StatelessWidget {
  final String text;
  final double height;
  const RowLogo({super.key, required this.text, this.height = 40});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white38
        : Colors.black12;
    return  SizedBox(width: 200,
      child: Row(
        children: [
          Image.asset(
            'assets/logos/android/res/mipmap-mdpi/ic_launcher.png',
            height: height,
          ),
          SizedBox(width: 5,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'T A L L Y A P P',
                  style: TextStyle(fontWeight: FontWeight.w100),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
                text == "" ? SizedBox() : Text(text,style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),)
              ],
            ),
          )
        ],
      ),
    );
  }
}
