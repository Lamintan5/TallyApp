import 'package:TallyApp/Widget/dialogs/call_actions/single_call_action.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class DialogMethod extends StatefulWidget {
  final Function update;
  const DialogMethod({super.key, required this.update});

  @override
  State<DialogMethod> createState() => _DialogMethodState();
}

class _DialogMethodState extends State<DialogMethod> {
  List<String> items = ['Cash', 'Electronic'];
  String? method;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    method = "Cash";
  }

  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(' Payment method :  ', style: TextStyle(color: secondaryColor),),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12,),
          decoration: BoxDecoration(
              color: color1,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  width: 1,
                  color: color1
              )
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: method,
              dropdownColor: dilogbg,
              icon: Icon(Icons.arrow_drop_down, color: normal),
              isExpanded: true,
              items: items.map(buildMenuItem).toList(),
              onChanged: (value) => setState(() => this.method = value),
            ),
          ),
        ),
        SingleCallAction(
          title: "Update",
          action: (){
          widget.update(method);
        },)
      ],
    );
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      '${item} Transaction',
    ),
  );
}
