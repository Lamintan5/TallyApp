import 'package:TallyApp/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyData extends StatelessWidget {
  final void Function() onTap;
  final String title;
  final Color highlightColor;
  final Color baseColor;
  const EmptyData({super.key, required this.onTap, required this.title, this.highlightColor = Colors.white, this.baseColor = screenBackgroundColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 100,),
        Image.asset("assets/add/box.png"),
        SizedBox(height: 10,),
        Text("You do not have any items yet", style: TextStyle(color: baseColor, fontSize: 18, fontWeight: FontWeight.w600),),
        Text("Start creating $title by clicking on 'Create'", style: TextStyle(color: Colors.grey[700]),),
        SizedBox(height: 10,),
        MaterialButton(
          elevation: 8,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          splashColor: CupertinoColors.activeBlue,
          minWidth: 200,
          padding: EdgeInsets.all(20),
          onPressed: onTap,
          child: Text("Create", style: TextStyle(color: highlightColor)),
          color: baseColor,
        ),
      ],
    );
  }
}
