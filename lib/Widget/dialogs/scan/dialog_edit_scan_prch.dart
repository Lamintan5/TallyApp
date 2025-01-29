import 'package:TallyApp/models/purchases.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../text/text_format.dart';
import '../../text_filed_input.dart';

class DialogEditScanPrch extends StatefulWidget {
  final PurchaseModel purchase;
  final Function update;
  final double amount;
  const DialogEditScanPrch({super.key, required this.purchase, required this.update, required this.amount});

  @override
  State<DialogEditScanPrch> createState() => _DialogEditScanPrchState();
}

class _DialogEditScanPrchState extends State<DialogEditScanPrch> {
  final formKey = GlobalKey<FormState>();

  TextEditingController _pay = TextEditingController();

  List<String> items = ['Cash', 'Electronic'];
  String? method;
  DateTime _dateTime = DateTime.now();
  DateTime _purchaseDate = DateTime.now();
  bool _loading = false;
  bool isComp = true;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    amount =  widget.amount;
    _pay.text = widget.purchase.paid.toString() =="0.0"? widget.amount.toString() :widget.purchase.paid.toString();
    method = widget.purchase.type.toString() == "" ? "Cash" : widget.purchase.type.toString();
    _purchaseDate = DateTime.parse(widget.purchase.date.toString());
    _dateTime = DateTime.parse(widget.purchase.due.toString());
    isComp = amount==double.parse(_pay.text.toString()) ? true : false;
    _pay.addListener(_handlePaymentChange);
  }

  @override
  void dispose() {
    _pay.removeListener(_handlePaymentChange);
    _pay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final hours = _purchaseDate.hour.toString().padLeft(2, '0');
    final minutes = _purchaseDate.minute.toString().padLeft(2, '0');
    return Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldInput(
              textEditingController: _pay,
              textInputType: TextInputType.numberWithOptions(decimal: true),
              labelText: 'Amount Paid',
              textAlign: TextAlign.center,
              validator: _validateAmount,
            ),
            SizedBox(height: 5,),
            Text(' Payment method :  ', style: TextStyle(color: secondaryColor),),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12,),
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      width: 1,
                      color: color
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
                              color: color,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  width: 1,
                                  color: color
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
                              color: color,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  width: 1,
                                  color: color
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
                                  :null),
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
            Divider(
              thickness: 0.2,
              color: reverse,
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                      child: InkWell(
                        onTap: (){Navigator.pop(context);},
                        child: SizedBox(height: 40,
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w700, fontSize: 15),
                              textAlign: TextAlign.center,),
                          ),
                        ),
                      )
                  ),
                  VerticalDivider(
                    thickness: 0.2,
                    color: reverse,
                  ),
                  Expanded(
                      child: InkWell(
                        onTap: ()async{
                          final isValidform = formKey.currentState!.validate();
                          if(isValidform){
                            setState(() {
                              _loading = true;
                            });
                            if(isComp){
                              widget.update(
                                  widget.purchase,
                                  _pay.text.toString(),
                                  method.toString(),
                                  _purchaseDate.toString(),
                                  _dateTime.toString()
                              );
                              Navigator.pop(context);
                            } else if (!isComp && _dateTime.isAfter(justToday)){
                              widget.update(
                                  widget.purchase,
                                  _pay.text.toString(),
                                  method.toString(),
                                  _purchaseDate.toString(),
                                  _dateTime.toString()
                              );
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: SizedBox(height: 40,
                          child: Center(
                            child: _loading
                                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: CupertinoColors.systemBlue,strokeWidth: 2,))
                                : Text(
                              "Change",
                              style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w700, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
  Future<TimeOfDay?> pickTime() => showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: _purchaseDate.hour, minute: _purchaseDate.minute),
  );
  void _showDatePicker(){
    showDatePicker(
      context: context,
      initialDate: _dateTime.isBefore(justToday)? DateTime.now() :  _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    ).then((value) {
      setState(() {
        _dateTime = value!;
      });
    });
  }
  void _showSaleDatePicker(){
    showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        _purchaseDate = value!;
      });
    });
  }
  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      '${item} Transaction',
    ),
  );
}
