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
  String fDate = "";
  String tDate = "";
  String dDate = "";
  String pTime = "";

  DateTime _dateTime = DateTime.now();
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

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

    final hours = _fromDate.hour.toString().padLeft(2, '0');
    final minutes = _fromDate.minute.toString().padLeft(2, '0');
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
                  children: [
                    Text(" From", style: TextStyle(color: secondaryColor),),
                    InkWell(
                      onTap: (){
                        _showFromDatePicker();
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
                        child: Text(fDate==""?"":DateFormat.yMMMd().format(DateTime.parse(fDate)), style: TextStyle( fontSize: 13),),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("To", style: TextStyle(color: secondaryColor),),
                    InkWell(
                      onTap: (){
                        _showToDatePicker();
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
                        child: Text(tDate==""?"":DateFormat.yMMMd().format(DateTime.parse(tDate)), style: TextStyle( fontSize: 13),),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          widget.from=="PURCHASE"? SizedBox() : SizedBox(width: 5,),
          widget.from=="PURCHASE"? SizedBox() : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(" Due Date", style: TextStyle(color: secondaryColor),),
              InkWell(
                onTap: (){
                  _showDueDatePicker();
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
                  child: Text(dDate==""?"":DateFormat.yMMMd().format(DateTime.parse(dDate)), style: TextStyle( fontSize: 13),),
                ),
              ),
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
                  fDate,
                  tDate,
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
    initialTime: TimeOfDay(hour: _fromDate.hour, minute: _fromDate.minute),
  );
  void _showDueDatePicker(){
    showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((value) {
      setState(() {
        _dateTime = value!;
        dDate = _dateTime.toString();
      });
    });
  }
  void _showFromDatePicker(){
    showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        _fromDate = value!;
        fDate = _fromDate.toString();
        if(tDate.isEmpty){
          tDate = fDate;
          _toDate = value;
        }
      });
    });
  }
  void _showToDatePicker(){
    showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        _toDate = value!;
        tDate = _toDate.toString();
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
