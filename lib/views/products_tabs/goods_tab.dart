import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/Widget/dialogs/call_actions/single_call_action.dart';
import 'package:TallyApp/Widget/empty_data.dart';
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
import '../../Widget/dialogs/dialog_add_product.dart';
import '../../Widget/dialogs/dialog_edit_product.dart';
import '../../Widget/dialogs/dialog_request.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/dialogs/filters/dialog_filter_goods.dart';
import '../../Widget/text/text_format.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/duties.dart';
import '../../models/entities.dart';
import '../../models/products.dart';
import '../../models/suppliers.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';


class GoodsTab extends StatefulWidget {
  final EntityModel entity;
  const GoodsTab({super.key, required this.entity});

  @override
  State<GoodsTab> createState() => _GoodsTabState();
}

class _GoodsTabState extends State<GoodsTab> {
  TextEditingController _search = TextEditingController();
  List<String> title = ['Total Products', 'Suppliers'];
  List<String> items = ['Store One', 'Store Two', 'Store Three', 'Store Four' , 'Store Five'];

  final ScrollController _horizontal = ScrollController();

  List<ProductModel> _products = [];
  List<ProductModel> _prd = [];
  List<ProductModel> _newPrd = [];
  List<SupplierModel> _spplr = [];
  List<SupplierModel> _newSpplr = [];
  List<SupplierModel> _fltSpplr = [];

  bool _loading = false;

  int? sortColumnIndex;
  bool isAscending = false;

  List<DutiesModel> _duties = [];
  String _dutiesString = "";
  String selectedID = "";
  late DutiesModel dutiesModel;
  int _layout = 0;
  int removed = 0;

  bool close = true;
  bool isFilled = false;

  List<String> admin = [];

  String category = "";
  String volume = "";
  String supplierId ="";

  int countPrd = 0;
  int countSppl = 0;

  _getDetails()async{
    _getData();
    await Data().checkProducts(_prd, (){});
    _newPrd = await Services().getMyPrdct(currentUser.uid);
    _newSpplr = await Services().getMySuppliers(currentUser.uid);
    await Data().addOrUpdateProductsList(_newPrd);
    await Data().addOrUpdateSuppliersList(_newSpplr).then((response){
      setState(() {
        _loading = response;
      });
    });
    _getData();
  }

  _getData()async{
    admin = widget.entity.admin.toString().split(",");
    _products = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _prd = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    _spplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _dutiesString = _duties.isEmpty? "": _duties.firstWhere((test) => test.eid == widget.entity.eid && test.pid == currentUser.uid, orElse: ()=>DutiesModel(did: "", duties: "")).duties.toString();

    _prd = _prd.where((element) {
      bool matchesEid = element.eid == widget.entity.eid;
      bool matchesCategory = category.isEmpty || element.category == category;
      bool matchesVolume = volume.isEmpty || element.volume == volume;
      bool matchesSupplier = supplierId.isEmpty || element.supplier == supplierId;

      return matchesEid && matchesCategory && matchesVolume && matchesSupplier;
    }).toList();

    _spplr = _spplr.where((element) => element.eid == widget.entity.eid).toList();
    countPrd = _prd.length;
    countSppl = _spplr.length;

    removed = _prd.where((element) => element.checked == "REMOVED").length;
    close = removed > 0? false: true;
    setState(() {
    });
  }
  _reload()async{
    _prd = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    _spplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _dutiesString = _duties.isEmpty? "": _duties.first.duties.toString();
    _prd = _prd.where((element) => element.eid == widget.entity.eid).toList();
    _spplr = _spplr.where((element) => element.eid == widget.entity.eid).toList();
    countPrd = _prd.length;
    countSppl = _spplr.length;
    admin = widget.entity.admin.toString().split(",");
    removed = _prd.where((element) => element.checked == "REMOVED").length;
    close = removed > 0? false: true;
    setState(() {
    });
  }
  _upload(ProductModel product)async{
    setState(() {
      _loading = true;
    });
    String name = TFormat().decryptField(product.name.toString(), product.eid.toString());
    Services.addProduct(product).then((response){
      if (response == "Success")
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Product ${name} was uploaded Successfully"),
            showCloseIcon: true,
          )
        );
      } else if (response == "Failed")
      {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Product ${name} was not uploaded. Please try again"),
              showCloseIcon: true,
              action: SnackBarAction(label: "Try Again", onPressed: _upload(product)),
            )
        );
      } else if(response == 'Exists')
      {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Product ${name} already Exists"),
              showCloseIcon: true,
            )
        );
      } else
      {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("mhmm 🤔 seems like something went wrong. Please try again later"),
              showCloseIcon: true,
            )
        );
      }
      _getDetails();
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
    if(Platform.isAndroid || Platform.isIOS){
      _layout = 1;
    } else {
      _layout = 0;
    }

  }

  @override
  Widget build(BuildContext context) {
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      _prd.forEach((item) {
        if (TFormat().decryptField(item.name.toString(), widget.entity.eid).toLowerCase().contains(_search.text.toString().toLowerCase())
            || TFormat().decryptField(item.category.toString(), widget.entity.eid).toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _prd;
    }
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

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
                          SizedBox(height: 10,),
                          Text(index==0
                              ?countPrd.toString()
                              : index==1
                              ?countSppl.toString()
                              :"0", style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),)
                        ],
                      ),
                    );
                  }),
              Row(
                children: [
                  _loading
                      ? Container(
                      width: 20, height: 20,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: CircularProgressIndicator(color: screenBackgroundColor,strokeWidth: 2,))
                      : SizedBox(),
                  Expanded(child: SizedBox()),
                  CardButton(
                    text:'Add',
                    backcolor: Colors.white,
                    icon: Icon(Icons.add,
                      size: 19,
                      color:  admin.contains(currentUser.uid)
                          ? screenBackgroundColor
                          : _dutiesString.contains("PRODUCT")
                          ?screenBackgroundColor
                          :Colors.red,
                    ),
                    forecolor:  admin.contains(currentUser.uid)
                        ? screenBackgroundColor
                        : _dutiesString.contains("PRODUCT")
                        ?screenBackgroundColor
                        :Colors.red,
                    onTap: () {
                      admin.contains(currentUser.uid)
                          ? dialogAdd(context)
                          : _dutiesString.contains("PRODUCT")
                          ?dialogAdd(context)
                          :dialogRequest(context, "Add");
                    },),
                  _products.isEmpty
                      ? SizedBox()
                      : CardButton(
                    text: _layout==0?'List':_layout==2?'Table':"QRCs",
                    backcolor: Colors.white,
                    icon: Icon(_layout==0?CupertinoIcons.list_dash:_layout==2?CupertinoIcons.table:CupertinoIcons.qrcode, color: screenBackgroundColor,size: 16,),
                    forecolor: screenBackgroundColor,
                    onTap: () {
                      setState(() {
                        if(_layout<2){
                          _layout++;
                        } else{
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
                    text: _prd.any((element) => element.checked == "false" || element.checked.toString().contains("EDIT") || element.checked.toString().contains("DELETE") )
                        ? "Upload"
                        : 'Reload',
                    backcolor: _prd.any((element) => element.checked == "false" || element.checked.toString().contains("EDIT") || element.checked.toString().contains("DELETE") )
                        ?Colors.red
                        :screenBackgroundColor,
                    icon: Icon(
                      _prd.any((element) => element.checked == "false" || element.checked.toString().contains("EDIT") || element.checked.toString().contains("DELETE") )
                          ?Icons.cloud_upload_rounded
                          :CupertinoIcons.refresh,
                      size: 16,
                      color:Colors.white,
                    ),
                    forecolor: Colors.white,
                    onTap: ()async {
                      setState(() {
                        _loading = true;
                        category = "";
                        volume = "";
                        supplierId = "";
                        close = true;
                      });
                    await Data().checkProducts(_prd, _reload).then((value){

                    });
                    _getDetails();
                  },
                  ),
                ],
              ),
              close == false
                  ? ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 400,
                  maxWidth: 600,
                ),
                child: Card(
                  color: Colors.white,
                  elevation: 8,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.delete, size: 30, color: Colors.red,),
                        SizedBox(width: 15,),
                        Expanded(
                          child: RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 13),
                                  children: [
                                    TextSpan(
                                        text: "Attention: ",
                                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)
                                    ),
                                    TextSpan(
                                        text: "${removed.toString()} ",
                                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)
                                    ),
                                    TextSpan(
                                        text: removed > 1? "products have " : "product has ",
                                        style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                    ),
                                    TextSpan(
                                        text: "been removed from our server by one of the managers. This change may impact your data. Would you like to update your list to reflect these changes? ",
                                        style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                    ),
                                    WidgetSpan(
                                        child: InkWell(
                                            onTap: (){_removeAll();},
                                            child: Text("Remove All", style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.bold),)
                                        )
                                    )
                                  ]
                              )
                          ),
                        ),
                        InkWell(
                            onTap: (){
                              setState(() {
                                close = true;
                              });
                            },
                            child: Icon(Icons.close, size: 30,color: Colors.black,)
                        )
                      ],
                    ),
                  ),
                ),
              )
                  :SizedBox(),
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
                      child: Text('Goods Table', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500 , color: Colors.black),),
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
                  ? EmptyData(
                        onTap: (){
                          admin.contains(currentUser.uid)
                              ? dialogAdd(context)
                              : _dutiesString.contains("PRODUCT")
                              ?dialogAdd(context)
                              :dialogRequest(context, "Add");
                        },
                        highlightColor: admin.contains(currentUser.uid)
                            ? Colors.white
                            : _dutiesString.contains("PRODUCT")
                            ?Colors.white
                            :Colors.red,
                        title: "goods"
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
                        Row(
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
                            Expanded(child: SizedBox()),

                            _layout==2
                                ?  CardButton(
                                  text:'Save',
                                  backcolor: Colors.white,
                                  icon: Icon(Icons.download, size: 19, color: screenBackgroundColor,), forecolor: screenBackgroundColor,
                                  onTap: () {

                                  },
                                )
                                : SizedBox()
                          ],
                        ),
                        SizedBox(height: 20),
                        _layout == 0
                            ? Scrollbar(
                          thumbVisibility: true,
                          controller: _horizontal,
                          child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                            controller: _horizontal,
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
                                  label: Text(
                                    "QR Code", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                ),
                                DataColumn(
                                    label: Text(
                                      "Action", style: TextStyle(color: Colors.white),),
                                    numeric: false,
                                    tooltip: 'Action to remove product from list'
                                ),
                              ],
                              rows: filteredList.map((product){
                                _fltSpplr = _spplr.where((sup) => sup.sid == product.supplier).toList();
                                double buy = double.parse(TFormat().decryptField(product.buying.toString(), widget.entity.eid.toString()));
                                double sell = double.parse(TFormat().decryptField(product.selling.toString(), widget.entity.eid.toString()));
                                String supplier = _fltSpplr.length == 0 ? 'N/A' : TFormat().decryptField(_fltSpplr.first.name.toString(), widget.entity.eid.toString());
                                String name = TFormat().decryptField(product.name.toString(), widget.entity.eid.toString());
                                String category = TFormat().decryptField(product.category.toString(), widget.entity.eid.toString());
                                String vol = TFormat().decryptField(product.volume.toString(), widget.entity.eid.toString());
                                return DataRow(
                                    cells: [
                                      DataCell(
                                          Text(name,style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text(category,style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text(vol,style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text(supplier,style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text('Ksh.${formatNumberWithCommas(buy)}',style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text('Ksh.${formatNumberWithCommas(sell)}',style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Center(child: Icon(Icons.qr_code, color: screenBackgroundColor,)),
                                          onTap: (){
                                            dialogQRCode(context, product);
                                          }
                                      ),
                                      DataCell(
                                        Center(
                                            child:  PopupMenuButton<String>(
                                              tooltip: 'Show options',
                                              child: Icon(
                                                product.checked == "false"
                                                    ?Icons.cloud_upload
                                                    :product.checked.contains("DELETE")|| product.checked.contains("REMOVED")
                                                    ?CupertinoIcons.delete
                                                    :product.checked.contains("EDIT")
                                                    ?Icons.edit_rounded
                                                    :Icons.more_vert,
                                                color
                                                    : product.checked == "false" || product.checked.contains("DELETE") || product.checked.contains("EDIT") || product.checked.contains("REMOVED")
                                                    ? Colors.red
                                                    :screenBackgroundColor,
                                              ),
                                              itemBuilder: (BuildContext context) {
                                                return [
                                                  if (product.checked == "false" || product.checked == "false, EDIT" || product.checked.contains("REMOVED"))
                                                    PopupMenuItem(
                                                      value: 'upload',
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.cloud_upload, color: Colors.red,),
                                                          SizedBox(width: 5,),
                                                          Text('Upload',style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                          ),
                                                        ],
                                                      ),
                                                      onTap: (){
                                                        admin.contains(currentUser.uid)
                                                            ? _upload(product)
                                                            : !_dutiesString.contains("PRODUCT")
                                                            ? dialogRequest(context, "Upload")
                                                            : _upload(product);
                                                      },
                                                    ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(CupertinoIcons.delete,
                                                          color: admin.contains(currentUser.uid)
                                                            ? reverse
                                                            : _dutiesString.contains("PRODUCT")
                                                            ?reverse
                                                            :Colors.red,),
                                                        SizedBox(width: 5,),
                                                        Text('Delete',style: TextStyle(
                                                          color: admin.contains(currentUser.uid)
                                                              ? reverse
                                                              : _dutiesString.contains("PRODUCT")
                                                              ?reverse
                                                              :Colors.red,
                                                        ),),
                                                      ],
                                                    ),
                                                    onTap: (){
                                                      admin.contains(currentUser.uid)
                                                          ? dialogDelete(context, product)
                                                          : !_dutiesString.contains("PRODUCT")
                                                          ? dialogRequest(context, "Remove")
                                                          : dialogDelete(context, product);
                                                    },
                                                  ),
                                                  PopupMenuItem(
                                                    value: product.checked.toString().contains("DELETE")? 'Restore' : 'Edit',
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          product.checked.toString().contains("DELETE")
                                                              ?Icons.restore
                                                              :Icons.edit,
                                                          color: admin.contains(currentUser.uid)
                                                            ? reverse
                                                            : _dutiesString.contains("PRODUCT")
                                                            ?reverse
                                                            :Colors.red,
                                                        ),
                                                        SizedBox(width: 5,),
                                                        Text(product.checked.toString().contains("DELETE")? 'Restore' :'Edit', style: TextStyle(
                                                          color: admin.contains(currentUser.uid)
                                                              ? reverse
                                                              : _dutiesString.contains("PRODUCT")
                                                              ?reverse
                                                              :Colors.red,),
                                                        ),
                                                      ],
                                                    ),
                                                    onTap: (){
                                                      admin.contains(currentUser.uid)
                                                          ? product.checked.toString().contains("DELETE")
                                                          ? _restore(product)
                                                          : dialogEdit(context, product)

                                                          : product.checked.toString().contains("DELETE")
                                                          ? !_dutiesString.contains("PRODUCT")? dialogRequest(context, "Edit") :  _restore(product)
                                                          : !_dutiesString.contains("PRODUCT")? dialogRequest(context, "Edit") : dialogEdit(context, product);
                                                    },
                                                  ),
                                                ];
                                              },
                                            )
                                        ),
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
                                    ]
                                );
                              }
                              ).toList(),
                            ),
                          ),
                            )
                            : _layout == 1
                            ?SizedBox(
                          width: 450,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index){
                                ProductModel product = filteredList[index];
                                _fltSpplr = _spplr.where((sup) => sup.sid == product.supplier).toList();
                                double buy = double.parse(TFormat().decryptField(product.buying.toString(), widget.entity.eid.toString()));
                                double sell = double.parse(TFormat().decryptField(product.selling.toString(), widget.entity.eid.toString()));
                                String supplier = _fltSpplr.length == 0 ? 'Supplier not available' : TFormat().decryptField(_fltSpplr.first.name.toString(), widget.entity.eid.toString());
                                String name = TFormat().decryptField(product.name.toString(), widget.entity.eid.toString());
                                String category = TFormat().decryptField(product.category.toString(), widget.entity.eid.toString());
                                String vol = TFormat().decryptField(product.volume.toString(), widget.entity.eid.toString());
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        setState(() {
                                          if(selectedID!=product.prid){
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
                                                      Text(name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                                                      SizedBox(width: 10,),
                                                      Text(category, style: TextStyle(color: Colors.black54, fontSize: 11),),
                                                      Expanded(child: SizedBox()),
                                                      Text('ML : ${vol}', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 11),),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text('Supplier : ${supplier}', style: TextStyle(fontSize: 11, color: Colors.black),),
                                                      Expanded(child: SizedBox()),
                                                      Text(
                                                        "BP: Ksh.${formatNumberWithCommas(buy)} SP: Ksh.${formatNumberWithCommas(sell)}",
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
                                        ?SizedBox()
                                        :Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Divider(
                                        color: Colors.black12,
                                        thickness: 1,height: 1,
                                      ),
                                    ),
                                    AnimatedSize(
                                      duration: Duration(milliseconds: 800),
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
                                                      ? dialogRequest(context, "Upload")
                                                      : _upload(product);
                                                  },
                                                icon: Icon(
                                                  Icons.cloud_upload,
                                                  color: admin.contains(currentUser.uid)
                                                      ? screenBackgroundColor
                                                      : _dutiesString.contains("PRODUCT")
                                                      ?screenBackgroundColor
                                                      :Colors.red,
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
                                                      ? dialogRequest(context, "Remove")
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
                                                      ? !_dutiesString.contains("PRODUCT")? dialogRequest(context, "Edit") :  _restore(product)
                                                      : !_dutiesString.contains("PRODUCT")? dialogRequest(context, "Edit") : dialogEdit(context, product);
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
                            :GridView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredList.length,
                            gridDelegate:  SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 300,
                                childAspectRatio: 2 / 2.2,
                                crossAxisSpacing: 1,
                                mainAxisSpacing: 1
                            ),
                            itemBuilder: (context, index){
                              ProductModel product = filteredList[index];
                              String name = TFormat().decryptField(product.name.toString(), widget.entity.eid.toString());
                              return DottedBorder(
                                color: secondaryColor,
                                borderType: BorderType.RRect,
                                dashPattern: [5, 5, 5, 5],
                                radius: Radius.circular(5),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: QrImageView(
                                          data: product.prid.toString(),
                                          backgroundColor: Colors.white,
                                          gapless: true,
                                          embeddedImage: AssetImage("assets/logos/android/res/mipmap-mdpi/ic_launcher.png"),
                                          embeddedImageStyle: QrEmbeddedImageStyle(
                                            size: Size.square(25),
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                                      child: Column(
                                        children: [
                                          Text(name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),),
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
                            }
                        ),
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
  void dialogAdd(BuildContext context) {
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          backgroundColor: dilogbg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: SizedBox(width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'A D D  N E W  I N V E N T O R Y'),
                Text('Enter details based on your items inorder to promote better user experience',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                DialogAddProduct(entity: widget.entity, addProduct: _addProduct,)
              ],
            ),
          ),
        )
    );
  }
  void _updateProduct(ProductModel product)async{
    print("Update Product ");
    _prd.firstWhere((element) => element.prid == product.prid).checked = "true";
    await Data().addOrUpdateProductsList(_prd);
    setState(() {
    });
  }
  void _addProduct(ProductModel product)async{
    List<String> uniqueProduct = [];
    List<ProductModel> _product = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String name = TFormat().decryptField(product.name.toString(), widget.entity.eid.toString());
    _product = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();

    _product.add(product);
    _prd.add(product);

    uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("myproducts", uniqueProduct);
    myProducts = uniqueProduct;
    countPrd = _prd.length;
    _getData();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Product ${name} was added to Products list"),
          showCloseIcon: true,
        )
    );

    await Services.addProduct(product).then((response){
      print(response);
      if(response == "Success"){
        product.checked = "true";
        _prd.firstWhere((element) => element.prid == product.prid).checked = "true";
        _product.firstWhere((element) => element.prid == product.prid).checked = "true";
        uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList("myproducts", uniqueProduct);
        myProducts = uniqueProduct;
        setState(() {

        });
      }
    });

    setState(() {

    });
  }
  void dialogQRCode(BuildContext context, ProductModel product) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: SizedBox(width: 400,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTitle(title: 'Q R C O D E'),
                  RichText(
                    textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Scan the QR Code below to quickly record sale for product ',
                            style: TextStyle(color: secondaryColor, fontSize: 12),
                          ),
                          TextSpan(
                            text: TFormat().decryptField(product.name.toString(), product.eid.toString()),
                            style: TextStyle(color: normal)
                          )
                        ]
                      )
                  ),
                  SizedBox(height: 20,),
                  Container(height: 300, width: 300,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: QrImageView (
                              data: product.prid.toString(),
                              backgroundColor: Colors.white,
                              gapless: true,
                              embeddedImage: AssetImage("assets/logos/android/res/mipmap-mdpi/ic_launcher.png"),
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
                  SizedBox(height: 10,),
                  SingleCallAction(),
                ],
              ),
            ),
          ),
        )
    );
  }
  void dialogRequest(BuildContext, String action){
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
                DialogRequest(action: action, account: 'PRODUCT', entity: widget.entity,),
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogDelete(BuildContext context, ProductModel product){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          backgroundColor: dilogbg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: SizedBox(width: 450,
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
                    action: (){
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
        )
    );
  }
  void dialogEdit(BuildContext context, ProductModel product){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          backgroundColor: dilogbg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: SizedBox(width: 450,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTitle(title: 'E D I T'),
                  Text('Enter new details in the fields below to make the necessary changes',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryColor, fontSize: 12),
                  ),
                  SizedBox(height: 10),
                  DialogEditProduct(product: product, getData: _reload,),
                ],
              ),
            ),
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

  _delete(ProductModel product)async{
    setState(() {
      _loading = true;
    });
    await Data().removeProduct(product, _reload, context).then((value){
      setState(() {
        _loading = value;
      });
    });
  }
  _restore(ProductModel product)async{
    List<String> uniqueProduct = [];
    List<ProductModel> _prduct = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _prduct = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _prduct.firstWhere((element) => element.prid == product.prid).checked = product.checked.toString().replaceAll(", DELETE", "");
    uniqueProduct = _prduct.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("myproducts", uniqueProduct);
    myProducts = uniqueProduct;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Product ${product.name} restored Successfully"),
            showCloseIcon: true,
        )
    );
    _reload();
  }
  _removeAll()async{
    List<String> uniqueProducts = [];
    List<ProductModel> _products = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _products = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();

    _products.removeWhere((element) => element.checked == "REMOVED" && element.eid == widget.entity.eid);
    _prd.removeWhere((element) => element.checked == "REMOVED" && element.eid == widget.entity.eid);

    uniqueProducts  = _products.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myproducts', uniqueProducts );
    myProducts = uniqueProducts;
    _reload();
    close = removed > 0? false: true;
    setState(() {

    });
  }
  void _filter(String? cat, String? vol, String? sid, String entityEid){
    supplierId = sid==null?"":sid;
    category = cat==null?"":TFormat().encryptText(cat, widget.entity.eid);
    volume = vol==null?"":TFormat().encryptText(vol, widget.entity.eid);
    _getData();
  }

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
  void onSort(int columnIndex, bool ascending){
    if(columnIndex == 0){
      _prd.sort((prd1, prd2) =>
          compareString(ascending, prd1.name.toString(), prd2.name.toString())
      );
    } else if (columnIndex == 1){
      _prd.sort((prd1, prd2) =>
          compareString(ascending, prd1.category.toString(), prd2.category.toString())
      );
    }else if (columnIndex == 3){
      _prd.sort((prd1, prd2) =>
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
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
    ),
  );
}
