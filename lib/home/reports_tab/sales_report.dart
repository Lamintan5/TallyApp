import 'dart:convert';

import 'package:TallyApp/Widget/dialogs/filters/dialog_filter_by_entity.dart';
import 'package:TallyApp/Widget/graphs/time_of_day.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/sales.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Widget/buttons/card_button.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/extras/best_customer.dart';
import '../../Widget/extras/best_manager.dart';
import '../../Widget/extras/enity_sale_report.dart';
import '../../Widget/graphs/barchart.dart';
import '../../Widget/graphs/pie_chart.dart';
import '../../Widget/graphs/small_line_graph.dart';
import '../../Widget/graphs/weekly_bar_chart.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';

class SaleReport extends StatefulWidget {
  final EntityModel entity;

  const SaleReport({super.key, required this.entity});

  @override
  State<SaleReport> createState() => _compSaleReportState();
}

class _compSaleReportState extends State<SaleReport> {
  List<String> title = ['Sales','Receivables', 'P/L'];
  List<SaleModel> _compSale = [];
  List<SaleModel> _sale = [];
  List<SaleModel> _newsales = [];
  List<SaleModel> _receivable = [];
  List<SaleModel> _newRecSale = [];

  EntityModel entity = EntityModel(eid: "");
  
  bool _period = true;
  bool _loading = false;
  
  String eid = "";

  List<SaleModel> _lastMnthSale = [];
  List<SaleModel> _mnthSale = [];
  List<SaleModel> _lastMnthRec = [];
  List<SaleModel> _mnthRec = [];
  List<SaleModel> _lastMnthPrf = [];
  List<SaleModel> _mnthPrf = [];

  double totalLstMnthSale = 0.0;
  double totalMnthSale = 0.0;
  double totalLstMnthRec = 0.0;
  double totalMnthRec = 0.0;
  double totalLstMnthPrf = 0.0;
  double totalMnthPrf = 0.0;

  double salePerform = 0.0;
  double receivePerform = 0.0;
  double profitPerform = 0.0;

  double totalSales = 0.0;
  double totalRecv = 0.0;
  double totalProfit = 0.0;

  _getDetails()async{
    _getData();
    _newsales = await Services().getMySale(currentUser.uid);
    await Data().addOrUpdateSalesList(_newsales).then((value){
      setState(() {
        _loading = value;
      });
    });
    _getData();
  }
  _getData()async{
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString)))
        .where((test) {return eid == "" || test.eid == eid.toString();}).toList();
    _compSale = _sale.where((element) => element.amount == element.paid && element.pid.toString().contains(currentUser.uid)).toList();
    _receivable = mySales
        .map((jsonString) => SaleModel.fromJson(json.decode(jsonString)))
        .where((element) {
      // Check if eid is not empty, then apply the filter
      bool filterByEid = eid == "" || element.eid == eid;
      return element.amount != element.paid &&
          element.pid.toString().contains(currentUser.uid) &&
          filterByEid;
    }).toList();

    for (var sales in _receivable) {
      bool idExists = _newRecSale.any((element) => element.saleid == sales.saleid);
      if (!idExists) {
        _newRecSale.add(sales);
      }
    }

    totalSales = _compSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * int.parse(element.quantity.toString())));
    totalRecv = _newRecSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
    totalProfit = _compSale.fold(0.0, (previousValue, element) => previousValue + ((double.parse(element.sprice.toString())*int.parse(element.quantity.toString())) - (double.parse(element.bprice.toString())*int.parse(element.quantity.toString()))));

    _lastMnthSale = _compSale.where((element) => DateTime.parse(element.time.toString()).month == DateTime.now().month -1).toList();
    _lastMnthRec = _newRecSale.where((element) => DateTime.parse(element.time.toString()).month == DateTime.now().month -1).toList();
    _lastMnthPrf = _compSale.where((element) => DateTime.parse(element.time.toString()).month == DateTime.now().month -1).toList();
    _mnthSale = _compSale.where((element) => DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
    _mnthRec = _newRecSale.where((element) => DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
    _mnthPrf = _compSale.where((element) => DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();

    totalLstMnthSale = _lastMnthSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * int.parse(element.quantity.toString())));
    totalMnthSale =_mnthSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * int.parse(element.quantity.toString())));
    totalLstMnthRec = _lastMnthRec.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
    totalMnthRec =_mnthRec.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
    totalLstMnthPrf = _lastMnthPrf.fold(0.0, (previousValue, element) => previousValue + ((double.parse(element.sprice.toString())*int.parse(element.quantity.toString())) - (double.parse(element.bprice.toString())*int.parse(element.quantity.toString()))));
    totalMnthPrf =_mnthPrf.fold(0.0, (previousValue, element) => previousValue + ((double.parse(element.sprice.toString())*int.parse(element.quantity.toString())) - (double.parse(element.bprice.toString())*int.parse(element.quantity.toString()))));

    salePerform = (totalMnthSale-totalLstMnthSale)/totalLstMnthSale*100;
    receivePerform = (totalMnthRec-totalLstMnthRec)/totalLstMnthRec*100;
    profitPerform = (totalMnthPrf-totalLstMnthPrf)/totalLstMnthPrf*100;
    setState(() {


    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    eid = widget.entity.eid;
    entity = widget.entity;
    _getDetails();
  }

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    final normal1 = Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final bold = TextStyle(color: reverse, fontSize: 15, fontWeight: FontWeight.w600);
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
                        color: color1,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title[index],
                                      style: TextStyle(color: reverse),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text("Ksh.${formatNumberWithCommas(index==0?totalSales :index==1?totalRecv:index==2?totalProfit:0)}",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:TextStyle(
                                          fontWeight: FontWeight.w100,
                                          color: secBtn,fontSize: 18
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              index == 0
                                  ? SmallLineGraph(eid: eid, tile: 'SALE',)
                                  : index==1
                                  ? SmallLineGraph(eid: eid, tile: 'REC',)
                                  : index==2
                                  ? SmallLineGraph(eid: eid, tile: 'P/L',)
                                  : SizedBox(),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Divider(
                            thickness: 1,
                            height: 1,
                            color: color1,
                          ),
                          SizedBox(height: 5,),
                          Row(
                            children: [
                              Icon(
                                index==0
                                    ?salePerform<0
                                    ?Icons.arrow_downward
                                    :Icons.arrow_upward
                                    :index==1
                                    ?receivePerform <0
                                    ?Icons.arrow_downward
                                    :Icons.arrow_upward
                                    :index==2
                                    ?profitPerform<0
                                    ?Icons.arrow_downward
                                    :Icons.arrow_upward
                                    :Icons.arrow_upward,
                                color: index==0
                                    ?salePerform<0
                                    ?Colors.red
                                    :Colors.green
                                    :index==1
                                    ?receivePerform <0
                                    ?Colors.red
                                    :Colors.green
                                    :index==2
                                    ?profitPerform<0
                                    ?Colors.red
                                    :Colors.green
                                    :Colors.green,
                                size: 15,
                              ),
                              Text(
                                index==0
                                    ?salePerform==double.infinity? '100%': salePerform.toStringAsFixed(2)+"%"
                                    :index==1
                                    ?receivePerform==double.infinity? '100%':receivePerform.toStringAsFixed(2)+"%"
                                    :index==2
                                    ?profitPerform==double.infinity? '100%':profitPerform.toStringAsFixed(2)+"%"
                                    :"0%",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: index==0
                                        ?salePerform<0
                                        ?Colors.red
                                        :Colors.green
                                        :index==1
                                        ?receivePerform <0
                                        ?Colors.red
                                        :Colors.green
                                        :index==2
                                        ?profitPerform<0
                                        ?Colors.red
                                        :Colors.green
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
            Row(
              children: [
                _loading? Container(
                    width: 20,height: 20,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: CircularProgressIndicator(color: reverse,strokeWidth: 2,)
                ) : SizedBox(),
                Expanded(child: SizedBox()),
                CardButton(
                    text: "Reload",
                    backcolor: screenBackgroundColor,
                    forecolor: Colors.white,
                    icon: Icon(CupertinoIcons.refresh, size: 20,),
                    onTap: (){
                      setState(() {
                        _loading = true;
                      });
                      _getDetails();
                    }
                ),
                widget.entity.eid==""
                    ? CardButton(
                    text: "Filter",
                    backcolor: Colors.white,
                    forecolor: Colors.black,
                    icon: Icon(Icons.filter_list_rounded, size: 20,color: Colors.black,),
                    onTap: (){dialogFilter(context);}
                )
                    : SizedBox(),
              ],
            ),
            SizedBox(height: 10,),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Container(
                  width: 450,height: 350,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  decoration: BoxDecoration(
                    color: color1,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(" Sales Summary", style: bold,
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
                          child:_period? WeeklyBarChart(
                            eid: eid,
                            activeColor: Colors.cyanAccent,
                            inactiveColor: normal1,
                            textColor: reverse, activeColor2: Colors.cyan,
                          ) :MyBarChart(
                            eid: eid,
                            activeColor: secBtn,
                            inactiveColor: normal1,
                            textColor: reverse,
                          )
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
                Container(
                  width: 450,
                  height: 350,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  decoration: BoxDecoration(
                    color: color1,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: PieChartGraph(eid: eid,),
                ),
                Container(
                  width: 450,height: 350,
                  decoration: BoxDecoration(
                    color: color1,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TimeOfDayGr(eid: eid, title: "SALE"),
                ),
                Container(
                  width: 450,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  decoration: BoxDecoration(
                    color: color1,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(" Frequent Customers", style: bold,
                              )
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      BestCustomer(eid: eid,)
                    ],
                  ),
                ),
                Container(
                  width: 450,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: color1,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(" Best Seller", style: bold,
                              )
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      BestManager(eid: eid,)
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Frequently Sold Product", style: bold),
                  SizedBox(height: 5,),
                  EntitySaleReport(eid: eid,),
                ],
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
  void dialogFilter(BuildContext context){
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'F I L T E R'),
                DialogFilterByEntity(entity: entity, filter: _filter,)
              ],
            ),
          ),
        )
    );
  }
  void _filter(EntityModel entityModel){
    _newRecSale.clear();
    entity = entityModel;
    eid = entityModel.eid;
    _getData();
  }

}
