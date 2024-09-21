import 'dart:convert';

import 'package:TallyApp/Widget/text/text_format.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/inventories.dart';
import 'package:TallyApp/models/products.dart';
import 'package:TallyApp/views/enty_tabs/sales.dart';
import 'package:flutter/material.dart';

import '../../models/sales.dart';
import '../../models/suppliers.dart';
import '../../utils/colors.dart';


class EntitySaleReport extends StatefulWidget {
  final String eid;
  const EntitySaleReport({super.key, required this.eid});

  @override
  State<EntitySaleReport> createState() => _EntitySaleReportState();
}

class _EntitySaleReportState extends State<EntitySaleReport> {
  late TextEditingController _search;

  List<ProductModel> _products = [];
  List<SaleModel> _sales = [];
  List<InventModel> _inv = [];
  List<SupplierModel> _suppliers = [];

  int? sortColumnIndex;
  bool isAscending = false;

  _getDetails(){
    _getData();
    _getData();
  }

  _getData(){
    _products = widget.eid == ""
        ? myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList()
        : myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).where((test) => test.eid ==widget.eid).toList();
    _sales =widget.eid == ""? mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((test) => double.parse(test.amount.toString()) == double.parse(test.paid.toString())
        && double.parse(test.paid.toString()) != 0.0).toList()
        : mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((test) => test.eid ==widget.eid && double.parse(test.amount.toString()) == double.parse(test.paid.toString())
        && double.parse(test.paid.toString()) != 0.0).toList();
    _inv = widget.eid == ""? myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList()
        :myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).where((test) => test.eid ==widget.eid).toList();
    _suppliers = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _products = _products.where((prd) => _sales.any((sale) => sale.productid == prd.prid)).toList();
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _search = TextEditingController();
    _getDetails();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _search.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      _products.forEach((item) {
        if (item.name.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.category.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.supplier.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _products;
    }
    final style = TextStyle(color: secondaryColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          constraints: BoxConstraints(
              maxWidth: 280,
              minWidth: 100
          ),
          padding: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: reverse
            ),
            borderRadius: BorderRadius.all(
                Radius.circular(10)
            ),
          ),
          child: TextFormField(
            controller: _search,
            keyboardType: TextInputType.text,
            style: TextStyle(color: reverse),
            decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(color: secondaryColor),
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                icon: Icon(Icons.search, color: reverse,),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none
                )
            ),
            onChanged:  (value) => setState((){}),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              headingRowHeight: 40,
              sortColumnIndex: sortColumnIndex,
              sortAscending: isAscending,
              showBottomBorder: false,
              columns: [
                DataColumn(
                  label: Text("Product", style: TextStyle(color: Colors.white),),
                  numeric: false,
                ),
                DataColumn(
                  label: Text("Category", style: TextStyle(color: Colors.white),),
                  numeric: false,
                ),
                DataColumn(
                  label: Text("Volume", style: TextStyle(color: Colors.white),),
                  numeric: false,
                ),
                DataColumn(
                  label: Text("Supplier", style: TextStyle(color: Colors.white),),
                  numeric: false,
                ),
                DataColumn(
                  label: Text("Buy Price", style: TextStyle(color: Colors.white),),
                  numeric: false,
                ),
                DataColumn(
                  label: Text("Sell Price", style: TextStyle(color: Colors.white),),
                  numeric: false,
                ),
                DataColumn(
                  label: Text("Units Sold", style: TextStyle(color: Colors.white),),
                  numeric: false,
                ),
                DataColumn(
                  label: Text("Status", style: TextStyle(color: Colors.white),),
                  numeric: false,
                ),
                DataColumn(
                  label: Text("Revenue", style: TextStyle(color: Colors.white),),
                  numeric: false,
                ),
                DataColumn(
                  label: Text("Profit", style: TextStyle(color: Colors.white),),
                  numeric: false,
                ),
              ],
              rows: filteredList.map((products){
                var _filtSales = _sales.where((element) => element.productid == products.prid).toList();
                var supplier = _suppliers.firstWhere((test) => test.sid == products.supplier, orElse: () => SupplierModel(sid: "", name: "N/A"));
                var units = _filtSales.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
                var inv = _inv.firstWhere((element) => element.productid == products.prid, orElse: ()=> InventModel(iid: "", quantity: "0"));
                var qnty = int.parse(inv.quantity.toString());

                double sprice = _filtSales.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
                double bprice = _filtSales.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
                double profit = sprice - bprice;

                return DataRow(
                  cells: [
                    DataCell(
                      Text(TFormat().toCamelCase(products.name.toString()), style: style),
                    ),
                    DataCell(
                      Text(products.category.toString(), style: style),
                    ),
                    DataCell(
                      Text(products.volume.toString(), style: style),
                    ),
                    DataCell(
                      Text(TFormat().toCamelCase(supplier.name.toString()), style: style),
                    ),
                    DataCell(
                      Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(products.buying.toString()))}", style: style),
                    ),
                    DataCell(
                      Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(products.selling.toString()))}", style: style),
                    ),
                    DataCell(
                      Center(child: Text(units.toString(), style: style)),
                    ),
                    DataCell(
                        Container(
                          height: 25,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: qnty<10 && qnty>4
                                  ? Colors.orange.withOpacity(0.3)
                                  :qnty < 5 && qnty >0
                                  ? Colors.purple.withOpacity(0.2)
                                  :qnty==0
                                  ? Colors.red.withOpacity(0.3)
                                  :Colors.green.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(50)
                          ),
                          child: Center(child: Text(
                            qnty < 10 && qnty > 4
                                ?"Low stock"
                                : qnty < 5 && qnty > 0
                                ? "Critically low"
                                : qnty == 0
                                ? "Out of stock"
                                : "In Stock",
                            style: TextStyle(
                                color: qnty<10 && qnty>4
                                    ? Colors.orange
                                    :qnty < 5 && qnty >0
                                    ? Colors.purple
                                    :qnty<1
                                    ? Colors.red
                                    :Colors.green,
                                fontWeight: FontWeight.w500
                            ),
                          )
                          ),
                        )
                    ),
                    DataCell(
                      Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(sprice)}", style: style),
                    ),
                    DataCell(
                      Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(profit)}", style: style),
                    ),
                  ]
                );
              }).toList()
          ),
        ),
      ],
    );
  }
}
