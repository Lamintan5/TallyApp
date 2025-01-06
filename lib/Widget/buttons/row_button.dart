import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RowButton extends StatelessWidget {
  final void Function() onTap;
  final Widget icon;
  final String title;
  final String subtitle;
  final bool isBeta;
  const RowButton({super.key, required this.onTap, required this.icon, required this.title, required this.subtitle, this.isBeta = false});

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 1),
      child: InkWell(
        splashColor: CupertinoColors.activeBlue,
        borderRadius: BorderRadius.circular(5),
        hoverColor: color1,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
              color: color1,
              borderRadius: BorderRadius.circular(5)
          ),
          child: Row(
            children: [
              icon,
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                    ),
                    subtitle==""?SizedBox():Text(subtitle, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: CupertinoColors.systemBlue),)
                  ],
                ),
              ),
              isBeta
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Text("Beta",style: TextStyle(color: Colors.black),),
                    )
                  : SizedBox(),
              Icon(Icons.keyboard_arrow_right)
            ],
          ),
        ),
      ),
    );
  }
}
