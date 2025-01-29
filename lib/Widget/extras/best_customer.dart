import 'dart:convert';

import 'package:TallyApp/models/sales.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

import '../../main.dart';
import '../../utils/colors.dart';
import '../text/text_format.dart';

class BestCustomer extends StatefulWidget {
  final String eid;
  const BestCustomer({super.key, required this.eid});

  @override
  State<BestCustomer> createState() => _BestCustomerState();
}

class _BestCustomerState extends State<BestCustomer> {
  List<SaleModel> _sale = [];
  List<SaleModel> _newSale = [];
  List<SaleModel> _filtSale = [];
  double percentage = 0.0;

  _getCustomers()async{
    _sale =  widget.eid == ""
        ? mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid).toList()
        : mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid && element.eid == widget.eid).toList();
    setState(() {
      for (var sales in _sale) {
        bool idExists = _newSale.any((element) => element.customer == sales.customer && element.phone == sales.phone);
        if (!idExists) {
          _newSale.add(sales);
        }
      }
      _newSale.sort((a, b) {
        int countA = _sale.where((sales) => sales.customer == a.customer && sales.phone == a.phone).length;
        int countB = _sale.where((sales) => sales.customer == b.customer && sales.phone == b.phone).length;
        return countB.compareTo(countA);
      });
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

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return SizedBox(width: 500,
      child: ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: _newSale.length < 5 ? _newSale.length : 5,
          itemBuilder: (context, index){
            SaleModel customer = _newSale[index];
            _filtSale = _sale.where((element) => element.customer.toString().trim() == customer.customer.toString().trim() && element.phone.toString().trim() == customer.phone.toString().trim()).toList();
            List<SaleModel> salesList = _filtSale.isEmpty? [] :_filtSale;
            var revenue = salesList.isEmpty? 0.0 : salesList.fold(0.0, (previousValue, element) => previousValue + double.parse(element.sprice.toString()) * double.parse(element.quantity.toString()));
            percentage = revenue/adjustHighestNumber(revenue);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color1,
                      radius: 20,
                      child: LineIcon.user(color: revers,),
                    ),
                    SizedBox(width: 5,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer.customer.toString(), style: TextStyle(fontSize: 13),),
                          Row(
                            children: [
                              Text(customer.phone.toString(), style: TextStyle(color: secondaryColor, fontSize: 12)),
                              Expanded(child: SizedBox()),
                              Text("${TFormat().getCurrency()}${formatNumberWithCommas(revenue)}", style: TextStyle(color: secondaryColor, fontSize: 12)),
                            ],
                          ),
                          LinearPercentIndicator(
                            animation: true,
                            animateFromLastPercent: true,
                            animationDuration: 800,
                            padding: EdgeInsets.zero,
                            lineHeight: 5,
                            percent: percentage,
                            progressColor: Colors.cyan,
                            backgroundColor: Colors.cyan.withOpacity(0.2),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
