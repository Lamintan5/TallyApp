import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/Widget/dialogs/dialog_edit_sale_qnty.dart';
import 'package:TallyApp/Widget/dialogs/dialog_pay_receivables.dart';
import 'package:TallyApp/home/action_bar/chats/message_screen.dart';
import 'package:TallyApp/home/action_bar/chats/web_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../Widget/buttons/bottom_call_buttons.dart';
import '../../Widget/buttons/card_button.dart';
import '../../Widget/dialogs/dialog_request.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/profile_images/user_profile.dart';
import '../../Widget/shimmer_widget.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/duties.dart';
import '../../models/entities.dart';
import '../../models/messages.dart';
import '../../models/payments.dart';
import '../../models/products.dart';
import '../../models/sales.dart';
import '../../models/suppliers.dart';
import '../../models/users.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';

class SaleItems extends StatefulWidget {
  final int index;
  final String saleId;
  final EntityModel entity;
  final String from;
  final Function getData;
  const SaleItems({super.key, required this.index, required this.saleId, required this.entity, required this.from, required this.getData});

  @override
  State<SaleItems> createState() => _SaleItemsState();
}

class _SaleItemsState extends State<SaleItems> {
  TextEditingController _search = TextEditingController();
  List<String> title = ['Receivable','Total Paid','Amount Due', 'Profits','Quantity', 'Items'];
  bool _loading = false;
  bool _layout = true;

  List<ProductModel> prd = [];
  List<ProductModel> _newprd = [];
  List<SaleModel> _sale = [];
  List<SaleModel> _newSale = [];
  List<SaleModel> _filtSale = [];
  List<SupplierModel> _spplr = [];
  List<SupplierModel> _fltSpplr = [];
  List<ProductModel> _products = [];
  List<UserModel> _user = [];

  double totalSprice = 0;
  double totalBprice = 0;
  double receivable = 0;
  double paid = 0;
  double quantity = 0;
  double changedAmount = 0;

  double newAmount = 0;

  SaleModel sale = SaleModel(saleid: "", customer: "", phone: "");
  UserModel seller = UserModel(uid: "", username: "", image: "", phone: "", email: "");

  String removed = "";
  String selectedID = "";

  int? sortColumnIndex;
  bool isAscending = false;
  bool close = true;

  List<DutiesModel> _duties = [];
  String _dutiesString = "";
  List<String> _dutiesList = [];
  late DutiesModel dutiesModel;

  List<String> pidListAsList = [];
  String pidList = "";
  List<String> admin = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(Platform.isAndroid || Platform.isIOS){
      _layout = false;
    } else {
      _layout = true;
    }
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.from == "SALES"
            ?'S${((widget.index)).toString().padLeft(3, '0')}'
            :'R${((widget.index)).toString().padLeft(3, '0')}'),
      ),
      body: WillPopScope(
        onWillPop: ()async{
          return true;
        },
        child:  Padding(
          padding: const EdgeInsets.all(8.0),
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
                                ?'Ksh.${formatNumberWithCommas(receivable)}'
                                :index==1
                                ?'Ksh.${formatNumberWithCommas(paid)}'
                                :index==2
                                ?'Ksh.${formatNumberWithCommas(totalSprice)}'
                                :index==3
                                ?'Ksh.${formatNumberWithCommas(totalSprice -totalBprice)}'
                                :index==4
                                ? quantity.toStringAsFixed(0)
                                : _products.length.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: index==0 && receivable < 0
                                      ? Colors.red
                                      : Colors.black
                              ),
                            ),

                          ],
                        ),
                      );
                    }),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sale.customer == ""
                            ? Container(
                          width: 200,
                          child: Row(
                            children: [
                              ShimmerWidget.circular(height: 40, width: 40,),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShimmerWidget.rectangular(height: 10, width: 100,),
                                    SizedBox(height: 4,),
                                    ShimmerWidget.rectangular(height: 10, width: double.infinity,),
                                    SizedBox(height: 2,),
                                    ShimmerWidget.rectangular(height: 10, width: double.infinity,),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                            : InkWell(
                          onTap: (){
                            dialogUser(
                                context,
                                "",
                                sale.customer.toString(),
                                "",
                                sale.phone.toString(),
                                sale.time.toString(),
                                sale.due.toString(),
                                "Customer"
                            );
                          },
                          child: Tooltip(
                            message: 'Customer Details',
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white10,
                                    child: LineIcon.user(color: reverse,),
                                  ),
                                  SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(sale.customer.toString(), style: TextStyle(fontSize: 11),),
                                      Text(sale.phone.toString(), style: TextStyle(fontSize: 11),),
                                      Text('Sale Date : ${DateFormat.yMMMd().format(DateTime.parse(sale.time.toString()))}', style: TextStyle(color: secondaryColor, fontSize: 11),),
                                      widget.from=='receivables'
                                          ?Text(sale.due.toString() == ""? "": 'Due Date : ${DateFormat.yMMMd().format(DateTime.parse(sale.due.toString()))}', style: TextStyle(color: secondaryColor, fontSize: 11),)
                                          :SizedBox(),

                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        seller.uid == ""
                            ? Container(
                          width: 200,
                          child: Row(
                            children: [
                              ShimmerWidget.circular(height: 40, width: 40,),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShimmerWidget.rectangular(height: 10, width: 100,),
                                    SizedBox(height: 4,),
                                    ShimmerWidget.rectangular(height: 10, width: double.infinity,),
                                    SizedBox(height: 2,),
                                    ShimmerWidget.rectangular(height: 10, width: double.infinity,),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                            : InkWell(
                          onTap: (){
                            dialogUser(
                                context,
                                seller.image.toString(),
                                seller.username.toString(),
                                seller.email.toString(),
                                seller.phone.toString(),
                                "",
                                "",
                                "Seller"
                            );
                          },
                          child: Tooltip(
                            message: 'Seller Details',
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  UserProfile(image: seller.image.toString(), radius: 25,),
                                  SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(seller.username.toString(), style: TextStyle(fontSize: 11),),
                                      Text(seller.email.toString(), style: TextStyle(color: secondaryColor, fontSize: 11),),
                                      Text(seller.phone.toString(), style: TextStyle(color: secondaryColor, fontSize: 11),),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                close == true && changedAmount != totalSprice && changedAmount !=0
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
                          Icon(CupertinoIcons.square_arrow_up_on_square, size: 30, color: CupertinoColors.systemBlue,),
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
                                          text:  "Some items in sale ",
                                          style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                      ),
                                      TextSpan(
                                          text: widget.from == "SALES"
                                              ?'S${((widget.index)).toString().padLeft(3, '0')} '
                                              :'R${((widget.index)).toString().padLeft(3, '0')} ',
                                          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)
                                      ),

                                      TextSpan(
                                          text: "have been updated or removed. These changes may impact your data. Would you like to update your list to reflect these modifications? ",
                                          style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                      ),
                                      WidgetSpan(
                                          child: InkWell(
                                              onTap: ()async{
                                                close = true;
                                                setState(() {
                                                  _loading = true;
                                                });
                                                await Data().updateSaleList(context, _sale, _update).then((value){
                                                  setState(() {
                                                    _loading = value;
                                                  });
                                                });
                                              },
                                              child: Text("Update All", style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.bold),)
                                          )
                                      )
                                    ]
                                )
                            ),
                          ),
                          InkWell(
                              onTap: (){
                                setState(() {
                                  close = false;
                                });
                              },
                              child: Icon(Icons.close, size: 30,color: Colors.black,)
                          )
                        ],
                      ),
                    ),
                  ),
                )
                    : SizedBox(),
                Row(
                  children: [
                    _loading
                        ? Container(
                      width: 20, height: 20,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: CircularProgressIndicator(
                        color: reverse,
                        strokeWidth: 2,
                      ),
                    )
                        : SizedBox(),
                    Expanded(child: SizedBox()),
                    CardButton(
                      text: _layout?'List':'Table',
                      backcolor: Colors.white,
                      icon: Icon(_layout?CupertinoIcons.list_dash:CupertinoIcons.table,
                        color: screenBackgroundColor,size: 16,),
                      forecolor: screenBackgroundColor,
                      onTap: () {
                        setState(() {
                          _layout=!_layout;
                        });
                      },
                    ),
                    CardButton(
                      text:_sale.any((test) => test.checked.toString().contains("false"))? 'Upload' : 'Reload',
                      backcolor: _sale.any((test) => test.checked.toString().contains("false"))?Colors.red :screenBackgroundColor,
                      icon: Icon(_sale.any((test) => test.checked.toString().contains("false"))
                          ? Icons.cloud_upload :CupertinoIcons.refresh, size: 16, color: Colors.white,),
                      forecolor: Colors.white,
                      onTap: () {
                        setState(() {
                          _loading = true;
                        });
                        _sale.any((test) => test.checked.toString().contains("false"))
                            ? _upload()
                            : _getDetails();
                        setState(() {
                          changedAmount = 0;
                          close = true;
                        });
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Divider(
                          height: 1,
                          color: reverse,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:10.0),
                        child: Text('Sales Items List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500 , color: reverse),),
                      ),
                      Expanded(
                        child: Divider(
                          height: 1,
                          color: reverse,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
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
                          Container(width: 300,
                            padding: EdgeInsets.only(left: 10),
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
                                  hintText: "Search...",
                                  hintStyle: TextStyle(color: secondaryColor),
                                  isDense: true,
                                  contentPadding: EdgeInsets.all(8),
                                  icon: Icon(Icons.search, color: Colors.black,),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none
                                  )
                              ),
                              onChanged:  (value) => setState((){}),
                            ),
                          ),
                          SizedBox(height: 20,),
                          _layout
                              ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            child: DataTable(
                              headingRowHeight: 30,
                              headingTextStyle: TextStyle(color: Colors.white),
                              headingRowColor: MaterialStateColor.resolveWith((states) {
                                return screenBackgroundColor;
                              }),
                              sortColumnIndex: sortColumnIndex,
                              sortAscending: isAscending,
                              columns: [
                                DataColumn(
                                  label: Text("PRODUCT NAME", style: TextStyle(color: Colors.white),),
                                  onSort: onSort,
                                  tooltip: 'Click here to sort list by name',
                                ),
                                DataColumn(
                                    label: Text("CATEGORY", style: TextStyle(color: Colors.white),),
                                    onSort: onSort,
                                    tooltip: 'Click here to sort list by category'
                                ),
                                DataColumn(
                                  label: Text("ML", style: TextStyle(color: Colors.white),),
                                ),
                                DataColumn(
                                  label: Text("QUANTITY", style: TextStyle(color: Colors.white),),
                                ),
                                DataColumn(
                                    label: Text("SUPPLIER", style: TextStyle(color: Colors.white),),
                                    onSort: onSort,
                                    tooltip: 'Click here to sort list by Supplier'
                                ),
                                DataColumn(
                                  label: Text("BUYING PRICE", style: TextStyle(color: Colors.white),),
                                ),
                                DataColumn(
                                  label: Text("SELLING PRICE", style: TextStyle(color: Colors.white),),
                                ),
                                DataColumn(
                                  label: Text("PROFIT", style: TextStyle(color: Colors.white),),
                                ),
                                DataColumn(
                                    label: Text("ACTION", style: TextStyle(color: Colors.white),),

                                ),

                              ],
                              rows: filteredList.map((product){
                                _fltSpplr = _spplr.where((sup) => sup.sid == product.supplier).toList();
                                _filtSale = _sale.where((element) => element.productid == product.prid).toList();
                                var sprice = _filtSale.isEmpty ? 0.0 : double.parse(_filtSale.first.sprice.toString()) * double.parse(_filtSale.first.quantity.toString());
                                var bprice = _filtSale.isEmpty ? 0.0 : double.parse(_filtSale.first.bprice.toString()) * double.parse(_filtSale.first.quantity.toString());
                                var qnty = _filtSale.isEmpty ? 0 : int.parse(_filtSale.first.quantity.toString());
                                var profit = _filtSale.isEmpty ? 0.0 : sprice-bprice;
                                var suppName = _fltSpplr.isEmpty? 'N/A' : _fltSpplr.first.name.toString();
                                var salemodel = _filtSale.isEmpty? SaleModel(saleid: "") : _filtSale.first;
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
                                          Center(child: Text(qnty.toString(),style: TextStyle(color: Colors.black),)),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text(suppName,style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text('Ksh.${formatNumberWithCommas(bprice)}',style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text('Ksh.${formatNumberWithCommas(sprice)}',style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Text('Ksh.${formatNumberWithCommas(profit)}',style: TextStyle(color: Colors.black),),
                                          onTap: (){
                                            // _setValues(inventory);
                                            // _selectedInv = inventory;
                                          }
                                      ),
                                      DataCell(
                                          Center(
                                            child: PopupMenuButton<String>(
                                              tooltip: 'Show options',
                                              child: salemodel.checked == 'true'
                                                  ? Icon(Icons.more_vert, color: screenBackgroundColor)
                                                  : salemodel.checked.toString().contains("REMOVED")
                                                  ? Icon(CupertinoIcons.delete_solid, color: Colors.red)
                                                  : salemodel.checked.toString().contains("DELETE")
                                                  ? Icon(CupertinoIcons.delete, color: Colors.red)
                                                  : salemodel.checked.toString().contains("EDIT")
                                                  ? Icon(Icons.edit, color: Colors.red)
                                                  : salemodel.checked.toString().contains("false")
                                                  ? Icon(Icons.cloud_upload, color: Colors.red,)
                                                  :Icon(Icons.more_vert, color: screenBackgroundColor),
                                              onSelected: (value) {
                                              },
                                              itemBuilder: (BuildContext context) {
                                                return [
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          CupertinoIcons.delete, color: admin.contains(currentUser.uid)
                                                            ? reverse
                                                            : _dutiesList.contains(widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE")
                                                            ?reverse
                                                            :Colors.red,
                                                        ),
                                                        SizedBox(width: 5,),
                                                        Text('Delete',style: TextStyle(
                                                          color: admin.contains(currentUser.uid)
                                                              ? reverse
                                                              : _dutiesList.contains(widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE")
                                                              ?reverse
                                                              :Colors.red,
                                                        ),),
                                                      ],
                                                    ),
                                                    onTap: (){
                                                      admin.contains(currentUser.uid)
                                                          ? dialogRemoveItem(context, product.name.toString(), salemodel)
                                                          : _dutiesList.contains("SALE") || _dutiesList.contains("RECEIVABLE")
                                                          ?dialogRemoveItem(context,  product.name.toString(), salemodel)
                                                          :dialogRequest(context, "Delete", widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE");
                                                    },
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          salemodel.checked.toString().contains("DELETE")
                                                              ? Icons.restore
                                                              :Icons.edit,
                                                          color: admin.contains(currentUser.uid)
                                                              ? reverse
                                                              : _dutiesList.contains(widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE")
                                                              ? reverse
                                                              : Colors.red,
                                                        ),
                                                        SizedBox(width: 5,),
                                                        Text(
                                                          salemodel.checked.toString().contains("DELETE")
                                                              ?"Restore"
                                                              :'Edit', style: TextStyle(
                                                          color: admin.contains(currentUser.uid)
                                                              ? reverse
                                                              : _dutiesList.contains(widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE")
                                                              ? reverse
                                                              : Colors.red,),
                                                        ),
                                                      ],
                                                    ),
                                                    onTap: (){
                                                      salemodel.checked.toString().contains("DELETE")
                                                          ?_restore(salemodel)
                                                          :admin.contains(currentUser.uid)
                                                          ? dialogEditItem(context, qnty, salemodel, product)
                                                          : _dutiesList.contains(widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE") || _dutiesList.contains("PAYABLE")
                                                          ?dialogEditItem(context, qnty, salemodel, product)
                                                          :dialogRequest(context, "Edit", widget.from == "payable"? "PAYABLE" :widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE");

                                                    },
                                                  ),
                                                ];
                                              },
                                            ),
                                          )
                                      ),
                                    ]
                                );
                              }
                              ).toList(),
                            ),
                          )
                              : SizedBox(width: 450,
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index){
                                  ProductModel product = filteredList[index];
                                  _fltSpplr = _spplr.where((sup) => sup.sid == product.supplier).toList();
                                  _filtSale = _sale.where((element) => element.productid == product.prid).toList();
                                  var sprice = _filtSale.isEmpty ? 0.0 : double.parse(_filtSale.first.sprice.toString()) * double.parse(_filtSale.first.quantity.toString());
                                  var bprice = _filtSale.isEmpty ? 0.0 : double.parse(_filtSale.first.bprice.toString()) * double.parse(_filtSale.first.quantity.toString());
                                  var qnty = _filtSale.isEmpty ? 0 : int.parse(_filtSale.first.quantity.toString());
                                  var profit = _filtSale.isEmpty ? 0.0 : sprice-bprice;
                                  var suppName = _fltSpplr.isEmpty? SupplierModel(sid: "") : _fltSpplr.first;
                                  var salemodel = _filtSale.isEmpty? SaleModel(saleid: "") : _filtSale.first;
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
                                                salemodel.checked == "false"
                                                    ?Icon(Icons.cloud_upload, color: Colors.red,)
                                                    :salemodel.checked.toString().contains("REMOVED")
                                                    ?Icon(CupertinoIcons.delete_solid, color: Colors.red)
                                                    : salemodel.checked.toString().contains("DELETE")
                                                    ? Icon(CupertinoIcons.delete, color: Colors.red)
                                                    :salemodel.checked.toString().contains("EDIT")
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
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Text(product.name.toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                                                        SizedBox(width: 10,),
                                                        Text('${product.category}', style: TextStyle(color: Colors.black54, fontSize: 11),),
                                                        Expanded(child: SizedBox()),
                                                        Text('Quantity : ${qnty} ', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700, fontSize: 11),),
                                                        Text('ML : ${product.volume}', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 11),),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(suppName.sid == "" ? 'Supplier not available'
                                                            : 'Supplier : ${suppName.name}',
                                                          style: TextStyle(fontSize: 11, color: Colors.black),),
                                                        Expanded(child: SizedBox()),
                                                        Text(
                                                          "BP: Ksh.${formatNumberWithCommas(double.parse(salemodel.bprice.toString()))} SP: Ksh.${formatNumberWithCommas(double.parse(salemodel.sprice.toString()))}",
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
                                      index == filteredList.length - 1 && selectedID != salemodel.sid && filteredList.length != 0
                                          ?SizedBox()
                                          :Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Divider(
                                          color: Colors.black12,
                                          thickness: 1,height: 1,
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
                                              BottomCallButtons(
                                                  onTap: (){
                                                    admin.contains(currentUser.uid)
                                                        ? dialogRemoveItem(context, product.name.toString(), salemodel)
                                                        : _dutiesList.contains("SALE") || _dutiesList.contains("RECEIVABLE")
                                                        ?dialogRemoveItem(context,  product.name.toString(), salemodel)
                                                        :dialogRequest(context, "Delete", widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE");
                                                  },
                                                  icon: Icon(
                                                    CupertinoIcons.delete,
                                                    color: admin.contains(currentUser.uid)
                                                        ? Colors.black
                                                        : _dutiesList.contains(widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE")
                                                        ? Colors.black
                                                        : Colors.red,
                                                  ),
                                                  actionColor: admin.contains(currentUser.uid)
                                                      ? Colors.black
                                                      : _dutiesList.contains(widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE")
                                                      ? Colors.black
                                                      : Colors.red,
                                                  title: "Delete"
                                              ),
                                              VerticalDivider(
                                                thickness: 0.5,
                                                width: 15,color: Colors.black12,
                                              ),
                                              BottomCallButtons(
                                                  onTap: (){
                                                    salemodel.checked.toString().contains("DELETE")
                                                        ?_restore(salemodel)
                                                        :admin.contains(currentUser.uid)
                                                        ? dialogEditItem(context, qnty, salemodel, product)
                                                        : _dutiesList.contains(widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE") || _dutiesList.contains("PAYABLE")
                                                        ?dialogEditItem(context, qnty, salemodel, product)
                                                        :dialogRequest(context, "Edit", widget.from == "payable"? "PAYABLE" :widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE");
                                                  },
                                                  icon: Icon(
                                                    salemodel.checked.toString().contains("DELETE")?Icons.restore:Icons.edit,
                                                    color: admin.contains(currentUser.uid)
                                                        ? Colors.black
                                                        : _dutiesList.contains(widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE")
                                                        ? Colors.black
                                                        : Colors.red,
                                                  ),
                                                  actionColor: admin.contains(currentUser.uid)
                                                      ? Colors.black
                                                      : _dutiesList.contains(widget.from == "RECEIVABLE"? "RECEIVABLE" :"SALE")
                                                      ? Colors.black
                                                      : Colors.red,
                                                  title: product.checked.toString().contains("DELETE")
                                                      ? 'Restore'
                                                      : "Edit"
                                              ),
                                            ],
                                          ),
                                        )
                                            : SizedBox(),
                                      )
                                    ],
                                  );
                                }),
                          ),
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
      floatingActionButton: receivable != 0
          ? FloatingActionButton.large(
        onPressed: (){
          dialogAddPayment(context);
        },
        backgroundColor: reverse,
        elevation: 11,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total', style: TextStyle(color: normal),),
            Text(NumberFormat.compact().format( receivable), style: TextStyle(color: normal, fontWeight: FontWeight.bold)),
            Text('Pay', style: TextStyle(color: normal),),
          ],
        ),
      )
          : SizedBox(),
    );
  }
  void dialogUser(BuildContext context, String image, String name, String email, String phone, String sale, String due, String user){
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    showDialog(context: context, builder: (context){
      return Dialog(
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
                SizedBox(height: 20,),
                user == "Customer"
                    ?  CircleAvatar(
                  radius: 40,
                  backgroundColor: color1,
                  child: LineIcon.user(color: revers,),
                )
                    : UserProfile(image: image, radius: 40,),
                SizedBox(height: 10,),
                Text(name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
                email==""?SizedBox() : Text(email),
                Text(phone),
                Text(user, style: TextStyle(color: secondaryColor),),
                user == "Seller"? SizedBox()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sale date : ${DateFormat.yMMMd().format(DateTime.parse(sale))}', style: TextStyle(color: secondaryColor, fontSize: 13),),
                    widget.from=='RECEIVABLE'
                        ? Text('    Due date : ${DateFormat.yMMMd().format(DateTime.parse(due))}', style: TextStyle(color: secondaryColor, fontSize: 13),)
                        : SizedBox(),
                  ],
                ),
                seller.uid == currentUser.uid ? SizedBox() :SizedBox(height: 10,),
                seller.uid == currentUser.uid ? SizedBox() :Divider(
                  thickness: 0.1,
                  color: revers,
                ),
                seller.uid == currentUser.uid ? SizedBox() :  IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                          child: InkWell(
                            onTap: (){
                              Platform.isIOS || Platform.isAndroid
                                  ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: seller), transition: Transition.rightToLeft)
                                  : Get.to(() => WebChat(selected: seller), transition: Transition.rightToLeft);
                            },
                            child: SizedBox(height: 40,
                              child: Center(
                                child: Text(
                                  'Message',
                                  style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.w700, fontSize: 15),
                                  textAlign: TextAlign.center,),
                              ),
                            ),
                          )
                      ),
                      Platform.isIOS || Platform.isAndroid? VerticalDivider(
                        thickness: 0.2,
                        color: revers,
                      ) : SizedBox(),
                      Platform.isIOS || Platform.isAndroid? Expanded(
                          child: InkWell(
                            onTap: (){
                              Navigator.pop(context);
                              if(seller.phone.toString().isEmpty){
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(Data().noPhone),
                                      showCloseIcon: true,
                                    )
                                );

                              } else {
                                _callNumber(seller.phone.toString());
                              }

                            },
                            child: SizedBox(height: 40,
                              child: Center(
                                child: Text(
                                  "Call",
                                  style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w700, fontSize: 15),
                                  textAlign: TextAlign.center,),
                              ),
                            ),
                          )
                      ) : SizedBox(),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogRequest(BuildContext, String action, String account){
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
                DialogRequest(action: action, account: account, entity: widget.entity,),
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogAddPayment(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
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
                DialogTitle(title: 'R E C E I V A L B E'),
                Text(
                  'Enter the complete payment for this particular sale',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                SizedBox(height: 5,),
                DialogPayReceivables(
                    amount: receivable,
                    updateReceivable: _updateReceivable
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogRemoveItem(BuildContext context, String name,  SaleModel salemodel){
    final style = TextStyle(fontSize: 13, color: secondaryColor);
    showDialog(context: context, builder: (context){
      return Dialog(
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
                DialogTitle(title: 'R E M O V E'),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Are you sure you wish to remove ",
                            style: style,
                          ),
                          TextSpan(
                              text: "${name} "
                          ),
                          TextSpan(
                            text: "from your Sales list? Please note that once this purchases is removed, all records associated with it will be permanently deleted.",
                            style: style,
                          ),
                        ]
                    )
                ),
                DoubleCallAction(
                  action: (){
                    _updateRemoved(salemodel);
                  },
                  title: "Remove",
                  titleColor: Colors.red,
                )
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogEditItem(BuildContext context, int quantity, SaleModel salemodel, ProductModel product){
    showDialog(context: context, builder: (context){
      return Dialog(
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
                DialogTitle(title: 'Q U A N T I T Y',),
                Text('Enter the number of ${product.name} that you have currently in stock',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                DialogEditSaleQnty(
                  updateQuantity: _updateQuantity,
                  sale: salemodel,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  _getDetails()async{
    _getData();
    _user = await Services().getCrntUsr(sale.sellerid.toString());
    _newSale = await Services().getMySale(currentUser.uid);
    _newprd = await Services().getMyPrdct(currentUser.uid);
    await Data().addOrUpdateUserList(_user);
    await Data().addOrUpdateSalesList(_newSale);
    await Data().addOrUpdateProductsList(_newprd);
    _getData();
  }
  _getData(){
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).where((element) => element.saleid == widget.saleId).toList();
    _sale = _sale.where((element) => element.checked != 'DELETED').toList();
    _products = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.entity.eid).toList();
    _products = _products.where((prd) => _sale.any((sale) => prd.prid == sale.productid)).toList();
    _spplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.entity.eid).toList();
    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.entity.eid).toList();
    _dutiesList =_duties.isEmpty? [] : _duties.first.duties!.split(",");
    sale = _sale.isEmpty? SaleModel(saleid: "", customer: "", phone: "", pid: "") : _sale.first;
    admin = widget.entity.admin.toString().split(",");
    seller = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).firstWhere((element) => element.uid == sale.sellerid,
        orElse: () => UserModel(uid: "", image: "", username: "N/A", email: "", phone: "") );
    paid = _sale.isEmpty? 0.0 : double.parse(_sale.first.paid.toString());
    totalSprice = _sale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
    totalBprice = _sale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
    quantity = _sale.fold(0.0, (previousValue, element) => previousValue + double.parse(element.quantity.toString()));
    receivable = totalSprice - paid;
    changedAmount = totalSprice;

    pidList = widget.entity.pid.toString();
    pidListAsList = pidList.split(",");
    setState(() {});
  }

  _upload(){}
  _updateRemoved(SaleModel sale){
    SaleModel updatingSale = _sale.firstWhere((element) => element.sid == sale.sid);
    if(!sale.checked.toString().contains("DELETE")){
      double amount = double.parse(updatingSale.sprice.toString()) * double.parse(updatingSale.quantity.toString());
      double finalAmount = double.parse(updatingSale.amount.toString()) - amount;
      _sale.where((element) => element.saleid == sale.saleid).forEach((action) => action.amount = finalAmount.toString());
      _sale.firstWhere((element) => element.sid == sale.sid).checked = updatingSale.checked.toString().contains("DELETE")? updatingSale.checked : "${updatingSale.checked}, DELETE";
    }
    changedAmount = _sale.where((element) => !element.checked.toString().contains("DELETE")).fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
    _sale.forEach((element){
      element.amount = changedAmount.toString();
    });
    receivable =  changedAmount - paid;
    Navigator.pop(context);
    setState(() {});
  }
  _updateQuantity(SaleModel sale, String selling, String quantity){
    _sale.firstWhere((element) => element.sid == sale.sid).quantity = quantity;
    _sale.firstWhere((element) => element.sid == sale.sid).sprice = selling;
    _sale.firstWhere((element) => element.sid == sale.sid).checked = sale.checked.toString().contains("EDIT")
        ? sale.checked
        : "${sale.checked}, EDIT";
    changedAmount = _sale.where((element) => !element.checked.toString().contains("DELETE")).fold(0.0, (previousValue, element) =>
    previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
    _sale.forEach((element){
      element.amount = changedAmount.toString();
    });
    receivable =  changedAmount - paid;
    setState(() {

    });
  }
  _restore(SaleModel sale)async{
    SaleModel updatingSale = _sale.firstWhere((element) => element.sid == sale.sid);
    _sale.firstWhere((element) => element.sid == sale.sid).checked = updatingSale.checked.toString().replaceAll(", DELETE", "");
    changedAmount = _sale.where((element) => !element.checked.toString().contains("DELETE")).fold(0.0, (previousValue, element) =>
    previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
    _sale.forEach((element){
      element.amount = changedAmount.toString();
    });
    receivable =  changedAmount - paid;
    setState(() {});
  }
  _update(){
    _getData();
    widget.getData();
  }
  _updateReceivable(double paid, String method)async{
    List<String> uniqueSale = [];
    List<String> uniquePayments = [];
    List<SaleModel> _sales = [];
    List<PaymentModel> _payments = [];
    Uuid uuid = Uuid();
    String payid = uuid.v1();

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _payments = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();
    _sales = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    double newPaid = (double.parse(sale.paid.toString()) + paid);

    _sale.forEach((element) async {
      _sales.firstWhere((test) => test.sid == element.sid).paid = newPaid.toString();
      _sales.firstWhere((test) => test.sid == element.sid).checked = element.checked.toString().contains("EDIT")
          ?element.checked
          : "${element.checked}, EDIT" ;
    });

    PaymentModel payment = PaymentModel(
        payid: payid,
        eid: widget.entity.eid,
        pid: widget.entity.pid,
        payerid: currentUser.uid,
        admin: widget.entity.admin,
        saleid: sale.saleid,
        purchaseid: "",
        items: _products.length.toString(),
        amount: receivable.toString(),
        paid: paid.toString(),
        type: "RECEIVABLE",
        method: method,
        checked: "false",
        time: DateTime.now().toString()
    );

    _payments.add(payment);

    uniqueSale = _sales.map((model) => jsonEncode(model.toJson())).toList();
    uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mysales', uniqueSale);
    sharedPreferences.setStringList('mypayments', uniquePayments );
    mySales = uniqueSale;
    myPayments = uniquePayments;
    _getData();
    widget.getData();
    await Services.updateSalePaid(widget.saleId, newPaid.toString()).then((response){
      if(response=="success"){
        _sales.where((element) => element.saleid == widget.saleId).forEach((salemodel){
          salemodel.checked = "true";
        });
        uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mysales', uniqueSale);
        mySales = uniqueSale;
      }
    });
    await Services.addPayment(payment).then((response){
      if(response=="Success"){
        payment.checked = "true";
      }
    });
    uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypayments', uniquePayments );
    myPayments = uniquePayments;
    _getData();
    widget.getData();
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
    }else if (columnIndex == 4){
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
  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
  _changeMess(MessModel mess){}
  _updateCount(){}
  _callNumber(String number) async{

  }
}
