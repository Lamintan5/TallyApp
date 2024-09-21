import 'dart:convert';

import 'package:TallyApp/Widget/logos/prop_logo.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/purchases.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../models/inventories.dart';
import '../../../models/payments.dart';
import '../../../models/sales.dart';
import '../../../resources/services.dart';
import '../../../utils/colors.dart';
import '../../empty_data.dart';
import '../../text_filed_input.dart';
import '../call_actions/dialog_edit_sales.dart';
import '../call_actions/double_call_action.dart';
import '../dialog_method.dart';
import '../dialog_title.dart';
import 'dialog_edit_scan_prch.dart';
import 'dialog_edit_scan_sale.dart';

class UniqueEntity{
  UniqueEntity({
   required this.eid,
   this.isExpanded = false,
});
  String eid;
  bool isExpanded;
}

class DialogScanPay extends StatefulWidget {
  final List<SaleModel> sales;
  final List<PurchaseModel> purchases;
  final Function clear;
  const DialogScanPay({super.key, required this.sales, required this.purchases, required this.clear});

  @override
  State<DialogScanPay> createState() => _DialogScanPayState();
}

class _DialogScanPayState extends State<DialogScanPay> {

  List<SaleModel> sales = [];
  List<SaleModel> mySale = [];
  List<SaleModel> _filtNewSale = [];
  List<SaleModel> _filtSale = [];
  List<SaleModel> _newSale = [];
  List<PurchaseModel> purchases = [];
  List<String?> eidList = [];
  List<UniqueEntity?> uniqueEid = [];
  List<EntityModel> entity = [];
  late DateTime now;
  double total = 0;
  double totalPaid = 0;
  bool _loading = false;

  _getData(){
    entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    mySale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    sales = widget.sales;
    purchases = widget.purchases;
    eidList = sales.isNotEmpty
        ? sales.map((sale) => sale.eid.toString()).toSet().toList()
        : purchases.map((purchase) => purchase.eid.toString()).toSet().toList();
    uniqueEid = eidList.map((eid)=>UniqueEntity(eid: eid.toString())).toList();
    _filtNewSale = mySale.where((element) => element.customer != "" && element.phone != "").toList();
    total = sales.isEmpty
        ?purchases.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())))
        :sales.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
    if(sales.isEmpty){
      for(var eids in uniqueEid){
        var totalPrchAmount = purchases.where((test) => test.eid == eids!.eid).fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
        purchases.where((test) => test.eid == eids!.eid).forEach((action){
          action.amount = totalPrchAmount.toString();
          action.paid =action.paid=="0.0" ? totalPrchAmount.toString() : action.paid;
        });
      }
    } else {
      for(var eids in uniqueEid){
        var totalSaleAmount = sales.where((test) => test.eid == eids!.eid).fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
        sales.where((test) => test.eid == eids!.eid).forEach((action){
          action.amount = totalSaleAmount.toString();
          action.paid = action.paid=="0.0" ? totalSaleAmount.toString() : action.paid;
        });
      }
    }
    totalPaid=0;
    uniqueEid.forEach((element){
      totalPaid = totalPaid + (sales.isEmpty
          ? double.parse(purchases.firstWhere((test) => test.eid == element!.eid).paid.toString())
          : double.parse(sales.firstWhere((test) => test.eid == element!.eid).paid.toString()));
    });

    setState(() {
      for (var sale in _filtNewSale) {
        bool idExists = _newSale.any((element) => element.customer == sale.customer && element.phone == sale.phone);
        if (!idExists) {
         _newSale.add(sale);
        }
      }
    });
    Future.delayed(Duration(seconds: 1)).then((value){
      return  setState(() {
        uniqueEid.first?.isExpanded = true;
      });
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();  
    now = DateTime.now();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final style = TextStyle(color: secondaryColor, fontSize: 13);
    final bold = TextStyle(color: reverse, fontSize: 13, fontWeight: FontWeight.w600);
    final highlight = TextStyle(color: secBtn, fontSize: 13, fontWeight: FontWeight.w600);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("   Ksh.${formatNumberWithCommas(totalPaid)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ).animate().fade(duration: Duration(milliseconds: 500)).slideY(curve: Curves.easeInOut),
                  total-totalPaid == 0? SizedBox() : Text("    Ksh.${formatNumberWithCommas(total-totalPaid)}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.red),
                  ).animate().fade(duration: Duration(milliseconds: 500)).slideY(curve: Curves.easeInOut),
                ],
              ),
            ),
            TextButton(
                onPressed: (){dialogMethod(context);},
                child: RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(child: purchases.any((test)=> test.type == "") || sales.any((test)=> test.method == "") ? SizedBox() : Icon(CupertinoIcons.checkmark_alt, color: secBtn,size: 15,)),
                      TextSpan(
                          text: "Method",
                          style: highlight
                      ),
                    ]
                  ),
                )
            ),
            sales.isEmpty
                ? SizedBox(height: 40,)
                : TextButton(
                onPressed: (){dialogSelectCustomer(context);},
                child: RichText(
                  text: TextSpan(
                      children: [
                        WidgetSpan(child: sales.any((test)=> test.customer == "") ? SizedBox() : Icon(CupertinoIcons.checkmark_alt, color: secBtn,size: 15,)),
                        TextSpan(
                            text: "Customer",
                            style: highlight
                        ),
                      ]
                  ),
                )
            )
          ],
        ),
        Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: SingleChildScrollView(
                  child: ExpansionPanelList(
                    dividerColor: secondaryColor,
                    animationDuration: Duration(seconds: 1),
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        uniqueEid[index]!.isExpanded = !uniqueEid[index]!.isExpanded;
                      });
                    },
                    children: uniqueEid.map<ExpansionPanel>((UniqueEntity? item){
                      EntityModel enty = entity.isNotEmpty
                          ? entity.firstWhere((element) => element.eid == item!.eid, orElse: () => EntityModel(eid: "", title: "N/A"))
                          : EntityModel(eid: "", title: "N/A");
                      var amount = sales.isNotEmpty
                          ? sales.where((test) => test.eid==item!.eid).fold(0.0, (previous, element) => previous + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())))
                          : purchases.where((test) => test.eid==item!.eid).fold(0.0, (previous, element) => previous + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
                      var items = sales.isNotEmpty
                          ? sales.where((test) => test.eid==item!.eid).length
                          : purchases.where((test) => test.eid==item!.eid).length;
                      var saleModel = sales.isNotEmpty
                          ? sales.firstWhere((test) => test.eid==item!.eid,
                          orElse: () => SaleModel(saleid: '')) : SaleModel(saleid: '');
                      var prchModel = purchases.isNotEmpty? purchases.firstWhere((test) => test.eid==item!.eid, orElse: () => PurchaseModel(purchaseid: ""))
                          : PurchaseModel(purchaseid: "");

                      final style = TextStyle(fontSize: 13, color: reverse);
                      final bold = TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: reverse);

                      return ExpansionPanel(
                          backgroundColor: enty.eid ==""
                              ?  Colors.red.withOpacity(0.5)
                              : bgColor,
                          canTapOnHeader: true,
                          headerBuilder: (BuildContext context, bool isExpanded){
                            return ListTile(
                              leading: PropLogo(entity: enty, radius: 10,stroke: 1,),
                              title: Text(enty.title!.toUpperCase(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
                              trailing: isExpanded
                                  ? SizedBox() 
                                  : Text(sales.isEmpty
                                  ? "Ksh.${formatNumberWithCommas(double.parse(prchModel.paid.toString()))}"
                                  : "Ksh.${formatNumberWithCommas(double.parse(saleModel.paid.toString()))}",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ).animate().fade(duration: Duration(milliseconds: 500)).slideY(curve: Curves.easeInOut),
                            );
                          },
                          body: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText  (
                                    text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text: "Items Sold : ",
                                              style: style
                                          ),
                                          TextSpan(
                                              text: items.toString(),
                                              style: bold
                                          )
                                        ]
                                    )
                                ),
                                RichText(
                                    text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text: "Amount due : ",
                                              style: style
                                          ),
                                          TextSpan(
                                              text: "Ksh.${formatNumberWithCommas(amount)}",
                                              style: bold
                                          ),
                                        ]
                                    )
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "Amount Paid : ",
                                                style: style
                                              ),
                                              TextSpan(
                                                  text:sales.isEmpty
                                                      ? "Ksh.${formatNumberWithCommas(double.parse(prchModel.paid.toString()))}"
                                                      : "Ksh.${formatNumberWithCommas(double.parse(saleModel.paid.toString()))}",
                                                  style: bold
                                              ),
                                            ]
                                          )
                                      ),
                                    ),
                                    Text(sales.isEmpty
                                        ? prchModel.type.toString()
                                        : saleModel.method.toString(), style: bold),
                                  ],
                                ),
                                sales.isEmpty
                                    ? SizedBox()
                                    :Text("Customer Details", style: TextStyle(fontSize: 15),),
                                sales.isEmpty
                                    ? SizedBox()
                                    : RichText(
                                    text: TextSpan(
                                        children: [
                                          WidgetSpan(
                                              child: LineIcon.user(size: 13)
                                          ),
                                          TextSpan(
                                              text: saleModel.customer==""? " N/A, ":" ${saleModel.customer}, ",
                                              style: bold
                                          ),
                                          WidgetSpan(
                                              child: LineIcon.phone(size: 13)
                                          ),
                                          TextSpan(
                                              text: saleModel.phone==""? " N/A ":" ${saleModel.phone} ",
                                              style: bold
                                          ),
                                        ]
                                    )
                                ),
                                RichText(
                                    text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text: sales.isEmpty
                                                  ?"Purchase Date : "
                                                  :"Sale Date : ",
                                              style: style
                                          ),
                                          TextSpan(
                                              text: "${DateFormat.yMMMd().format(DateTime.parse(sales.isEmpty ?prchModel.date.toString() :saleModel.date.toString()))}, "
                                                  "${DateFormat.Hm().format(DateTime.parse(sales.isEmpty ?prchModel.date.toString() :saleModel.date.toString()))} ",
                                              style: bold
                                          ),
                                        ]
                                    )
                                ),
                                RichText(
                                    text: TextSpan(
                                      children: [
                                        amount == double.parse(sales.isEmpty?prchModel.paid.toString() : saleModel.paid.toString())
                                            || (amount== 0 || double.parse(sales.isEmpty?prchModel.paid.toString() :saleModel.paid.toString())== 0)
                                            ?WidgetSpan(child: SizedBox())
                                            :TextSpan(
                                            text: "Due Date : ",
                                            style: style
                                        ),
                                        amount == double.parse(sales.isEmpty ?prchModel.paid.toString() :saleModel.paid.toString())
                                            || (amount== 0 || double.parse(sales.isEmpty ?prchModel.paid.toString() :saleModel.paid.toString())== 0)
                                            ?WidgetSpan(child: SizedBox())
                                            :TextSpan(
                                            text: "${DateFormat.yMMMd().format(DateTime.parse(sales.isEmpty ? prchModel.due.toString() : saleModel.due.toString()))}",
                                            style: bold
                                        ),
                                      ]
                                    )
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: (){
                                          sales.isEmpty
                                              ? dialogEditPrch(context, prchModel, amount)
                                              : dialogEdit(context, saleModel, amount);
                                        },
                                        child: Text("Edit", style: TextStyle(color: secBtn, fontSize: 15),),

                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          isExpanded: item!.isExpanded
                      );
                    }).toList(),
                  )
              ),
            )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: InkWell(
            onTap: (){
              setState(() {
                _loading = true;
              });
              if(sales.isEmpty && purchases.any((test) => test.type == "" || test.type!.isEmpty)){
                Get.snackbar(
                    "Alert",
                    "Please enter the payment method for the transactions below",
                  maxWidth: 500,
                  icon: Icon(Icons.warning, color: Colors.red),
                  shouldIconPulse: true,
                  forwardAnimationCurve: Curves.easeInOut,
                  reverseAnimationCurve: Curves.easeOut,
                );
                setState(() {
                  _loading = false;
                });
              } else if(sales.isNotEmpty && sales.any((test) => test.method == "" || test.customer=="")){
                Get.snackbar(
                  "Alert",
                  "Please enter the payment method and customer details for the transactions below",
                  maxWidth: 500,
                  icon: Icon(Icons.warning, color: Colors.red),
                  shouldIconPulse: true,
                  forwardAnimationCurve: Curves.easeInOut,
                  reverseAnimationCurve: Curves.easeOut,
                );
                setState(() {
                  _loading = false;
                });
              } else {
                _pay();
              }
            },
            borderRadius: BorderRadius.circular(5),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 700),
              padding: EdgeInsets.symmetric(vertical: 15),
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: sales.isEmpty && purchases.any((test) => test.type == "" || test.type!.isEmpty) || sales.isNotEmpty && sales.any((test) => test.method == "" || test.customer=="")
                      ? secBtn.withOpacity(0.3)
                      : secBtn
              ),
              child: Center(child: _loading
                  ?SizedBox(width: 15,height: 15, child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,))
                  :Text("PAY", style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
          child: RichText(
            textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "You are now recording payments for ",
                    style: style
                  ),
                  TextSpan(
                    text: sales.isEmpty?"Purchases ":"Sales ",
                    style: bold
                  ),
                  TextSpan(
                      text: "from ",
                      style: style
                  ),
                  TextSpan(
                      text: uniqueEid.length == 1? "1 Entity" : "${uniqueEid.length} Entities ",
                      style: bold
                  ),
                  TextSpan(
                      text: "with a total amount due of ",
                      style: style
                  ),
                  TextSpan(
                      text: "Kshs.${formatNumberWithCommas(total)}",
                      style: bold
                  ),
                ]
              )
          ),
        )
      ],
    );
  }
  void dialogEditPrch(BuildContext context, PurchaseModel purchase, double amount){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: Container(
            width: 450,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTitle(title: 'E D I T'),
                  Text(
                    'Enter details in the fields below to make the necessary changes',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryColor, fontSize: 12),
                  ),
                  SizedBox(height:5),
                  DialogEditScanPrch(
                    purchase: purchase,
                    update: _updatePrchList, amount: amount,
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
  void dialogEdit(BuildContext context, SaleModel sale, double amount){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: Container(
            width: 450,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTitle(title: 'E D I T'),
                  Text(
                    'Enter details in the fields below to make the necessary changes',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryColor, fontSize: 12),
                  ),
                  SizedBox(height:5),
                  DialogEditScanSale(
                    sale: sale,
                    update: _updateSalesList, amount: amount,
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
  void dialogMethod(BuildContext context){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "M E T H O D"),
                Text(
                  "Please enter the payment method used for recording these transactions",
                  style: TextStyle(color: secondaryColor),
                  textAlign: TextAlign.center,
                ),
                DialogMethod(
                  update: _updateMethod
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  _updateSalesList(SaleModel saleModel, String amount, String paid, String method, String name, String phone, String date, String due){
    sales.where((test) => test.eid == saleModel.eid).forEach((element){
      element.amount=amount;
      element.paid=paid;
      element.method = method;
      element.customer =name;
      element.phone = phone;
      element.date=date;
      element.due=due;
    });
    totalPaid=0;
    uniqueEid.forEach((element){
      totalPaid = totalPaid+double.parse(sales.firstWhere((test) => test.eid == element!.eid).paid.toString());
    });
    setState(() {
    });
  }
  _updatePrchList(PurchaseModel purchase, String paid, String method, String date, String due){
    purchases.where((test) => test.eid == purchase.eid).forEach((element){
      element.paid=paid;
      element.type=method;
      element.date=date;
      element.due=due;
    });
    totalPaid=0;
    uniqueEid.forEach((element){
      totalPaid = totalPaid+double.parse(purchases.firstWhere((test) => test.eid == element!.eid).paid.toString());
    });
    setState(() {
    });
  }
  _updateMethod(String method){
    setState(() {
      if(sales.isEmpty){
        purchases.forEach((action){
          action.type = method;
        });
      } else {
        sales.forEach((action){
          action.method = method;
        });
      }
    });
    Navigator.pop(context);

  }
  _pay()async{
    if(sales.isEmpty){
      List<String> uniquePurchase = [];
      List<String> uniqueInv = [];
      List<String> uniquePayments = [];
      List<PurchaseModel> _purchases = [];
      List<PurchaseModel> removedPurchase = [];
      List<InventModel> _inventory = [];
      List<PaymentModel> _payments = [];

      Uuid uuid = Uuid();
      String payid = "";
      now = DateTime.now();
      int items = 0;

      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      _purchases = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
      _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
      _payments = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();

      purchases.forEach((element) async {
        var inv = _inventory.firstWhere((invento) => invento.productid == element.productid);

        int newQuantity = 0;
        int quantity = int.parse(element.quantity!);
        int oldQuantity = int.parse(inv.quantity!);
        newQuantity = quantity+oldQuantity;

        _inventory.firstWhere((invento) => invento.productid == element.productid).quantity = newQuantity.toString();
        _purchases.add(element);
        removedPurchase.add(element);
      });

      uniqueEid.forEach((action)async{
        EntityModel enty = entity.firstWhere((test) => test.eid == action!.eid);
        PurchaseModel prchModel = purchases.firstWhere((test) => test.eid == action!.eid);
        var noItems = purchases.where((test) => test.eid==action!.eid).length;
        payid = uuid.v5(enty.eid, now.toString());

        PaymentModel payment = PaymentModel(
            payid: payid,
            eid: enty.eid,
            pid: enty.pid,
            payerid: currentUser.uid,
            admin: enty.admin,
            saleid: "",
            purchaseid: prchModel.purchaseid,
            items: noItems.toString(),
            amount: prchModel.amount,
            paid: prchModel.paid,
            type: double.parse(prchModel.amount.toString()) != double.parse(prchModel.paid.toString())? "PAYABLE" : "PURCHASE",
            method: prchModel.type,
            checked: "false",
            time: DateTime.now().toString()
        );

        _payments.add(payment);
      });

      uniquePurchase  = _purchases.map((model) => jsonEncode(model.toJson())).toList();
      uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
      uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList('mypurchases', uniquePurchase);
      sharedPreferences.setStringList('myinventory', uniqueInv);
      sharedPreferences.setStringList('mypayments', uniquePayments );
      myPurchases = uniquePurchase;
      myInventory = uniqueInv;
      myPayments = uniquePayments;

      if(removedPurchase.length==purchases.length){
        setState(() {
         // _loading = false;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Purchases recorded Successfully"),
            showCloseIcon: true,
          )
        );
      }

      purchases.forEach((element) async {
        int quantity = int.parse(element.quantity!);
        await Services.addPurchase(element).then((response)async{
          if(response=="Success"){
            element.checked = 'true';
            await Services.updateInvAddQnty(element.productid.toString(), quantity.toString());
            uniquePurchase  = _purchases.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList('mypurchases', uniquePurchase);
            myPurchases = uniquePurchase;
          }
        });
      });

      uniqueEid.forEach((action)async{
        EntityModel enty = entity.firstWhere((test) => test.eid == action!.eid);
        PurchaseModel prchModel = purchases.firstWhere((test) => test.eid == action!.eid);
        var noItems = purchases.where((test) => test.eid==action!.eid).length;
        payid = uuid.v5(enty.eid, now.toString());

        PaymentModel payment = PaymentModel(
            payid: payid,
            eid: enty.eid,
            pid: enty.pid,
            payerid: currentUser.uid,
            admin: enty.admin,
            saleid: "",
            purchaseid: prchModel.purchaseid,
            items: noItems.toString(),
            amount: prchModel.amount,
            paid: prchModel.paid,
            type: double.parse(prchModel.amount.toString()) != double.parse(prchModel.paid.toString())? "PAYABLE" : "PURCHASE",
            method: prchModel.type,
            checked: "false",
            time: DateTime.now().toString()
        );

        await Services.addPayment(payment).then((response){
          print(response);
          if(response=="Success"){
            payment.checked = "true";
            _payments.firstWhere((test) => test.payid == payment.payid).checked = "true";
            uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList('mypayments', uniquePayments );
            myPayments = uniquePayments;
          }
        });
      });
      widget.clear();
    }
    else {
      List<String> uniqueSales= [];
      List<String> uniqueInv = [];
      List<String> uniquePayments = [];
      List<SaleModel> _sales = [];
      List<SaleModel> removedSales = [];
      List<InventModel> _inventory = [];
      List<PaymentModel> _payments = [];


      Uuid uuid = Uuid();
      String payid = "";
      now = DateTime.now();
      int items = 0;

      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      _sales = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
      _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
      _payments = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();

      sales.forEach((element) async {
        var inv = _inventory.firstWhere((invento) => invento.productid == element.productid);

        int newQuantity = 0;
        int quantity = int.parse(element.quantity!);
        int oldQuantity = int.parse(inv.quantity!);
        newQuantity = oldQuantity-quantity;

        if(newQuantity<0){
          newQuantity = 0;
        }

        _inventory.firstWhere((invento) => invento.productid == element.productid).quantity = newQuantity.toString();
        _sales.add(element);
        removedSales.add(element);
      });

      uniqueEid.forEach((action)async{
        EntityModel enty = entity.firstWhere((test) => test.eid == action!.eid);
        SaleModel saleModel = sales.firstWhere((test) => test.eid == action!.eid);
        var noItems = sales.where((test) => test.eid==action!.eid).length;

        payid = uuid.v5(enty.eid, now.toString());

        PaymentModel payment = PaymentModel(
            payid: payid,
            eid: enty.eid,
            pid: enty.pid,
            payerid: currentUser.uid,
            admin: enty.admin,
            saleid: saleModel.saleid,
            purchaseid: "",
            items: noItems.toString(),
            amount: saleModel.amount,
            paid: saleModel.paid,
            type: double.parse(saleModel.amount.toString()) != double.parse(saleModel.paid.toString())? "RECEIVABLE" : "SALE",
            method: saleModel.method,
            checked: "false",
            time: DateTime.now().toString()
        );
        _payments.add(payment);
      });

      uniqueSales = _sales.map((model) => jsonEncode(model.toJson())).toList();
      uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
      uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList('myinventory', uniqueInv);
      sharedPreferences.setStringList('mysales', uniqueSales);
      sharedPreferences.setStringList('mypayments', uniquePayments);
      myInventory = uniqueInv;
      mySales = uniqueSales;
      myPayments = uniquePayments;

      if(removedSales.length==sales.length){
        Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Sales recorded Successfully"),
            showCloseIcon: true,
          )
        );
      }

      sales.forEach((element) async {
        int quantity = int.parse(element.quantity.toString());
        await Services.addSale(element).then((response)async{
          if(response=="Success"){
            element.checked = 'true';
            await Services.updateInvSubQnty(element.productid.toString(), quantity.toString());
            uniqueSales = _sales.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList('mysales', uniqueSales);
            mySales = uniqueSales;
            // widget.getData();
          }
        });
      });

      uniqueEid.forEach((action)async{
        EntityModel enty = entity.firstWhere((test) => test.eid == action!.eid);
        SaleModel saleModel = sales.firstWhere((test) => test.eid == action!.eid);
        payid = uuid.v5(enty.eid, now.toString());
        var noItems = sales.where((test) => test.eid==action!.eid).length;

        PaymentModel payment = PaymentModel(
            payid: payid,
            eid: enty.eid,
            pid: enty.pid,
            payerid: currentUser.uid,
            admin: enty.admin,
            saleid: saleModel.saleid,
            purchaseid: "",
            items: noItems.toString(),
            amount: saleModel.amount,
            paid: saleModel.paid,
            type: double.parse(saleModel.amount.toString()) != double.parse(saleModel.paid.toString())? "RECEIVABLE" : "SALE",
            method: saleModel.method,
            checked: "false",
            time: DateTime.now().toString()
        );

        await Services.addPayment(payment).then((response){
          if(response=="Success"){
            payment.checked = "true";
            _payments.firstWhere((test) => test.payid == payment.payid).checked = "true";
            uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList('mypayments', uniquePayments );
            myPayments = uniquePayments;
          }
        });
      });

      widget.clear();
    }
  }

  void dialogSelectCustomer(BuildContext context) {
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
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
          return  SizedBox(width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                DialogTitle(title: 'C U S T O M E R'),
                Text('Please select a customer by clicking on any of the options below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                          dialogAddCustomer(context);
                        },
                        child: Text('New Customer',style: TextStyle(color: CupertinoColors.activeBlue)))
                  ],
                ),
                _newSale.isEmpty
                    ? EmptyData(
                    onTap: (){
                      Navigator.pop(context);
                      dialogAddCustomer(context);
                    },
                    baseColor: revers,
                    highlightColor:normal,
                    title: "customers"
                )
                    : Expanded(
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: _newSale.length,
                      itemBuilder: (context, index){
                        SaleModel customer = _newSale[index];
                        String custName = _newSale.isEmpty? "" : customer.customer.toString();
                        String custPhone = _newSale.isEmpty? "" : customer.phone.toString();
                        _filtSale = mySale.where((element) => element.customer.toString().trim() == customer.customer.toString().trim() && element.phone.toString().trim() == customer.phone.toString().trim()).toList();
                        List<SaleModel> salesList = _filtSale.isEmpty? [] :_filtSale;
                        var revenue = salesList.isEmpty? 0.0 : salesList.fold(0.0, (previousValue, element) => previousValue + double.parse(element.sprice.toString()) * double.parse(element.quantity.toString()));
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                sales.forEach((element){
                                  element.customer = custName;
                                  element.phone = custPhone;
                                });
                              });
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(5),
                            hoverColor: color1,
                            child: Container(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: color1,
                                    radius: 20,
                                    child: LineIcon.user(color: revers,),
                                  ),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(custName.toString()),
                                        Text(custPhone.toString())
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text("Ksh.${formatNumberWithCommas(revenue)}"),
                                      Text("Revenue", style: TextStyle(color: secondaryColor),),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          );
        });
  }
  void dialogAddCustomer(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    TextEditingController _name = TextEditingController();
    TextEditingController _phone = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTitle(title: "C U S T O M E R"),
                  Column(
                    children: [
                      Text(
                        'Please enter all the fields below and press continue to enter new customer details.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryColor, fontSize: 12),
                      ),
                      SizedBox(height: 5,),
                      TextFieldInput(
                        textEditingController: _name,
                        textInputType: TextInputType.text,
                        labelText: 'Customer Name',
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return 'Please Enter Customer Name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5,),
                      TextFieldInput(
                        textEditingController: _phone,
                        textInputType: TextInputType.phone,
                        labelText: 'Customer Phone Number',
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number.';
                          }
                          if (value.length < 8) {
                            return 'phone number must be at least 8 characters long.';
                          }
                          if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
                            return null; // Valid input (contains only digits)
                          } else {
                            return 'Please enter a valid phone number';
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 5,),
                  DoubleCallAction(action: (){
                    final isValidform = formKey.currentState!.validate();
                    if(isValidform){
                      setState(() {
                        sales.forEach((element){
                          element.customer = _name.text.trim();
                          element.phone = _phone.text.trim();
                        });
                      });
                      Navigator.pop(context);
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
