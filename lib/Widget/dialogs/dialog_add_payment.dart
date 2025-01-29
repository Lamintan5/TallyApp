import 'package:TallyApp/Widget/dialogs/call_actions/single_call_action.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

import '../../main.dart';
import '../../utils/colors.dart';
import '../text/text_format.dart';
import '../text_filed_input.dart';

class DialogPayment extends StatefulWidget {
  final double amount;
  final Function updatePaid;
  const DialogPayment({super.key, required this.amount,  required this.updatePaid,});

  @override
  State<DialogPayment> createState() => _DialogPaymentState();
}

class _DialogPaymentState extends State<DialogPayment> {
  TextEditingController _pay = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DateTime _dateTime = DateTime.now();
  DateTime _purchaseDate = DateTime.now();

  String? type;
  List<String> items = ['Cash', 'Electronic'];

  bool _loading = false;
  bool isComp = false;
  double amount = 0.0;

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the correct amount';
    } else if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    } else {
      double enteredAmount = double.parse(value);
      if (enteredAmount > amount) {
        return 'Amount is more than ${TFormat().getCurrency()}${formatNumberWithCommas(amount)}';
      }
    }
    return null;
  }

  void _handlePaymentChange() {
    final value = _pay.text;
    if (value.isNotEmpty && double.tryParse(value) != null) {
      double enteredAmount = double.parse(value);
      if (enteredAmount < amount) {
        setState(() {
          isComp = false;
        });
      } else if (enteredAmount == amount) {
        setState(() {
          isComp = true;
        });
      }
    }
  }

  bool isToday(DateTime date) {
    DateTime today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }


  _record(){
    widget.updatePaid(amount.toString(), _pay.text.trim().toString(), _purchaseDate.toString(), _dateTime.toString(), type);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    amount =  widget.amount;
    _pay.text = amount.toString();
    type = "Electronic";
    isComp = amount==double.parse(_pay.text.toString()) ? true : false;
    _pay.addListener(_handlePaymentChange);
  }

  @override
  Widget build(BuildContext context) {
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final dialogBg =  Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final hours = _purchaseDate.hour.toString().padLeft(2, '0');
    final minutes = _purchaseDate.minute.toString().padLeft(2, '0');
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Enter the total amount purchased for all the goods',
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryColor, fontSize: 12),
            ),
          ),
          SizedBox(height: 10,),
          TextFieldInput(
            textEditingController: _pay,
            textInputType: TextInputType.number,
            labelText: 'Amount',
            textAlign: TextAlign.center,
            validator: _validateAmount,
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              Text('Payment Method :  ', style: TextStyle(color: secondaryColor),),
            ],
          ),
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
          SizedBox(height: 5,),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Purchase Date :", style: TextStyle(color: secondaryColor),),
                    InkWell(
                      onTap: (){
                        _showSaleDatePicker();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                        decoration: BoxDecoration(
                            color: color1,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                width: 1,
                                color: color1
                            )
                        ),
                        child: Text(DateFormat.yMMMd().format(_purchaseDate), style: TextStyle( fontSize: 13),),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Time :", style: TextStyle(color: secondaryColor),),
                    InkWell(
                      onTap: ()async{
                        final time =await pickTime();
                        if(time==null){
                          return;
                        } else {
                          final newDateTime = DateTime(
                              _purchaseDate.year,
                              _purchaseDate.month,
                              _purchaseDate.day,
                              time.hour,
                              time.minute
                          );
                          setState(() {
                            _purchaseDate = newDateTime;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                        decoration: BoxDecoration(
                            color: color1,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                width: 1,
                                color: color1
                            )
                        ),
                        child: Text('$hours:$minutes', style: TextStyle( fontSize: 13),),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          isComp
              ? SizedBox()
              : Text('Due Date', style: TextStyle(color: isToday(_dateTime)
              ?Colors.red
              :secondaryColor)),
          isComp
              ? SizedBox()
              : InkWell(
            onTap: _showDatePicker,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                  color: _dateTime.isBefore(justToday)?Colors.red.withOpacity(0.5):color1,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: isToday(_dateTime)
                          ?Colors.red
                          :color1,
                      width: 1
                  )
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Center(
                          child: Text(
                            DateFormat.yMMMd().format(_dateTime),
                            style: TextStyle(color: isToday(_dateTime)
                                ?Colors.red
                                :null
                            ),
                          )
                      )
                  ),
                  LineIcon.calendar(color: isToday(_dateTime)
                      ?Colors.red
                      :null,
                  ),
                ],
              ),
            ),
          ),
         SingleCallAction(action: (){
                final isValidform = formKey.currentState!.validate();
                if(isValidform){
                  if(isComp){
                    _record();
                  } else {
                    if(isToday(_dateTime)){
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Due date can not be same as today. Please select a different due date."),
                            showCloseIcon: true,
                          )
                      );
                    } else {
                      _record();
                    }
                  }
                }
              },title: "Pay",)

        ],
      ),
    );
  }
  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
  void _showDatePicker(){
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    ).then((value) {
      setState(() {
        _dateTime = value!;
      });
    });
  }
  Future<TimeOfDay?> pickTime() => showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: _purchaseDate.hour, minute: _purchaseDate.minute),
  );
  void _showSaleDatePicker(){
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        _purchaseDate = value!;
      });
    });
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item + " Transaction",style: TextStyle(fontSize:13 ),
    ),
  );
}
