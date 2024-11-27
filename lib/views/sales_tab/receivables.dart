import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:TallyApp/views/sales_tab/sale_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/buttons/bottom_call_buttons.dart';
import '../../Widget/buttons/card_button.dart';
import '../../Widget/dialogs/call_actions/dialog_edit_sales.dart';
import '../../Widget/dialogs/dialog_receipt.dart';
import '../../Widget/dialogs/dialog_request.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/dialogs/filters/dialog_filter_sales.dart';
import '../../Widget/empty_data.dart';
import '../../main.dart';
import '../../models/duties.dart';
import '../../models/inventories.dart';
import '../../models/sales.dart';
import '../../utils/colors.dart';
import '../create/create_sales.dart';

class Receivables extends StatefulWidget {
  final EntityModel entity;
  const Receivables({super.key, required this.entity});

  @override
  State<Receivables> createState() => _ReceivablesState();
}

class _ReceivablesState extends State<Receivables> {
  List<String> title = ['Total Receivables', 'Amount Paid', 'Selling Price', 'Profit', 'Items', 'Units'];
  final ScrollController _horizontal = ScrollController();
  List<SaleModel> _newSale = [];
  List<SaleModel> _sale = [];
  List<SaleModel> _allsales = [];
  late Set<SaleModel> uniqueSales;
  List<SaleModel> uniqueSaleList = [];
  List<SaleModel> _filtSale = [];
  List<String> _dutiesList =[];
  List<DutiesModel> _duties =[];
  bool _loading = false;
  bool _layout = true;
  double totalBprice= 0;
  double totalSprice= 0;
  double totalPaid= 0;
  double totalReceive= 0;
  double totalProfit= 0;
  int totalItems= 0;
  int totalSales = 0;
  int totalQuantity = 0;
  List<String> admin = [];
  String selectedID = '';
  int removed = 0;
  bool close = true;

  double amount = 0;
  String method = "";
  String sDate = "";
  String dDate = "";
  String sellerid = "";
  String cName = "";
  String cPhone = "";

  _getDetails()async{
    _getData();
    await Data().checkAndUploadSales(_allsales, (){});
    _newSale = await Services().getMySale(currentUser.uid);
    await Data().addOrUpdateSalesList(_newSale).then((value){
      setState(() {
        _loading = false;
      });
    });
    _getData();
  }

  _getData(){
    admin = widget.entity.admin.toString().split(",");
    _allsales = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _allsales = _allsales.where((element) => element.eid == widget.entity.eid
        && double.parse(element.amount.toString()) != double.parse(element.paid.toString())).toList();

    _sale = mySales
        .map((jsonString) => SaleModel.fromJson(json.decode(jsonString)))
        .where((test) {
      bool eidFilter = widget.entity.eid.isNotEmpty ? test.eid == widget.entity.eid : true;
      bool adminFilter = !admin.contains(currentUser.uid) ? test.sellerid.toString() == currentUser.uid : true;
      bool amountFilter = amount != 0 ? double.parse(test.paid!) == amount : true;
      bool methodFilter = method.isNotEmpty ? test.method == method : true;
      bool customerFilter = cPhone.isNotEmpty && cName.isNotEmpty ? test.customer == cName && test.phone == cPhone : true;
      bool dateFilter = sDate.isNotEmpty
          ? DateTime.parse(test.date.toString()).year == DateTime.parse(sDate.toString()).year &&
          DateTime.parse(test.date.toString()).month == DateTime.parse(sDate.toString()).month &&
          DateTime.parse(test.date.toString()).day == DateTime.parse(sDate.toString()).day
          : true;
      bool dueDateFilter = dDate.isNotEmpty
          ? DateTime.parse(test.due.toString()).year == DateTime.parse(dDate.toString()).year &&
          DateTime.parse(test.due.toString()).month == DateTime.parse(dDate.toString()).month &&
          DateTime.parse(test.due.toString()).day == DateTime.parse(dDate.toString()).day
          : true;
      bool sUidFilter = sellerid.isNotEmpty ? test.sellerid == sellerid : true;

      bool amountPaidCondition = double.parse(test.amount.toString()) != double.parse(test.paid.toString());

      return adminFilter && amountFilter && methodFilter && dateFilter && dueDateFilter && sUidFilter && customerFilter && eidFilter && amountPaidCondition;
    }).toList();

    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    _duties = _duties.where((test) => test.eid == widget.entity.eid && test.pid == currentUser.uid).toList();
    uniqueSales = _sale.toSet();
    uniqueSaleList = uniqueSales.toList();
    totalSales = uniqueSaleList.length;
    totalBprice = _sale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
    totalSprice = _sale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
    totalPaid = uniqueSaleList.fold(0, (sum, item) => sum +  double.parse(item.paid.toString()));
    totalReceive = totalSprice-totalPaid;
    totalProfit = totalSprice - totalBprice;
    totalItems = _sale.length;
    totalQuantity = _sale.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
    removed = _sale.where((element) => element.checked == "REMOVED").length;
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
    final revers =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final normal =  Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
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
                          Text(title[index], style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black)),
                          Text(
                            index==0
                                ?'Ksh.${formatNumberWithCommas(totalReceive)}'
                                :index==1
                                ? 'Ksh.${formatNumberWithCommas(totalPaid)}'
                                : index==2
                                ? 'Ksh.${formatNumberWithCommas(totalSprice)}'
                                : index==3
                                ? 'Ksh.${formatNumberWithCommas(totalProfit)}'
                                : index==4
                                ? totalItems.toString()
                                : totalQuantity.toString(),
                            style: TextStyle(fontWeight: FontWeight.w600,color: index==0 && totalReceive <0? Colors.red : Colors.black)
                          )
                        ],
                      ),
                    );
                  }),
              Row(
                children: [
                  _loading? Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  ) : SizedBox(),
                  Expanded(child: SizedBox()),
                  _allsales.isEmpty
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
                    text: _sale.any((test) => test.checked.toString().contains("false")
                        || test.checked.toString().contains("EDIT")
                        || test.checked.toString().contains("DELETE")
                    ) ? 'Upload' : 'Reload',
                    backcolor: _sale.any((test) => test.checked.toString().contains("false")
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
                        amount = 0;
                        method = "";
                        sDate = "";
                        dDate = "";
                        sellerid = "";
                        cName = "";
                        cPhone = "";
                        _loading = true;
                      });
                      _sale.any((test) => test.checked.toString().contains("false")
                          || test.checked.toString().contains("EDIT")
                          || test.checked.toString().contains("DELETE")
                      )
                          ? _checkData()
                          :_getDetails();
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
                        SizedBox(width: 15),
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
                                        text: removed > 1? "sale items have " : "sale item has ",
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
                            child: Icon(Icons.close, size: 30,color: Colors.black)
                        )
                      ],
                    ),
                  ),
                ),
              )
                  : SizedBox(),
              _allsales.isEmpty
                  ? SizedBox()
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
                      child: Text('Debt Book', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500 , color: Colors.black),),
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
              _allsales.isEmpty
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
                  child: Padding  (
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _layout ? Scrollbar(
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
                                columns: const [
                                  DataColumn(
                                    label: Text("RID", style: TextStyle(color: Colors.white,)),
                                    tooltip: "Receivable ID"
                                  ),
                                  DataColumn(
                                    label: Text("Items", style: TextStyle(color: Colors.white),),
                                      tooltip: "This is the total number of items"
                                  ),
                                  DataColumn(
                                    label: Text("Units", style: TextStyle(color: Colors.white),),
                                      tooltip: "This is the total number of units"
                                  ),
                                  DataColumn(
                                    label: Text("Buy Price", style: TextStyle(color: Colors.white),),
                                  ),
                                  DataColumn(
                                    label: Text("Sell Price", style: TextStyle(color: Colors.white),),
                                  ),
                                  DataColumn(
                                      label: Text("P/L", style: TextStyle(color: Colors.white),),
                                      tooltip: 'Profit Or Loss'
                                  ),
                                  DataColumn(
                                    label: Text("Paid", style: TextStyle(color: Colors.white),),
                                      tooltip: "This is the total amount paid"
                                  ),
                                  DataColumn(
                                    label: Text("Receivable", style: TextStyle(color: Colors.white),),
                                      tooltip: "This is the total amount receivable"
                                  ),
                                  DataColumn(
                                    label: Text("Customer", style: TextStyle(color: Colors.white),),
                                      tooltip: "This is the customers full name"
                                  ),
                                  DataColumn(
                                    label: Text("Phone", style: TextStyle(color: Colors.white),),
                                      tooltip: "This is the customers phone number"
                                  ),
                                  DataColumn(
                                    label: Text("Method", style: TextStyle(color: Colors.white),),
                                      tooltip: "This is the payment method"
                                  ),
                                  DataColumn(
                                    label: Text("Sale Date", style: TextStyle(color: Colors.white),),
                                      tooltip: "This is the date when receivable was recorded"
                                  ),
                                  DataColumn(
                                    label: Text("Due Date", style: TextStyle(color: Colors.white),),
                                      tooltip: "This is the due date"
                                  ),
                                  DataColumn(
                                    label: Text("Status", style: TextStyle(color: Colors.white),),
                                  ),
                                  DataColumn(
                                    label: Text("Action", style: TextStyle(color: Colors.white),),
                                  ),
                                ],
                                rows: uniqueSaleList.asMap().entries.map((entry){
                                  int index = entry.key + 1;
                                  SaleModel sale = entry.value;
                                  _filtSale = _sale.where((element) => element.saleid == sale.saleid).toList();
                                  int qnty = _filtSale.isEmpty ? 0 : _filtSale.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
                                  double sprice = _filtSale.isEmpty ? 0.0 : _filtSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
                                  double bprice = _filtSale.isEmpty ? 0.0 : _filtSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
                                  double profit = sprice - bprice;
                                  double amount = _filtSale.fold(0, (sum, item) => sum + (double.parse(item.sprice.toString()) * double.parse(item.quantity.toString())));
                                  double paid = double.parse(sale.paid.toString());
                                  var items = _filtSale.isEmpty == 0? 0 : _filtSale.length;
                                  var receivable = sprice - double.parse(sale.paid.toString());
                                  var status = paid / amount;
                                  return  DataRow(
                                      cells: [
                                        DataCell(
                                            Center(child: Text('R${index.toString().padLeft(3, '0')}' , style: TextStyle(color: Colors.black),)),
                                            onTap: (){
                                              items == 0? null :
                                              Get.to(()=>SaleItems(
                                                index: index,
                                                saleId: sale.saleid,
                                                entity: widget.entity, from: 'RECEIVABLE', getData: _getData,
                                              ),transition: Transition.downToUp);
                                            }
                                        ),
                                        DataCell(
                                            Center(
                                              child: Text('${items}', style: TextStyle(color: Colors.black),
                                              ),
                                            ),
                                            onTap: (){

                                            }
                                        ),
                                        DataCell(
                                            Center(child: Text(qnty.toString(), style: TextStyle(color: Colors.black))),
                                            onTap: (){

                                            }
                                        ),
                                        DataCell(
                                            Text('Ksh.${formatNumberWithCommas(bprice)}', style: TextStyle(color: Colors.black)),
                                            onTap: (){

                                            }
                                        ),
                                        DataCell(
                                            Text('Ksh.${formatNumberWithCommas(sprice)}', style: TextStyle(color: Colors.black)),
                                            onTap: (){

                                            }
                                        ),
                                        DataCell(
                                            Text('Ksh.${formatNumberWithCommas(profit)}', style: TextStyle(color: Colors.black)),
                                            onTap: (){

                                            }
                                        ),
                                        DataCell(
                                            Text('Ksh.${formatNumberWithCommas(double.parse(sale.paid.toString()))}', style: TextStyle(color: Colors.black)),
                                            onTap: (){

                                            }
                                        ),
                                        DataCell(
                                            Text('Ksh.${formatNumberWithCommas(receivable)}', style: TextStyle(color: receivable < 0? Colors.red: Colors.black)),
                                            onTap: (){

                                            }
                                        ),
                                        DataCell(
                                            Text(
                                                sale.customer.toString(), style: TextStyle(color: Colors.black)
                                            ),
                                            onTap: (){

                                            }
                                        ),
                                        DataCell(
                                            Center(
                                              child: Text(
                                                  sale.phone.toString(), style: TextStyle(color: Colors.black)
                                              ),
                                            ),
                                            onTap: (){

                                            }
                                        ),
                                        DataCell(
                                            Text(
                                                sale.method.toString().toUpperCase(), style: TextStyle(color: Colors.black)
                                            ),
                                            onTap: (){

                                            }
                                        ),
                                        DataCell(
                                            Center(
                                              child: Text(
                                                  DateFormat.yMMMd().format(DateTime.parse(sale.date.toString())), style: TextStyle(color: Colors.black)
                                              ),
                                            ),
                                            onTap: (){

                                            }
                                        ),
                                        DataCell(
                                            Center(
                                              child: Text(
                                                  sale.due.toString() == ""? "" : DateFormat.yMMMd().format(DateTime.parse(sale.due.toString())), style: TextStyle(color: Colors.black)
                                              ),
                                            ),
                                            onTap: (){

                                            }
                                        ),
                                        DataCell(
                                          Container(
                                            width: 100,
                                            margin: EdgeInsets.symmetric(vertical: 5),
                                            child: LiquidLinearProgressIndicator(
                                              value: status,
                                              valueColor: AlwaysStoppedAnimation(DateTime.parse(sale.due.toString()).isBefore(justToday)
                                                  ?Colors.red
                                                  :CupertinoColors.activeBlue),
                                              backgroundColor: Colors.black12,
                                              borderColor: Colors.white,
                                              borderWidth: 0,
                                              borderRadius: 10.0,
                                              direction: Axis.horizontal,
                                              center: Text('${(status*100).toStringAsFixed(0)}%', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                              child: PopupMenuButton<String>(
                                                tooltip: 'Show options',
                                                child: sale.checked =="false"
                                                    ?Icon(Icons.cloud_upload, color: Colors.red,)
                                                    :sale.checked.toString().contains("DELETE")
                                                    ?Icon(CupertinoIcons.delete, color: Colors.red,)
                                                    :sale.checked.toString().contains("REMOVED")
                                                    ?Icon(CupertinoIcons.delete_solid, color: Colors.red,)
                                                    :sale.checked.toString().contains("EDIT")
                                                    ?Icon(Icons.edit, color: Colors.red,)
                                                    :Icon(Icons.more_vert, color: Colors.black,
                                                ),
                                                itemBuilder: (BuildContext context) {
                                                  return [
                                                    if(sale.checked == "false"
                                                        || sale.checked == "false, EDIT"
                                                        || sale.checked.toString().contains("REMOVED"))
                                                      PopupMenuItem(
                                                        value: 'upload',
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(Icons.cloud_upload,
                                                              color: admin.contains(currentUser.uid)
                                                                  ? revers
                                                                  : _dutiesList.contains("RECEIVABLE")
                                                                  ?revers
                                                                  :Colors.red,
                                                            ),
                                                            SizedBox(width: 5,),
                                                            Text('Upload',style: TextStyle(
                                                              color: admin.contains(currentUser.uid)
                                                                  ? revers
                                                                  : _dutiesList.contains("RECEIVABLE")
                                                                  ?revers
                                                                  :Colors.red,
                                                            ),),
                                                          ],
                                                        ),
                                                        onTap: (){
                                                          admin.contains(currentUser.uid)
                                                              ? _upload(sale.saleid)
                                                              : _dutiesList.contains("RECEIVABLE")
                                                              ? _upload(sale.saleid)
                                                              : dialogRequest(BuildContext, "Upload");
                                                        },
                                                      ),
                                                    PopupMenuItem(
                                                      value: 'delete',
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(CupertinoIcons.delete,
                                                            color: admin.contains(currentUser.uid)
                                                              ? revers
                                                              : _dutiesList.contains("RECEIVABLE")
                                                              ?revers
                                                              :Colors.red,
                                                          ),
                                                          SizedBox(width: 5,),
                                                          Text('Delete',style: TextStyle(
                                                            color: admin.contains(currentUser.uid)
                                                                ? revers
                                                                : _dutiesList.contains("RECEIVABLE")
                                                                ?revers
                                                                :revers,
                                                          ),),
                                                        ],
                                                      ),
                                                      onTap: (){
                                                        admin.contains(currentUser.uid) || _dutiesList.contains("RECEIVABLE")
                                                            ? dialogDelete(context, sale)
                                                            : dialogRequest(BuildContext, "Delete");
                                                      },
                                                    ),
                                                    PopupMenuItem(
                                                      value: 'edit',
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(sale.checked.toString().contains("DELETE")
                                                              ?Icons.restore
                                                              :Icons.edit, color: admin.contains(currentUser.uid)
                                                              ? revers
                                                              : _dutiesList.contains("RECEIVABLE")
                                                              ?revers
                                                              :Colors.red,
                                                          ),
                                                          SizedBox(width: 5,),
                                                          Text(sale.checked.toString().contains("DELETE")
                                                              ?"Restore"
                                                              :'Edit', style: TextStyle(
                                                            color: admin.contains(currentUser.uid)
                                                                ? revers
                                                                : _dutiesList.contains("RECEIVABLE")
                                                                ?revers
                                                                :Colors.red,
                                                          ),
                                                          ),
                                                        ],
                                                      ),
                                                      onTap: (){
                                                        admin.contains(currentUser.uid)
                                                            ?sale.checked.toString().contains("DELETE")
                                                            ?_restore(sale.saleid)
                                                            : dialogEdit(context, sale)

                                                            :sale.checked.toString().contains("DELETE")
                                                            ?_dutiesList.contains("RECEIVABLE") ? _restore(sale.saleid) : dialogRequest(BuildContext, "Restore")
                                                            :_dutiesList.contains("RECEIVABLE") ?  dialogEdit(context, sale) : dialogRequest(BuildContext, "Edit");

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
                            :SizedBox(
                          width: 450,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: uniqueSaleList.length,
                              itemBuilder: (context, index){
                                SaleModel sale = uniqueSaleList[index];
                                _filtSale = _sale.where((element) => element.saleid == sale.saleid).toList();
                                int qnty = _filtSale.isEmpty ? 0 : _filtSale.fold(0, (previousValue, element) => previousValue + int.parse(element.quantity.toString()));
                                double sprice = _filtSale.isEmpty ? 0.0 : _filtSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
                                double bprice = _filtSale.isEmpty ? 0.0 : _filtSale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
                                double profit = sprice - bprice;
                                var items = _filtSale.isEmpty == 0? 0 : _filtSale.length;
                                var bold = TextStyle(fontWeight: FontWeight.w500, color: Colors.black);
                                var style = TextStyle(color: Colors.black, fontSize: 12);
                                int snapshot = index + 1;
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            if(selectedID!=sale.saleid){
                                              selectedID = sale.saleid;
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
                                                sale.checked == "false"
                                                    ?Icon(Icons.cloud_upload, color: Colors.red,)
                                                    :sale.checked.toString().contains("REMOVED")
                                                    ?Icon(CupertinoIcons.delete_solid, color: Colors.red)
                                                    : sale.checked.toString().contains("DELETE")
                                                    ? Icon(CupertinoIcons.delete, color: Colors.red)
                                                    :sale.checked.toString().contains("EDIT")
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
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                            'S${snapshot.toString().padLeft(3, '0')}',
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
                                                            sale.method.toString().toUpperCase(),
                                                            style: style
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text('BP : Ksh.${formatNumberWithCommas(bprice)}, SP : Ksh.${formatNumberWithCommas(sprice)}',
                                                            style: bold,
                                                          ),
                                                        ),
                                                        Text(
                                                            'P/L : Ksh.${formatNumberWithCommas(profit)}',
                                                          style: bold,
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                            'Sale Date : ${DateFormat.yMMMd().format(DateTime.parse(sale.date.toString()))}',
                                                            style: style
                                                        ),
                                                        Text(
                                                            'Due Date : ${DateFormat.yMMMd().format(DateTime.parse(sale.due.toString()))}',
                                                            style: style
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                      index == uniqueSaleList.length - 1 && selectedID != sale.saleid && uniqueSaleList.length != 0
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
                                        child: selectedID == sale.saleid
                                            ? IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              sale.checked == "false" || sale.checked == "false, EDIT"|| sale.checked.toString().contains("REMOVED")
                                                  ? BottomCallButtons(
                                                  onTap: (){ admin.contains(currentUser.uid)
                                                      ? _upload(sale.saleid)
                                                      : _dutiesList.contains("RECEIVABLE")
                                                      ? _upload(sale.saleid)
                                                      : dialogRequest(BuildContext, "Upload");
                                                    },
                                                  icon: Icon(Icons.cloud_upload, color: Colors.black,),
                                                  actionColor: Colors.black,
                                                  backColor: Colors.red.withOpacity(0.9),
                                                  title: "Upload"
                                              )
                                                  : SizedBox(),
                                              sale.checked == "false" || sale.checked == "false, EDIT" || sale.checked.toString().contains("REMOVED")
                                                  ?VerticalDivider(
                                                thickness: 0.5,
                                                width: 15,color: Colors.black12,
                                              )
                                                  : SizedBox(),
                                              BottomCallButtons(
                                                  onTap: (){
                                                    admin.contains(currentUser.uid) || _dutiesList.contains("RECEIVABLE")
                                                        ? dialogDelete(context, sale)
                                                        : dialogRequest(BuildContext, "Delete");
                                                  },
                                                  icon: Icon(
                                                    CupertinoIcons.delete,
                                                    color: admin.contains(currentUser.uid)
                                                        ? Colors.black
                                                        : _dutiesList.contains("RECEIVABLE")
                                                        ?Colors.black
                                                        :Colors.red,
                                                  ),
                                                  actionColor: admin.contains(currentUser.uid)
                                                      ? Colors.black
                                                      : _dutiesList.contains("RECEIVABLE")
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
                                                        ?sale.checked.toString().contains("DELETE")
                                                        ?_restore(sale.saleid)
                                                        : dialogEdit(context, sale)

                                                        :sale.checked.toString().contains("DELETE")
                                                        ?_dutiesList.contains("RECEIVABLE") ? _restore(sale.saleid) : dialogRequest(BuildContext, "Restore")
                                                        :_dutiesList.contains("RECEIVABLE") ?  dialogEdit(context, sale) : dialogRequest(BuildContext, "Edit");
                                                  },
                                                  icon: Icon(
                                                    sale.checked.toString().contains("DELETE")?Icons.restore:Icons.edit,
                                                    color: admin.contains(currentUser.uid)
                                                        ? Colors.black
                                                        : _dutiesList.contains("RECEIVABLE")
                                                        ?Colors.black
                                                        :Colors.red,
                                                  ),
                                                  actionColor: admin.contains(currentUser.uid)
                                                      ? Colors.black
                                                      : _dutiesList.contains("RECEIVABLE")
                                                      ?Colors.black
                                                      :Colors.red,
                                                  title: sale.checked.toString().contains("DELETE")
                                                      ? 'Restore'
                                                      :"Edit"
                                              ),
                                              VerticalDivider(
                                                thickness: 0.5,
                                                width: 15,color: Colors.black12,
                                              ),
                                              BottomCallButtons(
                                                  onTap: (){
                                                    items == 0? null :
                                                    Get.to(()=>SaleItems(
                                                      index: snapshot,
                                                      saleId: sale.saleid,
                                                      entity: widget.entity, from: 'SALES', getData: _getData,
                                                    ),transition: Transition.downToUp);
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
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'R E Q U E S T'),
                DialogRequest(action: action, account: 'RECEIVABLE', entity: widget.entity,),
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogDelete(BuildContext context, SaleModel sale){
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTitle(title: 'D E L E T E'),
                  Text(
                    'Are you sure you want to proceed with this action? Please note that once this sale is removed, all records associated with it will be permanently deleted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryColor, fontSize: 12),
                  ),
                  DoubleCallAction(
                    action: ()async{
                      Navigator.pop(context);
                      setState(() {
                        _loading = true;
                      });
                      await Data().removeSales(sale.saleid, _getData, context).then((value){
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
  void dialogEdit(BuildContext context, SaleModel sale){
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
                  DialogEditSales(
                    sale: sale,
                    getData: _getData,
                    from: 'RECEIVABLES',
                  )
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
                DialogFilterSales(entity: widget.entity, filter: _filter, from: 'RECEIVABLES',)
              ],
            ),
          ),
        )
    );
  }
  _restore(String saleid)async{
    List<String> uniqueSale = [];
    List<String> uniqueInv = [];
    List<SaleModel> _sales = [];
    List<InventModel> _inventory = [];
    int quantity = 0;
    int invQuantity = 0;
    int newQuantity = 0;
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _sales = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();

    _sales.where((element) => element.saleid == saleid).forEach((sale){
      sale.checked = sale.checked.toString().replaceAll(", DELETE", "");
      quantity = int.parse(sale.quantity.toString());
      invQuantity = int.parse(_inventory.firstWhere((element) => element.productid == sale.productid).quantity.toString());
      newQuantity = invQuantity - quantity;
      _inventory.firstWhere((test) => test.productid == sale.productid).quantity = newQuantity < 0? "0" : newQuantity.toString();
    });

    uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
    uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mysales', uniqueSale);
    sharedPreferences.setStringList('myinventory', uniqueInv);
    mySales = uniqueSale;
    myInventory = uniqueInv;
    _getData();

  }
  _upload(String saleid)async{
    setState(() {
      _loading = true;
    });

    List<String> uniqueSale = [];
    List<SaleModel> _sales = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _sales = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();

    _sales.where((test) => test.saleid == saleid).forEach((element) async {
      int quantity = int.parse(element.quantity!);
      await Services.addSale(element).then((response)async{
        if(response=="Success"){
          await Services.updateInvSubQnty(element.productid.toString(), quantity.toString());
          element.checked = 'true';
          _sales.firstWhere((sle)=>sle.sid==element.sid).checked="true";
          uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
          sharedPreferences.setStringList('mysales', uniqueSale);
          mySales = uniqueSale;
          setState(() {
            _loading = false;
          });
          _getData();
        } if(response=="Exists"){
          element.checked = 'true';
          _sales.firstWhere((sle)=>sle.sid==element.sid).checked="true";
          uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
          sharedPreferences.setStringList('mysales', uniqueSale);
          mySales = uniqueSale;
          setState(() {
            _loading = false;
          });
          _getData();
        } else {
          setState(() {
            _loading = false;
          });
        }
      });
    });
  }
  _removeAll()async{
    List<String> uniqueSale = [];
    List<SaleModel> _sales = [];

    List<SaleModel> salesToRemove = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _sales = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();

    _sales.where((test)=>test.checked.toString().contains("REMOVED") && test.eid == widget.entity.eid
        && double.parse(test.amount.toString()) != double.parse(test.paid.toString())).forEach((sale){
      salesToRemove.add(sale);
    });

    for (var sale in salesToRemove) {
      _sales.removeWhere((element) => element.sid == sale.sid);
    }

    uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mysales', uniqueSale);
    mySales = uniqueSale;
    _getData();
  }
  _checkData()async{
    setState(() {
      _loading = true;
    });
    await Data().checkAndUploadSales(_sale, _getData).then((value){
      setState(() {
        _loading = value;
      });
    });
  }
  _filter(double amnt, String mth, String sDte, String dDte, String sid, String cNme, String cPne){
    amount = amnt;
    method = mth;
    sDate = sDte;
    dDate = dDte;
    sellerid = sid;
    cName = cNme;
    cPhone = cPne;
    _getData();
  }

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
