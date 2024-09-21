import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';

import '../../models/entities.dart';
import '../products_tabs/goods_tab.dart';
import '../products_tabs/inventory_tab.dart';
import '../products_tabs/payables_tab.dart';
import '../products_tabs/purchases_tabs.dart';


class Products extends StatefulWidget {
  final EntityModel entity;
  const Products({super.key, required this.entity});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List<String> title = ['All Products','Categories', 'Suppliers'];
  String dropdownValue = 'Goods';
  String heading = 'Goods';

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
              }, items: [
              DropdownMenuItem<String>(
                value: "Goods",
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LineIcon.boxes(color: Colors.black,),
                    Text("Goods"),
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: "Purchase",
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LineIcon.luggageCart(color: Colors.black,),
                    Text("Purchase"),
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: "Payable",
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.money_dollar_circle,color: Colors.black,),
                    Text("Payable"),
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: "Inventory",
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.cube_box,color: Colors.black,),
                    Text("Inventory"),
                  ],
                ),
              ),
            ],
            ),
          ],
        ),
        dropdownValue == 'Goods'
            ? GoodsTab(entity: widget.entity,)
            : dropdownValue == 'Purchase'
            ? PurchaseTab(entity: widget.entity,)
            :  dropdownValue == 'Payable'
            ? PayablesTab(entity: widget.entity,)
            : dropdownValue == 'Inventory'
            ? InvReportTab(entity: widget.entity,)
            : SizedBox()
      ],
    );
  }
}
