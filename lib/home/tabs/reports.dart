import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/entities.dart';
import '../reports_tab/purchase_report.dart';
import '../reports_tab/sales_report.dart';

class Reports extends StatefulWidget {
  final EntityModel entity;
  const Reports({super.key, required this.entity});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> with TickerProviderStateMixin{
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  widget.entity.eid == ""
                      ? SizedBox()
                      : SizedBox(width: 10,),
                  widget.entity.eid == ""
                      ? SizedBox()
                      : IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(CupertinoIcons.arrow_left)),
                  Expanded(
                    child: Text("  Summary",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: reverse,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      unselectedLabelStyle: const TextStyle(fontSize: 15),
                      labelPadding: const EdgeInsets.only(bottom: 0),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 0,),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: secBtn,
                      splashBorderRadius: const BorderRadius.all(Radius.circular(30)),
                      tabs: [
                        Text('Sale',),
                        Text('Purchase',),
                      ],
                    ),
                  ),
                  SizedBox(width: 10,)
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SaleReport(entity: widget.entity),
                  PurchaseReport()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
