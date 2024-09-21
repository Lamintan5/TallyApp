import 'dart:convert';
import 'dart:ui';

import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/products.dart';
import 'package:TallyApp/models/suppliers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:TallyApp/utils/colors.dart';

import '../../Widget/frosted_glass.dart';
import '../../main.dart';
import '../../resources/services.dart';

class TestScan extends StatefulWidget {
  const TestScan({super.key});

  @override
  State<TestScan> createState() => _TestScanState();
}

class _TestScanState extends State<TestScan> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  MobileScannerController camerController = MobileScannerController();
  List<ProductModel> _products = [];
  List<ProductModel> _scannedPrds = [];
  List<ProductModel> _newproducts = [];
  List<SupplierModel> _supplr = [];
  List<SupplierModel> _newsupplr = [];
  bool isFlashOn = false;
  late ScrollController _scrollcontroller;
  late GlobalKey<AnimatedListState> _key;
  bool account = true;
  bool visible = true;
  bool volume = true;

  _getDetails()async{
    _getData();
    _newproducts = await Services().getMyPrdct(currentUser.uid);
    _newsupplr = await Services().getMySuppliers(currentUser.uid);
    await Data().addOrUpdateProductsList(_newproducts);
    await Data().addOrUpdateSuppliersList(_newsupplr);
    _getData();
  }

  _getData(){
    _products = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _supplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    setState(() {
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollcontroller = ScrollController();
    _key = GlobalKey();
    _getDetails();
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
                automaticallyImplyLeading: false,
                foregroundColor: reverse,
                toolbarHeight: 30,
                scrolledUnderElevation: 1000,
                centerTitle: true,
                elevation: 10,
                title: Text("QR Code Scanner", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),),
                actions: [
                  IconButton(onPressed: (){
                    setState(() {
                      volume = !volume;
                    });
                  },
                      icon: Icon(volume
                          ? Icons.volume_up
                          : Icons.volume_off)
                  ),
                  IconButton(
                      onPressed: (){
                        setState(() {
                          isFlashOn = !isFlashOn;
                          camerController.toggleTorch();
                        });
                      },
                      icon: Icon(isFlashOn? Icons.flash_off : Icons.flash_on)),
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
                                    child: Text(
                                      'To start a sale, select "Sale". For purchases, select "Purchase". Then, place the QR code in the scanner area for automatic scanning',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: (){
                                        setState(() {
                                          visible = false;
                                        });
                                      },
                                      icon: Icon(Icons.close))
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: FrostedGlass(
                              width: 250,
                              height: 60,
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap:(){
                                          setState(() {
                                            account = true;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: account?Colors.cyanAccent:Colors.transparent,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                              )
                                          ),
                                          height: 55,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              LineIcon.dollarSign(color: account?Colors.black:reverse,),
                                              Text('Sale', style: TextStyle(
                                                color: account?Colors.black:reverse,
                                                fontWeight: account?FontWeight.bold:FontWeight.normal,
                                              ),)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: VerticalDivider(
                                        color: Colors.grey,
                                        thickness: 3,
                                        width: 3,
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap:(){
                                          setState(() {
                                            account = false;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: account?Colors.transparent:Colors.cyanAccent,
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(10),
                                                bottomRight: Radius.circular(10),
                                              )
                                          ),
                                          height: 55,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              LineIcon.shoppingCart(color: account?reverse:Colors.black,),
                                              Text('Purchase', style: TextStyle(color: account?reverse:Colors.black),)
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
                                          ProductModel newPrd = _products.firstWhere((element) => element.prid == code);
                                          newPrd.quantity = "1";
                                          if(_scannedPrds.contains(newPrd)){
                                            print("Product ${newPrd.name} already exists");

                                          } else {
                                            if (code != null) {
                                              _scannedPrds.add(newPrd);
                                              await _playScanSound();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    showCloseIcon: true,
                                                    content: Text("Product ${newPrd.name} add to list"),
                                                  )
                                              );
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
                            Text("${_scannedPrds.length} Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
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
        onPressed: (){},
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
    var supplier = _supplr.isEmpty || _supplr.length == 0
        ? SupplierModel(sid: "", name: "")
        : _supplr.firstWhere((element) => element.sid == prdct.supplier, orElse: () => SupplierModel(sid: "", name: ""));
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
          color: revers2,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color1,
            child: Center(child: Text(prdct.quantity.toString(), style: TextStyle(color: reverse,fontSize: 14, fontWeight: FontWeight.w700),)),
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
                  ],
                ),
                RichText(
                    text:
                    TextSpan(
                        children: [

                          TextSpan(
                              text: 'Volume : ',
                              style: small
                          ),
                          TextSpan(
                              text: '${prdct.volume}, ',
                              style: bold
                          ),
                          TextSpan(
                              text: 'SP : ',
                              style: small
                          ),
                          TextSpan(
                              text: 'Ksh.${formatNumberWithCommas(double.parse(prdct.selling.toString()))}' ,
                              style: bold
                          ),
                        ]
                    )
                ),
              ],
            ),
          ),
          IconButton(onPressed: (){}, icon: Icon(Icons.edit)),
          IconButton(onPressed: (){
            if (_scannedPrds.isNotEmpty) {
              _scannedPrds.remove(prdct);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    showCloseIcon: true,
                    content: Text("Product ${prdct.name} removed from list"),
                  )
              );
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
  Future<void> _playScanSound() async {
    if(volume){
      await _audioPlayer.play(AssetSource('sounds/scan.mp3'));
    }
  }
  void _simulateRemove() {
    if (_scannedPrds.isNotEmpty) {
      final int removeIndex = 0;
      final ProductModel removedProduct = _scannedPrds.removeAt(removeIndex);

      if (mounted && _key.currentState != null) {
        _key.currentState!.removeItem(
          removeIndex,
              (context, animation) => FadeTransition(
            opacity: animation,
            child: ProductItem(removedProduct, 0),
          ),
          duration: Duration(milliseconds: 800),
        );
      }
    }
  }
  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}

// Container(
// margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// padding: EdgeInsets.symmetric(vertical: 10),
// width: double.infinity,
// decoration: BoxDecoration(
// color: color1,
// borderRadius: BorderRadius.circular(10)
// ),
// child: Column(
// children: [
// Text('QR SCANNER', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100),),
// SizedBox(height: 20,),
// Text("Place the QR code in the area", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),),
// Text("Scan the product QR code to instantly record the sale.", style: TextStyle(color: secondaryColor),),
// ],
// ),
// ),
// SizedBox(width: 400,height: 400,
// child: QRScannerOverlay(
// overlayColor: Colors.transparent,
// borderColor: Colors.cyanAccent,
// borderRadius: 10,
// borderStrokeWidth: 2,
// ),
// )
