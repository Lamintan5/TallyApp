import 'dart:convert';

import 'package:TallyApp/models/purchases.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../models/bar_model/weekly_data.dart';

class WeeklyPurchaseBar extends StatefulWidget {
  final Color activeColor;
  final Color activeColor2;
  final Color inactiveColor;
  final Color textColor;
  final bool grid;
  final String eid;
  const WeeklyPurchaseBar({super.key, required this.activeColor, required this.activeColor2, required this.inactiveColor, required this.textColor, required this.grid, required this.eid});

  @override
  State<WeeklyPurchaseBar> createState() => _WeeklyPurchaseBarState();
}

class _WeeklyPurchaseBarState extends State<WeeklyPurchaseBar> {
  List<PurchaseModel> _purchase = [];
  List<PurchaseModel> _payable = [];
  List<PurchaseModel> _newPurchase = [];
  List<PurchaseModel> _newPayable = [];
  List<double> weeklySummary = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  List<double> weeklyRevSummary = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  bool _loading = false;
  DateTime currentDate = DateTime.now();

  List<PurchaseModel> _mon = [];
  List<PurchaseModel> _tue = [];
  List<PurchaseModel> _wed = [];
  List<PurchaseModel> _thur = [];
  List<PurchaseModel> _frd = [];
  List<PurchaseModel> _sat = [];
  List<PurchaseModel> _sun = [];

  List<PurchaseModel> _monPayable = [];
  List<PurchaseModel> _tuePayable = [];
  List<PurchaseModel> _wedPayable = [];
  List<PurchaseModel> _thurPayable = [];
  List<PurchaseModel> _frdPayable = [];
  List<PurchaseModel> _satPayable = [];
  List<PurchaseModel> _sunPayable = [];

  double mon = 0.0;
  double tue = 0.0;
  double wed = 0.0;
  double thr = 0.0;
  double frd = 0.0;
  double sat = 0.0;
  double sun = 0.0;

  double monPayable = 0.0;
  double tuePayable = 0.0;
  double wedPayable = 0.0;
  double thrPayable = 0.0;
  double frdPayable = 0.0;
  double satPayable = 0.0;
  double sunPayable = 0.0;

  double highestWeek = 0.0;

  _getPurchase()async{
    setState(() {
      _loading = true;
    });
    _purchase =  widget.eid == ""
        ? myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid).toList()
        : myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid && element.eid == widget.eid).toList();
    _payable =  widget.eid == ""
        ? myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).where((element) => element.amount != element.paid).toList()
        : myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).where((element) => element.amount != element.paid && element.eid == widget.eid).toList();
    setState(() {
      for (var purchase in _purchase) {
        bool idExists = _newPurchase.any((element) => element.purchaseid == purchase.purchaseid);
        if (!idExists) {
          _newPurchase.add(purchase);
        }
      }
      for (var payable in _payable) {
        bool idExists = _newPayable.any((element) => element.purchaseid == payable.purchaseid);
        if (!idExists) {
          _newPayable.add(payable);
        }
      }
      _mon = _newPurchase.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.monday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _tue = _newPurchase.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.tuesday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _wed = _newPurchase.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.wednesday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _thur = _newPurchase.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.thursday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _frd = _newPurchase.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.friday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _sat = _newPurchase.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.saturday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _sun = _newPurchase.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.sunday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();

      _monPayable = _newPayable.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.monday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month ).toList();
      _tuePayable = _newPayable.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.tuesday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _wedPayable = _newPayable.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.wednesday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _thurPayable = _newPayable.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.thursday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _frdPayable = _newPayable.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.friday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _satPayable = _newPayable.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.saturday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _sunPayable = _newPayable.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.sunday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();

      mon = _mon.isEmpty ? 0.0 : _mon.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      tue = _tue.isEmpty ? 0.0 : _tue.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      wed = _wed.isEmpty ? 0.0 : _wed.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      thr = _thur.isEmpty ? 0.0 : _thur.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      frd = _frd.isEmpty ? 0.0 : _frd.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      sat = _sat.isEmpty ? 0.0 : _sat.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      sun = _sun.isEmpty ? 0.0 : _sun.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));

      monPayable = _monPayable.isEmpty ? 0.0 : _monPayable.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
      tuePayable = _tuePayable.isEmpty ? 0.0 : _tuePayable.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
      wedPayable = _wedPayable.isEmpty ? 0.0 : _wedPayable.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
      thrPayable = _thurPayable.isEmpty ? 0.0 : _thurPayable.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
      frdPayable = _frdPayable.isEmpty ? 0.0 : _frdPayable.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
      satPayable = _satPayable.isEmpty ? 0.0 : _satPayable.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
      sunPayable = _sunPayable.isEmpty ? 0.0 : _sunPayable.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));

      weeklySummary = [mon, tue, wed, thr, frd, sat, sun];
      weeklyRevSummary = [monPayable, tuePayable, wedPayable, thrPayable, frdPayable, satPayable, sunPayable];

      highestWeek = weeklySummary.fold(0, (maxWeek, week) => week > maxWeek ? week : maxWeek);

      _loading = false;
    });
  }

  double adjustHighestNumber(double number) {
    if (number >= 1 && number < 10) {
      return 10;
    } else if (number >= 10 && number < 100) {
      return 100;
    } else if (number >= 100 && number < 1000) {
      return 1000;
    } else if (number >= 1000 && number < 10000) {
      return 10000;
    } else if (number >= 10000 && number < 100000) {
      return 100000;
    } else if (number >= 100000 && number < 1000000) {
      return 1000000;
    } else if (number >= 1000000 && number < 10000000) {
      return 10000000;
    }
    return number;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPurchase();
  }

  @override
  Widget build(BuildContext context) {
    WeeklyData myBarData = WeeklyData(
      mon: weeklySummary[0],
      tue: weeklySummary[1],
      wed: weeklySummary[2],
      thr: weeklySummary[3],
      fri: weeklySummary[4],
      sat: weeklySummary[5],
      sun: weeklySummary[6],

      mon2: weeklyRevSummary[0],
      tue2: weeklyRevSummary[1],
      wed2: weeklyRevSummary[2],
      thr2: weeklyRevSummary[3],
      fri2: weeklyRevSummary[4],
      sat2: weeklyRevSummary[5],
      sun2: weeklyRevSummary[6],
    );
    myBarData.initializeBarData();
    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: highestWeek==0? 1000000 : adjustHighestNumber(highestWeek),
              minY: 0,
              gridData: FlGridData(show: widget.grid),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      reservedSize: 44,
                      showTitles: true,
                      getTitlesWidget: getLeftTitles
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: getBottomTitles),
                ),
              ),
              barGroups: myBarData.weeklyData.map((data){
                return BarChartGroupData(
                    x: data.x,
                    barRods: [
                      BarChartRodData(
                          toY: data.y,
                          color: widget.activeColor,
                          width: 20,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(2),
                            topLeft: Radius.circular(2),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: highestWeek==0? 1000000 : adjustHighestNumber(highestWeek),
                              color: widget.inactiveColor
                          )
                      ),
                      BarChartRodData(
                          toY: data.y2,
                          color: widget.activeColor2,
                          width: 20,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(2),
                            topLeft: Radius.circular(2),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: highestWeek==0? 1000000 : adjustHighestNumber(highestWeek),
                              color: widget.inactiveColor
                          )
                      ),
                    ]
                );
              }).toList(),
            ),
            swapAnimationDuration: Duration(milliseconds: 500), // Optional
            swapAnimationCurve: Curves.linear,
          ),
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            SizedBox(width: 50,),
            Container(
              width: 10, height: 6,
              decoration: BoxDecoration(
                  color: widget.activeColor,
                  borderRadius: BorderRadius.circular(2)
              ),
            ),
            SizedBox(width: 10,),
            Text("Purchase", style: TextStyle(fontSize: 11),),
            SizedBox(width: 20,),
            Container(
              width: 10, height: 6,
              decoration: BoxDecoration(
                  color: widget.activeColor2,
                  borderRadius: BorderRadius.circular(2)
              ),
            ),
            SizedBox(width: 10,),
            Text("Payable", style: TextStyle(fontSize: 11),)
          ],
        )
      ],
    );
  }

  Widget getLeftTitles(double value, TitleMeta meta){
    final style = TextStyle(
        color: widget.textColor,fontSize: 11
    );
    Widget text;
    text = Text(NumberFormat.compact().format(value), style: style,);
    return SideTitleWidget(child: text, axisSide: meta.axisSide);
  }
  Widget getBottomTitles(double value, TitleMeta meta){
    final style = TextStyle(
        color: widget.textColor
    );
    Widget text;
    switch (value.toInt()){
      case 0:
        text = Text('Mon', style: style);
        break;
      case 1:
        text = Text('Tue', style: style);
        break;
      case 2:
        text = Text('Wed', style: style);
        break;
      case 3:
        text = Text('Thr', style: style);
        break;
      case 4:
        text = Text('Fri', style: style);
        break;
      case 5:
        text = Text('Sat', style: style);
        break;
      default:
        text = Text('Sun', style: style);
        break;
    }
    return SideTitleWidget(child: text, axisSide: meta.axisSide);
  }
}
