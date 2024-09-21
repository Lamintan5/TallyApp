import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../models/bar_model/weekly_data.dart';
import '../../models/sales.dart';
import '../../utils/colors.dart';

class WeeklyBarChart extends StatefulWidget {
  final Color activeColor;
  final Color activeColor2;
  final Color inactiveColor;
  final Color textColor;
  final bool grid;
  final String eid;
  const WeeklyBarChart({
    super.key, required this.eid,
    this.activeColor = screenBackgroundColor,
    this.inactiveColor = Colors.white,
    this.textColor = Colors.black,
    this.grid = false,
    required this.activeColor2
  });

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  List<SaleModel> _sale = [];
  List<SaleModel> _rec = [];
  List<SaleModel> _newSale = [];
  List<SaleModel> _newRecSale = [];
  List<double> weeklySummary = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  List<double> weeklyRevSummary = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  bool _loading = false;
  DateTime currentDate = DateTime.now();


  List<SaleModel> _mon = [];
  List<SaleModel> _tue = [];
  List<SaleModel> _wed = [];
  List<SaleModel> _thur = [];
  List<SaleModel> _frd = [];
  List<SaleModel> _sat = [];
  List<SaleModel> _sun = [];

  List<SaleModel> _monRev = [];
  List<SaleModel> _tueRev = [];
  List<SaleModel> _wedRev = [];
  List<SaleModel> _thurRev = [];
  List<SaleModel> _frdRev = [];
  List<SaleModel> _satRev = [];
  List<SaleModel> _sunRev = [];


  double mon = 0.0;
  double tue = 0.0;
  double wed = 0.0;
  double thr = 0.0;
  double frd = 0.0;
  double sat = 0.0;
  double sun = 0.0;

  double monRev = 0.0;
  double tueRev = 0.0;
  double wedRev = 0.0;
  double thrRev = 0.0;
  double frdRev = 0.0;
  double satRev = 0.0;
  double sunRev = 0.0;

  double highestWeek = 0.0;

  _getSales()async{
    setState(() {
      _loading = true;
    });
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _sale = widget.eid == ""? _sale.where((element) => double.parse(element.amount.toString()) == double.parse(element.paid.toString())
        && double.parse(element.paid.toString()) != 0.0).toList()
        :  _sale.where((element) => element.eid == widget.eid && double.parse(element.amount.toString()) == double.parse(element.paid.toString())
        && double.parse(element.paid.toString()) != 0.0).toList();
    _rec = widget.eid == ""? _sale.where((element) => double.parse(element.amount.toString()) != double.parse(element.paid.toString())).toList()
        :  _sale.where((element) => element.eid == widget.eid && double.parse(element.amount.toString()) != double.parse(element.paid.toString())).toList();
    setState(() {
      for (var sales in _sale) {
        bool idExists = _newSale.any((element) => element.saleid == sales.saleid);
        if (!idExists) {
          _newSale.add(sales);
        }
      }
      for (var sales in _rec) {
        bool idExists = _newRecSale.any((element) => element.saleid == sales.saleid);
        if (!idExists) {
          _newRecSale.add(sales);
        }
      }
      _mon = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.monday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _tue = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.tuesday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _wed = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.wednesday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _thur = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.thursday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _frd = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.friday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _sat = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.saturday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _sun = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.sunday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();

      _monRev = _newRecSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.monday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month ).toList();
      _tueRev = _newRecSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.tuesday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _wedRev = _newRecSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.wednesday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _thurRev = _newRecSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.thursday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _frdRev = _newRecSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.friday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _satRev = _newRecSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.saturday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _sunRev = _newRecSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.sunday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();

      mon = _mon.isEmpty ? 0.0 : _mon.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      tue = _tue.isEmpty ? 0.0 : _tue.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      wed = _wed.isEmpty ? 0.0 : _wed.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      thr = _thur.isEmpty ? 0.0 : _thur.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      frd = _frd.isEmpty ? 0.0 : _frd.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      sat = _sat.isEmpty ? 0.0 : _sat.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      sun = _sun.isEmpty ? 0.0 : _sun.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));

      monRev = _monRev.isEmpty ? 0.0 : _monRev.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
      tueRev = _tueRev.isEmpty ? 0.0 : _tueRev.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
      wedRev = _wedRev.isEmpty ? 0.0 : _wedRev.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
      thrRev = _thurRev.isEmpty ? 0.0 : _thurRev.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
      frdRev = _frdRev.isEmpty ? 0.0 : _frdRev.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
      satRev = _satRev.isEmpty ? 0.0 : _satRev.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));
      sunRev = _sunRev.isEmpty ? 0.0 : _sunRev.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString()) - double.parse(element.paid.toString())));


      weeklySummary = [mon, tue, wed, thr, frd, sat, sun];
      weeklyRevSummary = [monRev, tueRev, wedRev, thrRev, frdRev, satRev, sunRev];

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
    _getSales();
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
            Text("Revenue", style: TextStyle(fontSize: 11),),
            SizedBox(width: 20,),
            Container(
              width: 10, height: 6,
              decoration: BoxDecoration(
                  color: widget.activeColor2,
                  borderRadius: BorderRadius.circular(2)
              ),
            ),
            SizedBox(width: 10,),
            Text("Receivables", style: TextStyle(fontSize: 11),)
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
