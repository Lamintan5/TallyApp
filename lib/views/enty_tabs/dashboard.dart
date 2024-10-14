import 'dart:convert';

import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/resources/socket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Widget/buttons/card_button.dart';
import '../../Widget/graphs/barchart.dart';
import '../../Widget/graphs/weekly_bar_chart.dart';
import '../../Widget/sellers.dart';
import '../../main.dart';
import '../../models/purchases.dart';
import '../../models/sales.dart';
import '../../models/suppliers.dart';
import '../../utils/colors.dart';


class Dashboard extends StatefulWidget {
  final EntityModel entity;
  const Dashboard({super.key, required this.entity});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> title = ['Sales','Purchase', 'P/L', 'Receivables', 'Payables', 'Suppliers'];
  bool _loading = false;
  bool _period = true;
  List<SaleModel> _sale = [];
  List<SaleModel> _compSale = [];
  List<SaleModel> _receivable = [];
  List<SaleModel> _newReceive = [];

  List<PurchaseModel> _purchase = [];
  List<PurchaseModel> _allPurchase = [];
  List<PurchaseModel> _payable = [];
  List<PurchaseModel> _newPayable = [];
  List<SupplierModel> _supplier = [];
  double totalBprice= 0;
  double totalSprice= 0;
  double totalProfit= 0;

  double totalPurchases= 0;

  double totalPayable= 0;
  double totalPayableAmount= 0;
  double totalPayablePaid= 0;

  double totalReceive= 0;
  double totalRecvPaid= 0;
  double totalRecvBprice= 0;
  double totalRecvSprice= 0;
  int totalSuppliers = 0;

  List<SaleModel> seller = [];
  List<SaleModel> worstSeller = [];

  List<String> admin = [];

  late Set<PurchaseModel> uniquePayable;
  List<PurchaseModel> uniquePayableList = [];

  late Set<SaleModel> uniqueReceive;
  List<SaleModel> uniqueReceiveList = [];

  _getDetails()async{
    _getData();
    await SocketManager().getDetails().then((response){
      Future.delayed(Duration.zero).then((value) {
        if (mounted) {
          setState(() {
            _loading = response;
          });
        }
      });
    });
    _getData();
  }

  _getData(){
    admin = widget.entity.admin.toString().split(",");
    _allPurchase = admin.contains(currentUser.uid)
        ? myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList()
        : myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).where((test) => test.purchaser.toString()==currentUser.uid).toList();
    _supplier = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _sale = admin.contains(currentUser.uid)
        ? mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList()
        : mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((test) => test.sellerid.toString()==currentUser.uid).toList();
    _compSale = _sale.where((element) => element.eid == widget.entity.eid && double.parse(element.amount.toString()) == double.parse(element.paid.toString())
        && double.parse(element.paid.toString()) != 0.0).toList();
    _receivable = _sale.where((element) => element.eid == widget.entity.eid && double.parse(element.amount.toString()) != double.parse(element.paid.toString())).toList();
    _supplier = _supplier.where((element) => element.eid == widget.entity.eid).toList();
    _purchase = _allPurchase.where((element) => element.eid == widget.entity.eid && double.parse(element.amount.toString()) == double.parse(element.paid.toString())).toList();
    _payable = _allPurchase.where((element) => element.eid == widget.entity.eid &&   double.parse(element.paid.toString()) < double.parse(element.amount.toString())).toList();
    totalPurchases = _purchase.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
    totalPayableAmount = _payable.fold(0, (sum, item) => sum +  (double.parse(item.bprice.toString()) * double.parse(item.quantity.toString())));
    uniquePayable = _payable.toSet();
    uniquePayableList = uniquePayable.toList();
    totalPayablePaid = uniquePayableList.fold(0, (sum, item) => sum +  double.parse(item.paid.toString()));
    totalPayable = totalPayableAmount - totalPayablePaid;

    totalSprice = _compSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
    totalBprice = _compSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
    totalProfit = totalSprice - totalBprice;

    totalRecvSprice = _receivable.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
    uniqueReceive = _receivable.toSet();
    uniqueReceiveList = uniqueReceive.toList();
    totalRecvPaid = uniqueReceiveList.fold(0, (sum, item) => sum +  double.parse(item.paid.toString()));
    totalReceive = totalRecvSprice-totalRecvPaid;


    totalSuppliers = _supplier.length;
    Future.delayed(Duration.zero).then((value) {
      if (mounted) {
        setState(() {});
      }
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
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    double largeTextThreshold = 1;
    bool isLargeText = textScaleFactor >= largeTextThreshold;
    final width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        children: [
          Text('Overview', style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600),),
          SizedBox(
            width: 500,
            child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:  const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1
                ),
                itemCount: title.length,
                itemBuilder: (context, index){
                  return Card(
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title[index], style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black),),
                        Text(
                          index==0
                              ?'Ksh.${formatNumberWithCommas(totalSprice)}'
                              : index==1
                              ? 'Ksh.${formatNumberWithCommas(totalPurchases)}'
                              : index==2
                              ? 'Ksh.${formatNumberWithCommas(totalProfit)}'
                              : index==3
                              ? 'Ksh.${formatNumberWithCommas(totalReceive)}'
                              : index == 4
                              ? 'Ksh.${formatNumberWithCommas(totalPayable)}'
                              : totalSuppliers.toString(),
                          style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),
                        )
                      ],
                    ),
                  );
                }),
          ),
          SizedBox(height: 10,),
          SizedBox(width: 500,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10,),
                  _loading
                      ? SizedBox(width: 20,  height: 20,child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,))
                      : SizedBox(),
                  Expanded(child: SizedBox()),
                  CardButton(
                    text: 'RELOAD',
                    backcolor: screenBackgroundColor,
                    icon: Icon(Icons.refresh, size: 19, color: Colors.white,),
                    forecolor: Colors.white,
                    onTap: (){
                      setState(() {
                        _loading = true;
                      });
                      _getDetails();
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 500,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Divider(
                      height: 1,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:10.0),
                    child: Text('Sellers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500 , color: Colors.black),),
                  ),
                  Expanded(
                    child: Divider(
                      height: 1,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Sellers(eid: widget.entity.eid,),
          SizedBox(width: 500,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Divider(
                      height: 1,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:10.0),
                    child: Text('Sale Trend Graph', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500 , color: Colors.black),),
                  ),
                  Expanded(
                    child: Divider(
                      height: 1,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10,),
                  InkWell(
                    onTap:(){
                      setState(() {
                        _period=!_period;
                      });
                    },
                    child: Card(
                      elevation: 4,
                      color: _period?screenBackgroundColor:Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        child: Text(_period?"Monthly":"Weekly", style: TextStyle(color: _period?Colors.white:Colors.black)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          SizedBox(height: 200,width: 500,
            child: _period
                ? WeeklyBarChart(eid: widget.entity.eid, activeColor2: CupertinoColors.systemBlue,activeColor: screenBackgroundColor,)
                : MyBarChart(eid: widget.entity.eid),
          ),
        ],
      ),
    );
  }
  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
