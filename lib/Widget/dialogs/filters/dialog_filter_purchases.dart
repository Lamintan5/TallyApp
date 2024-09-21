import 'dart:convert';

import 'package:TallyApp/models/purchases.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

import '../../../main.dart';
import '../../../models/entities.dart';
import '../../../models/users.dart';
import '../../../utils/colors.dart';
import '../../text_filed_input.dart';
import '../call_actions/double_call_action.dart';

class DialogFilterPurchases extends StatefulWidget {
  final EntityModel entity;
  final Function filter;
  final String from;
  const DialogFilterPurchases({super.key, required this.entity, required this.filter, required this.from});

  @override
  State<DialogFilterPurchases> createState() => _DialogFilterPurchasesState();
}

class _DialogFilterPurchasesState extends State<DialogFilterPurchases> {
  TextEditingController _bprice = TextEditingController();
  final formKey = GlobalKey<FormState>();

  List<String> items = ['Cash', 'Electronic'];

  List<UserModel> _user = [];
  List<PurchaseModel> _purchases = [];

  UserModel? selectedUser;

  String? type;
  String purchaserUid = "";
  String pDate = "";
  String dDate = "";
  String pTime = "";

  DateTime _dateTime = DateTime.now();
  DateTime _purchaseDate = DateTime.now();

  _getData(){
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _purchases = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _user = _user.where((user) => _purchases.any((prch) => user.uid==prch.purchaser)).toList();
    setState(() {
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
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
          TextFieldInput(
            textEditingController: _bprice,
            textInputType: TextInputType.number,
            labelText: 'Amount Paid',
            textAlign: TextAlign.center,
            validator: (value) {
              if(value==null || value.isEmpty){
                return null;
              }
              if (RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(value)) {
                return null;
              } else {
                return 'Please enter a valid number';
              }
            },
          ),
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
                        child: Text(pDate==""?"":DateFormat.yMMMd().format(DateTime.parse(pDate)), style: TextStyle(fontSize: 13),),
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(width: 10,),
              // Expanded(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Text("Time :", style: TextStyle(color: secondaryColor),),
              //       InkWell(
              //         onTap: ()async{
              //   child: Column(
              //           final time =await pickTime();
              //           if(time==null){
              //             return;
              //           } else {
              //             final newDateTime = DateTime(
              //                 _purchaseDate.year,
              //                 _purchaseDate.month,
              //                 _purchaseDate.day,
              //                 time.hour,
              //                 time.minute
              //             );
              //             setState(() {
              //               _purchaseDate = newDateTime;
              //               pTime = '${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')}';
              //             });
              //           }
              //         },
              //         child: Container(
              //           width: double.infinity,
              //           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              //           decoration: BoxDecoration(
              //               color: color1,
              //               borderRadius: BorderRadius.circular(5),
              //               border: Border.all(
              //                   width: 1,
              //                   color: color1
              //               )
              //           ),
              //           child: Text(pTime, style: TextStyle(fontSize: 13),),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(width: widget.from == "PAYABLE"?10:0,),
              widget.from == "PAYABLE"?Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Text('Due Date', style: TextStyle(color: secondaryColor),),
                     InkWell(
                      onTap: _showDatePicker,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                            color: color1,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: color1,
                                width: 1
                            )
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                                    dDate==""?"":DateFormat.yMMMd().format(DateTime.parse(dDate))
                                )
                            ),
                            LineIcon.calendar(),

                          ],
                        ),
                      ),
                    ) ,
                  ],
                ),
              ): SizedBox()
            ],
          ),
          _user.isEmpty ? SizedBox() :  Text('Purchaser :', style: TextStyle(color: secondaryColor),),
          _user.isEmpty ? SizedBox() : Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12,),
              decoration: BoxDecoration(
                  color: color1,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      width: 1,
                      color: color1
                  )
              ),
              child:  DropdownButtonHideUnderline(
                child: DropdownButton<UserModel>(
                  value: selectedUser,
                  dropdownColor: dgColor,
                  icon: Icon(Icons.arrow_drop_down, color: reverse),
                  isExpanded: true,
                  items: _user.map((UserModel user) {
                    return DropdownMenuItem<UserModel>(
                      value: user,
                      child: Text(user.username.toString(),style: TextStyle(fontWeight: FontWeight.normal),),
                    );
                  }).toList(),
                  onChanged: (UserModel? newValue) {
                    setState(() {
                      selectedUser = newValue;
                      purchaserUid = newValue!.uid;
                    });
                  },
                ),
              )
          ),
          DoubleCallAction(
            action: ()async{
              Navigator.pop(context);
              widget.filter(
                  _bprice.text.toString()==""?0.0:double.parse(_bprice.text.toString()),
                  type==null?"":type,
                  pDate,
                  dDate,
                  purchaserUid
              );
            },
            title: "Filter",
          ),
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
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((value) {
      setState(() {
        _dateTime = value!;
        dDate = _dateTime.toString();
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
        pDate = _purchaseDate.toString();
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
