import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';


class ShowMyCase extends StatelessWidget {
  final GlobalKey mykey;
  final String? title;
  final String description;
  final Widget child;
  const ShowMyCase({super.key, required this.mykey, this.title, required this.description, required this.child});

  @override
  Widget build(BuildContext context) {
    final dgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[850]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Showcase(
      key: mykey,
      title: title,
      description: description,
      child: child,
      titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: reverse),
      descTextStyle: TextStyle( fontWeight: FontWeight.normal, color: reverse),
      tooltipPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      tooltipBackgroundColor: dgColor!,
    );
  }
}
