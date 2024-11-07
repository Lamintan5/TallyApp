import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/dialogs/dialog_edit_inv_quantity.dart';
import 'package:TallyApp/Widget/dialogs/filters/dialog_filter_inv.dart';
import 'package:TallyApp/Widget/empty_data.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/inventories.dart';
import 'package:TallyApp/models/products.dart';
import 'package:TallyApp/models/suppliers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/buttons/bottom_call_buttons.dart';
import '../../Widget/buttons/card_button.dart';
import '../../Widget/dialogs/call_actions/double_call_action.dart';
import '../../Widget/dialogs/dialog_add_inv.dart';
import '../../Widget/dialogs/dialog_request.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/text/text_format.dart';
import '../../models/duties.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';

class InvReportTab extends StatefulWidget {
  final EntityModel entity;
  const InvReportTab({super.key, required this.entity});

  @override
  State<InvReportTab> createState() => _InvReportTabState();
}

class _InvReportTabState extends State<InvReportTab> {
  TextEditingController _search = TextEditingController();
  final ScrollController _horizontal = ScrollController();
  List<InventModel> _inv = [];
  List<InventModel> _newInv = [];
  String _dutiesList = "";
  List<DutiesModel> _duties =[];
  List<SupplierModel> _newSupplier = [];
  List<SupplierModel> _spplr = [];
  List<SupplierModel> _fltSpplr = [];
  List<InventModel> filtInv = [];
  List<ProductModel> _newPrd = [];
  List<ProductModel> _prd = [];
  String selectedID = "";

  List<String> title = ['Total Inventory'];
  List<ProductModel> _filteredPrdcts = [];
  List<String> admin = [];
  bool _layout = true;
  bool _loading = false;
  bool isFilled = false;

  int? sortColumnIndex;
  bool isAscending = false;
  int removed = 0;
  bool close = true;

  String category = "";
  String volume = "";
  String supplierId ="";
  String quantity = "";
  String bprice = "";
  String sprice = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
    if(Platform.isAndroid || Platform.isIOS){
      _layout = false;
    } else {
      _layout = true;
    }
  }


  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      _filteredPrdcts.forEach((item) {
        if (TFormat().decryptField(item.name.toString(), widget.entity.eid).toLowerCase().contains(_search.text.toString().toLowerCase())
            || TFormat().decryptField(item.category.toString(), widget.entity.eid).toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _filteredPrdcts;
    }
    return Expanded(
        child:SingleChildScrollView(
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
                          Text(
                            _filteredPrdcts.length.toString(),
                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600,),
                          )
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
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                      : SizedBox(),
                  Expanded(child: SizedBox()),
                  CardButton(
                    text:'Add',
                    backcolor: Colors.white,
                    icon: Icon(
                      Icons.add,
                      size: 19,
                      color: admin.contains(currentUser.uid)
                          ? screenBackgroundColor
                          : _dutiesList.contains("INVENTORY")
                          ?screenBackgroundColor
                          :Colors.red,
                    ),
                    forecolor:  admin.contains(currentUser.uid)
                        ? screenBackgroundColor
                        : _dutiesList.contains("INVENTORY")
                        ?screenBackgroundColor
                        :Colors.red,
                    onTap: () {
                      admin.contains(currentUser.uid)
                          ? dialogAddInventory(context)
                          : _dutiesList.contains("INVENTORY")
                          ?dialogAddInventory(context)
                          :dialogRequest(context, "Add");
                    },
                  ),
                  _inv.isEmpty
                      ? SizedBox()
                      : CardButton(
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
                    text:_inv.any((element) => element.checked.toString().contains("false") || element.checked.toString().contains("EDIT") || element.checked.toString().contains("DELETE"))
                        ?"Upload"
                        :'Reload',
                    backcolor: _inv.any((element) => element.checked.toString().contains("false") || element.checked.toString().contains("EDIT") || element.checked.toString().contains("DELETE"))
                        ?Colors.red
                        :screenBackgroundColor,
                    icon: Icon(_inv.any((element) => element.checked.toString().contains("false") || element.checked.toString().contains("EDIT") || element.checked.toString().contains("DELETE"))
                        ?Icons.cloud_upload
                        :CupertinoIcons.refresh,
                      size: 16,
                      color: Colors.white,
                    ), forecolor: Colors.white,
                    onTap: () async {
                      supplierId = "";
                      category = "";
                      volume = "";
                      quantity = "";
                      bprice = "";
                      sprice = "";
                      setState(() {
                        _loading = true;
                      });
                      _inv.any((element) => element.checked.toString().contains("false") || element.checked.toString().contains("EDIT") || element.checked.toString().contains("DELETE"))
                          ? _uploadData()
                          :_getDetails();
                    },
                  ),
                ],
              ),
              close == false
                  ?ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: 400,
                        maxWidth: 600
                    ),
                    child: Card(
                      color: Colors.white,
                      elevation: 8,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
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
                                            text: removed > 1? " inventories have " : " inventory has ",
                                            style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                        ),
                                        TextSpan(
                                            text: "been removed from our server by one of the managers. This change may impact your data. Would you like to update your list to reflect these changes? ",
                                            style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                        ),
                                        WidgetSpan(
                                            child: InkWell(
                                                onTap: (){_removeAll();},
                                                child: Text("Update", style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.bold),)
                                            )
                                        )
                                      ]
                                  )
                              ),
                            ),
                            IconButton(
                                onPressed: (){
                                  setState(() {
                                    close = true;
                                  });
                                },
                                icon: Icon(Icons.close, size: 30,color: Colors.black,)
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                  :SizedBox(),
              _inv.isEmpty
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
                      child: Text('Inventory List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500 , color: Colors.black),),
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
              _inv.isEmpty
                  ? EmptyData(
                  onTap: (){
                    admin.contains(currentUser.uid)
                        ? dialogAddInventory(context)
                        : _dutiesList.contains("INVENTORY")
                        ?dialogAddInventory(context)
                        :dialogRequest(context, "Add");
                  },
                  highlightColor: admin.contains(currentUser.uid)
                      ? Colors.white
                      : _dutiesList.contains("INVENTORY")
                      ?Colors.white
                      :Colors.red,
                  title: "inventory"
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
                              sortColumnIndex: sortColumnIndex,
                              sortAscending: isAscending,
                              headingRowColor: WidgetStateColor.resolveWith((states) {
                                return screenBackgroundColor;
                              }),
                              columns:  [
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
                                    tooltip: 'Click here to sort list by Category'
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
                                  label: Text("Quantity", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                ),
                                DataColumn(
                                  label: Text("Status", style: TextStyle(color: Colors.white),),
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
                                  label: Text("Inventory Value", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                ),
                                DataColumn(
                                  label: Text("Sale Value", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                ),
                                DataColumn(
                                  label: Text("Action", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                ),
                              ],
                              rows: filteredList.map((product){
                                filtInv = _inv.where((inv) => inv.productid == product.prid).toList();
                                var qnty = filtInv.length == 0 ? 0 : int.parse(TFormat().decryptField(filtInv.first.quantity.toString(), widget.entity.eid));
                                var invento = _inv.isEmpty? InventModel(iid: "") : _inv.firstWhere((inv) => inv.productid == product.prid);
                                String name = TFormat().decryptField(product.name.toString(), widget.entity.eid.toString());
                                String category = TFormat().decryptField(product.category.toString(), widget.entity.eid.toString());
                                String volume = TFormat().decryptField(product.volume.toString(), widget.entity.eid.toString());
                                double buy = double.parse(TFormat().decryptField(product.buying.toString(), widget.entity.eid.toString()));
                                double sell = double.parse(TFormat().decryptField(product.selling.toString(), widget.entity.eid.toString()));
                                String supplier = _spplr.isEmpty
                                    ? 'N/A'
                                    :  TFormat().decryptField(_spplr.firstWhere((sup) => sup.sid == product.supplier).name.toString(), widget.entity.eid.toString());
                                return DataRow(
                                    cells: [
                                      DataCell(
                                          Text(
                                            name,style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text(
                                            category,
                                            style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text(
                                            volume,
                                            style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text(
                                            supplier,
                                            style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Center(
                                            child: Text(
                                              qnty.toString(),
                                              style: TextStyle(color: Colors.black),),
                                          ),
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
                                                    ? Colors.orange.withOpacity(0.5)
                                                    :qnty < 5 && qnty >0
                                                    ? Colors.purple.withOpacity(0.5)
                                                    :qnty==0
                                                    ? Colors.red.withOpacity(0.5)
                                                    :Colors.green.withOpacity(0.5),
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
                                          ),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text(
                                            'Ksh.${formatNumberWithCommas(buy)}',
                                            style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text(
                                            'Ksh.${formatNumberWithCommas(sell)}',
                                            style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text(
                                            filtInv.length == 0 ? '0' : 'Ksh.${formatNumberWithCommas(qnty * buy)}',
                                            style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text(
                                            filtInv.length == 0 ? '0' : 'Ksh.${formatNumberWithCommas(qnty * sell)}',
                                            style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      // DataCell(
                                      //     Center(child: Icon(Icons.delete_forever,
                                      //       color: admin.contains(currentUser.uid)
                                      //           ? screenBackgroundColor
                                      //           : _dutiesList.contains("INVENTORY")
                                      //           ?screenBackgroundColor
                                      //           :Colors.red,
                                      //     )
                                      //     ),
                                      //     onTap: (){
                                      //
                                      //       // admin.contains(currentUser.uid)
                                      //       //     ? dialogRemoveInventory(context, inventory.prid, inventory.name)
                                      //       //     : _dutiesList.contains("INVENTORY")
                                      //       //     ?dialogRemoveInventory(context, inventory.prid, inventory.name)
                                      //       //     :dialogRequest(context, "Delete");
                                      //     }
                                      // ),
                                      // DataCell(
                                      //     Center(child: Icon(Icons.edit,
                                      //       color:  admin.contains(currentUser.uid)
                                      //           ? screenBackgroundColor
                                      //           : _dutiesList.contains("INVENTORY")
                                      //           ?screenBackgroundColor
                                      //           :Colors.red,
                                      //     )
                                      //     ),
                                      //     onTap: (){
                                      //       // admin.contains(currentUser.uid)
                                      //       //     ? dialogEditItem(context, inventory.name, inventory.prid)
                                      //       //     : _dutiesList.contains("INVENTORY")
                                      //       //     ?dialogEditItem(context, inventory.name, inventory.prid)
                                      //       //     :dialogRequest(context, "Edit");
                                      //
                                      //     }
                                      // ),
                                      DataCell(
                                        Center(
                                            child: PopupMenuButton<String>(
                                              tooltip: 'Show options',
                                              child: Icon(
                                                invento.checked == "false"
                                                  ?Icons.cloud_upload_rounded
                                                  :invento.checked.toString().contains("DELETE") || invento.checked.toString().contains("REMOVED")
                                                  ?CupertinoIcons.delete
                                                  :invento.checked.toString().contains("EDIT")
                                                  ?Icons.edit
                                                  :Icons.more_vert,
                                                color: invento.checked == "false"
                                                    || invento.checked.toString().contains("DELETE")
                                                    || invento.checked.toString().contains("EDIT")
                                                    || invento.checked.toString().contains("REMOVED")
                                                    ?Colors.red
                                                    :screenBackgroundColor,
                                              ),
                                              onSelected: (value) {
                                                print('Selected: $value');
                                              },
                                              itemBuilder: (BuildContext context) {
                                                return [
                                                  if (invento.checked == "false" || invento.checked == "false, EDIT"
                                                      || invento.checked.toString().contains("REMOVED"))
                                                    PopupMenuItem(
                                                      value: 'upload',
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.cloud_upload, color: Colors.red,),
                                                          SizedBox(width: 5,),
                                                          Text(
                                                            'Upload', style: TextStyle(
                                                            color:Colors.red,),
                                                          ),
                                                        ],
                                                      ),
                                                      onTap: (){
                                                        admin.contains(currentUser.uid) || _dutiesList.contains("INVENTORY")
                                                            ? _upload(invento)
                                                            : dialogRequest(BuildContext, "Upload");

                                                      },
                                                    ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(CupertinoIcons.delete, color: admin.contains(currentUser.uid)
                                                            ? reverse
                                                            : _dutiesList.contains("INVENTORY")
                                                            ?reverse
                                                            :Colors.red,),
                                                        SizedBox(width: 5,),
                                                        Text('Delete',style: TextStyle(
                                                          color: admin.contains(currentUser.uid)
                                                              ? reverse
                                                              : _dutiesList.contains("INVENTORY")
                                                              ?reverse
                                                              :Colors.red,
                                                        ),),
                                                      ],
                                                    ),
                                                    onTap: (){
                                                      admin.contains(currentUser.uid) || _dutiesList.contains("INVENTORY")
                                                          ? dialogDelete(context, invento)
                                                          : dialogRequest(BuildContext, "Delete");
                                                    },
                                                  ),
                                                  PopupMenuItem(
                                                    value: invento.checked.toString().contains("DELETE")
                                                        ? 'Restore'
                                                        : 'Edit',
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(invento.checked.toString().contains("DELETE") ?Icons.restore :Icons.edit,
                                                          color:admin.contains(currentUser.uid)? reverse : _dutiesList.contains("INVENTORY") ?reverse :Colors.red,
                                                        ),
                                                        SizedBox(width: 5,),
                                                        Text(invento.checked.toString().contains("DELETE") ?'Restore' :'Edit', style: TextStyle(
                                                          color:admin.contains(currentUser.uid) ? reverse : _dutiesList.contains("INVENTORY") ?reverse :Colors.red,),
                                                        ),
                                                      ],
                                                    ),
                                                    onTap: (){
                                                      admin.contains(currentUser.uid)
                                                          ? invento.checked.toString().contains("DELETE")
                                                          ? _restore(invento)
                                                          : dialogEditQuantity(context, invento)

                                                          : invento.checked.toString().contains("DELETE")
                                                          ? !_dutiesList.contains("PURCHASE")? dialogRequest(context, "Edit") :  _restore(invento)
                                                          : !_dutiesList.contains("PURCHASE")? dialogRequest(context, "Edit") : dialogEditQuantity(context, invento);

                                                    },
                                                  )

                                                ];
                                              },
                                            )
                                        ),
                                      ),
                                    ]
                                );
                              }
                              ).toList(),
                                                        ),
                                                      ),
                            )
                            : SizedBox(
                          width: 450,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index){
                                ProductModel product = filteredList[index];
                                _fltSpplr = _spplr.where((sup) => sup.sid == product.supplier).toList();
                                filtInv = _inv.where((inv) => inv.productid == product.prid).toList();
                                var qnty = filtInv.length == 0 ? 0 : int.parse(TFormat().decryptField(filtInv.first.quantity.toString(), widget.entity.eid));
                                var invento = filtInv.isEmpty || filtInv.length == 0 ? InventModel(iid: "") :filtInv.first;
                                String name = TFormat().decryptField(product.name.toString(), widget.entity.eid.toString());
                                String category = TFormat().decryptField(product.category.toString(), widget.entity.eid.toString());
                                String volume = TFormat().decryptField(product.volume.toString(), widget.entity.eid.toString());
                                double buy = double.parse(TFormat().decryptField(product.buying.toString(), widget.entity.eid.toString()));
                                double sell = double.parse(TFormat().decryptField(product.selling.toString(), widget.entity.eid.toString()));
                                String supplier = _spplr.isEmpty
                                    ? 'N/A'
                                    :  TFormat().decryptField(_spplr.firstWhere((sup) => sup.sid == product.supplier).name.toString(), widget.entity.eid.toString());
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            if(selectedID!=invento.iid){
                                              selectedID = invento.iid;
                                            } else {
                                              selectedID = "";
                                            }
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor:invento.checked != "true"
                                                  ? Colors.black12
                                                  : qnty<10 && qnty>4
                                                  ? Colors.orange.withOpacity(0.5)
                                                  :qnty < 5 && qnty >0
                                                  ? Colors.purple.withOpacity(0.5)
                                                  :qnty<1
                                                  ? Colors.red.withOpacity(0.5)
                                                  :Colors.green.withOpacity(0.5),
                                              child: Center(
                                                child:
                                                invento.checked == "false"
                                                    ?Icon(Icons.cloud_upload, color: Colors.red,)
                                                    :invento.checked.toString().contains("DELETE") || invento.checked.toString().contains("REMOVED")
                                                    ?Icon(CupertinoIcons.delete, color: Colors.red,)
                                                    :invento.checked.toString().contains("EDIT")
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
                                                      Text(name.toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                                                      Expanded(child: SizedBox()),
                                                      Text('Quantity : ${qnty.toString()}, ML : ${volume}',
                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11),),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('BP:Ksh.${formatNumberWithCommas(buy)}, SP:Ksh.${formatNumberWithCommas(sell)}', style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontSize: 11),),
                                                      Text('Supplier : ${supplier}', style: TextStyle(fontSize: 11, color: Colors.black),)
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('IV:Ksh.${formatNumberWithCommas(qnty * buy)}, SV:Ksh.${formatNumberWithCommas(qnty * sell)}', style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontSize: 11),),
                                                      Text('${category}', style: TextStyle(color: Colors.black, fontSize: 11),),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      index == filteredList.length - 1 && selectedID != invento.iid && filteredList.length != 0
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
                                        child: selectedID == invento.iid
                                            ? IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              invento.checked == "false" || invento.checked == "false, EDIT"|| invento.checked.toString().contains("REMOVED")
                                                  ? BottomCallButtons(
                                                  onTap: (){
                                                    admin.contains(currentUser.uid) || _dutiesList.contains("INVENTORY")
                                                        ? _upload(invento)
                                                        : dialogRequest(BuildContext, "Upload");
                                                  },
                                                  icon: Icon(Icons.cloud_upload,
                                                    color: admin.contains(currentUser.uid)
                                                        ? screenBackgroundColor
                                                        : _dutiesList.contains("INVENTORY")
                                                        ?screenBackgroundColor
                                                        :Colors.red,
                                                  ),
                                                  actionColor: admin.contains(currentUser.uid)
                                                      ? screenBackgroundColor
                                                      : _dutiesList.contains("INVENTORY")
                                                      ?screenBackgroundColor
                                                      :Colors.red,
                                                  backColor: Colors.red.withOpacity(0.9),
                                                  title: "Upload"
                                              ) : SizedBox(),
                                              invento.checked == "false" || invento.checked == "false, EDIT" || invento.checked.toString().contains("REMOVED")
                                                  ?VerticalDivider(
                                                thickness: 0.5,
                                                width: 15,color: Colors.black12,
                                              ) : SizedBox(),
                                              BottomCallButtons(
                                                  onTap: (){
                                                    admin.contains(currentUser.uid) || _dutiesList.contains("INVENTORY")
                                                        ? dialogDelete(context, invento)
                                                        : dialogRequest(BuildContext, "Delete");

                                                  },
                                                  icon: Icon(CupertinoIcons.delete,
                                                    color: admin.contains(currentUser.uid)
                                                        ? screenBackgroundColor
                                                        : _dutiesList.contains("INVENTORY")
                                                        ?screenBackgroundColor
                                                        :Colors.red,
                                                  ),
                                                  actionColor: admin.contains(currentUser.uid)
                                                      ? screenBackgroundColor
                                                      : _dutiesList.contains("INVENTORY")
                                                      ?screenBackgroundColor
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
                                                        ? invento.checked.toString().contains("DELETE")
                                                        ? _restore(invento)
                                                        : dialogEditQuantity(context, invento)

                                                        : invento.checked.toString().contains("DELETE")
                                                        ? !_dutiesList.contains("PURCHASE")? dialogRequest(context, "Edit") :  _restore(invento)
                                                        : !_dutiesList.contains("PURCHASE")? dialogRequest(context, "Edit") : dialogEditQuantity(context, invento);

                                                  },
                                                  icon: Icon(
                                                    invento.checked.toString().contains("DELETE")?Icons.restore:Icons.edit,
                                                    color: admin.contains(currentUser.uid)
                                                        ? screenBackgroundColor
                                                        : _dutiesList.contains("INVENTORY")
                                                        ?screenBackgroundColor
                                                        :Colors.red,
                                                  ),
                                                  actionColor: admin.contains(currentUser.uid)
                                                      ? screenBackgroundColor
                                                      : _dutiesList.contains("INVENTORY")
                                                      ?screenBackgroundColor
                                                      :Colors.red,
                                                  title: invento.checked.toString().contains("DELETE")
                                                      ? 'Restore'
                                                      :"Edit"
                                              ),
                                            ],
                                          ),
                                        )
                                            : SizedBox(),
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
  void dialogAddInventory(BuildContext context) {
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        backgroundColor: dilogbg,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        constraints: BoxConstraints(
            maxHeight: size.height - 100,
            minHeight: size.height - 100,
            maxWidth: 500,minWidth: 450
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            )
        ),
        builder: (context){
          return  Container(width: 450,
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                DialogTitle(title: 'A D D  I N V E N T O R Y'),
                Expanded(
                    child: DialogAddInv(entity: widget.entity, addInv: _addInv, products: _filteredPrdcts)
                )
              ],
            ),
          );
        });
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
                DialogRequest(action: action, account: 'INVENTORY', entity: widget.entity,),
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogDelete(BuildContext context, InventModel inventory){
    showDialog(context: context, builder: (context){
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'R E M O V E'),
                Text(
                  'Are you sure you wish to proceed? This action will permanently affect any record associated with this data',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                DoubleCallAction(action: (){
                  Navigator.pop(context);
                  _delete(inventory);
                }, title: "Delete",titleColor: Colors.red,)
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogEditQuantity(BuildContext context, InventModel inventory){
    showDialog(context: context, builder: (context){
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'Q U A N T I T Y'),
                Text('Enter the number of units that you have currently in stock',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                DialogEditInvQuantity(inventory: inventory, reload: _getData)
              ],
            ),
          ),
        ),
      );
    });
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
                DialogFilterInv(entity: widget.entity, filter: _filter)
              ],
            ),
          ),
        )
    );
  }

  _getDetails()async{
    _getData();
    await Data().checkInventory(_inv, (){});
    _newInv = await Services().getMyInv(currentUser.uid);
    _newSupplier = await Services().getMySuppliers(currentUser.uid);
    _newPrd = await Services().getMyPrdct(currentUser.uid);
    await Data().addOrUpdateProductsList(_newPrd);
    await Data().addOrUpdateSuppliersList(_newSupplier);
    await Data().addOrUpdateInvList(_newInv).then((value){
      setState(() {
        _loading = value;
      });
    });
    _getData();
  }

  _getData(){
    _inv = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _spplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _prd = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    _spplr = _spplr.where((element) => element.eid == widget.entity.eid).toList();
    _inv = _inv.where((element){
      bool matchesEid = element.eid == widget.entity.eid;
      bool matchsQuantity = quantity.isEmpty || element.quantity.toString() == quantity;

      return matchesEid && matchsQuantity;
    }).toList();

    _duties = _duties.where((element) => element.eid == widget.entity.eid && element.pid == currentUser.uid).toList();
    _dutiesList = _duties.isEmpty? "" : _duties.first.duties.toString();
    _filteredPrdcts = _prd.where((prd) => _inv.any((invento) => prd.prid == invento.productid)).toList();
    _filteredPrdcts = _filteredPrdcts.where((element) {
      bool matchesEid = element.eid == widget.entity.eid;
      bool matchesCategory = category.isEmpty || element.category == category;
      bool matchesVolume = volume.isEmpty || element.volume == volume;
      bool matchesSupplier = supplierId.isEmpty || element.supplier == supplierId;
      bool matchBuy = bprice.isEmpty || double.parse(element.buying!) == double.parse(bprice);
      bool matchSell = sprice.isEmpty || double.parse(element.selling!) == double.parse(sprice);

      return matchesEid && matchesCategory && matchesVolume && matchesSupplier && matchBuy && matchSell;
    }).toList();
    admin = widget.entity.admin.toString().split(",");
    removed = _inv.where((element) => element.checked == "REMOVED").length;
    close = removed > 0? false: true;
    setState(() {
    });
  }

  _addInv(List<InventModel> inventories)async{
    setState(() {
      _loading = true;
    });
    List<String> uniqueInventory = [];
    List<InventModel> _inventroy = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _inventroy = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _inventroy.addAll(inventories);
    _inv.addAll(inventories);


    uniqueInventory = _inventroy.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("myinventory", uniqueInventory);
    myInventory = uniqueInventory;
    _getData();

    inventories.forEach((inventory)async{
      await Services.addInventory(inventory).then((response){
        if(response=="Success"){
          _inventroy.firstWhere((test) => test.iid == inventory.iid).checked = "true";
          uniqueInventory = _inventroy.map((model) => jsonEncode(model.toJson())).toList();
          sharedPreferences.setStringList("myinventory", uniqueInventory);
          myInventory = uniqueInventory;
          _getData();
        }
      });
    });
    setState(() {
      _loading = false;
    });
  }

  _updateInventory(InventModel inventModel)async{
    print("Update Inventory ");
    _inv.firstWhere((element) => element.iid == inventModel.iid).checked = "true";
    _getData();
    setState(() {

    });
  }
  _delete(InventModel inventory)async{
    setState(() {
      _loading = true;
    });
    await Data().removeInventory(inventory, _getData, context).then((value){
      setState(() {
        _loading = value;
      });
    });
  }
  _restore(InventModel inventory)async{
    List<String> uniqueInventory = [];
    List<InventModel> _inventory = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _inventory.firstWhere((element) => element.iid == inventory.iid).checked = inventory.checked.toString().replaceAll(", DELETE", "");
    uniqueInventory = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("myinventory", uniqueInventory);
    myInventory = uniqueInventory;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Inventory restored Successfully"),
            showCloseIcon: true,
        )
    );
    _getData();
  }
  _upload(InventModel inventory)async{
    List<String> uniqueInventory = [];
    List<InventModel> _inventroy = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _inventroy = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    setState(() {
      _loading = true;
    });
    Services.addInventory(inventory).then((response){
      print(response);
      if (response == "Success")
      {
        _inv.firstWhere((element) => element.iid == inventory.iid).checked = "true";
        _inventroy.firstWhere((element) => element.iid == inventory.iid).checked = "true";
        uniqueInventory = _inventroy.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList("myinventory", uniqueInventory);
        myInventory = uniqueInventory;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Inventory was uploaded Successfully"),
              showCloseIcon: true,
            )
        );
      } else if (response == "Failed")
      {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Inventory was not uploaded. Please try again"),
              showCloseIcon: true,
              action: SnackBarAction(label: "Try Again", onPressed: _upload(inventory)),
            )
        );
      } else if(response == 'Exists')
      {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Inventory already Exists"),
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
      setState(() {
        _loading = false;
      });
    });
  }
  _removeAll()async{
    List<String> uniqueInventory = [];
    List<InventModel> _inventory = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();

    _inv.removeWhere((element) => element.checked == "REMOVED" && element.eid == widget.entity.eid);
    _inventory.removeWhere((element) => element.checked == "REMOVED" && element.eid == widget.entity.eid);

    uniqueInventory  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myinventory', uniqueInventory );
    myInventory = uniqueInventory;
    _getData();
    close = removed > 0? false: true;
    setState(() {

    });
  }
  _uploadData()async{
    setState((){
      _loading = true;
      close = true;
    });
    await Data().checkInventory(_inv, _getData).then((value){
      setState(() {
        _loading = value;
      });
    });
    _getData();
  }
  _filter(String? cat, String? vol, String? sid, String? qnty, String? buy, String? sell){
    supplierId = sid==null?"":sid;
    category = cat==null?"":TFormat().encryptText(cat, widget.entity.eid);
    volume = vol==null?"":TFormat().encryptText(vol, widget.entity.eid);
    quantity = qnty==null?"":TFormat().encryptText(qnty, widget.entity.eid);
    // bprice = buy==null?"":buy;
    // sprice = sell==null?"":sell;
    _getData();
  }


  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
  void onSort(int columnIndex, bool ascending){
    if(columnIndex == 0){
      _filteredPrdcts.sort((prd1, prd2) =>
          compareString(ascending, prd1.name.toString(), prd2.name.toString())
      );
    } else if (columnIndex == 1){
      _filteredPrdcts.sort((prd1, prd2) =>
          compareString(ascending, prd1.category.toString(), prd2.category.toString())
      );
    }else if (columnIndex == 4){
      _filteredPrdcts.sort((prd1, prd2) =>
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
