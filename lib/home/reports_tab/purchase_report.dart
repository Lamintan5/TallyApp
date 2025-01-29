import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Widget/buttons/card_button.dart';
import '../../Widget/extras/entity_purchase_report.dart';
import '../../Widget/graphs/weekly_purchase_bar.dart';
import '../../Widget/text/text_format.dart';
import '../../main.dart';
import '../../models/purchases.dart';
import '../../utils/colors.dart';

class PurchaseReport extends StatefulWidget {
  const PurchaseReport({super.key});

  @override
  State<PurchaseReport> createState() => _PurchaseReportState();
}

class _PurchaseReportState extends State<PurchaseReport> {
  List<String> title = ['Purchase','Payables'];
  List<PurchaseModel> _purchase = [];
  List<PurchaseModel> _payable = [];
  List<PurchaseModel> _newPayable = [];

  List<PurchaseModel> _lastMnthPurchase = [];
  List<PurchaseModel> _mnthPurchase = [];
  List<PurchaseModel> _lastMnthPayable= [];
  List<PurchaseModel> _mnthPayable = [];

  bool _loading = false;
  bool _period = true;

  double totalPurchase = 0.0;
  double totalPayable = 0.0;

  double purchasePerform = 0.0;
  double payablePerform = 0.0;

  double totalLstMnthPurchase = 0.0;
  double totalMnthPurchase = 0.0;
  double totalLstMnthPayable = 0.0;
  double totalMnthPayable = 0.0;

  _getPurchases()async{
    setState(() {
      _loading = true;
    });
    _purchase = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid && element.pid.toString().contains(currentUser.uid)).toList();
    _payable =  myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).where((element) => element.amount != element.paid && element.pid.toString().contains(currentUser.uid)).toList();
    setState(() {
      for (var payable in _payable) {
        bool idExists = _newPayable.any((element) => element.purchaseid == payable.purchaseid);
        if (!idExists) {
          _newPayable.add(payable);
        }
      }
      totalPurchase = _purchase.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * int.parse(element.quantity.toString())));
      totalPayable = _newPayable.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));

      _lastMnthPurchase = _purchase.where((element) => DateTime.parse(element.time.toString()).month == DateTime.now().month -1).toList();
      _lastMnthPayable = _newPayable.where((element) => DateTime.parse(element.time.toString()).month == DateTime.now().month -1).toList();
      _mnthPurchase = _purchase.where((element) => DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _mnthPayable = _newPayable.where((element) => DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();

      totalLstMnthPurchase = _lastMnthPurchase.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * int.parse(element.quantity.toString())));
      totalMnthPurchase =_mnthPurchase.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * int.parse(element.quantity.toString())));
      totalLstMnthPayable = _lastMnthPayable.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
      totalMnthPayable =_mnthPayable.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));

      purchasePerform = (totalMnthPurchase-totalLstMnthPurchase)/totalLstMnthPurchase*100;
      payablePerform = (totalMnthPurchase-totalLstMnthPurchase)/totalLstMnthPurchase*100;

      _loading = false;
    });
  }

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPurchases();
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final normal1 = Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
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
                  return Container(
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title[index],
                                    style: TextStyle(color: reverse),
                                  ),
                                  Text("${TFormat().getCurrency()}${formatNumberWithCommas(index==0?totalPurchase:totalPayable)}",
                                    style:TextStyle(
                                        fontWeight: FontWeight.w100,
                                        color: secBtn,fontSize: 18
                                    ),
                                  ),
                                ],
                              ),
                              // index == 0
                              //     ? SmallPrchLine(eid: "", tile: 'PURCHASE',)
                              //     : index==1
                              //     ? SmallPrchLine(eid: "", tile: 'PAYABLE',)
                              //     : SizedBox(),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Divider(
                            thickness: 1,
                            height: 1,
                            color: color,
                          ),
                          SizedBox(height: 5,),
                          Row(
                            children: [
                              Icon(
                                index==0
                                    ?purchasePerform<0
                                    ?Icons.arrow_downward
                                    :Icons.arrow_upward
                                    :payablePerform <0
                                    ?Icons.arrow_downward
                                    :Icons.arrow_upward,
                                color: index==0
                                    ?purchasePerform<0
                                    ?Colors.red
                                    :Colors.green
                                    :payablePerform <0
                                    ?Colors.red
                                    :Colors.green,
                                size: 15,
                              ),
                              Text(
                                index==0
                                    ?purchasePerform==double.infinity? '100%': purchasePerform.toString()+"%"
                                    :payablePerform==double.infinity? '100%':payablePerform.toString()+"%",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: index==0
                                        ?purchasePerform<0
                                        ?Colors.red
                                        :Colors.green
                                        :payablePerform <0
                                        ?Colors.red
                                        :Colors.green,
                                    fontSize: 11),
                              ),
                              SizedBox(width: 2,),
                              Text("Last month", style: TextStyle(fontSize: 11)),

                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            SizedBox(height: 10,),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Container(
                  width: 450,height: 350,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(" Purchase Summary", style: TextStyle(color: reverse, fontSize: 18, fontWeight: FontWeight.w600),
                              )
                          ),
                          CardButton(
                            text: _period?"Monthly":"Weekly",
                            backcolor: _period?screenBackgroundColor:Colors.white,
                            icon: Icon(Icons.access_time_rounded, size: 19, color: _period?Colors.white:Colors.black,),
                            forecolor: _period?Colors.white:Colors.black,
                            onTap: (){
                              setState(() {
                                _period=!_period;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                      Expanded(
                        child: WeeklyPurchaseBar(
                          eid: "",
                          activeColor: Colors.cyanAccent,
                          inactiveColor: normal1,
                          textColor: reverse, activeColor2: Colors.cyan, grid: false,
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        _period
                            ? "This chart presents a concise summary of the weekly sales performance for the current month"
                            : "This chart provides a comprehensive overview of the sales performance for the current year",
                        style: TextStyle(color: secondaryColor, fontSize: 11),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Frequently Bought Product", style: TextStyle(color: reverse, fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 10,),
                  EntityPurchaseReport(eid: "")
                ],
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
}
