import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/suppliers.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

import '../../Widget/buttons/card_button.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/dialogs/filters/dialog_filter_goods.dart';
import '../../Widget/text/text_format.dart';
import '../../main.dart';
import '../../models/products.dart';
import '../../models/sales.dart';
import '../../utils/colors.dart';

class SaleReport extends StatefulWidget {
  final EntityModel entity;
  const SaleReport({super.key, required this.entity});

  @override
  State<SaleReport> createState() => _SaleReportState();
}

class _SaleReportState extends State<SaleReport> {
  TextEditingController _search = TextEditingController();
  final ScrollController _horizontal = ScrollController();
  List<String> title = [ 'Total Sales','Total profit','Total Products', 'Units Sold'];

  bool _layout = true;
  bool _loading = false;
  bool isFilled = false;

  List<SaleModel> _sale =[];
  List<SaleModel> _newSale =[];
  List<SaleModel> _filtSale = [];
  List<ProductModel> _products = [];
  List<ProductModel> _newPrd = [];
  List<SupplierModel> _sppl = [];
  List<SupplierModel> _newSupp = [];
  List<SupplierModel> _fltSpplr = [];


  double tSPrice = 0;
  double tBPrice = 0;
  double tProfit = 0;
  int tQuantity = 0;
  int tProducts = 0;

  int? sortColumnIndex;
  bool isAscending = false;

  String category = "";
  String volume = "";
  String supplierId ="";

  _getDetails()async{
    _getData();
    _newSale = await Services().getMySale(currentUser.uid);
    _newPrd = await Services().getMyPrdct(currentUser.uid);
    _newSupp = await Services().getMySuppliers(currentUser.uid);
    await Data().addOrUpdateSalesList(_newSale);
    await Data().addOrUpdateProductsList(_newPrd);
    await Data().addOrUpdateSuppliersList(_newSupp).then((value){
      setState(() {
        _loading = value;
      });
    });
    _getData();
  }

  _getData(){
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _products = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _sppl = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _sale = _sale.where((element) => element.eid == widget.entity.eid && double.parse(element.amount.toString()) == double.parse(element.paid.toString())).toList();
    _products = _products.where((prd) => _sale.any((sale) => prd.prid == sale.productid)).toList();
    _products = _products.where((test){
      bool matchesEid = test.eid == widget.entity.eid;
      bool matchesCategory = category.isEmpty || test.category == category;
      bool matchesVolume = volume.isEmpty || test.volume == volume;
      bool matchesSupplier = supplierId.isEmpty || test.supplier == supplierId;
      return matchesEid && matchesCategory && matchesVolume && matchesSupplier;
    }).toList();
    tProducts = _products.length;
    tSPrice = _sale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString()) ));
    tBPrice = _sale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString()) ));
    tQuantity = _sale.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
    tProfit = tSPrice - tBPrice;
    setState(() {

    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
    if(Platform.isIOS || Platform.isAndroid){
      _layout = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
    return Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GridView.builder(
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
                          Text(index==0
                              ?'${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(tSPrice)}'
                              : index==1
                              ? '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(tProfit)}'
                              :index==2
                              ?tProducts.toString()
                              :tQuantity.toString(),
                            style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),)
                        ],
                      ),
                    );
                  }),
              Row(
                children: [
                  _loading
                      ?Container(
                    width: 15,height: 15,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  ) :SizedBox(),
                  Expanded(child: SizedBox()),
                  CardButton(
                    text: _layout?'List':'Table',
                    backcolor: Colors.white,
                    icon: Icon(_layout?CupertinoIcons.list_dash:CupertinoIcons.table, color: screenBackgroundColor,size: 16,),
                    forecolor: screenBackgroundColor,
                    onTap: () {
                      setState(() {
                        _layout=!_layout;
                      });
                    },
                  ),
                  CardButton(
                      text: "Filter",
                      backcolor: Colors.white,
                      forecolor: Colors.black,
                      icon: Icon(Icons.filter_list_rounded, size: 20,color: Colors.black,),
                      onTap: (){dialogFilter(context);}
                  ),
                  CardButton(
                    text: 'Reload',
                    backcolor: screenBackgroundColor,
                    icon: Icon(CupertinoIcons.refresh, size: 16, color: Colors.white,),
                    forecolor: Colors.white,
                    onTap: () {
                      setState(() {
                        supplierId = "";
                        category = "";
                        volume = "";
                        _loading = true;
                      });
                      _getDetails();
                    },
                  ),
                ],
              ),
              _products.isEmpty
                  ? SizedBox()
                  : Padding(
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
                      child: Text('Sale Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500 , color: Colors.black),),
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
              _products.isEmpty
                  ? Column(
                children: [
                  SizedBox(height: 100,),
                  Image.asset("assets/add/box.png"),
                  Text("You do not have any items yet", style: TextStyle(color: screenBackgroundColor, fontSize: 18, fontWeight: FontWeight.w600),),
                  Text("Please navigate to the sales section and add items to your list.", style: TextStyle(color: Colors.grey[700]),),
                ],
              )
                  : SizedBox(
                width: double.infinity,
                child: Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              maxWidth: 280,
                              minWidth: 100
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: Colors.black
                            ),
                            borderRadius: BorderRadius.all(
                                Radius.circular(10)
                            ),
                          ),
                          child: TextFormField(
                            controller: _search,
                            keyboardType: TextInputType.text,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: "Search",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(5)
                                ),
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
                              prefixIcon: Icon(CupertinoIcons.search, size: 20,color: secondaryColor),

                              prefixIconConstraints: BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 30
                              ),
                              suffixIcon: isFilled?InkWell(
                                  onTap: (){
                                    _search.clear();
                                    setState(() {
                                      isFilled = false;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(100),
                                  child: Icon(Icons.cancel, size: 20,color: secondaryColor)
                              ) :SizedBox(),
                              suffixIconConstraints: BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 30
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
                              filled: false,
                              isDense: true,
                            ),
                            onChanged:  (value) => setState((){
                              if(value.isNotEmpty){
                                isFilled = true;
                              } else {
                                isFilled = false;
                              }
                            }),
                          ),
                        ),
                        SizedBox(height: 20,),
                        _layout
                            ? Scrollbar(
                          thumbVisibility: true,
                          controller: _horizontal,
                              child: SingleChildScrollView(
                                controller: _horizontal,
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                              headingRowHeight: 30,
                              headingRowColor: WidgetStateColor.resolveWith((states) {
                                return screenBackgroundColor;
                              }),
                              sortColumnIndex: sortColumnIndex,
                              sortAscending: isAscending,
                              columns: [
                                DataColumn(
                                  label: Text("Product", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                  onSort: onSort,
                                    tooltip: 'Click here to sort list by name'
                                ),
                                DataColumn(
                                  label: Text("Category", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                  onSort: onSort,
                                    tooltip: 'Click here to sort list by category'
                                ),
                                DataColumn(
                                  label: Text("Volume", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                ),
                                DataColumn(
                                  label: Text("Supplier", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                  onSort: onSort,
                                    tooltip: 'Click here to sort list by Supplier'
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
                                  label: Text("Revenue", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                ),
                                DataColumn(
                                  label: Text("Profits", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                ),
                              ],
                              rows: filteredList.map((product){
                                _fltSpplr = _sppl.where((sup) => sup.sid == product.supplier).toList();
                                _filtSale = _sale.where((element) => element.productid == product.prid).toList();
                                double sprice = _filtSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString()) ));
                                double bprice = _filtSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString()) ));
                                double quantity = _filtSale.fold(0.0, (previousValue, element) => previousValue + double.parse(element.quantity.toString()));
                                double profit = sprice - bprice;
                                return DataRow(
                                    cells: [
                                      DataCell(
                                          Text(product.name.toString(),style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text(product.category.toString(),style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text(product.volume.toString(),style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),

                                      DataCell(
                                          Text(_fltSpplr.length == 0 ? 'N/A' : _fltSpplr.first.name.toString(),style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(product.buying.toString()))}',style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(product.selling.toString()))}',style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Center(child: Text(quantity.toStringAsFixed(0), style: TextStyle(color: Colors.black),)),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(sprice)}', style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),

                                      DataCell(
                                          Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(profit)}', style: TextStyle(color: Colors.black),),
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
                                                      ),
                            )
                            : SizedBox(width: 450,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index){
                                ProductModel product = filteredList[index];
                                _fltSpplr = _sppl.where((sup) => sup.sid == product.supplier).toList();
                                _filtSale = _sale.where((element) => element.productid == product.prid).toList();
                                double sprice = _filtSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString()) ));
                                double bprice = _filtSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString()) ));
                                int quantity = _filtSale.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
                                double profit = sprice - bprice;
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.black12,
                                        child: Center(child:
                                        product.checked == "false"
                                            ?Icon(Icons.cloud_upload, color: Colors.red,)
                                            :product.checked.toString().contains("DELETE") || product.checked.toString().contains("REMOVED")
                                            ?Icon(CupertinoIcons.delete, color: Colors.red,)
                                            :product.checked.toString().contains("EDIT")
                                            ?Icon(Icons.edit_rounded, color: Colors.red)
                                            :LineIcon.box(color: Colors.black,),
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(product.name.toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                                                SizedBox(width: 10,),
                                                Text('${product.category}', style: TextStyle(color: Colors.black54, fontSize: 11),),
                                                Expanded(child: SizedBox()),
                                                Text('ML : ${product.volume}', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 11),),

                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(_fltSpplr.length == 0 ? 'Supplier not available' : 'Supplier : ${_fltSpplr.first.name}', style: TextStyle(fontSize: 11, color: Colors.black),),
                                                Expanded(child: SizedBox()),
                                                Text(
                                                  "BP: ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(product.buying.toString()))} SP: ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(product.selling.toString()))}",
                                                  style: TextStyle(fontSize: 11, color: Colors.black),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text('Units Sold : $quantity',style: TextStyle(fontSize: 11, color: Colors.black)),
                                                Expanded(child: SizedBox()),
                                                Text(
                                                  "Revenue: ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(sprice)} Profits: ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(profit)}",
                                                  style: TextStyle(fontSize: 11, color: Colors.black),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                ),
              ),
               
            ],
          ),
        )
    );
  }
  void dialogFilter(BuildContext context){
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'F I L T E R'),
                DialogFilterGoods(entity: widget.entity, filter: _filter,)
              ],
            ),
          ),
        )
    );
  }

  void _filter(String? cat, String? vol, String? sid, String entityEid){
    supplierId = sid==null?"":sid;
    category = cat==null?"":cat;
    volume = vol==null?"":vol;
    _getData();
  }
  
  void onSort(int columnIndex, bool ascending){
    if(columnIndex == 0){
      _products.sort((prd1, prd2) =>
          compareString(ascending, prd1.name.toString(), prd2.name.toString())
      );
    } else if (columnIndex == 1){
      _products.sort((prd1, prd2) =>
          compareString(ascending, prd1.category.toString(), prd2.category.toString())
      );
    }else if (columnIndex == 3){
      _products.sort((prd1, prd2) =>
          compareString(ascending, prd1.supplier.toString(), prd2.supplier.toString())
      );
    }
    setState(() {
      this.sortColumnIndex = columnIndex;
      this.isAscending = ascending;
    });
  }
  int compareString(bool ascending, String value1, String value2){
    return ascending? value1.compareTo(value2) : value2.compareTo(value1);
  }
}
