import 'dart:convert';
import 'dart:ui';

import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/Widget/dialogs/scan/dialog_scan_pay.dart';
import 'package:TallyApp/home/tabs/sell_buy.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/inventories.dart';
import 'package:TallyApp/models/products.dart';
import 'package:TallyApp/models/purchases.dart';
import 'package:TallyApp/models/suppliers.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

import '../../Widget/dialogs/dialog_edit_prch_qnty.dart';
import '../../Widget/dialogs/dialog_edit_sale_qnty.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/frosted_glass.dart';
import '../../main.dart';
import '../../models/duties.dart';
import '../../models/entities.dart';
import '../../models/sales.dart';
import '../../resources/services.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  MobileScannerController camerController = MobileScannerController();
  List<ProductModel> _products = [];
  List<ProductModel> _scannedPrds = [];
  List<ProductModel> _newproducts = [];
  List<SupplierModel> _supplr = [];
  List<SupplierModel> _newsupplr = [];
  List<SaleModel> _scndSale = [];
  List<PurchaseModel> _scndPrch = [];
  List<InventModel> _inv = [];
  List<InventModel> _newInv = [];
  List<EntityModel> _entity = [];
  List<EntityModel> _newEntity = [];
  List<DutiesModel> _duties = [];
  List<DutiesModel> _newDuties = [];

  late ScrollController _scrollcontroller;
  late GlobalKey<AnimatedListState> _key;

  bool account = true;
  bool visible = true;
  bool volume = true;
  bool isFlashOn = false;

  String saleId = "";
  String purchaseId = "";

  late DateTime now;

  int snapshot = 0;
  Uuid uuid = Uuid();

  _getDetails()async{
    _getData();
    _newEntity = await Services().getCurrentEntity(currentUser.uid);
    _newproducts = await Services().getMyPrdct(currentUser.uid);
    _newsupplr = await Services().getMySuppliers(currentUser.uid);
    _newInv = await Services().getMyInv(currentUser.uid);
    _newDuties = await Services().getMyDuties(currentUser.uid);
    await Data().addOrUpdateProductsList(_newproducts);
    await Data().addOrUpdateSuppliersList(_newsupplr);
    await Data().addOrUpdateInvList(_newInv);
    await Data().addOrUpdateEntity(_newEntity);
    await Data().addOrUpdateDutyList(_newDuties);
    _getData();
  }

  _getData(){
    _products = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _supplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _inv = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    setState(() {
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollcontroller = ScrollController();
    _key = GlobalKey();
    if(myShowCases.contains("Scanner")){
      visible = false;
    }
    _getDetails();
    now = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarColor: Colors.transparent
        )
    );
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final revers2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.black12
        : Colors.white10;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: camerController,
            onDetect: (BarcodeCapture barcodes) {},
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaY: 5,
              sigmaX: 5,
            ),
            child: Container(),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                expandedHeight: 600,
                automaticallyImplyLeading: true,
                centerTitle: true,
                foregroundColor: reverse,
                toolbarHeight: 30,
                scrolledUnderElevation: 1000,
                elevation: 10,
                title: Text("QR Code Scanner", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),),
                actions: [
                  IconButton(onPressed: (){
                    setState(() {
                      volume = !volume;
                    });
                  },
                      icon: Icon(volume
                          ? CupertinoIcons.volume_up
                          : CupertinoIcons.volume_off)
                  ),
                  IconButton(
                      onPressed: (){
                        setState(() {
                          isFlashOn = !isFlashOn;
                          camerController.toggleTorch();
                        });
                      },
                      icon: Icon(isFlashOn
                          ? Icons.flash_off
                          : Icons.flash_on)),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: visible,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: color1,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child:
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'To start a sale, select "Sale". For purchases, select "Purchase". Then, place the QR code in the scanner area for automatic scanning. ',
                                            style: TextStyle(fontSize: 13, color: Colors.white)
                                          ),
                                          WidgetSpan(
                                              child: InkWell(
                                                onTap: (){
                                                  setState(() {
                                                    visible = false;
                                                    Data().addOrRemoveShowCase("Scanner","add");
                                                  });
                                                },
                                                child: Text("Okay got it", style: TextStyle(fontSize: 13, color: CupertinoColors.activeBlue, fontWeight: FontWeight.bold),),
                                              )
                                          ),
                                        ]
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
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
                                  indicatorColor: Colors.grey[800],
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
                          SizedBox(height: 30,),
                          Container(height: 300,width: 300,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: MobileScanner(
                                      controller: camerController,
                                      onDetect: (BarcodeCapture barcodes) async {

                                        for (var barcode in barcodes.barcodes) {
                                          final String? code = barcode.rawValue;
                                          ProductModel newPrd = _products.firstWhere((element) => element.prid == code,
                                              orElse: () => ProductModel(prid: ""));
                                          InventModel invtmodel = _inv.firstWhere((element) => element.productid == code,
                                              orElse: () => InventModel(iid: "", quantity: "0"));
                                          EntityModel enty = _entity.firstWhere((element) => element.eid ==newPrd.eid,
                                              orElse: () => EntityModel(eid: ""));
                                          var duties = _duties.firstWhere((test) => test.eid==enty.eid && test.pid == currentUser.uid, orElse: ()=> DutiesModel(did: ""));

                                          if(_scannedPrds.contains(newPrd) ){
                                            print("Product ${newPrd.name} already exists");

                                          } else {
                                            if (code != null && newPrd.prid!="" && enty.eid !="") {
                                              if(account){
                                                if(int.parse(invtmodel.quantity.toString()) < 1 || newPrd.checked.toString().contains("REMOVED") || enty.eid == ""){

                                                }
                                                else {
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
                                                    productid: code,
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

                                                  if(enty.admin.toString().split(",").contains(currentUser.uid)){
                                                      _scndSale.add(newSale);
                                                      _scannedPrds.add(newPrd);
                                                      await _playScanSound();
                                                      if (mounted && _key.currentState != null) {
                                                    int itemIndex = 0;
                                                    // Ensure itemIndex is within the valid range
                                                    if (itemIndex >= 0 && itemIndex <= _scannedPrds.length) {
                                                      _key.currentState!.insertItem(itemIndex, duration: Duration(milliseconds: 800));
                                                    } else {
                                                      // Handle the case where itemIndex is out of bounds
                                                      print('Invalid itemIndex: $itemIndex');
                                                    }
                                                  }
                                                  } else {
                                                    if(duties.duties.toString().contains("SALE")){
                                                       _scndSale.add(newSale);
                                                       _scannedPrds.add(newPrd);
                                                        await _playScanSound();
                                                        if (mounted && _key.currentState != null) {
                                                        int itemIndex = 0;
                                                        // Ensure itemIndex is within the valid range
                                                        if (itemIndex >= 0 && itemIndex <= _scannedPrds.length) {
                                                          _key.currentState!.insertItem(itemIndex, duration: Duration(milliseconds: 800));
                                                        } else {
                                                          // Handle the case where itemIndex is out of bounds
                                                          print('Invalid itemIndex: $itemIndex');
                                                        }
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
                                                  productid: code,
                                                  quantity: "1",
                                                  bprice: newPrd.buying,
                                                  paid: '0.0',
                                                  type: '',
                                                  checked: 'false',
                                                  due: DateTime.now().toString(),
                                                  time: DateTime.now().toString(),
                                                  date: DateTime.now().toString(),
                                                );
                                                if(newPrd.checked.toString().contains("REMOVED") || enty.eid == ""){

                                                } else {
                                                  if(enty.admin.toString().split(",").contains(currentUser.uid)){
                                                    _scndPrch.add(newPrch);
                                                    _scannedPrds.add(newPrd);
                                                    await _playScanSound();
                                                    if (mounted && _key.currentState != null) {
                                                    int itemIndex = 0;
                                                    // Ensure itemIndex is within the valid range
                                                    if (itemIndex >= 0 && itemIndex <= _scannedPrds.length) {
                                                      _key.currentState!.insertItem(itemIndex, duration: Duration(milliseconds: 800));
                                                    } else {
                                                      // Handle the case where itemIndex is out of bounds
                                                      print('Invalid itemIndex: $itemIndex');
                                                    }
                                                  }
                                                  } else {
                                                    if(duties.duties.toString().contains("PURCHASE")){
                                                      _scndPrch.add(newPrch);
                                                      _scannedPrds.add(newPrd);
                                                      await _playScanSound();
                                                      if (mounted && _key.currentState != null) {
                                                    int itemIndex = 0;
                                                    // Ensure itemIndex is within the valid range
                                                    if (itemIndex >= 0 && itemIndex <= _scannedPrds.length) {
                                                      _key.currentState!.insertItem(itemIndex, duration: Duration(milliseconds: 800));
                                                    } else {
                                                      // Handle the case where itemIndex is out of bounds
                                                      print('Invalid itemIndex: $itemIndex');
                                                    }
                                                  }
                                                    }
                                                  }
                                                }
                                              }
                                              setState(() {

                                              });
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                QRScannerOverlay(
                                  overlayColor: Colors.transparent,
                                  borderColor: Colors.white,
                                  borderRadius: 10,
                                  borderStrokeWidth: 2,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(20),
                  child: Container(
                    height: 30,
                    margin: EdgeInsets.only(left: 10, bottom: 20, ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 30,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("${_scannedPrds.length} Items, S:${_scndSale.length}, P:${_scndPrch.length}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                            Container(
                              width: 100,
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                        _scannedPrds.length == 0
                            ? SizedBox(width: 30,)
                            : IconButton(
                            onPressed: (){
                              if (_scannedPrds.isNotEmpty) {
                                List<ProductModel> productsToRemove = List.from(_scannedPrds);

                                Future<void> removeItemsWithDelay() async {
                                  for (var prdct in productsToRemove) {
                                    int index = _scannedPrds.indexOf(prdct);
                                    if (index != -1) {
                                      _scannedPrds.removeAt(index);
                                      _scndSale.removeWhere((element) => element.productid==prdct.prid);
                                      _scndPrch.removeWhere((element) => element.productid==prdct.prid);
                                      if (mounted && _key.currentState != null) {
                                        _key.currentState!.removeItem(
                                          index,
                                              (context, animation) => SlideTransition(
                                            position: animation.drive(
                                              Tween<Offset>(
                                                begin: const Offset(1, 0),
                                                end: Offset.zero,
                                              ).chain(CurveTween(curve: Curves.easeInOut)),
                                            ),
                                            child: ProductItem(prdct, index),
                                          ),
                                          duration: Duration(milliseconds: 800),
                                        );
                                      }
                                      await Future.delayed(Duration(milliseconds: 100));
                                    }
                                  }
                                  setState(() {

                                  });
                                }
                                removeItemsWithDelay();
                                snapshot = 0;
                                now = DateTime.now();
                              }
                            },
                            icon: Icon(Icons.clear_all)
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                  child: Container(
                    height: size.height - 80,
                    child: AnimatedList(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      key: _key,
                      controller: _scrollcontroller,
                      initialItemCount: _scannedPrds.length,
                      itemBuilder: (context, index, animation){
                        int newIndex = _scannedPrds.length -1 -index;
                        ProductModel prdct = _scannedPrds[newIndex];
                        return SizeTransition(
                          sizeFactor: animation,
                          child: ProductItem(prdct, index),
                        );
                      },
                    ),
                  )
              )
            ],
          )
        ],
      ),
      floatingActionButton: _scannedPrds.length == 0 ? SizedBox()  :  FloatingActionButton(
        onPressed: (){
          dialogPay(context);
        },
        shape: CircleBorder(),
        child: Icon(Icons.check),
      ),
    );
  }
  Widget ProductItem(ProductModel prdct, int index){
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final revers2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.black12
        : Colors.white10;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final bold = TextStyle(fontWeight: FontWeight.w700, fontSize: 11);
    final small = TextStyle(fontSize: 11, color: reverse);
    var salemodel = _scndSale.any((test) => test.productid.toString().contains(prdct.prid.toString()))
        ?_scndSale.firstWhere((element) => element.productid == prdct.prid, orElse: () => SaleModel(saleid: ""))
        : SaleModel(saleid: '', quantity: "0", sprice: "0.0");
    var prchmodel = _scndPrch.any((test) => test.productid.toString().contains(prdct.prid.toString()))
        ?_scndPrch.firstWhere((element) => element.productid == prdct.prid,
          orElse: () => PurchaseModel(purchaseid: ""))
        : PurchaseModel(purchaseid: '', quantity: "0", bprice: "0.0");
    //prdct.checked.toString().split(",").last
    var invmodel = _inv.any((test) => test.productid.toString().contains(prdct.prid.toString()))
        ? _inv.firstWhere((element) => element.productid == prdct.prid,
        orElse: () => InventModel(iid: "", quantity: "0"))
        : InventModel(iid: "", quantity: "0");
    var supplier = _inv.any((test) => test.productid.toString().contains(prdct.prid.toString()))
        ? SupplierModel(sid: "", name: "N/A")
        : _supplr.firstWhere((element) => element.sid == prdct.supplier, orElse: () => SupplierModel(sid: "", name: ""));
    var entity = _entity.any((test) => test.eid.toString().contains(prdct.eid.toString()))
        ?_entity.firstWhere((element) => element.eid == prdct.eid, orElse: () => EntityModel(eid: "", title: "N/A "))
        : EntityModel(eid: "", title: "N/A");
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
          color: prdct.checked.toString().split(",").last.contains("SALE") && invmodel.quantity == "0" || entity.eid == ""
              ? Colors.red.withOpacity(0.6)
              : revers2,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20, 
            backgroundColor: color1,
            child: Center(
                child: LineIcon.box(color: reverse,)
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(prdct.name.toString() , style: TextStyle(color: reverse, fontWeight: FontWeight.w600),),
                    SizedBox(width: 10,),
                    Text(prdct.category.toString(), style: TextStyle(color: reverse, fontSize: 11),),
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
                              text: '${prdct.volume}, ',
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
                          LineIcon.box(size: 12,),
                          Text(
                              'Units : ',
                              style: small
                          ),
                          Text(
                              '${prdct.checked.toString().split(",").last.contains("SALE")? salemodel.quantity : prchmodel.quantity}',
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
                          Icon(CupertinoIcons.money_dollar, size: 12,),
                          Text(
                              prdct.checked.toString().split(",").last.contains("SALE")? 'SP : ' : 'BP : ',
                              style: small
                          ),
                          Text(
                              prdct.checked.toString().split(",").last.contains("SALE")
                                  ?'Ksh.${formatNumberWithCommas(double.parse(salemodel.sprice.toString()))}'
                                  :'Ksh.${formatNumberWithCommas(double.parse(prchmodel.bprice.toString()))}',
                              style: bold
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          IconButton(
              onPressed: (){
                prdct.checked.toString().split(",").last.contains("SALE")
                    ?dialogEditSale(context, prdct, salemodel)
                    :dialogEditPrch(context, prdct, prchmodel);
              },
              icon: Icon(Icons.edit)
          ),
          IconButton(onPressed: (){
            if (_scannedPrds.isNotEmpty) {
              _scannedPrds.remove(prdct);
              _scndSale.removeWhere((element) => element.productid==prdct.prid);
              _scndPrch.removeWhere((element) => element.productid==prdct.prid);
              if (mounted && _key.currentState != null) {
                _key.currentState!.removeItem(
                  index,
                      (context, animation) => SizeTransition(
                    sizeFactor: animation,
                    child: ProductItem(prdct, 0),
                  ),
                  duration: Duration(milliseconds: 800),
                );
              }
            }
            setState(() {

            });
          },
            icon: Icon(Icons.delete_forever),
          )
        ],
      ),
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
                      if (_scannedPrds.isNotEmpty) {
                        List<ProductModel> productsToRemove = List.from(_scannedPrds);
                        Future<void> removeItemsWithDelay() async {
                          for (var prdct in productsToRemove) {
                            int index = _scannedPrds.indexOf(prdct);
                            if (index != -1) {
                              _scannedPrds.removeAt(index);
                              accnt=="sales"
                                  ? _scndPrch.removeWhere((element) => element.productid==prdct.prid)
                                  : _scndSale.removeWhere((element) => element.productid==prdct.prid) ;
                              if (mounted && _key.currentState != null) {
                                _key.currentState!.removeItem(
                                  index,
                                      (context, animation) => SlideTransition(
                                    position: animation.drive(
                                      Tween<Offset>(
                                        begin: const Offset(1, 0),
                                        end: Offset.zero,
                                      ).chain(CurveTween(curve: Curves.easeInOut)),
                                    ),
                                    child: ProductItem(prdct, index),
                                  ),
                                  duration: Duration(milliseconds: 800),
                                );
                              }
                              await Future.delayed(Duration(milliseconds: 100));
                            }
                          }
                          setState(() {
                          });
                        }
                        removeItemsWithDelay();
                        snapshot = 0;
                        Uuid uuid = Uuid();
                        saleId = uuid.v1();
                        purchaseId = uuid.v1();
                        now = DateTime.now();
                        Navigator.pop(context);
                        accnt=="sales"
                            ? account = true
                            : account = false;
                      }
                    }
                )
              ],
            ),
          ),
        ),
      );
    });    
  }

  _updateQuantity(SaleModel sale, String selling, String quantity){
    print("Updating quatity : $quantity, Selling Price : $selling");
    if(_scndSale.any((test) => test.sid.toString().contains(sale.sid.toString()))){
      _scndSale.firstWhere((element) => element.sid == sale.sid).quantity = quantity;
      _scndSale.firstWhere((element) => element.sid == sale.sid).sprice = selling;
      setState(() {

      });
    }
  }
  _updatePrchQuantity(PurchaseModel purchase, String quantity){
    if(_scndPrch.any((test) => test.prcid.toString().contains(purchase.prcid.toString()))){
      _scndPrch.firstWhere((element) => element.prcid == purchase.prcid).quantity = quantity;
      setState(() {

      });
    }
  }
  _clear(){
    if (_scannedPrds.isNotEmpty) {
      List<ProductModel> productsToRemove = List.from(_scannedPrds);

      Future<void> removeItemsWithDelay() async {
        for (var prdct in productsToRemove) {
          int index = _scannedPrds.indexOf(prdct);
          if (index != -1) {
            _scannedPrds.removeAt(index);

            if (mounted && _key.currentState != null) {
              _key.currentState!.removeItem(
                index,
                    (context, animation) => SlideTransition(
                  position: animation.drive(
                    Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeInOut)),
                  ),
                  child: ProductItem(prdct, index),
                ),
                duration: Duration(milliseconds: 800),
              );
            }
            await Future.delayed(Duration(milliseconds: 100));
          }
        }
        setState(() {
          // Update any state after removing items
        });
      }
      removeItemsWithDelay();
      _scndSale = [];
      _scndPrch = [];
      snapshot = 0;
      now = DateTime.now();
    }
  }

  Future<void> _playScanSound() async {
    if(volume){
      await _audioPlayer.play(AssetSource('sounds/scan.mp3'));
    }
  }

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}

