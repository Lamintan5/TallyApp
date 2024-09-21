import 'dart:convert';

import 'package:TallyApp/models/products.dart';
import 'package:TallyApp/models/sales.dart';
import 'package:TallyApp/models/suppliers.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';

import '../main.dart';
import '../utils/colors.dart';

class Sellers extends StatefulWidget {
  final String eid;
  const Sellers({super.key, required this.eid});

  @override
  State<Sellers> createState() => _SellersState();
}

class _SellersState extends State<Sellers> {
  List<SaleModel> _sale = [];
  List<SupplierModel> _supplier = [];
  List<ProductModel> _products = [];

  List<ProductModel> _filteredPrdcts = [];
  List<SupplierModel> _filtSupplier = [];
  List<SaleModel> _filtSale = [];

  List<SaleModel> seller = [];
  List<SaleModel> worstSeller = [];

  _getData(){
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _supplier = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _products = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _sale = _sale.where((element) => element.eid == widget.eid && double.parse(element.amount.toString()) == double.parse(element.paid.toString())
        && double.parse(element.paid.toString()) != 0.0).toList();
    setState(() {
      Map<String, List<SaleModel>> groupedSales = {};
      _sale.forEach((sale) {
        groupedSales.putIfAbsent(sale.productid!, () => []);
        groupedSales[sale.productid!]!.add(sale);
      });
      List<SaleModel> summedSales = [];
      List<SaleModel> summedWrstSales = [];

      groupedSales.forEach((productId, sales) {
        int totalQuantity = sales.map((sale) => int.parse(sale.quantity!)).reduce((a, b) => a + b);
        summedSales.add(SaleModel(saleid: '', productid: productId, quantity: totalQuantity.toString()));
        summedWrstSales.add(SaleModel(saleid: '', productid: productId, quantity: totalQuantity.toString()));
      });

      summedSales.sort((a, b) => int.parse(b.quantity!).compareTo(int.parse(a.quantity!)));
      summedWrstSales.sort((a, b) => int.parse(a.quantity!).compareTo(int.parse(b.quantity!)));

      seller = summedSales;
      worstSeller = summedWrstSales;

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 500,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('BEST SELLER', style: TextStyle(color: Colors.black),),
                SizedBox(height: 130,
                  child: Card(
                    elevation: 3,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                      child: ListView.builder(
                          itemCount: seller.length < 3? seller.length : 3,
                          itemBuilder: (context, index){
                            SaleModel sale = seller[index];
                            _filteredPrdcts = _products.where((element) => element.prid == sale.productid).toList();
                            _filtSale = _sale.where((element) => element.productid == sale.productid).toList();
                            _filtSupplier = _supplier.where((element) => element.sid == _filteredPrdcts.first.supplier).toList();
                            var name = _filteredPrdcts.isEmpty ? "N/A" : _filteredPrdcts.first.name.toString();
                            var vol = _filteredPrdcts.isEmpty ? "N/A" : _filteredPrdcts.first.volume.toString();
                            var cat = _filteredPrdcts.isEmpty ? "N/A" : _filteredPrdcts.first.category.toString();
                            var supplier = _filtSupplier.isEmpty ? "N/A" : _filtSupplier.first.name.toString();
                            int quantity = _filtSale.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.green.withOpacity(0.8),
                                        child: LineIcon.box(color: Colors.black,size: 20,),
                                      ),
                                      SizedBox(width: 5,),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(name,style: TextStyle(color: Colors.black, fontSize: 11),),
                                                SizedBox(width: 5,),
                                                Text("$cat" ,style: TextStyle(color: secondaryColor, fontSize: 10),)
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(child: Text("VOL : $vol  SPL : $supplier" ,style: TextStyle(color: secondaryColor, fontSize: 10),)),
                                                Text("${quantity.toString()} Units",style: TextStyle(color: Colors.black, fontSize: 10),),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2,),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Divider(
                                      thickness: 1,
                                      height: 1,
                                      color: Colors.black12,
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text('WORST SELLER', style: TextStyle(color: Colors.black),),
                SizedBox(height: 130,
                  child: Card(
                    elevation: 3,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                      child: ListView.builder(
                          itemCount: worstSeller.length < 3? worstSeller.length : 3,
                          itemBuilder: (context, index){
                            SaleModel sale = worstSeller[index];
                            _filteredPrdcts = _products.where((element) => element.prid == sale.productid).toList();
                            var name = _filteredPrdcts.isEmpty ? "N/A" : _filteredPrdcts.first.name.toString();
                            var vol = _filteredPrdcts.isEmpty ? "N/A" : _filteredPrdcts.first.volume.toString();
                            var cat = _filteredPrdcts.isEmpty ? "N/A" : _filteredPrdcts.first.category.toString();
                            _filtSale = _sale.where((element) => element.productid == sale.productid).toList();
                            _filtSupplier = _supplier.where((element) => element.sid == _filteredPrdcts.first.supplier).toList();
                            var supplier = _filtSupplier.isEmpty ? "N/A" : _filtSupplier.first.name.toString();
                            int quantity = _filtSale.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.red.withOpacity(0.8),
                                        child: LineIcon.box(color: Colors.black,size: 20,),
                                      ),
                                      SizedBox(width: 5,),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(name,style: TextStyle(color: Colors.black, fontSize: 11),),
                                                SizedBox(width: 5,),
                                                Text("$cat" ,style: TextStyle(color: secondaryColor, fontSize: 10),)
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(child: Text("VOL : $vol   SPL : $supplier",style: TextStyle(color: secondaryColor, fontSize: 10),)),
                                                Text("${quantity.toString()} Units",style: TextStyle(color: Colors.black, fontSize: 10),),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2,),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Divider(
                                      thickness: 1,
                                      height: 1,
                                      color: Colors.black12,
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
