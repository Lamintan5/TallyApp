import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Widget/text_filed_input.dart';
import '../../../models/billing.dart';
import '../../../models/data.dart';
import '../../../models/entities.dart';
import '../../../models/gate_way.dart';
import '../../../resources/services.dart';
import '../../../utils/colors.dart';

class BillScreen extends StatefulWidget {
  final EntityModel entity;
  final GateWayModel card;
  final BillingModel bill;
  final Function reload;
  final Function removeBill;
  const BillScreen({super.key, required this.entity, required this.card, required this.bill, required this.reload, required this.removeBill});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  List<String> _paybilloptions = ['One account for all units', 'Different accounts for different units'];

  final key = GlobalKey<FormState>();
  final _porchKey = GlobalKey<FormState>();
  final _tillKey = GlobalKey<FormState>();

  late TextEditingController _accno;
  late TextEditingController _busno;
  late TextEditingController _phone;
  late TextEditingController _till;

  late GateWayModel card;
  late BillingModel bill;

  bool _edit = false;
  bool _editing = false;
  bool _deleting = false;

  _getData(){
    _busno = TextEditingController();
    _accno = TextEditingController();
    _phone = TextEditingController();
    _till = TextEditingController();
    card = widget.card;
    bill = widget.bill;
    _busno.text = bill.businessno.toString();
    _accno.text = bill.accountno.toString();
    _phone.text = bill.phone.toString();
    _till.text = bill.tillno.toString();

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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _busno.dispose();
    _accno.dispose();
    _phone.dispose();
    _till.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(width: 20, height: 20, card.logo),
            SizedBox(width: 10,),
            Text(card.title)
          ],
        ),
        actions: [
          _deleting
              ? Container(
              width: 20,
              height: 20 ,
              margin: EdgeInsets.only(right: 10),
              child: CircularProgressIndicator(color: reverse,strokeWidth: 3,)
          )
              : PopupMenuButton(
              itemBuilder: (BuildContext context){
                return [
                  if(!_edit)
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.pen),
                          SizedBox(width: 5,),
                          Text('Edit'),
                        ],
                      ),
                      onTap: (){
                        setState(() {
                          _edit = true;
                        });
                      },
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.delete),
                        SizedBox(width: 5,),
                        Text('Delete'),
                      ],
                    ),
                    onTap: (){
                      // dialogRemove(context);
                    },
                  ),
                ];
              })
        ],
      ),
      body: Center(
        child: Container(
          width: 500,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: _edit
              ? bill.type =="BPB"
                ? Form(
                key: key,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    SizedBox(height: 30,),
                    Text(
                      "Update Pay Bill Detail",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10,),
                    TextFieldInput(
                      textEditingController: _busno,
                      labelText: "Business Number",
                      textInputType: TextInputType.number,
                      validator: (value){
                        if (value == null || value.isEmpty) {
                          return 'Please enter business number.';
                        }
                        if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
                          return null; // Valid input (contains only digits)
                        } else {
                          return 'Please enter a valid business number';
                        }
                      },
                    ),
                    SizedBox(height: 10,),
                    TextFieldInput(
                      textEditingController: _accno,
                      labelText: "Account Number",
                      textInputType: TextInputType.text,
                      validator: (value){
                        if (value == null || value.isEmpty) {
                          return 'Please enter account number.';
                        }
                      },
                    ),
                    SizedBox(height: 20,),
                    InkWell(
                      onTap: (){
                        final form = key.currentState!;
                        if(form.validate()) {
                          _update();
                        }
                      },
                      child: Container(
                        width: 500,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: secBtn
                        ),
                        child: Center(
                            child: _editing
                                ? SizedBox(
                                width: 15, height: 15,
                                child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,)
                            )
                                : Text(
                              "Update", style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                            ),
                            )
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: (){
                          setState(() {
                            _edit = false;
                            _busno.text = bill.businessno.toString();
                            _accno.text = bill.accountno.toString();
                          });
                        },
                        child: Text("Cancel")
                    )
                  ],
                ),
              )
                : bill.type == "Porchi"
                ? Form(
                    key: _porchKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        SizedBox(height: 30,),
                        Text(
                          "Update Phone Number",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10,),
                        TextFieldInput(
                          textEditingController: _phone,
                          labelText: "Phone",
                          maxLength: 13,
                          textInputType: TextInputType.phone,
                          validator: (value){
                            if (value == null || value.isEmpty) {
                              return 'Please enter a phone number.';
                            }
                            if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
                              return null;
                            } else {
                              return 'Please enter a valid phone number';
                            }
                          },
                        ),
                        SizedBox(height: 20,),
                        InkWell(
                          onTap: (){
                            final form = _porchKey.currentState!;
                            if(form.validate()) {
                              _update();
                            }
                          },
                          child: Container(
                            width: 500,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: secBtn
                            ),
                            child: Center(
                                child: _editing
                                    ? SizedBox(
                                    width: 15, height: 15,
                                    child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,)
                                )
                                    : Text(
                                  "Update", style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                                ),
                                )
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: (){
                              setState(() {
                                _edit = false;
                                _phone.text = bill.businessno.toString();
                              });
                            },
                            child: Text("Cancel")
                        )
                      ],
                    )
                  )
                : bill.type == "BBG"
                ? Form(
                    key: _tillKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        SizedBox(height: 30,),
                        Text(
                          "Update Till Number",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10,),
                        TextFieldInput(
                          textEditingController: _till,
                          labelText: "Till Number",
                          textInputType: TextInputType.number,
                          validator: (value){
                            if (value == null || value.isEmpty) {
                              return 'Please enter business number.';
                            }
                            if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
                              return null;
                            } else {
                              return 'Please enter a valid business number';
                            }
                          },
                        ),
                        SizedBox(height: 20,),
                        InkWell(
                          onTap: (){
                            final form = _tillKey.currentState!;
                            if(form.validate()) {
                              _update();
                            }
                          },
                          child: Container(
                            width: 500,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: secBtn
                            ),
                            child: Center(
                                child: _editing
                                    ? SizedBox(
                                    width: 15, height: 15,
                                    child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,)
                                )
                                    : Text(
                                  "Update", style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                                ),
                                )
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: (){
                              setState(() {
                                _edit = false;
                                _phone.text = bill.businessno.toString();
                              });
                            },
                            child: Text("Cancel")
                        )
                      ],
                    )
                )
                : SizedBox()
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: color1
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          bill.type=="Porchi"
                              ?"Phone Number"
                              :bill.type=="BBG"
                              ?"Till Number"
                              :"Business Number",
                          style: TextStyle(color: secondaryColor),
                        ),
                        Text(
                            bill.type.toString() =="Porchi"
                                ?bill.phone.toString()
                                :bill.type.toString()=="BBG"
                                ?bill.tillno.toString()
                                :bill.businessno.toString()
                        ),
                      ],
                    ),
                  ),
                  bill.type=="BPB"
                      ?Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: color1
                    ),
                    child:bill.type == "Different"
                        ? Text(
                      "Different accounts for different units",
                      style: TextStyle(color: secondaryColor),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Account no",
                          style: TextStyle(color: secondaryColor),
                        ),
                        Text(bill.accountno.toString()),
                      ],
                    ),
                  )
                      :SizedBox(),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: color1
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Created on",
                          style: TextStyle(color: secondaryColor),
                        ),
                        Text(DateFormat.yMMMEd().format(DateTime.parse(bill.time.toString()))),
                      ],
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: CupertinoColors.activeGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.checkmark_shield_fill, color: CupertinoColors.activeGreen,size: 40,),
                        SizedBox(width: 10,),
                        Expanded(
                            child:
                            Text(
                              'We adhere entirely to the data security standards of the payment card industry.',

                            )
                        ),
                        SizedBox(width: 10,),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      )
    );
  }
  void _update()async{
    setState(() {
      _editing = true;
    });
    List<String> _account = [];
    await Services.updateBill(
        widget.bill.bid,
        _busno.text,
        _accno.text,
        _phone.text,
        _till.text
    ).then((value)async{
      if(value=="success"){
        setState(() {
          bill.businessno = _busno.text;
          bill.accountno = _accno.text;
          bill.phone = _phone.text;
          bill.tillno = _till.text;
          _editing = false;
          _edit = false;
        });
        await Data().editBill(bill);
        widget.reload();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Account was updated successfully"),
              showCloseIcon: true,
            )
        );
      } else if(value=="failed"){
        setState(() {
          _editing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Account was not updated please try again"),
              showCloseIcon: true,
            )
        );
      }
    });
  }
}
