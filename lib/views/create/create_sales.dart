import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/dialogs/dialog_edit_sale_qnty.dart';
import 'package:TallyApp/Widget/dialogs/dialog_pay_sales.dart';
import 'package:TallyApp/Widget/dialogs/dialog_select_sale_prd.dart';
import 'package:TallyApp/Widget/text/text_format.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/inventories.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../Widget/buttons/bottom_call_buttons.dart';
import '../../Widget/buttons/card_button.dart';
import '../../Widget/dialogs/call_actions/double_call_action.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../api/mpesa-api.dart';
import '../../main.dart';
import '../../models/billing.dart';
import '../../models/data.dart';
import '../../models/payments.dart';
import '../../models/products.dart';
import '../../models/sales.dart';
import '../../models/suppliers.dart';
import '../../resources/services.dart';
import '../../resources/socket.dart';
import '../../utils/colors.dart';

class CreateSales extends StatefulWidget {
  final EntityModel entity;
  final Function getData;
  const CreateSales({super.key, required this.entity, required this.getData});

  @override
  State<CreateSales> createState() => _CreateSalesState();
}

class _CreateSalesState extends State<CreateSales> {
  Country _country = CountryParser.parseCountryCode(deviceModel.country == null? 'US' : deviceModel.country.toString());
  TextEditingController _search = TextEditingController();

  List<String> title = ['Total Items',];
  List<ProductModel> _products = [];
  List<SaleModel> _sale = [];
  List<SaleModel> _filtSale = [];
  List<SupplierModel> _spplr = [];
  List<SupplierModel> _fltSpplr = [];
  List<SupplierModel> _newSpplr = [];
  List<InventModel> _inventory = [];

  bool _layout = true;
  bool _loading = false;
  bool _prompted = false;

  String saleId = '';
  String admin = '';
  String selectedID = '';
  String _accessToken = '';
  String cPhone = "";

  double totalPrice = 0.0;


  void _listenToSocketEvents() {
    final socket = SocketManager().socket;
    socket.on('pay', (pay) async {
      if (!mounted) return;
      print('Event received: $pay');
      if (pay['accessToken'] == _accessToken) {
        if (pay['status'] == "Success") {
          // paymodel.payid == pay['payid'];
          bool isSuccess = false;
          //= await Data().addPayment(paymodel, widget.reload);
          if (isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment was recorded successfully✔️'),
                showCloseIcon: true,
              ),
            );
            Navigator.pop(context);
          } else {
            setState(() {
              // _prompted = false;
            });
          }
        } else {
          setState(() {
            // _prompted = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(pay['resultDesc']),
              showCloseIcon: true,
            ),
          );
        }
      }
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
    String uuid = Uuid().v1();
    saleId = uuid;
    _getDetails();
  }


  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
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
        title: Text("Create Sales"),
        actions: [
          _products.length==0
              ? SizedBox()
              : IconButton(
            onPressed: (){
              dialogAddPayment(context,);
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
              : dialogAddPayment(context);
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Expanded(
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
                                    Text(_products.length.toString(), style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),)
                                  ],
                                ),
                              );
                            }),
                        _prompted?Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
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
                                  Icon(Icons.dialpad, size: 30, color: Colors.black,),
                                  SizedBox(width: 15,),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Prompted", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),),
                                        RichText(
                                          textAlign: TextAlign.start,
                                            text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: 'A prompt has been successfully sent to ',
                                                      style: TextStyle(color: Colors.black)
                                                  ),
                                                  TextSpan(
                                                      text: '+${cPhone}. ',
                                                      style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600)
                                                  ),
                                                  TextSpan(
                                                      text: "Kindly enter your PIN to complete the transaction.",
                                                      style: TextStyle(color: Colors.black)
                                                  )
                                                ]
                                            )
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 15,),
                                  SizedBox(width: 20,height: 20, child: CircularProgressIndicator(color: Colors.black,strokeWidth: 3,))
                                ],
                              ),
                            ),
                          ),
                        ):SizedBox(),
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
                            _products.isEmpty
                                ? SizedBox()
                                : CardButton(
                                    text: 'CLEAR',
                                    backcolor: Colors.white,
                                    icon: Icon(Icons.clear_all, color: screenBackgroundColor,size: 19,),
                                    forecolor: screenBackgroundColor,
                                    onTap: () {
                                      setState(() {
                                        _prompted = false;
                                        _sale = [];
                                        _products = [];
                                        totalPrice = 0.0;
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
                                  color: reverse,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal:10.0),
                                child: Text('Sales Table', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500 , color: reverse),),
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
                                        headingTextStyle: TextStyle(color: Colors.white),
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
                                          _filtSale = _sale.where((element) => element.productid == product.prid).toList();
                                          var sprice = _filtSale.isEmpty ? 0.0 : double.parse(_filtSale.first.sprice.toString());
                                          var bprice = _filtSale.isEmpty ? 0.0 : double.parse(_filtSale.first.bprice.toString());
                                          var qnty = _filtSale.isEmpty ? 0 : int.parse(_filtSale.first.quantity.toString());
                                          var amount = _filtSale.isEmpty ? 0.0 : double.parse(_filtSale.first.amount.toString());
                                          var sid = _filtSale.isEmpty ? '' : _filtSale.first.sid.toString();
                                          var suppName = _fltSpplr.isEmpty ? 'N/A' : _fltSpplr.first.name.toString();
                                          var salemodel = _filtSale.isEmpty ? SaleModel(saleid: "") : _filtSale.first;
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
                                                    Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(bprice)}',style: TextStyle(color: Colors.black),),
                                                    onTap: (){
                                                      // _setValues(inventory);
                                                      // _selectedInv = inventory;
                                                    }
                                                ),
                                                DataCell(
                                                    Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(sprice)}',style: TextStyle(color: Colors.black),),
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
                                                                    Icon(Icons.delete_forever, color: reverse),
                                                                    SizedBox(width: 5,),
                                                                    Text('Delete',style: TextStyle(
                                                                      color: reverse,
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
                                                                    Icon(Icons.edit, color: reverse,
                                                                    ),
                                                                    SizedBox(width: 5,),
                                                                    Text('Edit', style: TextStyle(
                                                                      color: reverse,),
                                                                    ),
                                                                  ],
                                                                ),
                                                                onTap: (){
                                                                  dialogEditItem(context, product, salemodel);
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
                                      : SizedBox(width: 500,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: filteredList.length,
                                        itemBuilder: (context, index){
                                          ProductModel product = filteredList[index];
                                          _filtSale = _sale.where((element) => element.productid == product.prid).toList();
                                          _fltSpplr = _spplr.where((sup) => sup.sid == product.supplier).toList();
                                          var salemodel = _filtSale.isEmpty ? SaleModel(saleid: ""): _filtSale.first;
                                          var qnty = _filtSale.isEmpty? 0 : int.parse(_filtSale.first.quantity.toString());
                                          var suppName = _fltSpplr.isEmpty ? 'N/A' : _fltSpplr.first.name.toString();;
                                          var bprice = _filtSale.isEmpty? 0.0: double.parse(_filtSale.first.bprice.toString());
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
                                                                Text(product.name.toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                                                                SizedBox(width: 10,),
                                                                Text('${product.category}', style: TextStyle(color: Colors.black54, fontSize: 11),),
                                                                Expanded(child: SizedBox()),
                                                                Text("Units : ${qnty},", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11)),
                                                                SizedBox(width: 5,),
                                                                Text('ML : ${product.volume}', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 11),),

                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(_fltSpplr.length == 0 ? 'Supplier not available' : 'Supplier : ${_fltSpplr.first.name}', style: TextStyle(fontSize: 11, color: Colors.black),),
                                                                Expanded(child: SizedBox()),
                                                                Text(
                                                                  "BP: ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(product.buying.toString()))} SP: ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(product.selling.toString()))}",
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
                                                            dialogEditItem(context, product, salemodel);
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
      floatingActionButton: _products.length==0
          ? SizedBox()
          : FloatingActionButton.large(
        onPressed: (){
          dialogAddPayment(context);
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
  void dialogAddPayment(BuildContext context){
    showDialog(
        context: context,
        builder: (contex)=> Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: SizedBox(width: 500,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTitle(title: 'A D D  P A Y M E N T'),
                  DialogPaySales(
                    amount: totalPrice,
                    updatePaid: _updatePaid,
                    entity: widget.entity, initiateSTKPush: initiateStkPush,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
  void dialogSelectGood(BuildContext context){
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
          return SizedBox(
            width: 500,
            child: Column(
              children: [
                DialogTitle(title: 'P R O D U C T S'),
                Expanded(
                    child: DialogSelectSalesPrd(
                    addSale: _addProducts,
                    saleId: saleId,
                    entity: widget.entity,
                    products: _products
                ))
              ],
            ),
          );
    });
  }
  void dialogRemoveItem(BuildContext context, ProductModel product){
    final style = TextStyle(color: secondaryColor, fontSize: 12);
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    showDialog(context: context, builder: (context){
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(
          width: 500,
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
                              style: TextStyle(fontSize: 14, color: reverse)
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
                      _sale.removeWhere((element) => element.productid == product.prid);
                      totalPrice = _sale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
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
  void dialogEditItem(BuildContext context, ProductModel product, SaleModel sale){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    TextEditingController _quantity = TextEditingController();
    final style = TextStyle(color: secondaryColor, fontSize: 12);
    showDialog(context: context, builder: (context){
      return Dialog(
        backgroundColor: dilogbg,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(width: 500,
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
  void initiateStkPush(BillingModel bill, String accessToken, String amount, String paid, String method, String name, String phone, String date, String due) async {
    final mpesaService = MpesaApiService();

    print("Token : ${accessToken}, BNo : ${bill.businessno}, Paid : ${paid}, Phone : ${phone}, ANo : ${bill.accountno}");

    setState(() {
      _prompted = true;
      cPhone = phone;
      _accessToken = accessToken;
    });
    
    try {
      final response = await mpesaService.stkPush(
          accessToken: accessToken,
          businessShortCode: bill.businessno.toString(),
          amount: paid,
          phoneNumber: phone,
          accountReference: bill.accountno.toString(),
      );

      if (response['success'] == true) {
        setState(() {
          _prompted = true;
          _loading = false;
        });

        print("STK Push initiated successfully: ${response['data']}");
      } else {
        setState(() {
          _prompted = false;
          _loading = false;
        });
        print("STK Push failed: ${response['error']}");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${response['details']['errorMessage']}'),
              showCloseIcon: true,
            )
        );
      }
    } catch (e) {
      print("Exception occurred during STK Push: $e");

    }
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

  _addProducts(List<ProductModel> products, List<SaleModel> sales){
    _products.addAll(products);
    _sale.addAll(sales);
    totalPrice = _sale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
    setState(() {

    });
  }
  _updateQuantity(SaleModel sale, String selling, String quantity){
    _sale.firstWhere((element) => element.sid == sale.sid).quantity = quantity;
    _sale.firstWhere((element) => element.sid == sale.sid).sprice = selling;
    totalPrice = _sale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
    setState(() {

    });
  }
  _updatePaid(String amount, String paid, String method, String name, String phone, String date, String due)async{
    List<String> uniqueSales= [];
    List<String> uniqueInv = [];
    List<String> uniquePayments = [];
    List<SaleModel> _sales = [];
    List<InventModel> _inventory = [];
    List<PaymentModel> _payments = [];

    Uuid uuid = Uuid();
    String payid = uuid.v1();

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _sales = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _payments = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();
    print("Amount : $amount");
    print("Paid : $paid");

    _sale.forEach((element) async {
      element.amount = amount;
      element.paid = paid;
      element.customer = name;
      element.phone = phone;
      element.date = date;
      element.due = due;
      element.method = method;

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
    });

    PaymentModel payment = PaymentModel(
      payid: payid,
      eid: widget.entity.eid,
      pid: widget.entity.pid,
      payerid: currentUser.uid,
        admin: widget.entity.admin,
      saleid: saleId,
      purchaseid: "",
      items: _products.length.toString(),
      amount: amount,
      paid: paid,
      type: double.parse(amount) != double.parse(paid)? "RECEIVABLE" : "SALE",
      method: method,
      checked: "false",
      time: DateTime.now().toString()
    );

    _payments.add(payment);

    uniqueSales = _sales.map((model) => jsonEncode(model.toJson())).toList();
    uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myinventory', uniqueInv);
    sharedPreferences.setStringList('mysales', uniqueSales);
    sharedPreferences.setStringList('mypayments', uniquePayments );
    myInventory = uniqueInv;
    mySales = uniqueSales;
    myPayments = uniquePayments;
    widget.getData();

    _sale.forEach((element) async {
      int quantity = int.parse(element.quantity.toString());
      await Services.addSale(element).then((response)async{
        if(response=="Success"){
          element.checked = 'true';
          await Services.updateInvSubQnty(element.productid.toString(), quantity.toString());
          uniqueSales = _sales.map((model) => jsonEncode(model.toJson())).toList();
          sharedPreferences.setStringList('mysales', uniqueSales);
          mySales = uniqueSales;
          widget.getData();
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

  
}
