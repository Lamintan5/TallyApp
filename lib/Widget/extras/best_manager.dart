import 'dart:convert';

import 'package:TallyApp/Widget/items/item_best_seller.dart';
import 'package:TallyApp/models/sales.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class BestManager extends StatefulWidget {
  final String eid;
  const BestManager({super.key, required this.eid});

  @override
  State<BestManager> createState() => _BestManagerState();
}

class _BestManagerState extends State<BestManager> {
  List<SaleModel> _sale = [];
  List<SaleModel> _newSale = [];
  List<SaleModel> _filtSale = [];


  bool _loading = false;
  double percentage = 0.0;

  _getCustomers()async{
    setState(() {
      _loading = true;
    });
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString)))
    .where((test) {
      bool matchedEid = widget.eid.isEmpty || test.eid == widget.eid;
      bool matchesAmount = test.amount == test.paid;
      return matchedEid && matchesAmount;
    }).toList();
    setState(() {
      for (var sales in _sale) {
        bool idExists = _newSale.any((element) => element.sellerid == sales.sellerid);
        if (!idExists) {
          _newSale.add(sales);
        }
      }
      _newSale.sort((a, b) {
        double totalAmountA = _sale
            .where((sales) => sales.sellerid == a.sellerid)
            .fold(0, (previous, element) => previous + double.parse(element.sprice.toString()) * double.parse(element.quantity.toString()));

        double totalAmountB = _sale
            .where((sales) => sales.sellerid == b.sellerid)
            .fold(0, (previous, element) => previous + double.parse(element.sprice.toString()) * double.parse(element.quantity.toString()));

        return totalAmountB.compareTo(totalAmountA);
      });

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
    _getCustomers();

  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return  SizedBox(width: 500,
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: _newSale.length < 5 ? _newSale.length : 5,
          itemBuilder: (context, index){
            SaleModel sale = _newSale[index];
            _filtSale = _sale.where((element) => element.sellerid == sale.sellerid).toList();
            List<SaleModel> salesList = _filtSale.isEmpty? [] :_filtSale;
            var revenue = salesList.isEmpty? 0.0 : salesList.fold(0.0, (previousValue, element) => previousValue + double.parse(element.sprice.toString()) * double.parse(element.quantity.toString()));
            percentage = revenue/adjustHighestNumber(revenue);
            return ItemBestSeller(sale: sale, percentage: percentage, revenue: revenue);
          }),
    );
  }
}
