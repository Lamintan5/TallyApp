import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/purchases.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

import '../../main.dart';
import '../../utils/colors.dart';
import '../text_filed_input.dart';
import 'call_actions/double_call_action.dart';

class DialogEditPrchses extends StatefulWidget {
  final PurchaseModel purchase;
  final Function getData;
  final String from;
  const DialogEditPrchses({super.key, required this.purchase, required this.getData, required this.from});

  @override
  State<DialogEditPrchses> createState() => _DialogEditPrchsesState();
}

class _DialogEditPrchsesState extends State<DialogEditPrchses> {
  final formKey = GlobalKey<FormState>();
  List<String> items = ['Cash', 'Electronic'];
  TextEditingController _bprice = TextEditingController();
  String? type;
  DateTime _dateTime = DateTime.now();
  DateTime _purchaseDate = DateTime.now();
  bool _loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _purchaseDate = DateTime.parse(widget.purchase.date.toString());
    _bprice.text = widget.purchase.paid.toString();
    _dateTime = DateTime.parse(widget.purchase.due.toString());
    type = widget.purchase.type.toString();
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final dgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
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
          SizedBox(height: 5),
          TextFieldInput(
            textEditingController: _bprice,
            textInputType: TextInputType.number,
            labelText: 'Amount Paid',
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the correct amount';
              } else if (RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(value)) {
                double? enteredValue = double.tryParse(value);
                double? maxAmount = double.parse(widget.purchase.amount.toString());
                if (enteredValue != null && enteredValue > maxAmount) {
                  return 'The amount should not exceed $maxAmount';
                }
                return null;
              } else {
                return 'Please enter a valid number';
              }
            },
          ),
          SizedBox(height: 5,),
          Text('Payment Method : ', style: TextStyle(color: secondaryColor),),
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
                dropdownColor: dgColor,
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                isExpanded: true,
                items: items.map(buildMenuItem).toList(),
                onChanged: (value) => setState(() => this.type = value),
              ),
            ),
          ),
          SizedBox(height: 10),
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
                        child: Text(DateFormat.yMMMd().format(_purchaseDate), style: TextStyle(fontSize: 13),),
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
                        child: Text('$hours:$minutes', style: TextStyle(fontSize: 13),),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          widget.from == "PAYABLE"? Text('Due Date', style: TextStyle(color: secondaryColor),) : SizedBox(),
          widget.from == "PAYABLE"? InkWell(
            onTap: _showDatePicker,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                  color: _dateTime.isBefore(justToday)?Colors.red.withOpacity(0.5):color1,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: color1,
                      width: 1
                  )
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Center(
                          child: Text(
                            DateFormat.yMMMd().format(_dateTime),
                          )
                      )
                  ),
                  LineIcon.calendar(),

                ],
              ),
            ),
          ) : SizedBox(),
          SizedBox(height: widget.from == "PAYABLE"? 10 : 0),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                            setState(() {
                              _loading = true;
                            });
                            await Data().editPurchases(
                              context,
                              widget.getData,
                              widget.purchase.purchaseid,
                              _bprice.text.toString(),
                              widget.purchase.amount.toString(),
                              type.toString(),
                              _purchaseDate.toString(),
                              _dateTime.toString(),
                            ).then((value){
                              setState(() {
                                _loading = value;
                              });
                              Navigator.pop(context);
                            });
                          },
                          child: SizedBox(height: 40,
                            child: Center(
                              child: _loading
                                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: CupertinoColors.systemBlue,strokeWidth: 2,))
                                  :Text(
                                "Change",
                                style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w700, fontSize: 15),
                                textAlign: TextAlign.center,),
                            ),
                          ),
                        )
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
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
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item + " Transaction",
    ),
  );
}
