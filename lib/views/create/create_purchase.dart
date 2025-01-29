import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../Widget/buttons/bottom_call_buttons.dart';
import '../../Widget/buttons/card_button.dart';
import '../../Widget/dialogs/dialog_add_payment.dart';
import '../../Widget/dialogs/dialog_edit_prch_qnty.dart';
import '../../Widget/dialogs/dialog_select_product.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/text/text_format.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/inventories.dart';
import '../../models/payments.dart';
import '../../models/products.dart';
import '../../models/purchases.dart';
import '../../models/suppliers.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';


class CreatePurchase extends StatefulWidget {
  final EntityModel entity;
  final Function getPurchase;
  const CreatePurchase({super.key, required this.entity, required this.getPurchase});

  @override
  State<CreatePurchase> createState() => _CreatePurchaseState();
}

class _CreatePurchaseState extends State<CreatePurchase> {
  TextEditingController _search = TextEditingController();
  List<String> title = ['Total Items',];
  List<ProductModel> _products = [];

  String purchaseId = '';
  String removed = '';
  String selectedID = '';
  String admin = '';

  double amount = 0;
  double totalPrice = 0;

  bool _layout = true;
  bool _loading = false;

  List<SupplierModel> _fltSpplr = [];
  List<SupplierModel> _spplr = [];
  List<SupplierModel> _newSpplr = [];
  List<PurchaseModel> _filtPurchas = [];
  List<PurchaseModel> _purchase = [];
  List<InventModel> _inventory = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(Platform.isAndroid || Platform.isIOS){
      _layout = false;
    } else {
      _layout = true;
    }
    String uuid = Uuid().v1();
    purchaseId = uuid;
    _getDetails();

  }

  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final revers =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
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
        title: Text("Create Purchases"),
        actions: [
          _products.length==0
              ? SizedBox()
              : IconButton(
            onPressed: (){
              dialogAddPayment(context,_products.length);
            },
            icon: Icon(Icons.check),
            tooltip: 'Finish by recording payment',
            color: secBtn,
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: ()async{
          _products.length==0
              ? Navigator.pop(context)
              : dialogAddPayment(context,_products.length);
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: BouncingScrollPhysics(),
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
                                    Text(_products.length.toString(), style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),)
                                  ],
                                ),
                              );
                            }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CardButton(
                              text: 'ADD',
                              backcolor: Colors.white,
                              icon: Icon(Icons.add, color: Colors.black,size: 19,),
                              forecolor: Colors.black, onTap: () {
                              dialogSelectGood(context);
                            },),
                            _products.isEmpty
                                ? SizedBox()
                                : CardButton(
                              text: 'CLEAR',
                              backcolor: Colors.white,
                              icon: Icon(Icons.clear_all, color: screenBackgroundColor,size: 19,),
                              forecolor: screenBackgroundColor,
                              onTap: () {
                                setState(() {
                                  _purchase = [];
                                  _products = [];
                                  totalPrice = 0.0;
                                });
                              },
                            ),
                            CardButton(
                              text: _layout?'LIST':'TABLE',
                              backcolor: Colors.white,
                              icon: Icon(_layout?Icons.list:Icons.table_chart_sharp, color: screenBackgroundColor,size: 19,),
                              forecolor: screenBackgroundColor,
                              onTap: () {
                                setState(() {
                                  _layout=!_layout;
                                });
                              },
                            ),
                            CardButton(
                              text:'RELOAD',
                              backcolor: screenBackgroundColor,
                              icon: Icon(Icons.refresh, size: 19, color: Colors.white,), forecolor: Colors.white,
                              onTap: () {
                                _getData();
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
                                  color: normal,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal:10.0),
                                child: Text('Purchase Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500 , color: normal),),
                              ),
                              Expanded(
                                child: Divider(
                                  height: 1,
                                  color: normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                              hintStyle: TextStyle(color:secondaryColor),
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
                                      _loading? SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 2,
                                        ),
                                      ) : SizedBox()
                                    ],
                                  ),
                                  SizedBox(height: 20,),
                                  _layout
                                      ? SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    physics: NeverScrollableScrollPhysics(),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                      child: DataTable(
                                        headingRowHeight: 30,
                                        headingRowColor: MaterialStateColor.resolveWith((states) {
                                          return screenBackgroundColor;
                                        }),
                                        columns: [
                                          DataColumn(
                                              label: Text("PRODUCT NAME", style: TextStyle(color: Colors.white),),
                                              numeric: false,
                                              tooltip: 'Click here to sort list by name'
                                          ),
                                          DataColumn(
                                              label: Text("CATEGORY", style: TextStyle(color: Colors.white),),
                                              numeric: false,
                                              tooltip: 'Click here to sort list by category'
                                          ),

                                          DataColumn(
                                            label: Text("ML", style: TextStyle(color: Colors.white),),
                                            numeric: false,
                                          ),
                                          DataColumn(
                                            label: Text("QUANTITY", style: TextStyle(color: Colors.white),),
                                            numeric: false,
                                          ),
                                          DataColumn(
                                              label: Text("SUPPLIER", style: TextStyle(color: Colors.white),),
                                              numeric: false,
                                              tooltip: 'Click here to sort list by Supplier'

                                          ),
                                          DataColumn(
                                            label: Text("BUYING PRICE", style: TextStyle(color: Colors.white),),
                                            numeric: false,
                                          ),
                                          DataColumn(
                                            label: Text("SELLING PRICE", style: TextStyle(color: Colors.white),),
                                            numeric: false,
                                          ),

                                          DataColumn(
                                            label: Text("ACTION", style: TextStyle(color: Colors.white),),
                                            numeric: false,
                                          ),
                                        ],
                                        rows: filteredList.map((product){
                                          _fltSpplr = _spplr.where((sup) => sup.sid == product.supplier).toList();
                                          _filtPurchas = _purchase.where((element) => element.productid == product.prid).toList();
                                          var prchs = _filtPurchas.isEmpty ? PurchaseModel(purchaseid: ""): _filtPurchas.first;
                                          var qnty = _filtPurchas.isEmpty? 0 : int.parse(_filtPurchas.first.quantity.toString());
                                          String name = product.name.toString();
                                          String category = product.category.toString();
                                          String volume = product.volume.toString();
                                          double buy = double.parse(prchs.bprice.toString());
                                          double sell = double.parse(product.selling.toString());
                                          String supplier = _spplr.isEmpty
                                              ? 'N/A'
                                              :  _spplr.firstWhere((sup) => sup.sid == product.supplier).name.toString();
                                          return DataRow(
                                              cells: [
                                                DataCell(
                                                    Text(name.toString(),style: TextStyle(color: Colors.black),),
                                                    onTap: (){
                                                      // _setValues(inventory);
                                                      // _selectedInv = inventory;
                                                    }
                                                ),
                                                DataCell(
                                                    Text(category.toString(),style: TextStyle(color: Colors.black),),
                                                    onTap: (){
                                                      // _setValues(inventory);
                                                      // _selectedInv = inventory;
                                                    }
                                                ),
                                                DataCell(
                                                    Text(volume.toString(),style: TextStyle(color: Colors.black),),
                                                    onTap: (){
                                                      // _setValues(inventory);
                                                      // _selectedInv = inventory;
                                                    }
                                                ),
                                                DataCell(
                                                    Center(child: Text(qnty.toString(),style: TextStyle(color: Colors.black),)),
                                                    onTap: (){
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
                                                    Text('${TFormat().getCurrency()}${formatNumberWithCommas(buy*qnty)}',style: TextStyle(color: Colors.black),),
                                                    onTap: (){
                                                      // _setValues(inventory);
                                                      // _selectedInv = inventory;
                                                    }
                                                ),
                                                DataCell(
                                                    Text('${TFormat().getCurrency()}${formatNumberWithCommas(sell*qnty)}',style: TextStyle(color: Colors.black),),
                                                    onTap: (){
                                                      // _setValues(inventory);
                                                      // _selectedInv = inventory;
                                                    }
                                                ),

                                                DataCell(
                                                  Center(
                                                      child: PopupMenuButton(
                                                          tooltip: 'Show options',
                                                          child: Icon(Icons.more_vert, color: screenBackgroundColor,),
                                                          onSelected: (value) {
                                                          },
                                                          itemBuilder: (BuildContext context) {
                                                            return [
                                                              PopupMenuItem(
                                                                value: 'delete',
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Icon(Icons.delete_forever, color: revers),
                                                                    SizedBox(width: 5,),
                                                                    Text('Delete',style: TextStyle(
                                                                      color: revers,
                                                                    ),),
                                                                  ],
                                                                ),
                                                                onTap: (){
                                                                  dialogRemoveItem(context, product);
                                                                },
                                                              ),
                                                              PopupMenuItem(
                                                                value: 'edit',
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Icon(Icons.edit, color: revers,
                                                                    ),
                                                                    SizedBox(width: 5,),
                                                                    Text('Edit', style: TextStyle(
                                                                      color: revers,),
                                                                    ),
                                                                  ],
                                                                ),
                                                                onTap: (){
                                                                  dialogEditItem(context, product, prchs);
                                                                },
                                                              ),
                                                            ];
                                                          }
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
                                      : SizedBox(width: 450,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: filteredList.length,
                                        itemBuilder: (context, index){
                                          ProductModel product = filteredList[index];
                                          _filtPurchas = _purchase.where((element) => element.productid == product.prid).toList();

                                          var prchs = _filtPurchas.isEmpty ? PurchaseModel(purchaseid: ""): _filtPurchas.first;
                                          var qnty = _filtPurchas.isEmpty? 0 : int.parse(_filtPurchas.first.quantity.toString());
                                          String name = product.name.toString();
                                          String category = product.category.toString();
                                          String volume = product.volume.toString();
                                          double buy = double.parse(prchs.bprice.toString());
                                          double sell = double.parse(product.selling.toString());
                                          String supplier = _spplr.isEmpty
                                              ? 'N/A'
                                              :  _spplr.firstWhere((sup) => sup.sid == product.supplier).name.toString();
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
                                                                Text(name.toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                                                                SizedBox(width: 10,),
                                                                Text('${category}', style: TextStyle(color: Colors.black54, fontSize: 11),),
                                                                Expanded(child: SizedBox()),
                                                                Text("Units : ${qnty},", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11)),
                                                                SizedBox(width: 5,),
                                                                Text('ML : ${volume}', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 11),),

                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text( 'Supplier : ${supplier}', style: TextStyle(fontSize: 11, color: Colors.black),),
                                                                Expanded(child: SizedBox()),
                                                                Text(
                                                                  "BP: ${TFormat().getCurrency()}${formatNumberWithCommas(buy*qnty)} SP: ${TFormat().getCurrency()}${formatNumberWithCommas(sell*qnty)}",
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
                                                duration: Duration(milliseconds: 500),
                                                alignment: Alignment.topCenter,
                                                curve: Curves.easeInOut,
                                                child: selectedID == product.prid
                                                    ? IntrinsicHeight(
                                                  child: Row(
                                                    children: [

                                                      BottomCallButtons(
                                                          onTap: (){
                                                            dialogRemoveItem(context, product);
                                                          },
                                                          icon: Icon(CupertinoIcons.delete, color: Colors.black,),
                                                          actionColor: Colors.black,
                                                          title: "Delete"
                                                      ),
                                                      VerticalDivider(
                                                        thickness: 0.5,
                                                        width: 15,color: Colors.black12,
                                                      ),
                                                      BottomCallButtons(
                                                          onTap: (){
                                                            dialogEditItem(context, product, prchs);
                                                          },
                                                          icon: Icon(
                                                            Icons.edit,
                                                            color: Colors.black,),
                                                          actionColor: Colors.black,
                                                          title: "Edit"
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
                  )
              ),
              Text(
                Data().message,
                style: TextStyle(color: secondaryColor, fontSize: 10),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: totalPrice == 0
          ? SizedBox()
          : FloatingActionButton.large(
        onPressed: (){
          dialogAddPayment(context,_products.length);
        },
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total', style: TextStyle(color: Colors.black),),
            Text(NumberFormat.compact().format(totalPrice), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            Text('Pay', style: TextStyle(color: Colors.black),),
          ],
        ),
      ),
    );
  }
  void dialogSelectGood(BuildContext context) {
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
          return  SizedBox(width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                DialogTitle(title: 'P R O D U C T S'),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DialogSelectProduct(
                        entity: widget.entity,
                        addProducts: _addProducts,
                        purchaseId: purchaseId,
                        products: _products,
                      ),
                    )
                )
              ],
            ),
          );
        });
  }
  void dialogRemoveItem(BuildContext context, ProductModel product){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final style = TextStyle(color: secondaryColor, fontSize: 12);
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
                DialogTitle(title: 'R E M O V E'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Are you sure you wish to remove ",
                          style: style,
                        ),
                        TextSpan(
                          text: "${product.name} ",
                          style: TextStyle(fontSize: 14)
                        ),
                        TextSpan(
                          text: "from your purchases list?",
                          style: style,
                        ),
                      ]
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                DoubleCallAction(
                    title: "Remove",
                    titleColor: Colors.red,
                    action: (){
                      _products.remove(product);
                      _purchase.removeWhere((element) => element.productid == product.prid);
                      totalPrice = _purchase.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice.toString()) * double.parse(element.quantity.toString())));
                      Navigator.pop(context);
                      setState((){});
                    }
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogEditItem(BuildContext context, ProductModel product, PurchaseModel purchase){
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
                  updateQuantity: _updateQuantity, from: 'CREATE',
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogAddPayment(BuildContext context, int items){
    showDialog(
        context: context,
        builder: (contex)=> Dialog(
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
                  DialogTitle(title: 'A D D  P A Y M E N T'),
                  DialogPayment(
                    amount: totalPrice,
                    updatePaid: _updatePaid,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  _getDetails()async{
    _getData();
    _newSpplr = await Services().getMySuppliers(currentUser.uid);
    await Data().addOrUpdateSuppliersList(_newSpplr).then((response){});
    _getData();
  }
  _getData(){
    _spplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _spplr = _spplr.where((element) => element.eid == widget.entity.eid).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _inventory = _inventory.where((element) => element.eid == widget.entity.eid).toList();
    admin = widget.entity.pid.toString().split(",").first;
    setState(() {
    });
  }
  _updatesdasdasPaid(String amount, String paid, String date, String due, String method)async{
    setState(() {
      _loading = true;
    });
    List<String> uniquePurchase = [];
    List<String> uniqueInv = [];
    List<PurchaseModel> _purchases = [];
    List<InventModel> _inventory = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchases = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();

    for (var purchase in _purchase) {
      purchase.amount = amount;
      purchase.paid = paid;
      purchase.date = date;
      purchase.due = due;
      purchase.type = method;
      int quantity = int.parse(purchase.quantity.toString());
      int invQuantity = int.parse(_inventory.firstWhere((element) => element.productid == purchase.productid).quantity.toString());
      int newQuantity = invQuantity + quantity;

      _purchases.add(purchase);
      _inventory.firstWhere((test) => test.productid == purchase.productid).quantity = newQuantity.toString();

      await Services.addPurchase(purchase).then((response) async {
        if (response == "Success") {
          await Services.updateInvAddQnty(purchase.productid.toString(), purchase.quantity.toString());
          _purchases.firstWhere((element) => element.prcid == purchase.prcid).checked = "true";
        }
      });
    }
    uniquePurchase  = _purchases.map((model) => jsonEncode(model.toJson())).toList();
    uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypurchases', uniquePurchase);
    sharedPreferences.setStringList('myinventory', uniqueInv);
    myPurchases = uniquePurchase;
    myInventory = uniqueInv;
    widget.getPurchase();
    setState(() {
      _loading = false;
    });
    Navigator.pop(context);
  }

  _updatePaid(String amount, String paid, String date, String due, String method)async{
    List<String> uniquePurchase = [];
    List<String> uniqueInv = [];
    List<String> uniquePayments = [];
    List<PurchaseModel> _purchases = [];
    List<InventModel> _inventory = [];
    List<PaymentModel> _payments = [];

    Uuid uuid = Uuid();
    String payid = uuid.v1();

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchases = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _payments = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();

    _purchase.forEach((element) async {
      element.amount = amount;
      element.paid = paid;
      element.date = date;
      element.due = due;
      element.type = method;

      var inv = _inventory.firstWhere((invento) => invento.productid == element.productid);

      int newQuantity = 0;
      int quantity = int.parse(element.quantity!);
      int oldQuantity = int.parse(inv.quantity!);
      newQuantity = quantity+oldQuantity;

      _inventory.firstWhere((invento) => invento.productid == element.productid).quantity = newQuantity.toString();
      _purchases.add(element);
    });

    PaymentModel payment = PaymentModel(
        payid: payid,
        eid: widget.entity.eid,
        pid: widget.entity.pid,
        payerid: currentUser.uid,
        admin: widget.entity.admin,
        saleid: "",
        purchaseid: purchaseId,
        items: _products.length.toString(),
        amount: amount,
        paid: paid,
        type: double.parse(amount) != double.parse(paid)? "PAYABLE" : "PURCHASE",
        method: method,
        checked: "false",
        time: DateTime.now().toString()
    );

    _payments.add(payment);

    uniquePurchase  = _purchases.map((model) => jsonEncode(model.toJson())).toList();
    uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypurchases', uniquePurchase);
    sharedPreferences.setStringList('myinventory', uniqueInv);
    sharedPreferences.setStringList('mypayments', uniquePayments );
    myPurchases = uniquePurchase;
    myInventory = uniqueInv;
    myPayments = uniquePayments;
    widget.getPurchase.call();

    _purchase.forEach((element) async {
      int quantity = int.parse(element.quantity!);
      await Services.addPurchase(element).then((response)async{
        if(response=="Success"){
          element.checked = 'true';
          await Services.updateInvAddQnty(element.productid.toString(), quantity.toString());
          uniquePurchase  = _purchases.map((model) => jsonEncode(model.toJson())).toList();
          sharedPreferences.setStringList('mypurchases', uniquePurchase);
          myPurchases = uniquePurchase;
          widget.getPurchase();
        }
      });
    });

    await Services.addPayment(payment).then((response){
      print(response);
      if(response=="Success"){
        payment.checked = "true";
      }
    });
    uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypayments', uniquePayments );
    myPayments = uniquePayments;
  }

  _addProducts(List<ProductModel> products, List<PurchaseModel> purchase){
    _products.addAll(products);
    _purchase.addAll(purchase);
    _purchase.forEach((p){
      print(p.toJson());
    });
    totalPrice = _purchase.fold(0.0, (previousValue, element) =>
    previousValue + (double.parse(element.bprice.toString()) * int.parse(element.quantity.toString())));
    setState(() {
    });
  }
  _updateQuantity(PurchaseModel purchase, String quantity){
    _purchase.firstWhere((element) => element.prcid == purchase.prcid).quantity = quantity;
    totalPrice = _purchase.fold(0.0, (previousValue, element) =>
    previousValue + (double.parse(element.bprice.toString()) * int.parse(element.quantity.toString())));
    setState(() {

    });
  }
  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
