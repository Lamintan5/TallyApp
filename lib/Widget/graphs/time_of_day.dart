import 'dart:convert';

import 'package:TallyApp/Widget/text/text_format.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/sales.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

class TimeOfDayGr extends StatefulWidget {
  final String eid;
  final String title;
  const TimeOfDayGr({super.key, required this.eid, required this.title});

  @override
  State<TimeOfDayGr> createState() => _TimeOfDayGrState();
}

class _TimeOfDayGrState extends State<TimeOfDayGr> {
  List<Color> gradientColors = [Colors.cyan, Colors.blue];
  int day = 0;
  List<SaleModel> _sale = [];  List<String> hours = [
    "00:00", "01:00", "02:00", "03:00", "04:00", "05:00",
    "06:00", "07:00", "08:00", "09:00", "10:00", "11:00",
    "12:00", "13:00", "14:00", "15:00", "16:00", "17:00",
    "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"
  ];
  List<HourModel> _hours = [];
  List<String> _days =  [
    "All","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"
  ];

  double highestHour = 0.0;
  String dropdownValue = 'All';

  _getDetails(){
    _getData();
  }

  _getData(){
    _sale = mySales
        .map((jsonString) => SaleModel.fromJson(json.decode(jsonString)))
        .where((test) {
      DateTime testDate = DateTime.parse(test.date.toString());

      // If day == 0, skip filtering by day
      bool dayMatches = (day == 0) || (testDate.weekday == day);

      // If widget.eid is empty, skip filtering by eid
      bool eidMatches = widget.eid == "" || test.eid == widget.eid;

      // Return true only if both conditions are met along with amount == paid
      return (test.amount == test.paid) && dayMatches && eidMatches;
    })
        .toList();

    // _sale.forEach((e){
    //   print("${DateFormat.yMMMEd().format(DateTime.parse(e.date!))}");
    // });
    for (var entry in hours.asMap().entries) {
      int index = entry.key;
      String hour = entry.value;
      if (index < hours.length - 1) {
        var revenue = _sale.where((s) => DateTime.parse(s.date.toString()).hour >= index && DateTime.parse(s.date.toString()).hour < index + 1).toList()
            .fold(0.0, (previous, element) => previous + (double.parse(element.sprice.toString()) * int.parse(element.quantity.toString())));
        HourModel hourModel = HourModel(
            revenue: revenue,
            time: hour
        );
        _hours.add(hourModel);
      }
    }
    highestHour = _hours.fold(0, (maxAmount, amount) => amount.revenue > maxAmount ? amount.revenue : maxAmount);
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
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
      final dgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(" Sales by Time of Day", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),)),
              DropdownButton<String>(
                value: dropdownValue,
                isDense: true,
                borderRadius: BorderRadius.circular(5),
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                style: TextStyle(color: reverse),
                dropdownColor: dgColor,
                underline: Container(height: 2,color: reverse),
                onChanged: (String? newValue){
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: _days.asMap().entries.map((e){
                  int index = e.key;
                  String value = e.value;
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style: TextStyle(color: reverse),),
                    onTap: (){
                      _hours.clear();
                      day = index;
                      _getData();
                    },
                  );
                }).toList()
              ),
            ],
          ),
        ),
        SizedBox(height: 20,),
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 0, 20, 10),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false,),
                titlesData: FlTitlesData(
                  show: true,
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
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,getTitlesWidget: leftTitleWidgets),),
                ),
                borderData: FlBorderData(show: false,),
                maxY: TFormat().adjustHighestNumber(highestHour),
                minY: 0,
                lineBarsData: [
                  LineChartBarData(
                    spots: _hours.asMap().entries.map((entry){
                      int index = entry.key;
                      var period = entry.value;
                      var revenue = period.revenue;
                      return  FlSpot(index.toDouble(), revenue);
                    }).toList(),
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
          ),
        ),
      ],
    );
  }
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 11,);

    // List of hours in a day
    final List<String> hours = List.generate(24, (index) {
      final hour = index.toString().padLeft(2, '0');
      return '$hour';
    });

    // Determine the text based on the value
    Widget text;
    if (value.toInt() >= 0 && value.toInt() < hours.length) {
      text = Text(hours[value.toInt()], style: style);
    } else {
      text = Text('00', style: style); // Default fallback if out of range
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta){
    final style = TextStyle(
        color: Colors.white,fontSize: 10
    );
    Widget text;
    text = Text(NumberFormat.compact().format(value), style: style,);
    return SideTitleWidget(child: text, axisSide: meta.axisSide, space: 0,);
  }
}

class HourModel {
  String time;
  double revenue;


  HourModel({required this.revenue, required this.time});

  Map<String, dynamic> toJson() {
    return {
      'revenue': revenue,
      'time': time,
    };
  }
}
