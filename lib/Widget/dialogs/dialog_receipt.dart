import 'dart:convert';

import 'package:TallyApp/Widget/text/text_format.dart';
import 'package:TallyApp/home/tabs/payments.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/payments.dart';
import 'package:TallyApp/models/sales.dart';
import 'package:TallyApp/models/users.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DialogReceipt extends StatefulWidget {
  final SaleModel sale;
  const DialogReceipt({super.key, required this.sale});

  @override
  State<DialogReceipt> createState() => _DialogReceiptState();
}

class _DialogReceiptState extends State<DialogReceipt> {
  List<SaleModel> _sales = [];

  SaleModel sale = SaleModel(saleid: "");
  UserModel sender = UserModel(uid: "");

  int items = 0;
  int units = 0;
  
  double amount = 0;
  double paid = 0;
  double balance = 0;



  _getData(){
    sale = widget.sale;
    sender = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).firstWhere((test) => test.uid==sale.sellerid.toString(),
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
    final secColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(top: 20, bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.green.withOpacity(0.1)
          ),
          child: Icon(Icons.check_circle, color: Colors.green,),
        ),
        Text("Payment Success!",textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        Text("You payment has been successfully recorded",textAlign: TextAlign.center,),
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
                            horizontalItems("Ref Code",sale.saleid.toString().split("-").first.toUpperCase()),
                            horizontalItems("Items Sold",items.toString()),
                            horizontalItems("Total Units",units.toString()),
                            horizontalItems("Date",DateFormat.yMMMEd().format(DateTime.parse(sale.time.toString()))),
                            horizontalItems("Time",DateFormat.Hm().format(DateTime.parse(sale.time.toString()))),
                            horizontalItems("Sender",sender.username.toString()),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
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
                            horizontalItems("Amount Due","${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(amount)}"),
                            horizontalItems("Amount Paid","${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paid)}"),
                            horizontalItems("Balance","${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)}"),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Payment Status", style: TextStyle(fontSize: 15, color: secondaryColor),),
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
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
                            )
                          ],
                        ),
                      ),
                    ),
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
        //          color: secColor,
        //          width: 1
        //        )
        //       ),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Icon(Icons.download, color: secColor,),
        //           SizedBox(width: 10,),
        //           Text("Get PDF Receipt", style: TextStyle(color: secColor, fontWeight: FontWeight.w600),)
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
                color: secColor,
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
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: secondaryColor),),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),

        ],
      ),
    );
  }
}
