import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/colors.dart';
import '../text_filed_input.dart';

class DialogPayReceivables extends StatefulWidget {
  final double amount;
  final Function updateReceivable;
  const DialogPayReceivables({super.key, required this.amount, required this.updateReceivable});

  @override
  State<DialogPayReceivables> createState() => _DialogPayReceivablesState();
}

class _DialogPayReceivablesState extends State<DialogPayReceivables> {
  TextEditingController _pay = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _paying = false;
  List<String> items = ['Cash', 'Electronic'];
  String? type;

  _record(){
    widget.updateReceivable(double.parse(_pay.text), type);
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pay.text = widget.amount.toString();
    type = 'Electronic';
  }

  @override
  Widget build(BuildContext context) {
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final dialogBg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFieldInput(
            textEditingController: _pay,
            textInputType: TextInputType.number,
            labelText: 'Amount',
            textAlign: TextAlign.center,
            validator: (value){
              if (value == null || value.isEmpty) {
                return 'Please enter the correct amount';
              } else if (RegExp(r'^[0-9.]+$').hasMatch(value)) {
                try {
                  double enteredAmount = double.parse(value);
                  if (enteredAmount > widget.amount) {
                    return 'Amount is more than ${formatNumberWithCommas(widget.amount)}';
                  } else {
                    return null;
                  }
                } catch (e) {
                  return 'Please enter a valid number';
                }
              } else {
                return 'Please enter a valid number';
              }
            },
          ),
          SizedBox(height: 5,),
          Text('Payment Method :  ', style: TextStyle(color: secondaryColor),),
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
                value: type,
                dropdownColor: dialogBg,
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                isExpanded: true,
                items: items.map(buildMenuItem).toList(),
                onChanged: (value) => setState(() => this.type = value),
              ),
            ),
          ),
          DoubleCallAction(action: _record, title: "Pay",)
        ],
      ),
    );
  }
  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item + " Transaction",
    ),
  );
}
