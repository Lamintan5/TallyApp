import 'dart:convert';

import 'package:TallyApp/models/sales.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

import '../../main.dart';

class PieChartGraph extends StatefulWidget {
  final String eid;
  const PieChartGraph({super.key, required this.eid});

  @override
  State<PieChartGraph> createState() => _PieChartGraphState();
}

class _PieChartGraphState extends State<PieChartGraph> {
  List<SaleModel> _sale = [];
  bool _loading = false;
  int touchedIndex = -1;

  double profit = 0;
  double profitPrcnt = 0;
  double selling = 0;
  double buying = 0;
  double buyingpPrcnt = 0;

  _getSales()async{
    setState(() {
      _loading = true;
    });
    _sale =  widget.eid == ""
        ? mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid).toList()
        : mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid && element.eid == widget.eid).toList();
    setState(() {
      selling = _sale.fold(0.0, (previousValue, element) => previousValue + double.parse(element.sprice.toString()) *int.parse(element.quantity.toString()));
      buying = _sale.fold(0.0, (previousValue, element) => previousValue + double.parse(element.bprice.toString()) *int.parse(element.quantity.toString()));
      profit = selling - buying;
      buyingpPrcnt = buying/selling;
      profitPrcnt = profit/selling;
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
    _getSales();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse
                        .touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 0,
              centerSpaceRadius: 90,
              sections: showingSections(),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: CircleAvatar(
                    backgroundColor: screenBackgroundColor,
                    child: LineIcon.wallet(color: Colors.cyan,),
                  ),
                ),
                SizedBox(width: 5,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sales Revenue", style: TextStyle(fontSize: 12),),
                    Text("Ksh.${formatNumberWithCommas(buying)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100, color: Colors.cyan),),
                  ],
                )
              ],
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                      color: Colors.cyanAccent,
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: CircleAvatar(
                    backgroundColor: screenBackgroundColor,
                    child: Icon(Icons.trending_up, color: Colors.cyanAccent,),
                  ),
                ),
                SizedBox(width: 5,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Profits", style: TextStyle(fontSize: 12),),
                    Text("Ksh.${formatNumberWithCommas(profit)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100, color: Colors.cyanAccent),),
                  ],
                )
              ],
            ),
            SizedBox(height: 20,),
          ],
        ),
        const SizedBox(
          width: 5,
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 50.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.cyan,
            value: _sale.isEmpty ? 50 : buyingpPrcnt,
            title: '${(buyingpPrcnt*100).toStringAsFixed(2)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.cyanAccent,
            value: _sale.isEmpty ? 50 :profitPrcnt,
            title: '${(profitPrcnt*100).toStringAsFixed(2)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );

        default:
          throw Error();
      }
    });
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  const Indicator({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        Container(
          width: 10, height: 10,
          color: color,
        ),
        SizedBox(width: 10,),
        Text(text)
      ],
    );
  }
}

