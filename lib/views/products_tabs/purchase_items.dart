import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/Widget/dialogs/dialog_edit_prch_qnty.dart';
import 'package:TallyApp/Widget/empty_data.dart';
import 'package:TallyApp/Widget/profile_images/current_profile.dart';
import 'package:TallyApp/models/purchases.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../Widget/buttons/bottom_call_buttons.dart';
import '../../Widget/buttons/card_button.dart';
import '../../Widget/dialogs/dialog_pay_prch_itms.dart';
import '../../Widget/dialogs/dialog_remove_purchase.dart';
import '../../Widget/dialogs/dialog_request.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/dialogs/filters/dialog_filter_goods.dart';
import '../../Widget/profile_images/user_profile.dart';
import '../../Widget/shimmer_widget.dart';
import '../../home/action_bar/chats/message_screen.dart';
import '../../home/action_bar/chats/web_chat.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/duties.dart';
import '../../models/entities.dart';
import '../../models/inventories.dart';
import '../../models/messages.dart';
import '../../models/payments.dart';
import '../../models/products.dart';
import '../../models/suppliers.dart';
import '../../models/users.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';

class PurchaseItems extends StatefulWidget {
  final int index;
  final String purchaseId;
  final EntityModel entity;
  final String pid;
  final String from;
  final Function getPurchase;
  const PurchaseItems({super.key, required this.index, required this.purchaseId, required this.entity, required this.pid, required this.from, required this.getPurchase});

  @override
  State<PurchaseItems> createState() => _PurchaseItemsState();
}

class _PurchaseItemsState extends State<PurchaseItems> {
  List<String> title = ['Total Amount','Total Paid','Balance', 'Total Items','Total Quantity',];
  UserModel user = UserModel(uid: "", image: "", username: "", email: "", phone: "");
  PurchaseModel purchaseModel = PurchaseModel(purchaseid: "");
  TextEditingController _search = TextEditingController();
  final ScrollController _horizontal = ScrollController();
  List<PurchaseModel> _purchase = [];
  List<PurchaseModel> _newPrch = [];
  List<ProductModel> _products = [];
  List<ProductModel> _newPrds = [];
  List<SupplierModel> _spplr = [];
  List<UserModel> _user = [];
  List<DutiesModel> _duties = [];
  List<DutiesModel> _newduties = [];
  String _dutiesList = "";

  List<String> admin = [];
  String selectedID = "";

  double totalAmount = 0;
  double totalPaid = 0;
  double payable = 0;
  double newAmount = 0;
  double changedAmount = 0;

  int totalQuantities = 0;
  int? sortColumnIndex;

  bool isAscending = false;
  bool _loading = false;
  bool _layout = true;
  bool close = true;

  String category = "";
  String volume = "";
  String supplierId ="";

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
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final revers =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final appBarColor =  Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    final bgColor =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : screenBackgroundColor;
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
        title: Text('P${((int.parse(widget.index.toString()))).toString().padLeft(3, '0')}'),
        actions: [
          changedAmount != totalAmount &&  changedAmount != 0
              ? IconButton(
                  onPressed: ()async{
                    setState(() {
                      _loading = true;
                    });
                    await Data().updatePurchaseList(context, _purchase, _getDetails).then((value){
                      setState(() {
                        _loading = value;
                      });
                    });
                  },
                  icon: Icon(CupertinoIcons.check_mark_circled_solid, color: CupertinoColors.systemBlue,)
                )
              : SizedBox()
        ],
      ),
      body: WillPopScope(
          onWillPop: ()async{
            return true;
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:  const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 3 / 2,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1
                      ),
                      itemCount: title.length,
                      itemBuilder: (context, index){
                        return Card(
                          margin: EdgeInsets.all(5),
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
                              Text(
                                index==0
                                  ?'Ksh.${formatNumberWithCommas(totalAmount)}'
                                  :index==1
                                  ?'Ksh.${formatNumberWithCommas(totalPaid)}'
                                  :index==2
                                  ?'Ksh.${formatNumberWithCommas(totalAmount-totalPaid)}'
                                  :index==3
                                  ?_purchase.length.toString()
                                  :totalQuantities.toString(),
                                style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),
                              ),
                            ],
                          ),
                        );
                      }),
                  Row(
                    children: [
                      user.uid == ""
                          ? Container(
                        width: 200,
                        margin: EdgeInsets.all(10),
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
                          : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: (){
                            dialogUser(
                              context,
                              user.username.toString(),
                              user.email.toString(),
                              user.phone.toString(),
                              purchaseModel.time.toString(),
                              purchaseModel.due.toString(),
                            );
                          },
                          child: Tooltip(
                            message: 'Purchaser Details',
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  purchaseModel.purchaser == currentUser.uid
                                      ? CurrentImage(radius: 25,)
                                      : UserProfile(image: user.image.toString(), radius: 25,),
                                  SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user.username.toString(), style: TextStyle(fontSize: 11),),
                                      Text(user.email.toString(), style: TextStyle(color: secondaryColor, fontSize: 11),),
                                      Text(user.phone.toString(), style: TextStyle(color: secondaryColor, fontSize: 11),),
                                      ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _loading
                          ? Container(
                        width: 20, height: 20,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: CircularProgressIndicator(
                          color: revers,
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
                          text: "Filter",
                          backcolor: Colors.white,
                          forecolor: Colors.black,
                          icon: Icon(Icons.filter_list_rounded, size: 20,color: Colors.black,),
                          onTap: (){dialogFilter(context);}
                      ),
                      CardButton(
                        text:_purchase.any((test) => test.checked.toString().contains("false"))? 'Upload' : 'Reload',
                        backcolor: _purchase.any((test) => test.checked.toString().contains("false"))?Colors.red :screenBackgroundColor,
                        icon: Icon(
                          _purchase.any((test) => test.checked.toString().contains("false"))
                              ? Icons.cloud_upload :CupertinoIcons.refresh, size: 16, color: Colors.white,),
                        forecolor: Colors.white,
                        onTap: () {
                          setState(() {
                            category = "";
                            volume = "";
                            supplierId = "";
                            _loading = true;
                          });
                          _purchase.any((test) => test.checked.toString().contains("false"))
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
                  close == true && changedAmount != totalAmount &&  changedAmount != 0
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
                                            text:  "Some items in purchase ",
                                            style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                        ),
                                        TextSpan(
                                            text: "P${((widget.index)).toString().padLeft(3, '0')} ",
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
                                                  await Data().updatePurchaseList(context, _purchase, _update).then((value){
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
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Divider(
                            height: 1,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal:10.0),
                          child: Text('Purchase Items List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500 , color: Colors.white),),
                        ),
                        Expanded(
                          child: Divider(
                            height: 1,
                            color: Colors.white,
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
                            Container(
                              width: 300,
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
                                ? Scrollbar(
                              thumbVisibility: true,
                              controller: _horizontal,
                                  child: SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    controller: _horizontal,
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                  headingRowHeight: 30,
                                  headingRowColor: MaterialStateColor.resolveWith((states) {
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
                                      label: Text("Quantity", style: TextStyle(color: Colors.white),),
                                      numeric: false,
                                    ),
                                    DataColumn(
                                        label: Text("Supplier", style: TextStyle(color: Colors.white),),
                                        numeric: false,
                                        onSort: onSort,
                                    ),
                                    DataColumn(
                                      label: Text("Buy Price", style: TextStyle(color: Colors.white),),
                                      numeric: false,
                                    ),
                                    DataColumn(
                                        label: Text("Action", style: TextStyle(color: Colors.white),),
                                        numeric: false,
                                    ),
                                  ],
                                  rows: filteredList.map((product){
                                    var prchsmodel = _purchase.isEmpty? PurchaseModel(purchaseid: "") : _purchase.firstWhere((element) => element.productid == product.prid);
                                    var qnty =  int.parse(prchsmodel.quantity.toString());
                                    var _filtSupplr = _spplr.where((sup) => sup.sid == product.supplier).toList();
                                    var suppName = _filtSupplr.isEmpty ? SupplierModel(sid: "", name: "N/A") : _filtSupplr.firstWhere((sup) => sup.sid == product.supplier);
                                    var bprice =  double.parse(prchsmodel.bprice.toString());
                                    return DataRow(
                                        cells: [
                                          DataCell(
                                            Text(product.name.toString(),style: TextStyle(color: Colors.black),),
                                          ),
                                          DataCell(
                                            Text(product.category.toString(),style: TextStyle(color: Colors.black),),
                                          ),
                                          DataCell(
                                            Text(product.volume.toString(),style: TextStyle(color: Colors.black),),
                                          ),
                                          DataCell(
                                            Center(child: Text(qnty.toString(),style: TextStyle(color: Colors.black),)),
                                          ),
                                          DataCell(
                                            Text(suppName.name.toString(),style: TextStyle(color: Colors.black),),
                                          ),
                                          DataCell(
                                            Text('Ksh.${formatNumberWithCommas(bprice * qnty)}',style: TextStyle(color: Colors.black),),
                                          ),
                                          DataCell(
                                              Center(
                                                child: PopupMenuButton<String>(
                                                  tooltip: 'Show options',
                                                  child: prchsmodel.checked == 'true'
                                                      ? Icon(Icons.more_vert, color: screenBackgroundColor)
                                                      : prchsmodel.checked.toString().contains("REMOVED") || prchsmodel.checked.toString().contains("DELETE")
                                                      ? Icon(CupertinoIcons.delete, color: Colors.red)
                                                      : prchsmodel.checked.toString().contains("EDIT")
                                                      ? Icon(Icons.edit, color: Colors.red)
                                                      : prchsmodel.checked.toString().contains("false")
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
                                                            Icon(CupertinoIcons.delete, color: admin.contains(currentUser.uid)
                                                                ? revers
                                                                : _dutiesList.contains( widget.from == "payable"? "PAYABLE" :"PURCHASE")
                                                                ?revers
                                                                :Colors.red,),
                                                            SizedBox(width: 5,),
                                                            Text('Delete',style: TextStyle(
                                                              color: admin.contains(currentUser.uid)
                                                                  ? revers
                                                                  : _dutiesList.contains( widget.from == "payable"? "PAYABLE" :"PURCHASE")
                                                                  ?revers
                                                                  :Colors.red,
                                                            ),),
                                                          ],
                                                        ),
                                                        onTap: (){
                                                          admin.contains(currentUser.uid)
                                                              ? dialogRemoveItem(context, product.name.toString(), prchsmodel)
                                                              : _dutiesList.contains( widget.from == "payable"? "PAYABLE" :"PURCHASE") || _dutiesList.contains("PAYABLE")
                                                              ?dialogRemoveItem(context,  product.name.toString(), prchsmodel)
                                                              :dialogRequest(context, "Delete", widget.from == "payable"? "PAYABLE" :"PURCHASE");
                                                        },
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              prchsmodel.checked.toString().contains("DELETE")
                                                                  ? Icons.restore
                                                                  :Icons.edit,
                                                              color: admin.contains(currentUser.uid)
                                                                  ? revers
                                                                  : _dutiesList.contains( widget.from == "payable"? "PAYABLE" :"PURCHASE")
                                                                  ? revers
                                                                  : Colors.red,
                                                            ),
                                                            SizedBox(width: 5,),
                                                            Text(
                                                              prchsmodel.checked.toString().contains("DELETE")
                                                                  ?"Restore"
                                                                  :'Edit', style: TextStyle(
                                                              color: admin.contains(currentUser.uid)
                                                                  ? revers
                                                                  : _dutiesList.contains( widget.from == "payable"? "PAYABLE" :"PURCHASE")
                                                                  ? revers
                                                                  : Colors.red,
                                                            ),
                                                            ),
                                                          ],
                                                        ),
                                                        onTap: (){
                                                          prchsmodel.checked.toString().contains("DELETE")
                                                              ?_restore(prchsmodel)
                                                              :admin.contains(currentUser.uid)
                                                              ? dialogEditItem(context, qnty, prchsmodel, product)
                                                              : _dutiesList.contains( widget.from == "payable"? "PAYABLE" :"PURCHASE") || _dutiesList.contains("PAYABLE")
                                                              ?dialogEditItem(context, qnty, prchsmodel, product)
                                                              :dialogRequest(context, "Edit", widget.from == "payable"? "PAYABLE" :"PURCHASE");

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
                                                              ),
                                )
                                : SizedBox(width: 450,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index){
                                    ProductModel product = filteredList[index];
                                    var prchsmodel = _purchase.isEmpty? PurchaseModel(purchaseid: "") : _purchase.firstWhere((element) => element.productid == product.prid);
                                    var qnty =  int.parse(prchsmodel.quantity.toString());
                                    var _filtSupplr = _spplr.where((sup) => sup.sid == product.supplier).toList();
                                    var suppName = _filtSupplr.isEmpty ? SupplierModel(sid: "", name: "") : _filtSupplr.firstWhere((sup) => sup.sid == product.supplier);
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
                                                  prchsmodel.checked == "false"
                                                      ?Icon(Icons.cloud_upload, color: Colors.red,)
                                                      :prchsmodel.checked.toString().contains("DELETE") || prchsmodel.checked.toString().contains("REMOVED")
                                                      ?Icon(CupertinoIcons.delete, color: Colors.red,)
                                                      :prchsmodel.checked.toString().contains("EDIT")
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
                                                            "BP: Ksh.${formatNumberWithCommas(double.parse(prchsmodel.bprice.toString()))} SP: Ksh.${formatNumberWithCommas(double.parse(product.selling.toString()))}",
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
                                        index == filteredList.length - 1 && selectedID != prchsmodel.prcid && filteredList.length != 0
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
                                                          ? dialogRemoveItem(context, product.name.toString(), prchsmodel)
                                                          : _dutiesList.contains( widget.from == "payable"? "PAYABLE" :"PURCHASE") || _dutiesList.contains("PAYABLE")
                                                          ?dialogRemoveItem(context,  product.name.toString(), prchsmodel)
                                                          :dialogRequest(context, "Delete", widget.from == "payable"? "PAYABLE" :"PURCHASE");
                                                    },
                                                    icon: Icon(
                                                      CupertinoIcons.delete,
                                                      color: admin.contains(currentUser.uid)
                                                          ? Colors.black
                                                          : _dutiesList.contains( widget.from == "payable"? "PAYABLE" :"PURCHASE")
                                                          ? Colors.black
                                                          : Colors.red,
                                                    ),
                                                    actionColor: admin.contains(currentUser.uid)
                                                        ? Colors.black
                                                        : _dutiesList.contains( widget.from == "payable"? "PAYABLE" :"PURCHASE")
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
                                                      prchsmodel.checked.toString().contains("DELETE")
                                                          ?_restore(prchsmodel)
                                                          :admin.contains(currentUser.uid)
                                                          ? dialogEditItem(context, qnty, prchsmodel, product)
                                                          : _dutiesList.contains( widget.from == "payable"? "PAYABLE" :"PURCHASE") || _dutiesList.contains("PAYABLE")
                                                          ?dialogEditItem(context, qnty, prchsmodel, product)
                                                          :dialogRequest(context, "Edit", widget.from == "payable"? "PAYABLE" :"PURCHASE");
                                                    },
                                                    icon: Icon(
                                                      prchsmodel.checked.toString().contains("DELETE")?Icons.restore:Icons.edit,
                                                      color: admin.contains(currentUser.uid)
                                                          ? Colors.black
                                                          : _dutiesList.contains( widget.from == "payable"? "PAYABLE" :"PURCHASE")
                                                          ? Colors.black
                                                          : Colors.red,
                                                    ),
                                                    actionColor: admin.contains(currentUser.uid)
                                                        ? Colors.black
                                                        : _dutiesList.contains( widget.from == "payable"? "PAYABLE" :"PURCHASE")
                                                        ? Colors.black
                                                        : Colors.red,
                                                    title: prchsmodel.checked.toString().contains("DELETE")
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
          )
      ),
      floatingActionButton: payable != 0
          ? FloatingActionButton.large(
        onPressed: (){
          dialogAddPayment(context);
        },
        backgroundColor: revers,
        elevation: 11,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total', style: TextStyle(color: normal)),
            Text(NumberFormat.compact().format( payable), style: TextStyle(color: normal, fontWeight: FontWeight.bold)),
            Text('Pay', style: TextStyle(color: normal),),
          ],
        ),
      )
          : SizedBox(),
    );
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
                DialogTitle(title: 'P A Y A B L E'),
                SizedBox(height: 5,),
                Text(
                  'Enter the complete payment for this particular purchase',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                SizedBox(height: 5,),
                DialogPayPrchItem(
                  amount: payable,
                  updatePayable: _updatePayable,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogRequest(BuildContext, String action, String account){
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
                DialogTitle(title: 'R E Q U E S T'),
                DialogRequest(action: action, account: account, entity: widget.entity,),
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogUser(BuildContext context, String name, String email, String phone, String puchase, String due){
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
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
                purchaseModel.purchaser == currentUser.uid
                    ? CurrentImage(radius: 40,)
                    :UserProfile(image: user.image.toString(), radius: 40,),
                SizedBox(height: 10,),
                Text(name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
                email==""?SizedBox() : Text(email),
                Text(phone),
                Text("PURCHASER", style: TextStyle(color: secondaryColor, fontSize: 11),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Purchase date : ${DateFormat.yMMMd().format(DateTime.parse(puchase))}', style: TextStyle(color: secondaryColor, fontSize: 10),),
                      widget.from=='payable'? Text('    Due date : ${DateFormat.yMMMd().format(DateTime.parse(due))}', style: TextStyle(color: secondaryColor, fontSize: 10),) : SizedBox(),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(
                      thickness: 0.2,
                      color: reverse,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                              child: InkWell(
                                onTap: (){
                                  Navigator.pop(context);
                                  Platform.isIOS || Platform.isAndroid
                                      ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: user), transition: Transition.rightToLeft)
                                      : Get.to(() => WebChat(selected: user), transition: Transition.rightToLeft);
                                  },
                                child: SizedBox(height: 40,
                                  child: Center(
                                    child: Text(
                                      'Message',
                                      style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w700, fontSize: 15),
                                      textAlign: TextAlign.center,),
                                  ),
                                ),
                              )
                          ),
                          Platform.isIOS || Platform.isAndroid? VerticalDivider(
                            thickness: 0.2,
                            color: reverse,
                          ) : SizedBox(),
                          Platform.isIOS || Platform.isAndroid? Expanded(
                              child: InkWell(
                                onTap: (){
                                  Navigator.pop(context);
                                  if(user.phone.toString().isEmpty){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(Data().noPhone),
                                        showCloseIcon: true,
                                      )
                                    );

                                  } else {
                                    _callNumber(user.phone.toString());
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
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogEditItem(BuildContext context, int quantity, PurchaseModel prchsModel, ProductModel product){
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
                DialogEditPrchQnty(
                  quantity: quantity,
                  purchase: prchsModel,
                  updateQuantity: _updateQuantity, from: 'ITEMS',

                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogRemoveItem(BuildContext context, String name,  PurchaseModel prchmodel){
    final style = TextStyle(fontSize: 13, color: secondaryColor);
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
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
                              text: "${name} ",
                              style: TextStyle(color: normal),
                          ),
                          TextSpan(
                            text: "from your Purchases list? Please note that once this purchases is removed, all records associated with it will be permanently deleted.",
                            style: style,
                          ),
                        ]
                    )
                ),
                DoubleCallAction(
                  action: (){
                    _updateRemoved(prchmodel);
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

  _getDetails()async{
    _getData();
    _user = await Services().getCrntUsr(purchaseModel.purchaser.toString());
    _newPrch = await Services().getMyPurchase(currentUser.uid);
    _newPrds = await Services().getMyPrdct(currentUser.uid);
    _newduties = await Services().getMyDuties(currentUser.uid);
    await Data().addOrUpdateDutyList(_newduties);
    await Data().addOrUpdateProductsList(_newPrds);
    await Data().addOrUpdateUserList(_user);
    await Data().addOrUpdatePurchaseList(_newPrch).then((value){
      print("V $value");
      setState(() {
        _loading = value;
      });
    });
    _getData();
  }
  _getData(){
    _purchase = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _products = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _spplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    _purchase = _purchase.where((element) => element.purchaseid == widget.purchaseId).toList();
    _spplr = _spplr.where((element) => element.eid == widget.entity.eid).toList();
    _duties = _duties.where((element) => element.eid == widget.entity.eid && element.pid == currentUser.uid).toList();
    _dutiesList = _duties.isEmpty? "" : _duties.first.duties.toString();
    purchaseModel = _purchase.first;
    user = purchaseModel.purchaser == currentUser.uid? currentUser : myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).firstWhere((element) => element.uid == purchaseModel.purchaser,
        orElse: () => UserModel(uid: "", image: "", username: "N/A", email: "", phone: ""));
    _products = _products.where((prd) => _purchase.any((prch) => prd.prid == prch.productid) && prd.eid == widget.entity.eid).toList();
    _products = _products.where((element) {
      bool matchesEid = element.eid == widget.entity.eid;
      bool matchesCategory = category.isEmpty || element.category == category;
      bool matchesVolume = volume.isEmpty || element.volume == volume;
      bool matchesSupplier = supplierId.isEmpty || element.supplier == supplierId;

      return matchesEid && matchesCategory && matchesVolume && matchesSupplier;
    }).toList();
    admin = widget.entity.admin.toString().split(",");
    totalQuantities = _purchase.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
    totalAmount = _purchase.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
    totalPaid = double.parse(_purchase.first.paid.toString());
    payable = totalAmount - totalPaid;
    // changedAmount = totalPaid;
    newAmount = totalAmount;
    setState(() {

    });
  }

  _update(){
    _getData();
    widget.getPurchase();
  }
  _reload(){
    totalQuantities = _purchase.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
    totalAmount = _purchase.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
    totalPaid = double.parse(_purchase.first.paid.toString());
    payable = totalAmount - totalPaid;
    changedAmount = totalPaid;
    newAmount = totalAmount;
    setState(() {

    });
  }
  _upload()async{
    setState(() {
      _loading = true;
    });
    List<String> uniquePurchase = [];
    List<PurchaseModel> _purchases = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchases = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();

    for (var purchase in _purchase) {
      await Services.addPurchase(purchase).then((response) async {
        if (response == "Success") {
          await Services.updateInvAddQnty(purchase.productid.toString(), purchase.quantity.toString());
          _purchases.firstWhere((element) => element.prcid == purchase.prcid).checked = "true";
          widget.getPurchase();
        }
      });
    }
    uniquePurchase  = _purchases.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypurchases', uniquePurchase);
    myPurchases = uniquePurchase;
    _getData();
    widget.getPurchase();
    setState(() {
      _loading = false;
    });
  }
  void _filter(String? cat, String? vol, String? sid, String entityEid){
    supplierId = sid==null?"":sid;
    category = cat==null?"":cat;
    volume = vol==null?"":vol;
    _getData();
  }

  _updateQuantity(PurchaseModel purchase, String quantity){
    PurchaseModel updatingPrch = _purchase.firstWhere((element) => element.prcid == purchase.prcid);
    int diffQ =  int.parse(quantity.toString()) - int.parse(purchase.quantity.toString());
    double amount = double.parse(updatingPrch.bprice.toString()) * diffQ;
    double finalAmount = double.parse(updatingPrch.amount.toString()) + amount;

    _purchase.firstWhere((element) => element.prcid == purchase.prcid).quantity = quantity;
    _purchase.where((element) => element.purchaseid == purchase.purchaseid).forEach((action) => action.amount = finalAmount.toString());
    _purchase.firstWhere((element) => element.prcid == purchase.prcid).checked = updatingPrch.checked.toString().contains("EDIT")? updatingPrch.checked : "${updatingPrch.checked}, EDIT";
    changedAmount = _purchase.where((element) => !element.checked.toString().contains("DELETE")).fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
    payable =  changedAmount - totalPaid;
    _purchase.forEach((element){
      element.amount = changedAmount.toString();
    });
    setState(() {});
  }
  _updateRemoved(PurchaseModel purchase){
    PurchaseModel updatingPrch = _purchase.firstWhere((element) => element.prcid == purchase.prcid);
    if(!purchase.checked.toString().contains("DELETE")){
      double amount = double.parse(updatingPrch.bprice.toString()) * double.parse(updatingPrch.quantity.toString());
      double finalAmount = double.parse(updatingPrch.amount.toString()) - amount;
      _purchase.where((element) => element.purchaseid == purchase.purchaseid).forEach((action) => action.amount = finalAmount.toString());
      _purchase.firstWhere((element) => element.prcid == purchase.prcid).checked = updatingPrch.checked.toString().contains("DELETE")? updatingPrch.checked : "${updatingPrch.checked}, DELETE";
    }
    changedAmount = _purchase.where((element) => !element.checked.toString().contains("DELETE")).fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
    payable =  changedAmount - totalPaid;
    _purchase.forEach((element){
      element.amount = changedAmount.toString();
    });
    Navigator.pop(context);
    setState(() {});
  }
  _restore(PurchaseModel purchase)async{
    PurchaseModel updatingPrch = _purchase.firstWhere((element) => element.prcid == purchase.prcid);
    _purchase.firstWhere((element) => element.prcid == purchase.prcid).checked = updatingPrch.checked.toString().replaceAll(", DELETE", "");
    changedAmount = _purchase.where((element) => !element.checked.toString().contains("DELETE")).fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
    payable =  changedAmount - totalPaid;
    _purchase.forEach((element){
      element.amount = changedAmount.toString();
    });
    setState(() {});
  }
  _updatePayable(double paid, String method)async{
    List<String> uniquePurchase = [];
    List<String> uniquePayments = [];
    List<PurchaseModel> _purchases = [];
    List<PaymentModel> _payments = [];
    Uuid uuid = Uuid();
    String payid = uuid.v1();

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchases = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _payments = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();

    double newPaid = (double.parse(purchaseModel.paid.toString()) + paid);

    _purchase.forEach((element) async {
      _purchases.firstWhere((test) => test.prcid == element.prcid).paid = (double.parse(element.paid.toString()) + paid).toString();
      _purchases.firstWhere((test) => test.prcid == element.prcid).checked = element.checked.toString().contains("EDIT")
          ?element.checked
          : "${element.checked}, EDIT" ;
    });

    PaymentModel payment = PaymentModel(
        payid: payid,
        eid: widget.entity.eid,
        pid: widget.entity.pid,
        payerid: currentUser.uid,
        admin: widget.entity.admin,
        saleid: "",
        purchaseid: purchaseModel.purchaseid,
        items: _products.length.toString(),
        amount: payable.toString(),
        paid: paid.toString(),
        type: "PAYABLE",
        method: method,
        checked: "false",
        time: DateTime.now().toString()
    );

    _payments.add(payment);

    uniquePurchase  = _purchases.map((model) => jsonEncode(model.toJson())).toList();
    uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypurchases', uniquePurchase);
    sharedPreferences.setStringList('mypayments', uniquePayments );
    myPurchases = uniquePurchase;
    myPayments = uniquePayments;
    _getData();
    widget.getPurchase();
    await Services.updatePrchPaid(widget.purchaseId, newPaid.toString()).then((value){
      if(value=="success"){
        _purchases.where((element) => element.purchaseid == widget.purchaseId).forEach((purchase){
          purchase.checked = "true";
        });
        uniquePurchase  = _purchases.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mypurchases', uniquePurchase);
        myPurchases = uniquePurchase;
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
    widget.getPurchase();
  }

  _updateChecked(String check, String productid)async{
    _purchase.firstWhere((element) => element.productid == productid).checked = check;
    await Data().addOrUpdatePurchaseList(_purchase);
    widget.getPurchase();
    _reload();
  }
  checkRemoved(String newRemoved, String productid)async{
    _purchase.removeWhere((element) => element.productid ==productid);
    _products.removeWhere((element) => element.prid == productid);
    _reload();
    double newfAmount = 0.0;
    newfAmount = _purchase.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
    newAmount = newfAmount;
    widget.getPurchase();
    setState(() {
      // removed = newRemoved;
    });
  }
  _changeMess(MessModel mess){}
  _updateCount(){}
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
  _callNumber(String number) async{

  }
}
