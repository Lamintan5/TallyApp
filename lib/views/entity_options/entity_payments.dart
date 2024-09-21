import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/buttons/card_button.dart';
import '../../Widget/items/item_paymements.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/entities.dart';
import '../../models/payments.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';

class EntityPayments extends StatefulWidget {
  final EntityModel entity;
  const EntityPayments({super.key, required this.entity});

  @override
  State<EntityPayments> createState() => _EntityPaymentsState();
}

class _EntityPaymentsState extends State<EntityPayments> {
  List<String> title = ['In-Payments', 'Out-Payments', 'Transactions', 'Units Sold','Units Purchased', 'Customers'];
  List<PaymentModel> _pay = [];
  List<PaymentModel> _newpay = [];
  List<PaymentModel> _sale = [];
  List<PaymentModel> _purchase = [];

  bool _loading = false;
  bool _reloading = false;
  bool close = true;

  double inPay = 0;
  double outPay = 0;

  int removed = 0;

  _getDetails()async{
    _getData();
    _newpay = await Services().getMyPayments(currentUser.uid);
    await Data().addOrUpdatePayments(_newpay);
    _getData();
  }
  _getData(){
    _pay = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();
    _pay = _pay.where((element) => element.eid == widget.entity.eid).toList();
    _sale = _pay.where((element) => element.type == "SALE" || element.type == "RECEIVABLE").toList();
    _purchase = _pay.where((element) => element.type == "PURCHASE" || element.type == "PAYABLE").toList();
    inPay = _sale.fold(0, (previousValue, element) => previousValue + double.parse(element.paid.toString()));
    outPay = _purchase.fold(0, (previousValue, element) => previousValue + double.parse(element.paid.toString()));
    _pay.sort((a, b) => DateTime.parse(a.time.toString()).compareTo(DateTime.parse(b.time.toString())));
    removed = _pay.where((element) => element.checked == "REMOVED").length;
    close = removed > 0 ?false: true;
    setState(() {
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(" Payments", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30),),
              SizedBox(height: 10,),
              Expanded(child:
              SingleChildScrollView(
                child: Column(
                  children: [
                    GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:  const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 1
                        ),
                        itemCount: title.length,
                        itemBuilder: (context, index){
                          return Card(
                            margin: EdgeInsets.all(5),
                            elevation: 3,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(title[index], style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black),),
                                SizedBox(height: 10,),
                                Text(
                                  index==0
                                      ?'Ksh.${formatNumberWithCommas(inPay)}'
                                      : index==1
                                      ? 'Ksh.${formatNumberWithCommas(outPay)}'
                                      : index==2
                                      ? _pay.length.toString()
                                      : index==3
                                      ?_sale.length.toString()
                                      : index==4
                                      ?_purchase.length.toString()
                                      :"0",
                                  style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),
                                )
                              ],
                            ),
                          );
                        }),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        SizedBox(width: 10,),
                        _reloading || _loading
                            ? SizedBox(
                            width: 15, height: 15,
                            child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2,))
                            : SizedBox(),
                        Expanded(child: SizedBox()),
                        CardButton(
                          text:'FILTER',
                          backcolor: Colors.white,
                          icon: Icon(Icons.filter_list, size: 19, color: Colors.black,), forecolor: Colors.black,
                          onTap: () {

                          },
                        ),
                        CardButton(
                          text:'RELOAD',
                          backcolor: screenBackgroundColor,
                          icon: Icon(Icons.refresh, size: 19, color: Colors.white,), forecolor: Colors.white,
                          onTap: (){_getDetails();},
                        ),
                      ],
                    ),
                    close == false
                        ? ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 400,
                        maxWidth: 600,
                      ),
                      child: Card(
                        color: Colors.white,
                        elevation: 8,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.delete, size: 30, color: Colors.red,),
                              SizedBox(width: 15,),
                              Expanded(
                                child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(fontSize: 13),
                                        children: [
                                          TextSpan(
                                              text: "Attention: ",
                                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)
                                          ),
                                          TextSpan(
                                              text: "${removed.toString()} ",
                                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)
                                          ),
                                          TextSpan(
                                              text: removed > 1? "payment records have " : "payment record has ",
                                              style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                          ),
                                          TextSpan(
                                              text: "been removed from our server by one of the managers. This change may impact your data. Would you like to update your list to reflect these changes? ",
                                              style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                          ),
                                          WidgetSpan(
                                              child: InkWell(
                                                  onTap: (){
                                                    _removeAll();
                                                  },
                                                  child: Text("Remove All", style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.bold),)
                                              )
                                          )
                                        ]
                                    )
                                ),
                              ),
                              InkWell(
                                  onTap: (){
                                    setState(() {
                                      close = true;
                                    });
                                  },
                                  child: Icon(Icons.close, size: 30,color: Colors.black,)
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                        : SizedBox(),
                    SizedBox(height: 10,),
                    Container(
                      constraints: BoxConstraints(
                        minWidth: 400,
                        maxWidth: 500,
                      ),
                      child: GroupedListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.all(5),
                        order: GroupedListOrder.DESC,
                        elements: _pay,
                        groupBy: (payment) => DateTime(
                          DateTime.parse(payment.time.toString()).year,
                          DateTime.parse(payment.time.toString()).month,
                          DateTime.parse(payment.time.toString()).day,
                        ),
                        groupHeaderBuilder: (PaymentModel payment) {
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final yesterday = today.subtract(Duration(days: 1));
                          final time = DateTime.parse(payment.time.toString());
                          return Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              margin: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                time.year == now.year && time.month == now.month && time.day == now.day
                                    ? 'Today'
                                    : time.year == yesterday.year && time.month == yesterday.month && time.day == yesterday.day
                                    ? 'Yesterday'
                                    : DateFormat.yMMMd().format(time),
                                style: TextStyle(fontSize: 9),
                              ),
                            ),
                          );
                        },
                        itemComparator: (item1, item2) => DateTime.parse(item1.time.toString()).compareTo(DateTime.parse(item2.time.toString())),
                        indexedItemBuilder : (BuildContext context, PaymentModel payment, int index) {
                          return ItemPayments(payment: payment, from: "Entity",);
                        },
                      ),
                    ),
                  ],
                ),
              )
              )
            ],
          ),
        ),
      ),
    );
  }
  _removeAll()async{
    List<String> uniquePayment = [];
    List<PaymentModel> _payments = [];

    List<PaymentModel> payToRemove = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _payments = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();

    _payments.where((test)=>test.checked.toString().contains("REMOVED")).forEach((payment){
      payToRemove.add(payment);
    });

    for (var payment in payToRemove) {
      _payments.removeWhere((element) => element.payid == payment.payid);
    }

    uniquePayment  = _payments.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypayments', uniquePayment);
    myPayments = uniquePayment;
    _getData();
  }
  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
