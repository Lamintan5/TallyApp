import 'dart:convert';

import 'package:TallyApp/Widget/text/text_format.dart';
import 'package:TallyApp/models/products.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';

import '../../main.dart';
import '../../models/sales.dart';
import '../../utils/colors.dart';

class PieChartGraph extends StatefulWidget {
  final String eid;
  const PieChartGraph({super.key, required this.eid});

  @override
  State<PieChartGraph> createState() => _PieChartGraphState();
}

class _PieChartGraphState extends State<PieChartGraph> {
  List<SaleModel> _sale = [];
  List<ProductModel> _products = [];
  List<PrdModel> _prd = [];
  List colors = [
    CupertinoColors.activeBlue,
    Colors.cyan,
    CupertinoColors.activeGreen,
    CupertinoColors.activeOrange,
    CupertinoColors.destructiveRed
  ];

  int touchedIndex = -1;

  double one = 1;
  double two = 1;
  double three = 1;
  double four = 1;
  double five = 1;
  double total = 0;

  _getDetails()async{
    _getData();
    _getData();
  }

  _getData(){
    _sale =  widget.eid == ""
        ? mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid).toList()
        : mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid && element.eid == widget.eid).toList();
    _products =  widget.eid == ""
        ? myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList()
        : myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).where((test) => test.eid == widget.eid).toList();
    _products = _products.where((prd) => _sale.any((sale) => sale.productid == prd.prid)).toList();
    _products.forEach((product){
      var revenue = _sale.where((test)=>test.productid==product.prid).toList().fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));;
      var units = _sale.where((test)=>test.productid==product.prid).toList().fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));;
      PrdModel prd = PrdModel(
          prid: product.prid,
          name: product.name.toString(),
          revenue: revenue,
          units: units
      );
      if(!_prd.any((test)=>test.prid==prd.prid)){
        _prd.add(prd);
      }
    });
    _prd.sort((a, b) => b.revenue.compareTo(a.revenue));
    List<double> revenues = List.generate(5, (index) => index < _prd.length ? _prd[index].revenue : 0.0);

    one = revenues[0];
    two = revenues[1];
    three = revenues[2];
    four = revenues[3];
    five = revenues[4];

    total = one + two + three + four + five;
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
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("  Top Selling Products", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        _prd.isEmpty? Expanded(child: Center(child: Text("No data yet", style: TextStyle(color: secondaryColor),)))
            : Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
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
              Container(
                constraints: BoxConstraints(
                  minWidth: 100,
                  maxWidth: 150
                ),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _prd.length>5?5:_prd.length,
                    itemBuilder: (context, index){
                      PrdModel prdMdl = _prd[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 10,height: 10,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: colors[index]
                              ),
                            ),
                            SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(prdMdl.name, style: TextStyle(fontSize: 11),),
                                Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(prdMdl.revenue)}", style: TextStyle(fontSize: 11))
                              ],
                            )
                          ],
                        ),
                      );
                    }),
              ),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }
  List<PieChartSectionData> showingSections() {
    return List.generate(5, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 50.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: colors[0],
            value: one,
            title: '${((one/total)*100).toStringAsFixed(2)}%',
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
            color: colors[1],
            value: two,
            title:  '${((two/total)*100).toStringAsFixed(2)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: colors[2],
            value: three,
            title: '${((three/total)*100).toStringAsFixed(2)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: colors[3],
            value: four,
            title: '${((four/total)*100).toStringAsFixed(2)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 4:
          return PieChartSectionData(
            color: colors[4],
            value: five,
            title: '${((five/total)*100).toStringAsFixed(2)}%',
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

class PrdModel {
  String prid;
  String name;
  double revenue;
  int units;

  PrdModel({required this.prid, required this.name, required this.revenue, required this.units});

  Map<String, dynamic> toJson() {
    return {
      'prid': prid,
      'name': name,
      'revenue': revenue,
      'units': units,
    };
  }
}