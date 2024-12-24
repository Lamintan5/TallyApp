import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/text/text_format.dart';
import 'package:TallyApp/home/tabs/payments.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/payments.dart';
import 'package:TallyApp/models/sales.dart';
import 'package:TallyApp/models/users.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../home/action_bar/chats/message_screen.dart';
import '../../home/action_bar/chats/web_chat.dart';
import '../../models/messages.dart';
import '../profile_images/current_profile.dart';
import '../profile_images/user_profile.dart';

class DialogReceipt extends StatefulWidget {
  final SaleModel sale;
  const DialogReceipt({super.key, required this.sale});

  @override
  State<DialogReceipt> createState() => _DialogReceiptState();
}

class _DialogReceiptState extends State<DialogReceipt> {
  List<SaleModel> _sales = [];

  SaleModel sale = SaleModel(saleid: "");
  UserModel cashier = UserModel(uid: "");

  int items = 0;
  int units = 0;
  
  double amount = 0;
  double paid = 0;
  double balance = 0;



  _getData(){
    sale = widget.sale;
    cashier = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).firstWhere((test) => test.uid==sale.sellerid.toString(),
        orElse: ()=>UserModel(uid: "",username: "N/A"));
    _sales = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((test) => test.saleid == sale.saleid).toList();
    items = _sales.length;
    units = _sales.isEmpty ? 0 : _sales.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
    amount = double.parse(sale.amount.toString());
    paid = double.parse(sale.paid.toString());
    balance = amount - paid;

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
    final reverse =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final normal =  Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final heading = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
    final padding = EdgeInsets.symmetric(vertical: 8, horizontal: 10);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(top: 20, bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.green.withOpacity(0.1)
          ),
          child: Icon(Icons.check_circle, color: Colors.green,size: 30,),
        ),
        Text("Payment Success!",textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
        Text("You payment has been successfully recorded",textAlign: TextAlign.center, style: TextStyle(color: secondaryColor),),
        Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 30,),
                    Card(
                      elevation: 8,
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Basic Information", style: heading,),
                              ],
                            ),
                            horizontalItems("Ref Code",sale.saleid.toString().split("-").first.toUpperCase()),
                            horizontalItems("Items Sold",items.toString()),
                            horizontalItems("Total Units",units.toString()),
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
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Payment Details", style: heading,),
                              ],
                            ),
                            horizontalItems("Amount Due","${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(amount)}"),
                            horizontalItems("Amount Paid","${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paid)}"),
                            horizontalItems("Balance","${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)}"),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Status", style: TextStyle(fontSize: 15, color: secondaryColor),),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                   decoration: BoxDecoration(
                                     color:balance == 0?  Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                     borderRadius: BorderRadius.circular(100)
                                   ),
                                    child: Center(child: Text(balance == 0? "Complete":"Incomplete",
                                      style: TextStyle(
                                          color:balance == 0?  Colors.green : Colors.red
                                        ),
                                      )
                                    ),
                                  )
                                ],
                              ),
                            ),
                            horizontalItems("Date Paid", DateFormat('d MMMM y').format(DateTime.parse(sale.time.toString()))),
                            horizontalItems("Time", DateFormat('HH:mm').format(DateTime.parse(sale.time.toString()))),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("  cashier", style: heading,),
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
                            cashier.uid == currentUser.uid
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
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 20),
        //   child: InkWell(
        //     onTap: (){
        //
        //     },
        //     borderRadius: BorderRadius.circular(5),
        //     child: Container(
        //       padding: EdgeInsets.symmetric(vertical: 15),
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(5),
        //        border: Border.all(
        //          color: secBtn,
        //          width: 1
        //        )
        //       ),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Icon(Icons.download, color: secBtn,),
        //           SizedBox(width: 10,),
        //           Text("Get PDF Receipt", style: TextStyle(color: secBtn, fontWeight: FontWeight.w600),)
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        // SizedBox(height: 10,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(5),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: secBtn,
              ),
              child: Center(child: Text("Done", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),)),
            ),
          ),
        ),
        SizedBox(height: 20,)
      ],
    );
  }
  Widget horizontalItems(String title, String value){
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: secondaryColor),),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),

        ],
      ),
    );
  }
  _updateCount(){}
  _changeMess(MessModel messModel){}
}
