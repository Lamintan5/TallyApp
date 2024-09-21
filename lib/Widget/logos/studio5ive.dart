import 'package:flutter/material.dart';

class Studio5ive extends StatelessWidget {
  const Studio5ive({super.key,});

  @override
  Widget build(BuildContext context) {
    final image =  Theme.of(context).brightness == Brightness.dark
        ? "assets/logo/5logo_72.png"
        : "assets/logo/5logo_72_black.png";
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
            height: 15,
            image
        ),
        SizedBox(width: 5,),
        Text("S T U D I O 5 I V E", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w100),)
      ],
    );
  }
}
