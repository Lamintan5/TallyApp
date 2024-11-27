import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/dialogs/dialog_edit_prch_qnty.dart';
import 'package:TallyApp/Widget/dialogs/dialog_edit_prchses.dart';
import 'package:TallyApp/Widget/dialogs/filters/dialog_filter_purchases.dart';
import 'package:TallyApp/views/products_tabs/purchase_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/buttons/bottom_call_buttons.dart';
import '../../Widget/buttons/card_button.dart';
import '../../Widget/dialogs/call_actions/double_call_action.dart';
import '../../Widget/dialogs/dialog_request.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/empty_data.dart';
import '../../Widget/text_filed_input.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/duties.dart';
import '../../models/entities.dart';
import '../../models/inventories.dart';
import '../../models/purchases.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';
import '../create/create_purchase.dart';

class PurchaseTab extends StatefulWidget {
  final EntityModel entity;
  const PurchaseTab({super.key, required this.entity});

  @override
  State<PurchaseTab> createState() => _PurchaseTabState();
}

class _PurchaseTabState extends State<PurchaseTab> {
  TextEditingController _search = TextEditingController();
  List<String> title = ['Total Amount' , 'Total Purchases', 'Total Units'];
  bool _loading = false;
  bool close = true;
  List<PurchaseModel> _purchase = [];
  List<PurchaseModel> _allpurchase = [];
  List<PurchaseModel> _newPurchase = [];
  List<PurchaseModel> _filtPrch = [];
  List<InventModel> _newInvetory = [];
  final ScrollController _horizontal = ScrollController();
  double totalAmount = 0;
  int totalItems = 0;
  int removed = 0;
  List<String> admin = [];
  String selectedID = "";
  List<DutiesModel> _duties = [];
  List<DutiesModel> _newduties = [];
  String _dutiesList = "";
  late Set<PurchaseModel> uniquePurchase;
  List<PurchaseModel> uniquePurchaseList = [];
  final formKey = GlobalKey<FormState>();
  bool _layout = true;

  double amount = 0;
  String method = "";
  String pDate = "";
  String dDate = "";
  String pUid = "";

  _getDetails()async{
    _getData();
    await Data().checkAndUploadPurchases(_allpurchase, (){}).then((value){});
    _newPurchase = await Services().getMyPurchase(currentUser.uid);
    _newInvetory = await Services().getMyInv(currentUser.uid);
    _newduties = await Services().getMyDuties(currentUser.uid);
    await Data().addOrUpdateDutyList(_newduties);
    await Data().addOrUpdatePurchaseList(_newPurchase);
    await Data().addOrUpdateInvList(_newInvetory).then((value){
      _loading = value;
    });
    _getData();
  }

  _getData(){
    admin = widget.entity.admin.toString().split(",");
    _allpurchase = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _allpurchase = _allpurchase.where((element) => element.eid == widget.entity.eid
        && double.parse(element.amount.toString()) == double.parse(element.paid.toString())).toList();
    _purchase = myPurchases
        .map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString)))
        .where((test) {
      // Check if current user is not an admin, then filter by purchaser UID
      bool purchaserFilter = !admin.contains(currentUser.uid) ? test.purchaser.toString() == currentUser.uid : true;
      // If amount is not 0, filter by paid amount
      bool amountFilter = amount != 0 ? double.parse(test.paid!) == amount : true;
      // If method is not empty, filter by method type
      bool methodFilter = method.isNotEmpty ? test.type == method : true;
      // If date is not empty, filter by the date
      bool dateFilter = pDate.isNotEmpty ? DateTime.parse(test.date.toString()).year == DateTime.parse(pDate.toString()).year
      && DateTime.parse(test.date.toString()).month == DateTime.parse(pDate.toString()).month
      && DateTime.parse(test.date.toString()).day == DateTime.parse(pDate.toString()).day  : true;

      bool pUidFilter = pUid.isNotEmpty ? test.purchaser == pUid : true;
      // Return true if all conditions are met
      return purchaserFilter && amountFilter && methodFilter && dateFilter  && pUidFilter;
    }).toList();

    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    _purchase = _purchase.where((element) => element.eid == widget.entity.eid
        && double.parse(element.amount.toString()) == double.parse(element.paid.toString())).toList();
    _duties = _duties.where((element) => element.eid == widget.entity.eid && element.pid == currentUser.uid).toList();
    _dutiesList = _duties.isEmpty? "" : _duties.first.duties.toString();
    totalAmount = _purchase.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
    totalItems = _purchase.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
    uniquePurchase = _purchase.toSet();
    uniquePurchaseList = uniquePurchase.toList();
    removed = _purchase.where((element) => element.checked == "REMOVED").length;
    close = removed > 0 ?false: true;
    setState(() {
    });
  }

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
    return Expanded(
        child: SingleChildScrollView(
          primary: Platform.isAndroid || Platform.isIOS? true :  false,
          physics: BouncingScrollPhysics(),
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
                            index == 0
                                ? 'Ksh.${formatNumberWithCommas(totalAmount)}'
                                : index==1
                                ? uniquePurchaseList.length.toString()
                                :totalItems.toString(), style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),)
                        ],
                      ),
                    );
                  }
              ),
              Row(
                children: [
                  _loading
                      ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                      : SizedBox(),
                  Expanded(child: SizedBox()),
                  CardButton(
                    text: 'Add',
                    backcolor: Colors.white,
                    icon: Icon(
                      Icons.add,
                      color: admin.contains(currentUser.uid)
                          ? screenBackgroundColor
                          : _dutiesList.contains("PURCHASE")
                          ?screenBackgroundColor
                          :Colors.red,
                      size: 19,
                    ),
                    forecolor: admin.contains(currentUser.uid)
                        ? screenBackgroundColor
                        : _dutiesList.contains("PURCHASE")
                        ?screenBackgroundColor
                        :Colors.red,
                    onTap: () {
                      admin.contains(currentUser.uid)
                          ? Get.to(()=>CreatePurchase(entity: widget.entity, getPurchase: _getData,),transition: Transition.rightToLeft)
                          : _dutiesList.contains("PURCHASE")
                          ?Get.to(()=>CreatePurchase(entity: widget.entity, getPurchase: _getData),transition: Transition.rightToLeft)
                          :dialogRequest(context, "Add");
                    },),
                  _allpurchase.isEmpty
                      ?SizedBox()
                      :CardButton(
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
                    text: _purchase.any((test) => test.checked.toString().contains("false")
                        || test.checked.toString().contains("EDIT")
                        || test.checked.toString().contains("DELETE")
                    ) ? 'Upload' : 'Reload',
                    backcolor: _purchase.any((test) => test.checked.toString().contains("false")
                        || test.checked.toString().contains("EDIT")
                        || test.checked.toString().contains("DELETE")
                    ) ? Colors.red
                        :screenBackgroundColor,
                    icon: Icon(CupertinoIcons.refresh,
                      size: 16,
                      color: Colors.white,),
                    forecolor: Colors.white,
                    onTap: () {
                      setState(() {
                        _loading = true;
                      });
                          amount = 0.0;
                          method = "";
                          pDate = "";
                          dDate = "";
                          pUid = "";
                          _purchase.any((test) => test.checked.toString().contains("false")
                              || test.checked.toString().contains("EDIT")
                              || test.checked.toString().contains("DELETE")
                          ) ? _checkData()
                          :_getDetails();
                    },),
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
                                        text: removed > 1? "purchase items have " : "purchase item has ",
                                        style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                    ),
                                    TextSpan(
                                        text: "been removed from our server by one of the managers. This change may impact your data. Would you like to update your list to reflect these changes? ",
                                        style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                    ),
                                    WidgetSpan(
                                        child: InkWell(
                                            onTap: (){
                                              _removeAll();
                                            },
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
                  : SizedBox(),
              _allpurchase.isEmpty
                  ?SizedBox()
                  :Padding(
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
                      child: Text('Purchases', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500 , color: Colors.black),),
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
              _allpurchase.isEmpty
                  ? EmptyData(
                      onTap: (){
                        admin.contains(currentUser.uid)
                            ? Get.to(()=>CreatePurchase(entity: widget.entity, getPurchase: _getData,),transition: Transition.rightToLeft)
                            : _dutiesList.contains("PURCHASE")
                            ?Get.to(()=>CreatePurchase(entity: widget.entity, getPurchase: _getData),transition: Transition.rightToLeft)
                            :dialogRequest(context, "Add");
                      },
                      highlightColor: admin.contains(currentUser.uid)
                          ? Colors.white
                          : _dutiesList.contains("PURCHASE")
                          ?Colors.white
                          :Colors.red,
                      title: 'purchases'
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
                    child:  _layout
                        ? Scrollbar(
                        thumbVisibility: true,
                        controller: _horizontal,
                          child: SingleChildScrollView(
                            controller: _horizontal,
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                            showBottomBorder: true,
                            headingRowHeight: 30,
                            headingRowColor: WidgetStateColor.resolveWith((states) {
                              return screenBackgroundColor;
                            }),
                            columns: [
                              DataColumn(
                                  label: Text("PID", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                  tooltip: "This is the Purchase ID",
                              ),
                              DataColumn(
                                  label: Text("Items", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                  tooltip: "This is the total number of items"),
                              DataColumn(
                                  label: Text("Units", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                  tooltip: "This is the total number of units"),
                              DataColumn(
                                  label: Text("Amount", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                  tooltip: "This is total amount for all items"),
                              DataColumn(
                                  label: Text("Method", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                  tooltip: "This is the payment method"),

                              DataColumn(
                                  label: Text("Purchase Date", style: TextStyle(color: Colors.white),),
                                  numeric: false,
                                  tooltip: "This is the date when purchase was made"),
                              DataColumn(
                                label: Text("Action", style: TextStyle(color: Colors.white),),
                                numeric: false,
                              ),
                            ],
                            rows: uniquePurchaseList.asMap().entries.map((entry){
                              int index = entry.key + 1;
                              PurchaseModel purchase = entry.value;
                              _filtPrch = _purchase.where((element) => element.purchaseid == purchase.purchaseid).toList();
                              double qnty = _filtPrch.isEmpty ? 0.0 : _filtPrch.fold(0.0, (previousValue, element) => previousValue + double.parse(element.quantity.toString()));
                              double amount = _filtPrch.fold(0, (sum, item) => sum + (double.parse(item.bprice.toString()) * double.parse(item.quantity.toString())));
                              var items = _filtPrch.isEmpty == 0? 0 : _filtPrch.length;
                              return  DataRow(
                                  cells: [
                                    DataCell(
                                        Center(child: Text('P${index.toString().padLeft(3, '0')}' , style: TextStyle(color: Colors.black),)),
                                        onTap: (){
                                          items==0? null :
                                          Get.to(()=>PurchaseItems(
                                            index: index,
                                            purchaseId: purchase.purchaseid,
                                            entity: widget.entity,
                                            pid: purchase.pid.toString(),
                                            from: 'purchase', getPurchase: _getData,

                                          ), transition: Transition.rightToLeft
                                          );
                                        }
                                    ),
                                    DataCell(
                                        Center(
                                          child: Text('${(items).toInt()}', style: TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        onTap: (){

                                        }
                                    ),
                                    DataCell(
                                        Center(child: Text(qnty.toStringAsFixed(0), style: TextStyle(color: Colors.black))),
                                        onTap: (){

                                        }
                                    ),
                                    DataCell(
                                        Text('Ksh.${formatNumberWithCommas(amount)}', style: TextStyle(color: Colors.black)),
                                        onTap: (){

                                        }
                                    ),
                                    DataCell(
                                        Text(purchase.type.toString().toUpperCase(), style: TextStyle(color: Colors.black)),
                                        onTap: (){

                                        }
                                    ),
                                    DataCell(
                                        Center(
                                          child: Text(
                                              DateFormat.yMMMd().format(DateTime.parse(purchase.date.toString())), style: TextStyle(color: Colors.black)
                                          ),
                                        ),
                                        onTap: (){

                                        }
                                    ),
                                    DataCell(
                                      Center(
                                          child: PopupMenuButton<String>(
                                            tooltip: 'Show options',
                                            child: _purchase.where((element) => element.purchaseid == purchase.purchaseid).toList().any((element) => element.checked == 'false')
                                                ? Icon(Icons.cloud_upload, color: Colors.red,)
                                                : _purchase.where((element) => element.purchaseid == purchase.purchaseid).toList().any((element) => element.checked.toString().contains("REMOVED") || element.checked.toString().contains("DELETE"))
                                                ? Icon(CupertinoIcons.delete, color: Colors.red,)
                                                : _purchase.where((element) => element.purchaseid == purchase.purchaseid).toList().any((element) => element.checked.toString().contains("EDIT"))
                                                ? Icon(Icons.edit, color: Colors.red,)
                                                : Icon(Icons.more_vert, color: screenBackgroundColor,),
                                            onSelected: (value) {
                                            },
                                            itemBuilder: (BuildContext context) {
                                              return [
                                                if(_purchase.where((element) => element.purchaseid == purchase.purchaseid).toList().any((element) => element.checked == 'false'
                                                    || element.checked == "false, EDIT"
                                                    || element.checked.toString().contains("REMOVED")))
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
                                                      admin.contains(currentUser.uid)
                                                          ? _upload(purchase.purchaseid)
                                                          : !_dutiesList.contains("PURCHASE")
                                                          ? dialogRequest(context, "Upload")
                                                          : _upload(purchase.purchaseid);

                                                    },
                                                  ),
                                                PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(CupertinoIcons.delete, color: admin.contains(currentUser.uid)
                                                          ? reverse
                                                          : _dutiesList.contains("PURCHASE")
                                                          ?reverse
                                                          :Colors.red,),
                                                      SizedBox(width: 5,),
                                                      Text('Delete',style: TextStyle(
                                                        color: admin.contains(currentUser.uid)
                                                            ? reverse
                                                            : _dutiesList.contains("PURCHASE")
                                                            ?reverse
                                                            :Colors.red,
                                                      ),),
                                                    ],
                                                  ),
                                                  onTap: (){
                                                    admin.contains(currentUser.uid)
                                                        ? dialogDelete(context, purchase)
                                                        : !_dutiesList.contains("PURCHASE")
                                                        ? dialogRequest(context, "Remove")
                                                        : dialogDelete(context, purchase);

                                                  },
                                                ),
                                                PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        _purchase.where((element) => element.purchaseid == purchase.purchaseid).toList().any((element) => element.checked.toString().contains("DELETE"))
                                                            ? Icons.restore
                                                            :Icons.edit,
                                                        color: admin.contains(currentUser.uid)
                                                            ? reverse
                                                            : _dutiesList.contains("PURCHASE")
                                                            ? reverse
                                                            : Colors.red,
                                                      ),
                                                      SizedBox(width: 5,),
                                                      Text(
                                                        _purchase.where((element) => element.purchaseid == purchase.purchaseid).toList().any((element) => element.checked.toString().contains("DELETE"))
                                                            ?"Restore"
                                                            :'Edit', style: TextStyle(
                                                        color: admin.contains(currentUser.uid)
                                                            ? reverse
                                                            : _dutiesList.contains("PURCHASE")
                                                            ? reverse
                                                            : Colors.red,),
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: (){
                                                    admin.contains(currentUser.uid)
                                                        ? purchase.checked.toString().contains("DELETE")
                                                        ? _restore(purchase.purchaseid)
                                                        : dialogEdit(context, purchase)

                                                        : purchase.checked.toString().contains("DELETE")
                                                        ? !_dutiesList.contains("PURCHASE")? dialogRequest(context, "Edit") :  _restore(purchase.purchaseid)
                                                        : !_dutiesList.contains("PURCHASE")? dialogRequest(context, "Edit") : dialogEdit(context, purchase);
                                                  },
                                                ),
                                              ];
                                            },
                                          )
                                      ),
                                    ),
                                  ]
                              );
                            }).toList()
                                                ),
                                              ),
                        )
                        : SizedBox(
                      width: 450,
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: uniquePurchaseList.length,
                          itemBuilder: (context, index){
                            int snapshot = index + 1;
                            PurchaseModel purchase = uniquePurchaseList[index];
                            _filtPrch = _purchase.where((element) => element.purchaseid == purchase.purchaseid).toList();
                            int qnty = _filtPrch.isEmpty ? 0 : _filtPrch.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
                            double amount = _filtPrch.fold(0, (sum, item) => sum + (double.parse(item.bprice.toString()) * double.parse(item.quantity.toString())));
                            var items = _filtPrch.isEmpty == 0? 0 : _filtPrch.length;

                            var bold = TextStyle(fontWeight: FontWeight.w500, color: Colors.black);
                            var style = TextStyle(color: Colors.black, fontSize: 12);

                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: (){
                                      setState(() {
                                        if(selectedID!=purchase.purchaseid){
                                          selectedID = purchase.purchaseid;
                                        } else {
                                          selectedID = "";
                                        }
                                      });
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.black12,
                                          child: Center(
                                            child:
                                            purchase.checked == "false"
                                                ?Icon(Icons.cloud_upload, color: Colors.red,)
                                                :purchase.checked.toString().contains("DELETE") || purchase.checked.toString().contains("REMOVED")
                                                ?Icon(CupertinoIcons.delete, color: Colors.red,)
                                                :purchase.checked.toString().contains("EDIT")
                                                ?Icon(Icons.edit_rounded, color: Colors.red)
                                                :LineIcon.boxes(color: Colors.black,),
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                        'P${snapshot.toString().padLeft(3, '0')}',
                                                        style: bold
                                                    ),
                                                    Text(
                                                        'Ksh.${formatNumberWithCommas(amount)}',
                                                        style: bold
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    RichText(
                                                        text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                  text: 'Items : ',
                                                                  style: style
                                                              ),
                                                              TextSpan(
                                                                  text: '${items} ',
                                                                  style: style
                                                              ),
                                                              TextSpan(
                                                                  text: 'Units : ',
                                                                  style: style
                                                              ),
                                                              TextSpan(
                                                                  text: '${qnty} ',
                                                                  style: style
                                                              ),
                                                            ]
                                                        )
                                                    ),
                                                    Text(
                                                        purchase.type.toString().toUpperCase(),
                                                        style: style
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                    'Purchase Date : ${DateFormat.yMMMd().format(DateTime.parse(purchase.date.toString()))}',
                                                    style: style
                                                ),
                                              ],
                                            )
                                        ),
                                      ],
                                    ),
                                  ),
                                  index == uniquePurchaseList.length - 1 && selectedID != purchase.purchaseid && uniquePurchaseList.length != 0
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
                                    child: selectedID == purchase.purchaseid
                                        ? IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          purchase.checked == "false" || purchase.checked == "false, EDIT"|| purchase.checked.toString().contains("REMOVED")
                                              ? BottomCallButtons(
                                              onTap: (){
                                                admin.contains(currentUser.uid)
                                                    ? _upload(purchase.purchaseid)
                                                    : !_dutiesList.contains("PURCHASE")
                                                    ? dialogRequest(context, "Upload")
                                                    : _upload(purchase.purchaseid);
                                              },
                                              icon: Icon(Icons.cloud_upload, color: Colors.black,),
                                              actionColor: Colors.black,
                                              backColor: Colors.red.withOpacity(0.9),
                                              title: "Upload"
                                          ) : SizedBox(),
                                          purchase.checked == "false" || purchase.checked == "false, EDIT" || purchase.checked.toString().contains("REMOVED")
                                              ?VerticalDivider(
                                            thickness: 0.5,
                                            width: 15,color: Colors.black12,
                                          ) : SizedBox(),
                                          BottomCallButtons(
                                              onTap: (){
                                                admin.contains(currentUser.uid)
                                                    ? dialogDelete(context, purchase)
                                                    : !_dutiesList.contains("PURCHASE")
                                                    ? dialogRequest(context, "Remove")
                                                    : dialogDelete(context, purchase);
                                              },
                                              icon: Icon(CupertinoIcons.delete, color: admin.contains(currentUser.uid)
                                                  ? Colors.black
                                                  : _dutiesList.contains("PURCHASE")
                                                  ?Colors.black
                                                  :Colors.red,),
                                              actionColor: admin.contains(currentUser.uid)
                                                  ? Colors.black
                                                  : _dutiesList.contains("PURCHASE")
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
                                                    ? purchase.checked.toString().contains("DELETE")
                                                    ? _restore(purchase.purchaseid)
                                                    : dialogEdit(context, purchase)

                                                    : purchase.checked.toString().contains("DELETE")
                                                    ? !_dutiesList.contains("PURCHASE")? dialogRequest(context, "Edit") :  _restore(purchase.purchaseid)
                                                    : !_dutiesList.contains("PURCHASE")? dialogRequest(context, "Edit") : dialogEdit(context, purchase);
                                              },
                                              icon: Icon(
                                                purchase.checked.toString().contains("DELETE")?Icons.restore:Icons.edit,
                                                color: admin.contains(currentUser.uid)
                                                    ? Colors.black
                                                    : _dutiesList.contains("PURCHASE")
                                                    ?Colors.black
                                                    :Colors.red,),
                                              actionColor: admin.contains(currentUser.uid)
                                                  ? Colors.black
                                                  : _dutiesList.contains("PURCHASE")
                                                  ?Colors.black
                                                  :Colors.red,
                                              title: purchase.checked.toString().contains("DELETE")
                                                  ? 'Restore'
                                                  :"Edit"
                                          ),
                                          VerticalDivider(
                                            thickness: 0.5,
                                            width: 15,color: Colors.black12,
                                          ),
                                          BottomCallButtons(
                                              onTap: (){
                                                items==0? null :
                                                Get.to(()=>PurchaseItems(
                                                  index: index,
                                                  purchaseId: purchase.purchaseid,
                                                  entity: widget.entity,
                                                  pid: purchase.pid.toString(),
                                                  from: 'purchase', getPurchase: _getData,

                                                ), transition: Transition.rightToLeft
                                                );
                                              },
                                              icon: Icon(
                                                CupertinoIcons.list_bullet_below_rectangle,
                                                color: Colors.black,),
                                              actionColor: Colors.black,
                                              title: "View"
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
                    ),
                  ),
                ),
              ),
               
            ],
          ),
        )
    );
  }
  void dialogDelete(BuildContext context, PurchaseModel purchase){
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
                    'Are you sure you want to proceed with this action? Please note that once this purchases is removed, all records associated with it will be permanently deleted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryColor, fontSize: 12),
                  ),
                  DoubleCallAction(
                    action: ()async{
                      Navigator.pop(context);
                      setState(() {
                        _loading = true;
                      });
                      await Data().removePurchases(purchase.purchaseid, _getData, context).then((value){
                        setState(() {
                          _loading = value;
                        });
                      });
                    },
                    title: "Delete", titleColor: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
  void dialogEdit(BuildContext context, PurchaseModel purchase){
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: SizedBox(width: 450,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DialogTitle(title: 'E D I T'),
                    Text(
                      'Enter new details in the fields below to make the necessary changes',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondaryColor, fontSize: 12),
                    ),
                    SizedBox(height:5),
                    DialogEditPrchses(purchase: purchase, getData: _getDetails, from: 'PURCHASES',),
                  ],
                ),
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
                DialogRequest(action: action, account: 'PURCHASE', entity: widget.entity,),
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
            width: 450,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'F I L T E R'),
                DialogFilterPurchases(entity: widget.entity, filter: _filter, from: "PURCHASES")

              ],
            ),
          ),
        )
    );
  }

  _restore(String purchaseid)async{
    List<String> uniquePurchase = [];
    List<String> uniqueInv = [];
    List<PurchaseModel> _purchase = [];
    List<InventModel> _inventory = [];
    int quantity = 0;
    int invQuantity = 0;
    int newQuantity = 0;
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchase = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();

    _purchase.where((element) => element.purchaseid == purchaseid).forEach((purchase){
      print("resotre : PurchaseId : ${purchase.purchaseid}, PRCID : ${purchase.prcid}");
      purchase.checked = purchase.checked.toString().replaceAll(", DELETE", "");
      quantity = int.parse(purchase.quantity.toString());
      invQuantity = int.parse(_inventory.firstWhere((element) => element.productid == purchase.productid).quantity.toString());
      newQuantity = invQuantity + quantity;
      _inventory.firstWhere((test) => test.productid == purchase.productid).quantity = newQuantity < 0? "0" : newQuantity.toString();
    });

    uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
    uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypurchases', uniquePurchase);
    sharedPreferences.setStringList('myinventory', uniqueInv);
    myPurchases = uniquePurchase;
    myInventory = uniqueInv;
    _getData();
  }
  _upload(String purchaseid)async{
    setState(() {
      _loading = true;
    });

    List<String> uniquePurchase = [];
    List<PurchaseModel> _purchases = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchases = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();

    _purchase.where((test) => test.purchaseid == purchaseid).forEach((element) async {
      int quantity = int.parse(element.quantity!);
      await Services.addPurchase(element).then((response)async{
        if(response=="Success"){
          await Services.updateInvAddQnty(element.productid.toString(), quantity.toString());
          element.checked = 'true';
          _purchases.firstWhere((prch)=>prch.prcid==element.prcid).checked="true";
          uniquePurchase  = _purchases.map((model) => jsonEncode(model.toJson())).toList();
          sharedPreferences.setStringList('mypurchases', uniquePurchase);
          myPurchases = uniquePurchase;
          _getData();
      } if(response=="Exists"){
          element.checked = 'true';
          _purchases.firstWhere((prch)=>prch.prcid==element.prcid).checked="true";
          uniquePurchase  = _purchases.map((model) => jsonEncode(model.toJson())).toList();
          sharedPreferences.setStringList('mypurchases', uniquePurchase);
          myPurchases = uniquePurchase;
          _getData();
        }
      });
    });
    setState(() {
      _loading = false;
    });


  }
  _checkData()async{
    setState(() {
      _loading = true;
    });
    await Data().checkAndUploadPurchases(_purchase, _getData).then((value){
      setState(() {
        _loading = value;
      });
    });
  }
  _removeAll()async{
    List<String> uniquePurchase = [];
    List<String> uniqueInv = [];
    List<PurchaseModel> _purchases = [];

    List<PurchaseModel> purchasesToRemove = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchases = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();

    _purchase.where((test)=>test.checked.toString().contains("REMOVED") && test.eid == widget.entity.eid).forEach((purchase){
      purchasesToRemove.add(purchase);
    });

    for (var purchase in purchasesToRemove) {
      _purchases.removeWhere((element) => element.prcid == purchase.prcid);
    }

    uniquePurchase  = _purchases.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypurchases', uniquePurchase);
    myPurchases = uniquePurchase;
    _getData();
  }
  _filter(double amnt, String mthd, String pDte, String dDte, String purchaserUid){
    amount = amnt;
    method = mthd;
    pDate = pDte.toString();
    dDate = dDte.toString();
    pUid = purchaserUid;
    _getData();

  }

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
