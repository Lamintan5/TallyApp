import 'dart:convert';

import 'package:TallyApp/models/sales.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../models/data.dart';

class SmallLineGraph extends StatefulWidget {
  final String eid;
  final String tile;
  const SmallLineGraph({super.key, required this.eid, required this.tile});

  @override
  State<SmallLineGraph> createState() => _SmallLineGraphState();
}

class _SmallLineGraphState extends State<SmallLineGraph> {
  List<SaleModel> _sale = [];
  List<SaleModel> _rec = [];
  List<SaleModel> _newSale = [];
  List<SaleModel> _newsales = [];
  List<SaleModel> _newRecSale = [];
  List<double> weeklySummary = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  List<double> weeklyRevSummary = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  List<double> weeklyProfitSummary = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
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

  List<SaleModel> _monProfit = [];
  List<SaleModel> _tueProfit = [];
  List<SaleModel> _wedProfit = [];
  List<SaleModel> _thurProfit = [];
  List<SaleModel> _frdProfit = [];
  List<SaleModel> _satProfit = [];
  List<SaleModel> _sunProfit = [];

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

  double monProfit = 0.0;
  double tueProfit = 0.0;
  double wedProfit = 0.0;
  double thrProfit = 0.0;
  double frdProfit = 0.0;
  double satProfit = 0.0;
  double sunProfit = 0.0;

  double highestWeek = 0.0;
  double highestRecWeek = 0.0;
  double highestProfitWeek = 0.0;

  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];
  _getDetails()async{
    _getSales();
    _newsales = await Services().getMySale(currentUser.uid);
    await Data().addOrUpdateSalesList(_newsales);
    _getSales();
  }

  _getSales()async{
    setState(() {
      _loading = true;
    });
    _sale =  widget.eid == ""
        ? mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid).toList()
        : mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid && element.eid == widget.eid).toList();
    _rec = widget.eid == ""
        ? mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((element) => element.amount != element.paid).toList()
        : mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((element) => element.amount != element.paid && element.eid == widget.eid).toList();
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
      _mon = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.monday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month ).toList();
      _tue = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.tuesday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _wed = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.wednesday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _thur = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.thursday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _frd = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.friday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _sat = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.saturday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _sun = _newSale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.sunday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();

      _monProfit = _sale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.monday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month ).toList();
      _tueProfit = _sale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.tuesday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _wedProfit = _sale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.wednesday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _thurProfit = _sale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.thursday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _frdProfit = _sale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.friday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _satProfit = _sale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.saturday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();
      _sunProfit = _sale.where((element) => DateTime.parse(element.time.toString()).weekday == DateTime.sunday &&  DateTime.parse(element.time.toString()).month == DateTime.now().month).toList();


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

      monProfit = _monProfit.isEmpty ? 0.0 : _monProfit.fold(0.0, (previousValue, element) => previousValue + ((double.parse(element.sprice.toString())*int.parse(element.quantity.toString())) - (double.parse(element.bprice.toString())*int.parse(element.quantity.toString()))));
      tueProfit = _tueProfit.isEmpty ? 0.0 : _tueProfit.fold(0.0, (previousValue, element) => previousValue + ((double.parse(element.sprice.toString())*int.parse(element.quantity.toString())) - (double.parse(element.bprice.toString())*int.parse(element.quantity.toString()))));
      wedProfit = _wedProfit.isEmpty ? 0.0 : _wedProfit.fold(0.0, (previousValue, element) => previousValue + ((double.parse(element.sprice.toString())*int.parse(element.quantity.toString())) - (double.parse(element.bprice.toString())*int.parse(element.quantity.toString()))));
      thrProfit = _thurProfit.isEmpty ? 0.0 : _thurProfit.fold(0.0, (previousValue, element) => previousValue + ((double.parse(element.sprice.toString())*int.parse(element.quantity.toString())) - (double.parse(element.bprice.toString())*int.parse(element.quantity.toString()))));
      frdProfit = _frdProfit.isEmpty ? 0.0 : _frdProfit.fold(0.0, (previousValue, element) => previousValue + ((double.parse(element.sprice.toString())*int.parse(element.quantity.toString())) - (double.parse(element.bprice.toString())*int.parse(element.quantity.toString()))));
      satProfit = _satProfit.isEmpty ? 0.0 : _satProfit.fold(0.0, (previousValue, element) => previousValue + ((double.parse(element.sprice.toString())*int.parse(element.quantity.toString())) - (double.parse(element.bprice.toString())*int.parse(element.quantity.toString()))));
      sunProfit = _sunProfit.isEmpty ? 0.0 : _sunProfit.fold(0.0, (previousValue, element) => previousValue + ((double.parse(element.sprice.toString())*int.parse(element.quantity.toString())) - (double.parse(element.bprice.toString())*int.parse(element.quantity.toString()))));

      weeklySummary = [mon, tue, wed, thr, frd, sat, sun];
      weeklyRevSummary = [monRev, tueRev, wedRev, thrRev, frdRev, satRev, sunRev];
      weeklyProfitSummary = [monProfit, tueProfit, wedProfit, thrProfit, frdProfit, satProfit, sunProfit];

      highestWeek = weeklySummary.fold(0, (maxWeek, week) => week > maxWeek ? week : maxWeek);
      highestRecWeek = weeklyRevSummary.fold(0, (maxWeek, week) => week > maxWeek ? week : maxWeek);
      highestProfitWeek = weeklyProfitSummary.fold(0, (maxWeek, week) => week > maxWeek ? week : maxWeek);

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
    _getDetails();
  }


  @override
  Widget build(BuildContext context) {

    return SizedBox(width: 30,height: 20,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: false,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.cyan,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.cyan,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: false,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: bottomTitleWidgets),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,),),
          ),
          borderData: FlBorderData(show: false,),
          maxY: 10,
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, widget.tile == "SALE"? mon==0? 0 :double.parse((mon/adjustHighestNumber(highestWeek)*10).toStringAsFixed(2)) : widget.tile == "P/L"? monProfit==0? 0 :double.parse((monProfit/adjustHighestNumber(highestProfitWeek)*10).toStringAsFixed(2)) : monRev==0? 0 :double.parse((monRev/adjustHighestNumber(highestRecWeek)*10).toStringAsFixed(2))),
                FlSpot(1, widget.tile == "SALE"? tue==0? 0 :double.parse((tue/adjustHighestNumber(highestWeek)*10).toStringAsFixed(2)) : widget.tile == "P/L"? tueProfit==0? 0 :double.parse((tueProfit/adjustHighestNumber(highestProfitWeek)*10).toStringAsFixed(2)) : tueRev==0? 0 :double.parse((tueRev/adjustHighestNumber(highestRecWeek)*10).toStringAsFixed(2))),
                FlSpot(2, widget.tile == "SALE"? wed==0? 0 :double.parse((wed/adjustHighestNumber(highestWeek)*10).toStringAsFixed(2)) : widget.tile == "P/L"? wedProfit==0? 0 :double.parse((wedProfit/adjustHighestNumber(highestProfitWeek)*10).toStringAsFixed(2)) : wedRev==0? 0 :double.parse((wedRev/adjustHighestNumber(highestRecWeek)*10).toStringAsFixed(2))),
                FlSpot(3, widget.tile == "SALE"? thr==0? 0 :double.parse((thr/adjustHighestNumber(highestWeek)*10).toStringAsFixed(2)) : widget.tile == "P/L"? thrProfit==0? 0 :double.parse((thrProfit/adjustHighestNumber(highestProfitWeek)*10).toStringAsFixed(2)) : thrRev==0? 0 :double.parse((thrRev/adjustHighestNumber(highestRecWeek)*10).toStringAsFixed(2))),
                FlSpot(4, widget.tile == "SALE"? frd==0? 0 :double.parse((frd/adjustHighestNumber(highestWeek)*10).toStringAsFixed(2)) : widget.tile == "P/L"? frdProfit==0? 0 :double.parse((frdProfit/adjustHighestNumber(highestProfitWeek)*10).toStringAsFixed(2)) : frdRev==0? 0 :double.parse((frdRev/adjustHighestNumber(highestRecWeek)*10).toStringAsFixed(2))),
                FlSpot(5, widget.tile == "SALE"? sat==0? 0 :double.parse((sat/adjustHighestNumber(highestWeek)*10).toStringAsFixed(2)) : widget.tile == "P/L"? satProfit==0? 0 :double.parse((satProfit/adjustHighestNumber(highestProfitWeek)*10).toStringAsFixed(2)) : satRev==0? 0 :double.parse((satRev/adjustHighestNumber(highestRecWeek)*10).toStringAsFixed(2))),
                FlSpot(6, widget.tile == "SALE"
                    ? sun==0? 0 :double.parse((sun/adjustHighestNumber(highestWeek)*10).toStringAsFixed(2))
                    : widget.tile == "P/L"? sunProfit==0? 0 :double.parse((sunProfit/adjustHighestNumber(highestProfitWeek)*10).toStringAsFixed(2)) : sunRev==0? 0 :double.parse((sunRev/adjustHighestNumber(highestRecWeek)*10).toStringAsFixed(2))),
              ],
              isCurved: true,
              gradient: LinearGradient(
                colors: gradientColors,
              ),
              barWidth: 1,
              isStrokeCapRound: false,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: gradientColors
                      .map((color) => color.withOpacity(0.3))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 11,
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

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }
  Widget leftTitleWidgets(double value, TitleMeta meta){
    final style = TextStyle(
        color: Colors.white,fontSize: 11
    );
    Widget text;
    text = Text(NumberFormat.compact().format(value), style: style,);
    return SideTitleWidget(child: text, axisSide: meta.axisSide);
  }



}