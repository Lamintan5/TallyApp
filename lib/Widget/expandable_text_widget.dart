import 'package:flutter/material.dart';

import '../utils/colors.dart';


class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final Color textColor;
  final double textSize;
  final Color showTextColor;
  final double height;
  const ExpandableTextWidget({Key? key, required this.text, this.height = 200, this.textColor = Colors.grey, this.showTextColor = Colors.grey, this.textSize = 12}) : super(key: key);

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  late String firstHalf;
  late String secondHalf;
  bool hiddenText = true;

  @override
  void initState() {
    super.initState();
    if(widget.text.length>widget.height) {
      firstHalf = widget.text.substring(0, widget.height.toInt());
      secondHalf = widget.text.substring(widget.height.toInt()+1, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf= "";
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: secondHalf.isEmpty?Text(firstHalf,):Column(
        children: [
          Text(hiddenText?(firstHalf+"..."):(firstHalf+secondHalf), style: TextStyle(color: widget.textColor, fontSize: widget.textSize),),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                highlightColor : Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  setState((){
                    hiddenText=!hiddenText;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(hiddenText?"Show more":"Show less", style: TextStyle(fontSize: 11, color: secondaryColor),),
                    Icon(hiddenText?Icons.arrow_drop_down:Icons.arrow_drop_up, color:widget.showTextColor, size: 20,),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
