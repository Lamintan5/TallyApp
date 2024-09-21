import 'package:TallyApp/models/entities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';

import '../sales_tab/receivables.dart';
import '../sales_tab/sales_overview.dart';
import '../sales_tab/sales_report.dart';


class Sales extends StatefulWidget {
  final EntityModel entity;
  const Sales({super.key, required this.entity});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  String dropdownValue = 'Sales';
  String heading = 'Sales';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(' ${heading}', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),),
            DropdownButton<String>(
              icon: Icon(Icons.menu, color: Colors.black,),
              value: dropdownValue,
              style: TextStyle(color: Colors.black),
              dropdownColor: Colors.white,
              underline: Container(height: 2,color: Colors.black,),
              onChanged: (String? newValue){
                setState(() {
                  dropdownValue = newValue!;
                  heading = newValue;
                });
              }, items:  [
              DropdownMenuItem<String>(
                value: "Sales",
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.cart,color: Colors.black,size: 15,),
                    SizedBox(width: 5,),
                    Text("Sales"),
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: "Receivables",
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.money_dollar, color: Colors.black,size: 20,),
                    SizedBox(width: 5,),
                    Text("Receivables"),
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: "Report",
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.chart_bar_square, color: Colors.black,),
                    SizedBox(width: 5,),
                    Text("Report"),
                  ],
                ),
              ),
            ],
            ),
          ],
        ),
        dropdownValue == 'Sales'
            ? SalesOverview(entity: widget.entity,)
            :  dropdownValue == 'Receivables'
            ? Receivables(entity: widget.entity)
            : dropdownValue == 'Report'
            ? SaleReport(entity: widget.entity)
            : SizedBox()
      ],
    );
  }
}
