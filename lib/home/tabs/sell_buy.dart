import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/home/tabs/scanner.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../Widget/buttons/card_button.dart';
import '../../Widget/dialogs/call_actions/double_call_action.dart';
import '../../Widget/dialogs/dialog_edit_prch_qnty.dart';
import '../../Widget/dialogs/dialog_edit_sale_qnty.dart';
import '../../Widget/dialogs/dialog_method.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/dialogs/filters/dialog_filter_goods.dart';
import '../../Widget/dialogs/scan/dialog_edit_scan_prch.dart';
import '../../Widget/dialogs/scan/dialog_edit_scan_sale.dart';
import '../../Widget/dialogs/scan/dialog_scan_pay.dart';
import '../../Widget/empty_data.dart';
import '../../Widget/frosted_glass.dart';
import '../../Widget/logos/prop_logo.dart';
import '../../Widget/text_filed_input.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/duties.dart';
import '../../models/entities.dart';
import '../../models/inventories.dart';
import '../../models/payments.dart';
import '../../models/products.dart';
import '../../models/purchases.dart';
import '../../models/sales.dart';
import '../../models/suppliers.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';

class SellOrBuy extends StatefulWidget {
  const SellOrBuy({super.key});

  @override
  State<SellOrBuy> createState() => _SellOrBuyState();
}

class _SellOrBuyState extends State<SellOrBuy> {
  TextEditingController _search = TextEditingController();
  List<String> title = [ 'Items', 'Units','Amount Due'];

  List<ProductModel> _prd = [];
  List<ProductModel> _newPrd = [];
  List<ProductModel> _scannedPrds = [];
  List<SupplierModel> _spplr = [];
  List<SupplierModel> _newSpplr = [];
  List<DutiesModel> _duties = [];
  List<DutiesModel> _newDuties = [];

  List<PurchaseModel> _scndPrch = [];
  List<InventModel> _inv = [];
  List<InventModel> _newInv = [];
  List<EntityModel> _entity = [];
  List<EntityModel> _newEntity = [];
  List<UniqueEntity?> uniqueEid = [];

  List<SaleModel> _filtNewSale = [];
  List<SaleModel> _newSale = [];
  List<SaleModel> _scndSale = [];
  List<SaleModel> _filtSale = [];
  List<SaleModel> mySale = [];

  List<String?> eidList = [];


  bool account = true;
  bool _loading = false;
  bool close = false;
  bool _expanded = true;

  String saleId = "";
  String purchaseId = "";
  String category = "";
  String volume = "";
  String supplierId ="";
  String eid = "";

  late DateTime now;

  int snapshot = 0;
  int items = 0;
  int units = 0;

  double  amountDue = 0;
  double  totalPaid = 0;

  Uuid uuid = Uuid();

  late ScrollController _scrollcontroller;
  late GlobalKey<AnimatedListState> _key;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(myShowCases.contains("Sell/Buy")){
      close = true;
    }
    _scrollcontroller = ScrollController();
    _key = GlobalKey();
    _getDetails();
    now = DateTime.now();
    _expanded = Platform.isAndroid || Platform.isIOS? true : false;
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final reverse5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final style = TextStyle(color: secondaryColor, fontSize: 13);
    final bold = TextStyle(color: reverse, fontSize: 13, fontWeight: FontWeight.w600);
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      _prd.forEach((item) {
        if (item.name.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.category.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.supplier.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _prd;
    }
    final size = MediaQuery.of(context).size;
    final highlight = TextStyle(color: secBtn, fontSize: 13, fontWeight: FontWeight.w600);
    _expanded = size.width>=1500?false:true;
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sell/Purchase", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: reverse),),
                          Platform.isAndroid || Platform.isIOS
                              ?IconButton(
                              onPressed: (){
                                Get.to(() => Scanner(), transition: Transition.rightToLeft);
                              },
                              icon: Icon(CupertinoIcons.qrcode_viewfinder)) : SizedBox()
                        ],
                      ),
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
                                        ? items.toString()
                                        : index==1
                                        ? units.toString()
                                        : "Ksh.${formatNumberWithCommas(amountDue)}",
                                    style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),)
                                ],
                              ),
                            );
                          }),
                      _expanded
                          ? close ? SizedBox()
                          :  Padding(
                            padding: const EdgeInsets.only(top: 10.0, right: 5, left: 5),
                            child: RichText(
                              textAlign: TextAlign.center,
                            text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'To initiate a sale, choose the \'Sale\' option. For recording purchases, select \'Purchase.\' If you prefer to use a scanner for documenting sales or purchases, click the ',
                                    style: style,
                                  ),
                                  WidgetSpan(
                                    child: Icon(CupertinoIcons.qrcode_viewfinder, size: 13,),
                                  ),
                                  TextSpan(
                                    text: ' scanner icon ',
                                    style: bold,
                                  ),
                                  TextSpan(
                                    text: 'on the toolbar. ',
                                    style: style,
                                  ),
                                  WidgetSpan(
                                    child: InkWell(
                                        onTap: (){
                                          setState(() {
                                            close = true;
                                            Data().addOrRemoveShowCase("Sell/Buy","add");
                                          });
                                        },
                                        child: Text("Okay got it", style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.bold),)
                                    ),
                                  ),
                                ]
                            )
                            ),
                          )
                          : SizedBox(),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CardButton(
                              text: "Clear",
                              backcolor: Colors.white,
                              forecolor: Colors.black,
                              icon: Icon(Icons.clear_all, color: Colors.black, size: 19,),
                              onTap: _clear
                          ),
                          CardButton(
                              text: "Filter",
                              backcolor: Colors.white,
                              forecolor: Colors.black,
                              icon: Icon(Icons.filter_list_rounded, color: Colors.black, size: 19,),
                              onTap: (){dialogFilter(context);}
                          ),
                          CardButton(
                              text: "Reload",
                              backcolor: screenBackgroundColor,
                              forecolor: Colors.white,
                              icon: Icon(CupertinoIcons.refresh, color: Colors.white, size: 16,),
                              onTap: (){
                                _clear();
                                _getDetails();
                              }
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Center(
                        child: AnimatedToggleSwitch<bool>.size(
                          current: account,
                          values: const [true, false],
                          iconOpacity: 0.5,
                          height: 30,
                          indicatorSize: const Size.fromWidth(90),
                          customIconBuilder: (context, local, global) => Text(
                            local.value ? "Sell" : "Buy",
                            style: TextStyle(
                                color: Color.lerp(reverse, reverse, local.animationValue)
                            ),
                          ),
                          borderWidth: 1,
                          iconAnimationType: AnimationType.onHover,
                          style: ToggleStyle(
                            indicatorColor: CupertinoColors.systemGrey,
                            backgroundColor: color1,
                            borderColor: color2,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              const BoxShadow(
                                color: Colors.black26,
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 3)
                              )
                            ]
                          ),
                          selectedIconScale: 1,
                          onChanged: (value){
                            setState(() {
                              account = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 10,),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth: 500,
                                        minWidth: 300
                                    ),
                                    padding: EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                      color: color1,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: _search,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                          hintText: "Search for products...",
                                          hintStyle: TextStyle(color: secondaryColor),
                                          filled: false,
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(8),
                                          icon: Icon(Icons.search, color: secondaryColor,),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none
                                          )
                                      ),
                                      onChanged:  (value) => setState((){}),
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Expanded(
                                      child: SizedBox(width: 500,
                                        child: ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            itemCount: filteredList.length,
                                            itemBuilder: (context, index){
                                              ProductModel product = filteredList[index];
                                              var supplier = _spplr.firstWhere((sup) => sup.sid == product.supplier, orElse: ()=> SupplierModel(sid: "", name: "N/A"));
                                              var salemodel = _scndSale.any((test) => test.productid.toString().contains(product.prid.toString()))
                                                  ?_scndSale.firstWhere((element) => element.productid == product.prid, orElse: () => SaleModel(saleid: ""))
                                                  : SaleModel(saleid: '', quantity: "0", sprice: "0.0");
                                              var prchmodel = _scndPrch.any((test) => test.productid.toString().contains(product.prid.toString()))
                                                  ?_scndPrch.firstWhere((element) => element.productid == product.prid,
                                                  orElse: () => PurchaseModel(purchaseid: ""))
                                                  : PurchaseModel(purchaseid: '', quantity: "0", bprice: "0.0");
                                              //prdct.checked.toString().split(",").last
                                              var invmodel = _inv.any((test) => test.productid.toString().contains(product.prid.toString()))
                                                  ? _inv.firstWhere((element) => element.productid == product.prid,
                                                  orElse: () => InventModel(iid: "", quantity: "0"))
                                                  : InventModel(iid: "", quantity: "0");

                                              var entity = _entity.any((test) => test.eid.toString().contains(product.eid.toString()))
                                                  ?_entity.firstWhere((element) => element.eid == product.eid, orElse: () => EntityModel(eid: "", title: "N/A "))
                                                  : EntityModel(eid: "", title: "N/A");

                                              var highlight = product.checked.toString().split(",").last.contains("SALE")
                                                  ? int.parse(salemodel.quantity!) == 0 ? reverse : Colors.black
                                                  : int.parse(prchmodel.quantity!) == 0 ? reverse : Colors.black;
                                              final bold = TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: highlight);
                                              final small = TextStyle(fontSize: 11, color: highlight);
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                                child: InkWell(
                                                  onTap: (){
                                                    setState(() {
                                                      ProductModel newPrd = _prd.firstWhere((element) => element.prid == product.prid,
                                                          orElse: () => ProductModel(prid: ""));
                                                      InventModel invtmodel = _inv.firstWhere((element) => element.productid == product.prid,
                                                          orElse: () => InventModel(iid: "", quantity: "0"));
                                                      EntityModel enty = _entity.firstWhere((element) => element.eid ==newPrd.eid,
                                                          orElse: () => EntityModel(eid: ""));
                                                      var duties = _duties.firstWhere((test) => test.eid==enty.eid && test.pid == currentUser.uid, orElse: ()=> DutiesModel(did: ""));

                                                      if(account){
                                                        saleId = uuid.v5(enty.eid, now.toString());
                                                        snapshot = snapshot+1;
                                                        newPrd.checked =  newPrd.checked.toString().contains("SALE")? newPrd.checked
                                                            :  "${newPrd.checked.toString().split(",").first}, SALE";
                                                        SaleModel newSale = SaleModel(
                                                          saleid: saleId,
                                                          sid: saleId+snapshot.toString(),
                                                          iid: invtmodel.iid,
                                                          eid: newPrd.eid,
                                                          pid: newPrd.pid,
                                                          sellerid: currentUser.uid,
                                                          productid: product.prid,
                                                          customer: "",
                                                          phone: "",
                                                          bprice: newPrd.buying,
                                                          sprice: newPrd.selling,
                                                          amount: "0.0",
                                                          paid: '0.0',
                                                          method: '',
                                                          quantity: "1",
                                                          checked: 'false',
                                                          date: DateTime.now().toString(),
                                                          due: DateTime.now().toString(),
                                                          time: DateTime.now().toString(),
                                                        );
                                                        if(_scannedPrds.contains(product) ){
                                                          _scannedPrds.removeWhere((test) => test.prid == product.prid);
                                                          _scndSale.removeWhere((test) => test.productid == product.prid);
                                                        } else {
                                                          if(int.parse(invtmodel.quantity.toString()) < 1 || newPrd.checked.toString().contains("REMOVED") || enty.eid == ""){

                                                          }
                                                          else {
                                                            if(enty.admin.toString().split(",").contains(currentUser.uid)){
                                                              _scndSale.add(newSale);
                                                              _scannedPrds.add(newPrd);
                                                            } else {
                                                              if(duties.duties.toString().contains("SALE")){
                                                                _scndSale.add(newSale);
                                                                _scannedPrds.add(newPrd);
                                                              }
                                                            }

                                                          }
                                                        }

                                                      } else {
                                                        purchaseId = uuid.v5(enty.eid, now.toString());
                                                        snapshot = snapshot+1;
                                                        newPrd.checked = newPrd.checked.toString().contains("PURCHASE")
                                                            ? newPrd.checked : "${newPrd.checked.toString().split(",").first}, PURCHASE";
                                                        PurchaseModel newPrch =  PurchaseModel(
                                                          purchaseid: purchaseId,
                                                          amount: '0.0',
                                                          prcid: purchaseId+snapshot.toString(),
                                                          eid: newPrd.eid,
                                                          pid: newPrd.pid,
                                                          purchaser: currentUser.uid,
                                                          productid: product.prid,
                                                          quantity: "1",
                                                          bprice: newPrd.buying,
                                                          paid: '0.0',
                                                          type: '',
                                                          checked: 'false',
                                                          due: DateTime.now().toString(),
                                                          time: DateTime.now().toString(),
                                                          date: DateTime.now().toString(),
                                                        );
                                                        if(_scannedPrds.contains(product) ){
                                                          _scannedPrds.removeWhere((test) => test.prid == product.prid);
                                                          _scndPrch.removeWhere((test) => test.productid == product.prid);
                                                        } else {
                                                          if(newPrd.checked.toString().contains("REMOVED") || enty.eid == ""){

                                                          } else {
                                                            if(enty.admin.toString().split(",").contains(currentUser.uid)){
                                                              _scndPrch.add(newPrch);
                                                              _scannedPrds.add(newPrd);
                                                            } else {
                                                              if(duties.duties.toString().contains("PURCHASE")){
                                                                _scndPrch.add(newPrch);
                                                                _scannedPrds.add(newPrd);
                                                              }
                                                            }
                                                          }
                                                        }

                                                      }
                                                      _count();
                                                    });
                                                  },
                                                  borderRadius: BorderRadius.circular(5),
                                                  hoverColor: color1,
                                                  child: AnimatedContainer(
                                                    duration: Duration(milliseconds: 500),
                                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: product.checked.toString().split(",").last.contains("SALE")
                                                            ? int.parse(salemodel.quantity!) == 0 ? Colors.transparent : Colors.cyan
                                                            : int.parse(prchmodel.quantity!) == 0 ? Colors.transparent : Colors.cyan
                                                    ),
                                                    child:Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 20,
                                                          backgroundColor: color1,
                                                          child: Center(
                                                              child: LineIcon.box(color: highlight,)
                                                          ),
                                                        ),
                                                        SizedBox(width: 10,),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(product.name.toString() , style: TextStyle(color: highlight, fontWeight: FontWeight.w600),),
                                                                  SizedBox(width: 10,),
                                                                  Text(product.category.toString(), style: TextStyle(color: highlight, fontSize: 11),),
                                                                  Expanded(child: SizedBox()),
                                                                ],
                                                              ),
                                                              RichText(
                                                                  text:
                                                                  TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                            text: 'Entity : ',
                                                                            style: small
                                                                        ),
                                                                        TextSpan(
                                                                            text: '${entity.title}, ',
                                                                            style: bold
                                                                        ),
                                                                        TextSpan(
                                                                            text: 'Volume : ',
                                                                            style: small
                                                                        ),
                                                                        TextSpan(
                                                                            text: '${product.volume}, ',
                                                                            style: bold
                                                                        ),
                                                                      ]
                                                                  )
                                                              ),
                                                              Wrap(
                                                                spacing: 5, runSpacing: 5,
                                                                children: [
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                    decoration: BoxDecoration(
                                                                        color: color1,
                                                                        borderRadius: BorderRadius.circular(4)
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min  ,
                                                                      children: [
                                                                        LineIcon.box(size: 12,color: highlight,),
                                                                        Text(
                                                                            'Units : ',
                                                                            style: small
                                                                        ),
                                                                        Text(
                                                                            '${product.checked.toString().split(",").last.contains("SALE")? salemodel.quantity : prchmodel.quantity}',
                                                                            style: bold
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                    decoration: BoxDecoration(
                                                                        color: color1,
                                                                        borderRadius: BorderRadius.circular(4)
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min  ,
                                                                      children: [
                                                                        Icon(CupertinoIcons.money_dollar, size: 12,color: highlight,),
                                                                        Text(
                                                                            product.checked.toString().split(",").last.contains("SALE")? 'SP : ' : 'BP : ',
                                                                            style: small
                                                                        ),
                                                                        Text(
                                                                            product.checked.toString().split(",").last.contains("SALE")
                                                                                ?'Ksh.${formatNumberWithCommas(double.parse(salemodel.sprice.toString()))}'
                                                                                :'Ksh.${formatNumberWithCommas(double.parse(prchmodel.bprice.toString()))}',
                                                                            style: bold
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        product.checked.toString().split(",").last.contains("SALE")
                                                            ? int.parse(salemodel.quantity!) == 0 ?  SizedBox() : IconButton(
                                                            onPressed: (){
                                                              dialogEditSale(context, product, salemodel);
                                                            },
                                                            icon: Icon(Icons.edit, color: highlight,)
                                                        )
                                                            : int.parse(prchmodel.quantity!) == 0 ?  SizedBox() : IconButton(
                                                            onPressed: (){
                                                              dialogEditPrch(context, product, prchmodel);
                                                            },
                                                            icon: Icon(Icons.edit, color: highlight,)
                                                        )


                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );

                                            }),
                                      )
                                  )
                                ],
                              ),
                            ),
                            _expanded
                                ? SizedBox()
                                : Container(
                              constraints: BoxConstraints(
                                maxWidth: 500,
                                minWidth: 400
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("   Ksh.${formatNumberWithCommas(amountDue)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                            ).animate().fade(duration: Duration(milliseconds: 500)).slideY(curve: Curves.easeInOut),
                                            amountDue-totalPaid == 0? SizedBox() : Text("    Ksh.${formatNumberWithCommas(amountDue-totalPaid)}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.red),
                                            ).animate().fade(duration: Duration(milliseconds: 500)).slideY(curve: Curves.easeInOut),
                                          ],
                                        ),
                                      ),
                                      _scndSale.isEmpty && _scndPrch.isEmpty
                                          ? SizedBox()
                                          : TextButton(
                                          onPressed: (){dialogMethod(context);},
                                          child: RichText(
                                            text: TextSpan(
                                                children: [
                                                  WidgetSpan(child: _scndPrch.any((test)=> test.type == "") || _scndSale.any((test)=> test.method == "")
                                                      ? SizedBox()
                                                      : Icon(CupertinoIcons.checkmark_alt, color: secBtn,size: 15,)),
                                                  TextSpan(
                                                      text: "Method",
                                                      style: highlight
                                                  ),
                                                ]
                                            ),
                                          )
                                      ),
                                      _scndSale.isEmpty
                                          ? SizedBox(height: 40,)
                                          : TextButton(
                                          onPressed: (){dialogSelectCustomer(context);},
                                          child: RichText(
                                            text: TextSpan(
                                                children: [
                                                  WidgetSpan(child: _scndSale.any((test)=> test.customer == "") ? SizedBox() : Icon(CupertinoIcons.checkmark_alt, color: secBtn,size: 15,)),
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
                                                EntityModel enty = _entity.isNotEmpty
                                                    ? _entity.firstWhere((element) => element.eid == item!.eid, orElse: () => EntityModel(eid: "", title: "N/A"))
                                                    : EntityModel(eid: "", title: "N/A");
                                                var amount = _scndSale.isNotEmpty
                                                    ? _scndSale.where((test) => test.eid==item!.eid).fold(0.0, (previous, element) => previous + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())))
                                                    : _scndPrch.where((test) => test.eid==item!.eid).fold(0.0, (previous, element) => previous + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
                                                var items = _scndSale.isNotEmpty
                                                    ? _scndSale.where((test) => test.eid==item!.eid).length
                                                    : _scndPrch.where((test) => test.eid==item!.eid).length;
                                                var saleModel = _scndSale.isNotEmpty
                                                    ? _scndSale.firstWhere((test) => test.eid==item!.eid,
                                                    orElse: () => SaleModel(saleid: '')) : SaleModel(saleid: '');
                                                var prchModel = _scndPrch.isNotEmpty? _scndPrch.firstWhere((test) => test.eid==item!.eid, orElse: () => PurchaseModel(purchaseid: ""))
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
                                                            : Text(_scndSale.isEmpty
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
                                                                              text:_scndSale.isEmpty
                                                                                  ? "Ksh.${formatNumberWithCommas(double.parse(prchModel.paid.toString()))}"
                                                                                  : "Ksh.${formatNumberWithCommas(double.parse(saleModel.paid.toString()))}",
                                                                              style: bold
                                                                          ),
                                                                        ]
                                                                    )
                                                                ),
                                                              ),
                                                              Text(_scndSale.isEmpty
                                                                  ? prchModel.type.toString()
                                                                  : saleModel.method.toString(), style: bold),
                                                            ],
                                                          ),
                                                          _scndSale.isEmpty
                                                              ? SizedBox()
                                                              :Text("Customer Details", style: TextStyle(fontSize: 15),),
                                                          _scndSale.isEmpty
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
                                                                        text: _scndSale.isEmpty
                                                                            ?"Purchase Date : "
                                                                            :"Sale Date : ",
                                                                        style: style
                                                                    ),
                                                                    TextSpan(
                                                                        text: "${DateFormat.yMMMd().format(DateTime.parse(_scndSale.isEmpty ?prchModel.date.toString() :saleModel.date.toString()))}, "
                                                                            "${DateFormat.Hm().format(DateTime.parse(_scndSale.isEmpty ?prchModel.date.toString() :saleModel.date.toString()))} ",
                                                                        style: bold
                                                                    ),
                                                                  ]
                                                              )
                                                          ),
                                                          RichText(
                                                              text: TextSpan(
                                                                  children: [
                                                                    amount == double.parse(_scndSale.isEmpty?prchModel.paid.toString() : saleModel.paid.toString())
                                                                        || (amount== 0 || double.parse(_scndSale.isEmpty?prchModel.paid.toString() :saleModel.paid.toString())== 0)
                                                                        ?WidgetSpan(child: SizedBox())
                                                                        :TextSpan(
                                                                        text: "Due Date : ",
                                                                        style: style
                                                                    ),
                                                                    amount == double.parse(_scndSale.isEmpty ?prchModel.paid.toString() :saleModel.paid.toString())
                                                                        || (amount== 0 || double.parse(_scndSale.isEmpty ?prchModel.paid.toString() :saleModel.paid.toString())== 0)
                                                                        ?WidgetSpan(child: SizedBox())
                                                                        :TextSpan(
                                                                        text: "${DateFormat.yMMMd().format(DateTime.parse(_scndSale.isEmpty ? prchModel.due.toString() : saleModel.due.toString()))}",
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
                                                                  _scndSale.isEmpty
                                                                      ? dialogEditPrchList(context, prchModel, amount)
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
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _expanded
                    ? SizedBox()
                    : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        _loading = true;
                      });
                      if(_scndSale.isEmpty && _scndPrch.any((test) => test.type == "" || test.type!.isEmpty)){
                        Get.snackbar(
                          "Alert",
                          "Please enter the payment method for the transactions below",
                          maxWidth: 500,
                          icon: Icon(Icons.warning_amber_rounded, color: Colors.red),
                          shouldIconPulse: true,
                          forwardAnimationCurve: Curves.easeInOut,
                          reverseAnimationCurve: Curves.easeOut,
                        );
                        setState(() {
                          _loading = false;
                        });
                      } else if(_scndSale.isNotEmpty && _scndSale.any((test) => test.method == "" || test.customer=="")){
                        Get.snackbar(
                          "Alert",
                          "Please enter the payment method and customer details for the transactions below",
                          maxWidth: 500,
                          icon: Icon(Icons.warning_amber_rounded, color: Colors.red),
                          shouldIconPulse: true,
                          forwardAnimationCurve: Curves.easeInOut,
                          reverseAnimationCurve: Curves.easeOut,
                        );
                        setState(() {
                          _loading = false;
                        });
                      } else {
                        if(_scndPrch.isNotEmpty || _scndSale.isNotEmpty){
                          _pay();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please select any product to record transaction"),
                                showCloseIcon: true,
                            )
                          );
                          setState(() {
                            _loading = false;
                          });
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 700),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      width: 450,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: _scndPrch.isEmpty && _scndSale.isEmpty
                              ?  secBtn.withOpacity(0.3)
                              : _scndPrch.any((test) => test.type == "" || test.type!.isEmpty) ||  _scndSale.any((test) => test.method == "" || test.customer=="")
                              ? secBtn.withOpacity(0.3)
                              : secBtn
                      ),
                      child: Center(child: _loading
                          ?SizedBox(width: 15,height: 15, child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,))
                          :Text("PAY", style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),)),
                    ),
                  ),
                ),
                _expanded
                    ? SizedBox()
                    : Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          children: [
                            TextSpan(
                                text: "You are now recording payments for ",
                                style: style
                            ),
                            TextSpan(
                                text: account?"Sales ":"Purchases ",
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
                                text: "Kshs.${formatNumberWithCommas(amountDue)}",
                                style: bold
                            ),
                          ]
                      )
                  ),
                )
              ],
            ),
          )
      ),
      floatingActionButton: _scannedPrds.length == 0
          ? SizedBox()
          :  _expanded ? FloatingActionButton(
        onPressed: (){
          dialogPay(context);
        },
        shape: CircleBorder(),
        child: Icon(Icons.check),
      ) : SizedBox(),
    );
  }

  void dialogEditSale(BuildContext context, ProductModel product, SaleModel sale){
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    TextEditingController _quantity = TextEditingController();
    final style = TextStyle(color: secondaryColor, fontSize: 12);
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
                DialogTitle(title: 'E D I T'),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Please enter the number of units of  ",
                          style: style,
                        ),
                        TextSpan(
                            text: "${product.name} ",
                            style: TextStyle(fontSize: 12,color: reverse)
                        ),
                        TextSpan(
                          text: "to record for this sale, or update the selling price of this product.",
                          style: style,
                        ),
                      ]
                  ),
                ),
                DialogEditSaleQnty(sale: sale, updateQuantity: _updateQuantity)
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogEditPrch(BuildContext context, ProductModel product, PurchaseModel purchase){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    TextEditingController _quantity = TextEditingController();
    final style = TextStyle(color: secondaryColor, fontSize: 12);
    showDialog(context: context, builder: (context){
      return Dialog(
        backgroundColor: dilogbg,
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
                DialogTitle(title: 'Q U A N T I T Y'),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Enter the number of ",
                          style: style,
                        ),
                        TextSpan(
                            text: "${product.name} ",
                            style: TextStyle(fontSize: 12, color: secondaryColor, fontWeight: FontWeight.w900)
                        ),
                        TextSpan(
                          text: "that you have currently in stock",
                          style: style,
                        ),
                      ]
                  ),
                ),
                DialogEditPrchQnty(
                  purchase: purchase,
                  quantity: int.parse(purchase.quantity!),
                  updateQuantity: _updatePrchQuantity, from: 'CREATE',
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogAlert(BuildContext context, String accnt){
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
                DialogTitle(title: "A L E R T"),
                Text(
                  "Switching to the ${accnt} mode will clear all items from the ${accnt=="sales"? 'purchase':'sales'} list.", style: TextStyle(color: secondaryColor),
                  textAlign: TextAlign.center,
                ),
                DoubleCallAction(
                    action: (){
                      _scannedPrds = [];
                      _scndSale = [];
                      _scndPrch = [];
                      snapshot = 0;
                      Uuid uuid = Uuid();
                      saleId = uuid.v1();
                      purchaseId = uuid.v1();
                      now = DateTime.now();
                      Navigator.pop(context);
                      accnt=="sales"
                          ? account = true
                          : account = false;
                     _count();

                    }
                )
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogPay(BuildContext context){
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
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
          return SizedBox(width: 450,
            child: Column(
              children: [
                DialogTitle(title: "P A Y M E N T S"),
                Expanded(child: DialogScanPay(sales: _scndSale, purchases: _scndPrch, clear: _clear)),
              ],
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
                DialogFilterGoods(entity: EntityModel(eid: ""), filter: _filter,)
              ],
            ),
          ),
        )
    );
  }

  void dialogEditPrchList(BuildContext context, PurchaseModel purchase, double amount){
    showDialog(
        context: context,
        
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
                                _scndSale.forEach((element){
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
                        _scndSale.forEach((element){
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

  _pay()async{
    if(_scndSale.isEmpty){
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


      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      _purchases = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
      _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
      _payments = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();

      _scndPrch.forEach((element) async {
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
        EntityModel enty = _entity.firstWhere((test) => test.eid == action!.eid);
        PurchaseModel prchModel = _scndPrch.firstWhere((test) => test.eid == action!.eid);
        var noItems = _scndPrch.where((test) => test.eid==action!.eid).length;
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

      if(removedPurchase.length==_scndPrch.length){
        setState(() {
          // _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Purchases recorded Successfully"),
          showCloseIcon: true,
        )
        );
      }

      _scndPrch.forEach((element) async {
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
        EntityModel enty = _entity.firstWhere((test) => test.eid == action!.eid);
        PurchaseModel prchModel = _scndPrch.firstWhere((test) => test.eid == action!.eid);
        var noItems = _scndPrch.where((test) => test.eid==action!.eid).length;
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
          if(response=="Success"){
            payment.checked = "true";
            _payments.firstWhere((test) => test.payid == payment.payid).checked = "true";
            uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList('mypayments', uniquePayments );
            myPayments = uniquePayments;
          }
        });
      });
      _clear();
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

      _scndSale.forEach((element) async {
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
        EntityModel enty = _entity.firstWhere((test) => test.eid == action!.eid);
        SaleModel saleModel = _scndSale.firstWhere((test) => test.eid == action!.eid);
        var noItems = _scndSale.where((test) => test.eid==action!.eid).length;

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

      if(removedSales.length==_scndSale.length){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Sales recorded Successfully"),
          showCloseIcon: true,
        )
        );
      }

      _scndSale.forEach((element) async {
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
        EntityModel enty = _entity.firstWhere((test) => test.eid == action!.eid);
        SaleModel saleModel = _scndSale.firstWhere((test) => test.eid == action!.eid);
        payid = uuid.v5(enty.eid, now.toString());
        var noItems = _scndSale.where((test) => test.eid==action!.eid).length;

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

      _clear();
    }
  }

  _clear(){
    _scndSale = [];
    _scndPrch = [];
    _scannedPrds = [];
    _count();
    _loading = false;
    setState(() {

    });
  }
  _getDetails()async{
    _getData();
    _newEntity = await Services().getCurrentEntity(currentUser.uid);
    _newPrd = await Services().getMyPrdct(currentUser.uid);
    _newSpplr = await Services().getMySuppliers(currentUser.uid);
    _newInv = await Services().getMyInv(currentUser.uid);
    _newDuties = await Services().getMyDuties(currentUser.uid);
    await Data().addOrUpdateProductsList(_newPrd);
    await Data().addOrUpdateSuppliersList(_newSpplr);
    await Data().addOrUpdateInvList(_newInv);
    await Data().addOrUpdateEntity(_newEntity);
    await Data().addOrUpdateDutyList(_newDuties);
    _getData();
  }
  _getData(){
    _prd = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    _spplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _inv = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    mySale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _filtNewSale = mySale.where((element) => element.customer != "" && element.phone != "").toList();
    _prd = _prd.where((element) {
      bool matchesEid = eid.isEmpty || element.eid == eid;
      bool matchesCategory = category.isEmpty || element.category == category;
      bool matchesVolume = volume.isEmpty || element.volume == volume;
      bool matchesSupplier = supplierId.isEmpty || element.supplier == supplierId;

      return matchesEid && matchesCategory && matchesVolume && matchesSupplier;
    }).toList();
    _prd.where((element) => element.checked != "true").forEach((prd)async {
      await Data().checkAndUploadProduct(prd, _updateProduct);
    });
    Future.delayed(Duration.zero).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  _count(){
    items =_scannedPrds.length;
    units = _scndSale.isEmpty
        ? _scndPrch.fold(0, (previous, element) => previous + int.parse(element.quantity.toString()))
        : _scndSale.fold(0, (previous, element) => previous + int.parse(element.quantity.toString()));
    amountDue = _scndSale.isEmpty
        ? _scndPrch.fold(0.0, (previous, element) => previous + (double.parse(element.quantity.toString()) * double.parse(element.bprice.toString())))
        : _scndSale.fold(0.0, (previous, element) => previous + (double.parse(element.quantity.toString()) * double.parse(element.sprice.toString())));
    eidList = _scndSale.isNotEmpty
        ? _scndSale.map((sale) => sale.eid.toString()).toSet().toList()
        : _scndPrch.map((purchase) => purchase.eid.toString()).toSet().toList();
    uniqueEid = eidList.map((eid)=>UniqueEntity(eid: eid.toString())).toList();
    for (var sale in _filtNewSale) {
      bool idExists = _newSale.any((element) => element.customer == sale.customer && element.phone == sale.phone);
      if (!idExists) {
        _newSale.add(sale);
      }
    }
    if(_scndSale.isEmpty){
      for(var eids in uniqueEid){
        var totalPrchAmount = _scndPrch.where((test) => test.eid == eids!.eid).fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
        _scndPrch.where((test) => test.eid == eids!.eid).forEach((action){
          action.amount = totalPrchAmount.toString();
          action.paid =totalPrchAmount.toString();
        });
      }
    } else {
      for(var eids in uniqueEid){
        var totalSaleAmount = _scndSale.where((test) => test.eid == eids!.eid).fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
        _scndSale.where((test) => test.eid == eids!.eid).forEach((action){
          action.amount = totalSaleAmount.toString();
          action.paid = totalSaleAmount.toString();
        });
      }
    }

    totalPaid = amountDue;

    setState(() {

    });
  }
  _updateQuantity(SaleModel sale, String selling, String quantity){
    print("Updating quatity : $quantity, Selling Price : $selling");
    if(_scndSale.any((test) => test.sid.toString().contains(sale.sid.toString()))){
      _scndSale.firstWhere((element) => element.sid == sale.sid).quantity = quantity;
      _scndSale.firstWhere((element) => element.sid == sale.sid).sprice = selling;
      _count();
    }
  }
  _updatePrchQuantity(PurchaseModel purchase, String quantity){
    if(_scndPrch.any((test) => test.prcid.toString().contains(purchase.prcid.toString()))){
      _scndPrch.firstWhere((element) => element.prcid == purchase.prcid).quantity = quantity;
      _count();
    }
  }
  _updatePrchList(PurchaseModel purchase, String paid, String method, String date, String due){
    _scndPrch.where((test) => test.eid == purchase.eid).forEach((element){
      element.paid=paid;
      element.type=method;
      element.date=date;
      element.due=due;
    });
    totalPaid=0;
    uniqueEid.forEach((element){
      totalPaid = totalPaid+double.parse(_scndPrch.firstWhere((test) => test.eid == element!.eid).paid.toString());
    });
    setState(() {
    });
  }
  _updateSalesList(SaleModel saleModel, String amount, String paid, String method, String name, String phone, String date, String due){
    _scndSale.where((test) => test.eid == saleModel.eid).forEach((element){
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
      totalPaid = totalPaid+double.parse(_scndSale.firstWhere((test) => test.eid == element!.eid).paid.toString());
    });
    setState(() {
    });
  }
  _updateMethod(String method){
    setState(() {
      if(_scndSale.isEmpty){
        _scndPrch.forEach((action){
          action.type = method;
        });
      } else {
        _scndSale.forEach((action){
          action.method = method;
        });
      }
    });
    Navigator.pop(context);

  }
  void _filter(String? cat, String? vol, String? sid, String? entityEid){
    supplierId = sid==null?"":sid;
    category = cat==null?"":cat;
    volume = vol==null?"":vol;
    eid = entityEid==null?"":entityEid;
    _getData();
  }

  void _updateProduct(ProductModel product)async{
    _prd.firstWhere((element) => element.prid == product.prid).checked = "true";
    await Data().addOrUpdateProductsList(_prd);
    setState(() {
    });
  }

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
