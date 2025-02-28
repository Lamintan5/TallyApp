import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Widget/profile_images/current_profile.dart';
import '../../Widget/profile_images/user_profile.dart';
import '../../Widget/text/text_format.dart';
import '../../main.dart';
import '../../models/entities.dart';
import '../../models/messages.dart';
import '../../models/payments.dart';
import '../../models/users.dart';
import '../../utils/colors.dart';
import '../action_bar/chats/message_screen.dart';
import '../action_bar/chats/web_chat.dart';

class Receipt extends StatefulWidget {
  final PaymentModel payment;
  const Receipt({super.key, required this.payment});

  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  List<EntityModel> _enty = [];
  List<UserModel> _user = [];
  List<UserModel> _newUser = [];

  List<String> _expans = ["Basic","Payment"];

  late EntityModel entity;
  late PaymentModel payment;
  late UserModel cashier;

  double paid = 0;
  double due = 0;
  double balance = 0;

  _getData(){
    _enty = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();

    entity = _enty.firstWhere((enty) => enty.eid == payment.eid, orElse: () => EntityModel(eid: "", title: '--'));
    cashier = _user.firstWhere((user) => user.uid == payment.payerid, orElse: () => UserModel(uid: "", username: "--", firstname: "", lastname: "", image: ""));

    if(cashier.uid.isEmpty){
      _getUser();
    }

    paid = double.parse(payment.paid.toString());
    due = double.parse(payment.amount.toString());
    balance = due - paid;
  }

  _getUser()async{
    _newUser = await Services().getCrntUsr(payment.payerid.toString());
    await Data().addOrUpdateUserList(_newUser);
    cashier = _newUser.isNotEmpty? _newUser.first:UserModel(uid: "", username: "--", firstname: "", lastname: "", image: "");
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    payment = widget.payment;
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final reverse =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final normal =  Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final statusColor = balance > 0 ? CupertinoColors.systemRed : CupertinoColors.activeGreen;
    final heading = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
    final padding = EdgeInsets.symmetric(vertical: 8, horizontal: 10);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: Container(
                  width: 500,
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 50),
                        Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: secBtn.withOpacity(0.15)
                            ),
                            child: Icon(CupertinoIcons.doc_plaintext,color: secBtn, size: 30,)
                        ),
                        SizedBox(height: 5,),
                        Text("Receipt", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),),
                        SizedBox(height: 20,),
                        Card(
                          elevation: 8,
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Padding(
                            padding: padding,
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if(_expans.contains("Basic")){
                                        _expans.remove("Basic");
                                      } else {
                                        _expans.add("Basic");
                                      }
                                    });
                                  },
                                  hoverColor: color1,
                                  borderRadius: BorderRadius.circular(5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Basic Information", style: heading,),
                                      AnimatedRotation(
                                        duration: Duration(milliseconds: 500),
                                        turns: _expans.contains("Basic") ? 0.5 : 0.0,
                                        child: Icon(Icons.keyboard_arrow_down),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedSize(
                                  duration: Duration(milliseconds: 500),
                                  alignment: Alignment.topCenter,
                                  curve: Curves.easeInOut,
                                  child: _expans.contains("Basic")?  Column(
                                    children: [
                                      horizontalItems("Property", entity.title.toString().split("-").first),
                                      horizontalItems("No of Items", payment.items.toString()),
                                      horizontalItems("Account", TFormat().toCamelCase(payment.type.toString())),
                                    ],
                                  ) : SizedBox(),
                                ),

                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Card(
                          elevation: 8,
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Padding(
                            padding: padding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if(_expans.contains("Payment")){
                                        _expans.remove("Payment");
                                      } else {
                                        _expans.add("Payment");
                                      }
                                    });
                                  },
                                  hoverColor: color1,
                                  borderRadius: BorderRadius.circular(5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Payment Details", style: heading,),
                                      AnimatedRotation(
                                        duration: Duration(milliseconds: 500),
                                        turns: _expans.contains("Payment") ? 0.5 : 0.0,
                                        child: Icon(Icons.keyboard_arrow_down),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedSize(
                                  duration: Duration(milliseconds: 500),
                                  alignment: Alignment.topCenter,
                                  curve: Curves.easeInOut,
                                  child:_expans.contains("Payment")?  Column(
                                    children: [
                                      horizontalItems("Receipt ID", payment.payid.toString().split("-").first.toUpperCase()),
                                      horizontalItems("Amount Due", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(due)}'),
                                      horizontalItems("Balance", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)}'),
                                      horizontalItems("Amount Paid", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paid)}'),
                                      Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Status", style: TextStyle(fontSize: 15, color: secondaryColor),),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: statusColor.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(50)
                                              ),
                                              child: Text(
                                                balance > 0 ? "Incomplete" : "Complete",
                                                style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),),
                                            )
                                          ],
                                        ),
                                      ),
                                      horizontalItems("Date Paid", DateFormat('d MMMM y ● HH:mm').format(DateTime.parse(payment.time.toString()))),

                                    ],
                                  ) : SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("  Cashier", style: heading,),
                          ],
                        ),
                        Card(
                          elevation: 8,
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                            child: Row(
                              children: [
                                cashier.uid==currentUser.uid
                                    ? CurrentImage(radius: 20,)
                                    : UserProfile(image: cashier.image.toString(), radius: 20,),
                                SizedBox(width: 10,),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(cashier.username.toString(), style: TextStyle(fontWeight: FontWeight.w500),),
                                      Text("${cashier.firstname.toString()} ${cashier.lastname.toString()}", style: TextStyle(color: secondaryColor),),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20,),
                                cashier.uid == currentUser.uid || cashier.uid.isEmpty
                                    ? SizedBox()
                                    :  Row(
                                        children: [
                                            InkWell(
                                              onTap: (){
                                                Platform.isIOS || Platform.isAndroid
                                                    ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: cashier,), transition: Transition.rightToLeft)
                                                    : Get.to(() => WebChat(selected: cashier), transition: Transition.rightToLeft);
                                              },
                                              borderRadius: BorderRadius.circular(50),
                                              splashColor: secBtn,
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: color1,
                                                    borderRadius: BorderRadius.circular(50)
                                                ),
                                                child: Icon(CupertinoIcons.text_bubble, color: reverse,size: 18,),
                                              ),
                                            ),
                                            SizedBox(width: 10,),
                                            InkWell(
                                              onTap: (){
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text("Feature currently unavailable"),
                                                      showCloseIcon: true,
                                                    )
                                                );
                                              },
                                              borderRadius: BorderRadius.circular(50),
                                              splashColor: secBtn,
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: color1,
                                                    borderRadius: BorderRadius.circular(50)
                                                ),
                                                child: Icon(CupertinoIcons.phone, color: reverse,size: 18,),
                                              ),
                                            ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
            ),
            Container(
              width: 500,
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  color: secBtn,
                  borderRadius: BorderRadius.circular(15)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Paid", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: normal),),
                  Text(
                    "${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paid)}",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: normal),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget horizontalItems(String title, String value){
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: secondaryColor),),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
        ],
      ),
    );
  }
  _updateCount(){}
  _changeMess(MessModel messModel){}
}
