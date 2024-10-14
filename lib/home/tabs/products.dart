import 'dart:convert';

import 'package:TallyApp/models/entities.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/buttons/bottom_call_buttons.dart';
import '../../Widget/buttons/card_button.dart';
import '../../Widget/dialogs/call_actions/double_call_action.dart';
import '../../Widget/dialogs/call_actions/single_call_action.dart';
import '../../Widget/dialogs/dialog_edit_product.dart';
import '../../Widget/dialogs/dialog_request.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/dialogs/filters/dialog_filter_goods.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/duties.dart';
import '../../models/products.dart';
import '../../models/suppliers.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  TextEditingController _search = TextEditingController();
  List<String> title = ['Total Products', 'Suppliers'];
  List<String> items = [
    'Store One',
    'Store Two',
    'Store Three',
    'Store Four',
    'Store Five'
  ];

  List<ProductModel> _prd = [];
  List<ProductModel> _allprd = [];
  List<ProductModel> _newPrd = [];
  List<SupplierModel> _spplr = [];
  List<SupplierModel> _newSpplr = [];
  List<SupplierModel> _fltSpplr = [];
  List<EntityModel> _entity = [];

  bool _loading = false;

  int? sortColumnIndex;
  bool isAscending = false;

  List<DutiesModel> _duties = [];
  String _dutiesString = "";
  late DutiesModel dutiesModel;
  int _layout = 0;
  int removed = 0;
  bool close = true;

  
  String selectedID = "";

  int countPrd = 0;
  int countSppl = 0;

  String category = "";
  String volume = "";
  String supplierId ="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      _prd.forEach((item) {
        if (item.name.toString().toLowerCase().contains(_search.text.toString().toLowerCase()) ||
            item.category.toString().toLowerCase().contains(_search.text.toString().toLowerCase()) ||
            item.supplier.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _prd;
    }
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            " Products",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30),
          ),
          SizedBox(height: 10,),
          GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1),
              itemCount: title.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title[index],
                        style: TextStyle(
                            fontWeight: FontWeight.w300, color: Colors.black),
                      ),
                      Text(
                        index == 0
                            ? countPrd.toString()
                            : index == 1
                                ? countSppl.toString()
                                : "0",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black),
                      )
                    ],
                  ),
                );
              }),
          Row(
            children: [
              _loading?Container(
                width: 20,height: 20,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: CircularProgressIndicator(color: reverse,strokeWidth: 2,)
              ):SizedBox(),
              Expanded(child: SizedBox()),
              CardButton(
                text: _layout == 0
                    ? 'List'
                    : _layout == 2
                        ? 'Table'
                        : "QRCs",
                backcolor: Colors.white,
                icon: Icon(
                  _layout == 0
                      ? CupertinoIcons.list_dash
                      : _layout == 2
                          ? CupertinoIcons.table
                          : CupertinoIcons.qrcode,
                  color: screenBackgroundColor,
                  size: 16,
                ),
                forecolor: screenBackgroundColor,
                onTap: () {
                  setState(() {
                    if (_layout < 2) {
                      _layout++;
                    } else {
                      _layout = 0;
                    }
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
                icon: Icon(
                  CupertinoIcons.refresh,
                  size: 16,
                  color: Colors.white,
                ),
                forecolor: Colors.white,
                onTap: () {
                  setState(() {
                    category = "";
                    volume = "";
                    supplierId = "";
                    _loading = true;
                  });
                  _getDetails();
                },
              ),
            ],
          ),
          close == false
              ? Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 400,
                      maxWidth: 600,
                    ),
                    child: Card(
                      color: Colors.white,
                      elevation: 8,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.delete,
                              size: 30,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(fontSize: 13),
                                      children: [
                                    TextSpan(
                                        text: "Attention: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: "${removed.toString()} ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: removed > 1
                                            ? "products have "
                                            : "product has ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black)),
                                    TextSpan(
                                        text:
                                            "been removed from our server by one of the managers. This change may impact your data. Would you like to update your list to reflect these changes? ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black)),
                                    WidgetSpan(
                                        child: InkWell(
                                            onTap: () {
                                              _removeAll();
                                            },
                                            child: Text(
                                              "Remove All",
                                              style: TextStyle(
                                                  color: CupertinoColors
                                                      .systemBlue,
                                                  fontWeight: FontWeight.bold),
                                            )))
                                  ])),
                            ),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    close = true;
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 30,
                                  color: Colors.black,
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: _allprd.isEmpty
                      ? Column(
                          children: [
                            SizedBox(
                              height: 100,
                            ),
                            Image.asset("assets/add/box.png"),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "You do not have any items yet",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Navigate to entity products tab to add new products to your list",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth: 280, minWidth: 100),
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.black),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: TextFormField(
                                    controller: _search,
                                    keyboardType: TextInputType.text,
                                    style: TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                        hintText: "Search...",
                                        hintStyle:
                                            TextStyle(color: secondaryColor),
                                        filled: false,
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(8),
                                        icon: Icon(
                                          Icons.search,
                                          color: Colors.black,
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none)),
                                    onChanged: (value) => setState(() {}),
                                  ),
                                ),
                                _layout == 2
                                    ? CardButton(
                                        text: 'Save',
                                        backcolor: Colors.white,
                                        icon: Icon(
                                          CupertinoIcons.arrow_down_to_line,
                                          size: 16,
                                          color: screenBackgroundColor,
                                        ),
                                        forecolor: screenBackgroundColor,
                                        onTap: () {},
                                      )
                                    : SizedBox()
                              ],
                            ),
                            SizedBox(height: 20),
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _layout == 0
                                          ? SingleChildScrollView(
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
                                                      label: Text(
                                                        "PRODUCT NAME",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      numeric: false,
                                                      onSort: onSort,
                                                      tooltip:
                                                          'Click here to sort list by name'),
                                                  DataColumn(
                                                      label: Text(
                                                        "CATEGORY",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      numeric: false,
                                                      onSort: onSort,
                                                      tooltip:
                                                          'Click here to sort list by category'),
                                                  DataColumn(
                                                    label: Text(
                                                      "VOLUME",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    numeric: false,
                                                  ),
                                                  DataColumn(
                                                      label: Text(
                                                        "SUPPLIER",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      numeric: false,
                                                      onSort: onSort,
                                                      tooltip:
                                                          'Click here to sort list by Supplier'),
                                                  DataColumn(
                                                    label: Text(
                                                      "BUYING PRICE",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    numeric: false,
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      "SELLING PRICE",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    numeric: false,
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      "QR CODE",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    numeric: false,
                                                  ),
                                                  DataColumn(
                                                      label: Text(
                                                        "ACTION",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      numeric: false,
                                                      tooltip:
                                                          'Action to remove product from list'),
                                                ],
                                                rows: filteredList.map((product) {
                                                  _fltSpplr = _spplr.where((sup) => sup.sid == product.supplier).toList();
                                                  EntityModel entity = _entity.firstWhere((test) => test.eid==product.eid, orElse: ()=>EntityModel(eid: "", admin: ""));
                                                  List<String> admin = entity.admin.toString().split(",");
                                                  return DataRow(cells: [
                                                    DataCell(
                                                      Text(
                                                        product.name.toString(),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        product.category
                                                            .toString(),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        product.volume
                                                            .toString(),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        _fltSpplr.length == 0
                                                            ? 'N/A'
                                                            : _fltSpplr
                                                                .first.name
                                                                .toString(),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        'Ksh.${formatNumberWithCommas(double.parse(product.buying.toString()))}',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        'Ksh.${formatNumberWithCommas(double.parse(product.selling.toString()))}',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    DataCell(
                                                        Center(
                                                            child: Icon(
                                                          Icons.qr_code,
                                                          color:
                                                              screenBackgroundColor,
                                                        )), onTap: () {
                                                      dialogQRCode(
                                                          context, product);
                                                    }),
                                                    DataCell(
                                                      Center(
                                                          child:
                                                              PopupMenuButton<String>(
                                                                tooltip: 'Show options',
                                                                child: Icon(
                                                                  product.checked == "false"
                                                              ? Icons.cloud_upload
                                                              : product.checked.contains("DELETE") || product.checked.contains("REMOVED")
                                                                  ? CupertinoIcons.delete
                                                                  : product.checked.contains("EDIT")
                                                                      ? Icons.edit_rounded
                                                                      : Icons.more_vert,
                                                          color: product.checked == "false" || product.checked.contains("DELETE") || product.checked.contains("EDIT") 
                                                              || product.checked.contains("REMOVED")
                                                              ? Colors.red
                                                              : screenBackgroundColor,
                                                        ),
                                                        itemBuilder:
                                                            (BuildContextcontext) {
                                                          return [
                                                            if (product.checked == "false" || product.checked == "false, EDIT" || product.checked.contains("REMOVED"))
                                                              PopupMenuItem(
                                                                value: 'upload',
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Icon(Icons.cloud_upload,
                                                                      color: Colors.red,
                                                                    ),
                                                                    SizedBox(width: 5,),
                                                                    Text('Upload',
                                                                      style: TextStyle(color: Colors.red,),
                                                                    ),
                                                                  ],
                                                                ),
                                                                onTap: () {
                                                                  _upload(product);
                                                                },
                                                              ),
                                                            PopupMenuItem(
                                                              value: 'delete',
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Icon(
                                                                    CupertinoIcons.delete,
                                                                    color: admin.contains(currentUser.uid)
                                                                        ? reverse
                                                                        : _dutiesString.contains("PRODUCT")
                                                                            ? reverse
                                                                            : Colors.red,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    'Delete',
                                                                    style: TextStyle(
                                                                      color: admin.contains(currentUser.uid)
                                                                          ? reverse
                                                                          : _dutiesString.contains("PRODUCT")
                                                                              ? reverse
                                                                              : Colors.red,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              onTap: () {
                                                                admin.contains(currentUser.uid)
                                                                    ? dialogDelete(context, product)
                                                                    : !_dutiesString.contains("PRODUCT")
                                                                    ? dialogRequest(context, "Remove", entity)
                                                                    : dialogDelete(context, product);
                                                              },
                                                            ),
                                                            PopupMenuItem(
                                                              value: product.checked.toString().contains("DELETE")
                                                                  ? 'Restore'
                                                                  : 'Edit',
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Icon(
                                                                    product.checked.toString().contains("DELETE")
                                                                        ? Icons.restore
                                                                        : Icons.edit,
                                                                    color: admin.contains(currentUser.uid)
                                                                        ? reverse
                                                                        : _dutiesString.contains("PRODUCT")
                                                                            ? reverse
                                                                            : Colors.red,
                                                                  ),
                                                                  SizedBox(width: 5,),
                                                                  Text(
                                                                    product.checked.toString().contains("DELETE")
                                                                        ? 'Restore'
                                                                        : 'Edit',
                                                                    style:
                                                                        TextStyle(
                                                                      color: admin.contains(currentUser.uid)
                                                                          ? reverse
                                                                          : _dutiesString.contains("PRODUCT")
                                                                              ? reverse
                                                                              : Colors.red,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              onTap: () {
                                                                admin.contains(currentUser.uid)
                                                                    ? product.checked.toString().contains("DELETE")
                                                                    ? _restore(product)
                                                                    : dialogEdit(context, product)

                                                                    : product.checked.toString().contains("DELETE")
                                                                    ? !_dutiesString.contains("PURCHASE")? dialogRequest(context, "Edit", entity) :  _restore(product)
                                                                    : !_dutiesString.contains("PURCHASE")? dialogRequest(context, "Edit", entity) : dialogEdit(context, product);
                                                              },
                                                            ),
                                                          ];
                                                        },
                                                      )),
                                                    ),

                                                    // DataCell(
                                                    //     Center(child: Icon(
                                                    //       Icons.edit,
                                                    //       color: admin.contains(currentUser.uid)
                                                    //           ? screenBackgroundColor
                                                    //           : _dutiesString.contains("PRODUCT")
                                                    //           ?screenBackgroundColor
                                                    //           :Colors.red,
                                                    //     )
                                                    //     ),
                                                    //     onTap: (){
                                                    //       // admin.contains(currentUser.uid)
                                                    //       //     ?dialogEditItem(context, product)
                                                    //       //     : _dutiesString.contains("PRODUCT")
                                                    //       //     ?dialogEditItem(context, product)
                                                    //       //     :dialogRequest(context, "Edit");
                                                    //     }
                                                    // ),
                                                  ]);
                                                }).toList(),
                                              ),
                                            )
                                          : _layout == 1
                                              ? SizedBox(
                                                  width: 450,
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics: NeverScrollableScrollPhysics(),
                                                      itemCount: filteredList.length,
                                                      itemBuilder:(context, index) {
                                                        ProductModel product = filteredList[index];
                                                        _fltSpplr = _spplr.where((sup) => sup.sid == product.supplier).toList();
                                                        EntityModel entity = _entity.firstWhere((test) => test.eid==product.eid, orElse: ()=>EntityModel(eid: "", admin: ""));
                                                        List<String> admin = entity.admin.toString().split(",");
                                                        return Column(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  if (selectedID != product.prid) {
                                                                    selectedID = product.prid;
                                                                  } else {
                                                                    selectedID = "";
                                                                  }
                                                                });
                                                              },
                                                              child: Container(
                                                                margin: EdgeInsets.symmetric(vertical: 5),
                                                                child: Row(
                                                                  children: [
                                                                    CircleAvatar(
                                                                      radius: 20,
                                                                      backgroundColor: Colors.black12,
                                                                      child:
                                                                          Center(
                                                                        child: product.checked == "false"
                                                                            ? Icon(
                                                                                Icons.cloud_upload,
                                                                                color: Colors.red,
                                                                              )
                                                                            : product.checked.toString().contains("DELETE") || product.checked.toString().contains("REMOVED")
                                                                                ? Icon(
                                                                                    CupertinoIcons.delete,
                                                                                    color: Colors.red,
                                                                                  )
                                                                                : product.checked.toString().contains("EDIT")
                                                                                    ? Icon(Icons.edit_rounded, color: Colors.red)
                                                                                    : LineIcon.box(
                                                                                        color: Colors.black,
                                                                                      ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                product.name.toString(),
                                                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Text(
                                                                                '${product.category}',
                                                                                style: TextStyle(color: Colors.black54, fontSize: 11),
                                                                              ),
                                                                              Expanded(child: SizedBox()),
                                                                              Text(
                                                                                'ML : ${product.volume}',
                                                                                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 11),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                _fltSpplr.length == 0 ? 'Supplier not available' : 'Supplier : ${_fltSpplr.first.name}',
                                                                                style: TextStyle(fontSize: 11, color: Colors.black),
                                                                              ),
                                                                              Expanded(child: SizedBox()),
                                                                              Text(
                                                                                "BP: Ksh.${formatNumberWithCommas(double.parse(product.buying.toString()))} SP: Ksh.${formatNumberWithCommas(double.parse(product.selling.toString()))}",
                                                                                style: TextStyle(fontSize: 11, color: Colors.black),
                                                                              )
                                                                            ],
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            index == filteredList.length - 1 && selectedID != product.prid && filteredList.length != 0
                                                                ? SizedBox()
                                                                : Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            5),
                                                                    child:
                                                                        Divider(
                                                                      color: Colors
                                                                          .black12,
                                                                      thickness:
                                                                          1,
                                                                      height: 1,
                                                                    ),
                                                                  ),
                                                            AnimatedSize(
                                                              duration: Duration(milliseconds: 500),
                                                              alignment: Alignment.topCenter,
                                                              curve: Curves.easeInOut,
                                                              child: selectedID == product.prid
                                                                  ? IntrinsicHeight(
                                                                child: Row(
                                                                  children: [
                                                                    product.checked == "false" || product.checked == "false, EDIT" || product.checked.toString().contains("REMOVED") ? BottomCallButtons(
                                                                        onTap: (){
                                                                          admin.contains(currentUser.uid)
                                                                              ? _upload(product)
                                                                              : !_dutiesString.contains("PRODUCT")
                                                                              ? dialogRequest(context, "Upload", entity)
                                                                              : _upload(product);
                                                                        },
                                                                        icon: Icon(Icons.cloud_upload,
                                                                          color: Colors.black,
                                                                        ),
                                                                        actionColor: Colors.black,
                                                                        backColor: Colors.red.withOpacity(0.9),
                                                                        title: "Upload"
                                                                    ) : SizedBox(),
                                                                    product.checked == "false" || product.checked == "false, EDIT"|| product.checked.toString().contains("REMOVED") ?VerticalDivider(
                                                                      thickness: 0.5,
                                                                      width: 15,color: Colors.black12,
                                                                    ) : SizedBox(),
                                                                    BottomCallButtons(
                                                                        onTap: (){
                                                                          admin.contains(currentUser.uid)
                                                                              ? dialogDelete(context, product)
                                                                              : !_dutiesString.contains("PRODUCT")
                                                                              ? dialogRequest(context, "Remove", entity)
                                                                              : dialogDelete(context, product);
                                                                        },
                                                                        icon: Icon(CupertinoIcons.delete,
                                                                          color: admin.contains(currentUser.uid)
                                                                              ? Colors.black
                                                                              : _dutiesString.contains("PRODUCT")
                                                                              ?Colors.black
                                                                              :Colors.red,
                                                                        ),
                                                                        actionColor: admin.contains(currentUser.uid)
                                                                            ? Colors.black
                                                                            : _dutiesString.contains("PRODUCT")
                                                                            ?Colors.black
                                                                            :Colors.red,
                                                                        title: "Delete"
                                                                    ),
                                                                    VerticalDivider(
                                                                      thickness: 0.5,
                                                                      width: 15,color: Colors.black12,
                                                                    ),
                                                                    BottomCallButtons(
                                                                        onTap: (){
                                                                          admin.contains(currentUser.uid)
                                                                              ? product.checked.toString().contains("DELETE")
                                                                              ? _restore(product)
                                                                              : dialogEdit(context, product)

                                                                              : product.checked.toString().contains("DELETE")
                                                                              ? !_dutiesString.contains("PURCHASE")? dialogRequest(context, "Edit", entity) :  _restore(product)
                                                                              : !_dutiesString.contains("PURCHASE")? dialogRequest(context, "Edit", entity) : dialogEdit(context, product);
                                                                        },
                                                                        icon: Icon(
                                                                          product.checked.toString().contains("DELETE")?Icons.restore:Icons.edit,
                                                                          color: admin.contains(currentUser.uid)
                                                                              ? Colors.black
                                                                              : _dutiesString.contains("PRODUCT")
                                                                              ?Colors.black
                                                                              :Colors.red,),
                                                                        actionColor: admin.contains(currentUser.uid)
                                                                            ? Colors.black
                                                                            : _dutiesString.contains("PRODUCT")
                                                                            ?Colors.black
                                                                            :Colors.red,
                                                                        title: product.checked.toString().contains("DELETE")
                                                                            ? 'Restore'
                                                                            : "Edit"
                                                                    ),
                                                                    VerticalDivider(
                                                                      thickness: 0.5,
                                                                      width: 15,color: Colors.black12,
                                                                    ),
                                                                    BottomCallButtons(
                                                                        onTap: (){
                                                                          dialogQRCode(context, product);
                                                                        },
                                                                        icon: Icon(
                                                                          CupertinoIcons.qrcode,
                                                                          color: Colors.black,),
                                                                        actionColor: Colors.black,
                                                                        title: "QRCode"
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                                  : SizedBox(),
                                                            )
                                                          ],
                                                        );
                                                      }),
                                                )
                                              : GridView.builder(
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      filteredList.length,
                                                  gridDelegate:
                                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                                          maxCrossAxisExtent:
                                                              300,
                                                          childAspectRatio:
                                                              2 / 2.2,
                                                          crossAxisSpacing: 1,
                                                          mainAxisSpacing: 1),
                                                  itemBuilder:
                                                      (context, index) {
                                                    ProductModel product =
                                                        filteredList[index];
                                                    return DottedBorder(
                                                      color: secondaryColor,
                                                      borderType:
                                                          BorderType.RRect,
                                                      dashPattern: [5, 5, 5, 5],
                                                      radius:
                                                          Radius.circular(5),
                                                      child: Column(
                                                        children: [
                                                          Expanded(
                                                            child: Center(
                                                              child:
                                                                  QrImageView(
                                                                data: product
                                                                    .prid
                                                                    .toString(),
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                gapless: true,
                                                                embeddedImage:
                                                                    AssetImage(
                                                                        "assets/logos/android/res/mipmap-mdpi/ic_launcher.png"),
                                                                embeddedImageStyle:
                                                                    QrEmbeddedImageStyle(
                                                                  size: Size
                                                                      .square(
                                                                          25),
                                                                ),
                                                                version:
                                                                    QrVersions
                                                                        .auto,
                                                                errorStateBuilder:
                                                                    (cxt, err) {
                                                                  return Container(
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'Uh oh! Something went wrong...',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0,
                                                                    vertical:
                                                                        0),
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  product.name
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          18),
                                                                ),
                                                                // Row(
                                                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                //   children: [
                                                                //     Expanded(child: Text('Buying Price : Ksh.${formatNumberWithCommas(double.parse(product.selling!))}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),)),
                                                                //     Text('${product.volume}', style: TextStyle(color: Colors.black, ),),
                                                                //   ],
                                                                // ),
                                                                // Row(
                                                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                //   children: [
                                                                //     Expanded(child: Text('Selling Price : Ksh.${formatNumberWithCommas(double.parse(product.selling!))}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),)),
                                                                //     Text('${product.category}', style: TextStyle(color: Colors.black, ),),
                                                                //   ],
                                                                // ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  })
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void dialogQRCode(BuildContext context, ProductModel product) {
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    showDialog(
        context: context,
        builder: (context) => Dialog(
              alignment: Alignment.center,
              backgroundColor: dilogbg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: SizedBox(
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DialogTitle(title: 'Q R C O D E'),
                      Text(
                        'Scan the QR Code below to quickly record sale for product : ${product.name}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryColor, fontSize: 12),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 300,
                        width: 300,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: QrImageView(
                                  data: product.prid.toString(),
                                  backgroundColor: Colors.white,
                                  gapless: true,
                                  embeddedImage: AssetImage(
                                      "assets/logos/android/res/mipmap-mdpi/ic_launcher.png"),
                                  embeddedImageStyle: QrEmbeddedImageStyle(
                                    size: Size.square(40),
                                  ),
                                  version: QrVersions.auto,
                                  errorStateBuilder: (cxt, err) {
                                    return Container(
                                      child: Center(
                                        child: Text(
                                          'Uh oh! Something went wrong...',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            QRScannerOverlay(
                              borderColor: normal,
                              overlayColor: Colors.transparent,
                              borderRadius: 10,
                              borderStrokeWidth: 2,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SingleCallAction(),
                    ],
                  ),
                ),
              ),
            ));
  }

  void _updateProduct(ProductModel product) async {
    _prd.firstWhere((element) => element.prid == product.prid).checked = "true";
    await Data().addOrUpdateProductsList(_prd);
    setState(() {});
  }

  void dialogRequest(BuildContext, String action, EntityModel entity){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    showDialog(context: context, builder: (context){
      return Dialog(
        backgroundColor: dilogbg,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'R E Q U E S T'),
                DialogRequest(action: action, account: 'PRODUCT', entity: entity,),
              ],
            ),
          ),
        ),
      );
    });
  }

  void dialogDelete(BuildContext context, ProductModel product) {
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(
        context: context,
        builder: (context) => Dialog(
              alignment: Alignment.center,
              backgroundColor: dilogbg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: SizedBox(
                width: 450,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DialogTitle(title: 'D E L E T E'),
                      Text(
                        'Are you sure you want to proceed with this action? Please note that once this product is removed, all records associated with it will be permanently deleted.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryColor, fontSize: 12),
                      ),
                      DoubleCallAction(
                        action: () {
                          Navigator.pop(context);
                          _delete(product);
                        },
                        title: "Delete",
                        titleColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  void dialogEdit(BuildContext context, ProductModel product) {
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(
        context: context,
        builder: (context) => Dialog(
              alignment: Alignment.center,
              backgroundColor: dilogbg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: SizedBox(
                width: 450,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DialogTitle(title: 'E D I T'),
                      Text(
                        'Enter new details in the fields below to make the necessary changes',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryColor, fontSize: 12),
                      ),
                      SizedBox(height: 10),
                      DialogEditProduct(
                        product: product,
                        getData: _getData,
                      ),
                    ],
                  ),
                ),
              ),
            ));
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
                DialogFilterGoods(entity: EntityModel(eid: ""), filter: _filter,)
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
  _getDetails() async {
    _getData();
    await Data().checkProducts(_prd, () {});
    _newPrd = await Services().getMyPrdct(currentUser.uid);
    _newSpplr = await Services().getMySuppliers(currentUser.uid);
    await Data().addOrUpdateProductsList(_newPrd);
    await Data().addOrUpdateSuppliersList(_newSpplr).then((value){
      setState(() {
        _loading = value;
      });
    });
    _getData();
  }

  _getData() {
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _prd = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _allprd = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    _spplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _prd = _prd.where((element) {
      bool matchesCategory = category.isEmpty || element.category == category;
      bool matchesVolume = volume.isEmpty || element.volume == volume;
      bool matchesSupplier = supplierId.isEmpty || element.supplier == supplierId;

      return matchesCategory && matchesVolume && matchesSupplier;
    }).toList();
    _dutiesString = _duties.isEmpty ? "" : _duties.first.duties.toString();
    countPrd = _prd.length;
    countSppl = _spplr.length;
    // _prd.where((element) => element.checked != "true").forEach((prd)async {
    //   await Data().checkAndUploadProduct(prd, _updateProduct);
    // });
    removed = _prd.where((element) => element.checked == "REMOVED").length;
    close = removed > 0 ? false : true;
    setState(() {});
  }

  _delete(ProductModel product) async {
    setState(() {
      _loading = true;
    });
    await Data().removeProduct(product, _getData, context).then((value) {
      setState(() {
        _loading = value;
      });
    });
  }

  _restore(ProductModel product) async {
    List<String> uniqueProduct = [];
    List<ProductModel> _prduct = [];
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _prduct = myProducts
        .map((jsonString) => ProductModel.fromJson(json.decode(jsonString)))
        .toList();
    _prduct.firstWhere((element) => element.prid == product.prid).checked =
        product.checked.toString().replaceAll(", DELETE", "");
    uniqueProduct = _prduct.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("myproducts", uniqueProduct);
    myProducts = uniqueProduct;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Product ${product.name} restored Successfully"),
      showCloseIcon: true,
    ));
    _getData();
  }

  _removeAll() async {
    List<String> uniqueProducts = [];
    List<ProductModel> _products = [];
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _products = myProducts
        .map((jsonString) => ProductModel.fromJson(json.decode(jsonString)))
        .toList();

    _products.removeWhere((element) => element.checked == "REMOVED");
    _prd.removeWhere((element) => element.checked == "REMOVED");

    uniqueProducts =
        _products.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myproducts', uniqueProducts);
    myProducts = uniqueProducts;
    _getData();
    close = removed > 0 ? false : true;
    setState(() {});
  }

  _upload(ProductModel product) async {
    setState(() {
      _loading = true;
    });
    Services.addProduct(product).then((response) {
      if (response == "Success") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Product ${product.name} was uploaded Successfully"),
          showCloseIcon: true,
        ));
      } else if (response == "Failed") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Product ${product.name} was not uploaded. Please try again"),
          showCloseIcon: true,
          action:
              SnackBarAction(label: "Try Again", onPressed: _upload(product)),
        ));
      } else if (response == 'Exists') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Product ${product.name} already Exists"),
          showCloseIcon: true,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "mhmm 🤔 seems like something went wrong. Please try again later"),
          showCloseIcon: true,
        ));
      }
      _getDetails();
      setState(() {
        _loading = false;
      });
    });
  }

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  void onSort(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      _prd.sort((prd1, prd2) =>
          compareString(ascending, prd1.name.toString(), prd2.name.toString()));
    } else if (columnIndex == 1) {
      _prd.sort((prd1, prd2) => compareString(
          ascending, prd1.category.toString(), prd2.category.toString()));
    } else if (columnIndex == 3) {
      _prd.sort((prd1, prd2) => compareString(
          ascending, prd1.supplier.toString(), prd2.supplier.toString()));
    }
    setState(() {
      this.sortColumnIndex = columnIndex;
      this.isAscending = ascending;
    });
  }

  int compareString(bool ascending, String value1, String value2) {
    return ascending ? value1.compareTo(value2) : value2.compareTo(value1);
  }
}
