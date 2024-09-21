import 'dart:convert';

import 'package:TallyApp/main.dart';
import 'package:flutter/material.dart';

import '../models/entities.dart';
import '../models/sales.dart';
import 'credits.dart';

class BasicStats extends StatefulWidget {
  const BasicStats({super.key});

  @override
  State<BasicStats> createState() => _BasicStatsState();
}

class _BasicStatsState extends State<BasicStats> {
  List<EntityModel> _entity = [];
  List<SaleModel> _sale = [];
  List<SaleModel> _newSale = [];

  Set<String> managers = Set();

  int noEntity = 0;
  int noCustomers = 0;
  int noSuppliers = 0;
  int noManagers = 0;


  _getDetails(){
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid).toList();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _entity.forEach((entity){
      List<String> pidList = entity.pid!.split(',').map((e) => e.trim()).toList();
      managers.addAll(pidList);

    });
    setState(() {
      for (var sales in _sale) {
        bool idExists = _newSale.any((element) => element.customer == sales.customer && element.phone == sales.phone);
        if (!idExists) {
          _newSale.add(sales);
        }
      }
      noEntity = myEntity.length;
      noSuppliers = mySuppliers.length;
      noCustomers = _newSale.length;
      noManagers = managers.length;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Credit(title: 'Entities', subtitle: noEntity.toString(),),
        Credit(title: 'Customers', subtitle: noCustomers.toString()),
        Credit(title: 'Suppliers', subtitle: noSuppliers.toString()),
        Credit(title: 'Manager', subtitle: noManagers.toString())
      ],
    );
  }
}
