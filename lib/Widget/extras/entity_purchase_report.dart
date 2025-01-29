import 'dart:convert';

import 'package:TallyApp/models/products.dart';
import 'package:TallyApp/models/purchases.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../models/data.dart';
import '../../models/inventories.dart';
import '../../models/suppliers.dart';
import '../../utils/colors.dart';
import '../text/text_format.dart';

class EntityPurchaseReport extends StatefulWidget {
  final String eid;
  const EntityPurchaseReport({super.key, required this.eid});

  @override
  State<EntityPurchaseReport> createState() => _EntityPurchaseReportState();
}

class _EntityPurchaseReportState extends State<EntityPurchaseReport> {
  bool _loading = true;
  List<PurchaseModel> _purchase =[];
  List<PurchaseModel> _newpurchase =[];
  List<PurchaseModel> _filtPrch =[];
  List<PurchaseModel> _newPurchase =[];
  List<ProductModel> _products = [];
  List<ProductModel> _newproducts = [];
  List<ProductModel> _filteredPrdcts = [];
  List<SupplierModel> _spplr = [];
  List<SupplierModel> _newspplr = [];
  List<SupplierModel> _fltSpplr = [];
  List<InventModel> inv = [];
  List<InventModel> filtInv = [];

  _getDetails()async{
    _getPurchases();
    _newpurchase = await Services().getMyPurchase(currentUser.uid);
    _newspplr = await Services().getMySuppliers(currentUser.uid);
    _newproducts = await Services().getMyPrdct(currentUser.uid);
    await Data().addOrUpdatePurchaseList(_newpurchase);
    await Data().addOrUpdateSuppliersList(_newspplr);
    await Data().addOrUpdateProductsList(_newproducts);
    _getPurchases();
  }


  _getPurchases()async{
    setState(() {
      _loading = true;
    });
    _purchase =  widget.eid == ""
        ? myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid).toList()
        : myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).where((element) => element.amount == element.paid && element.eid == widget.eid).toList();
    _spplr =  widget.eid == ""
        ? mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList()
        : mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.eid).toList();
    _products = widget.eid == ""
        ? myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList()
        : myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.eid).toList();
    inv = widget.eid == ""
        ? myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList()
        : myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).where((element) =>  element.eid == widget.eid).toList();
    setState(() {
      for (var purchase in _purchase) {
        bool idExists = _newPurchase.any((element) => element.productid == purchase.productid);
        if (!idExists) {
          _newPurchase.add(purchase);
        }
      }
      _newPurchase.sort((a, b) {
        int countA = _purchase.where((sales) => sales.productid == a.productid).length;
        int countB = _purchase.where((sales) => sales.productid == b.productid).length;
        return countB.compareTo(countA);
      });
      _loading = false;
    });
  }

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40,
        headingRowColor: WidgetStateColor.resolveWith((states) {
          return color1;
        }),
        columns: [
          DataColumn(
            label: Text("PRODUCT NAME", style: TextStyle(color: Colors.white),),
            numeric: false,
          ),
          DataColumn(
            label: Text("CATEGORY", style: TextStyle(color: Colors.white),),
            numeric: false,
          ),
          DataColumn(
            label: Text("ML", style: TextStyle(color: Colors.white),),
            numeric: false,
          ),
          DataColumn(
            label: Text("SUPPLIER", style: TextStyle(color: Colors.white),),
            numeric: false,
          ),
          DataColumn(
            label: Text("BUYING PRICE", style: TextStyle(color: Colors.white),),
            numeric: false,
          ),
          DataColumn(
              label: Text("UNITS", style: TextStyle(color: Colors.white),),
              numeric: false,
              tooltip: "total units bought"
          ),
          DataColumn(
            label: Text("STATUS", style: TextStyle(color: Colors.white),),
            numeric: false,
          ),
        ],
        rows: _newPurchase.map((product){
          _filteredPrdcts = _products.where((element) => element.prid == product.productid).toList();
          var name = _filteredPrdcts.isEmpty ? "N/A" : _filteredPrdcts.first.name.toString();
          var car = _filteredPrdcts.isEmpty ? "N/A" : _filteredPrdcts.first.category.toString();
          var vol = _filteredPrdcts.isEmpty ? "0" : _filteredPrdcts.first.volume.toString();
          var supplierId = _filteredPrdcts.isEmpty? "" : _filteredPrdcts.first.supplier;
          _fltSpplr = _spplr.where((element) => element.sid == supplierId).toList();
          var supplier = _fltSpplr.isEmpty ? "N/A" : _fltSpplr.first.name.toString();
          filtInv = inv.where((inv) => inv.productid == _filteredPrdcts.first.prid).toList();
          var qnty = filtInv.length == 0 ? 0 : int.parse(filtInv.first.quantity.toString());
          _filtPrch = _purchase.where((element) => element.productid == product.productid).toList();
          var qntyPrch = _filtPrch.isEmpty ? 0 : _filtPrch.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
          final style = TextStyle(color: secondaryColor);
          return DataRow(
              cells: [
                DataCell(
                    Text(name,style: style),
                    onTap: (){
                      // _setValues(inventory);
                      // _selectedInv = inventory;
                    }
                ),
                DataCell(
                    Text(car,style:style),
                    onTap: (){
                      // _setValues(inventory);
                      // _selectedInv = inventory;
                    }
                ),
                DataCell(
                    Text(vol,style: style),
                    onTap: (){
                      // _setValues(inventory);
                      // _selectedInv = inventory;
                    }
                ),
                DataCell(
                    Text(supplier,style: style),
                    onTap: (){
                      // _setValues(inventory);
                      // _selectedInv = inventory;
                    }
                ),
                DataCell(
                    Text('${TFormat().getCurrency()}${formatNumberWithCommas(double.parse(product.bprice.toString()))}',style: style),
                    onTap: (){
                      // _setValues(inventory);
                      // _selectedInv = inventory;
                    }
                ),
                DataCell(
                    Center(child: Text(qntyPrch.toString(), style:style)),
                    onTap: (){
                      // _setValues(inventory);
                      // _selectedInv = inventory;
                    }
                ),
                DataCell(
                    Container(
                      height: 25,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: qnty<10 && qnty>4
                              ? Colors.orange.withOpacity(0.3)
                              :qnty < 5 && qnty >0
                              ? Colors.purple.withOpacity(0.3)
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
                                :qnty==0
                                ? Colors.red
                                :Colors.green,
                            fontWeight: FontWeight.w500
                        ),
                      )
                      ),
                    ),
                    onTap: (){
                      // _setValues(inventory);
                      // _selectedInv = inventory;
                    }
                ),
              ]
          );
        }
        ).toList(),
      ),
    );
  }
}
