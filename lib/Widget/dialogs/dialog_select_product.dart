import 'dart:convert';

import 'package:TallyApp/main.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:uuid/uuid.dart';

import '../../models/entities.dart';
import '../../models/inventories.dart';
import '../../models/products.dart';
import '../../models/purchases.dart';
import '../../models/suppliers.dart';

class DialogSelectProduct extends StatefulWidget {
  final EntityModel entity;
  final Function addProducts;
  final String purchaseId;
  final List<ProductModel> products;
  const DialogSelectProduct({super.key, required this.entity, required this.addProducts, required this.purchaseId, required this.products});

  @override
  State<DialogSelectProduct> createState() => _DialogSelectProductState();
}

class _DialogSelectProductState extends State<DialogSelectProduct> {
  TextEditingController _search = TextEditingController();
  List<ProductModel> _prd = [];
  List<ProductModel> _filteredPrdcts = [];
  List<ProductModel> _newprd = [];
  List<PurchaseModel> _purchase = [];
  List<InventModel> inv = [];
  List<InventModel> newInv = [];
  List<InventModel> filtInv = [];
  List<SupplierModel> _spplr = [];
  List<SupplierModel> _fltSpplr = [];

  String prcid = "";

  bool isAllSelected  = false;
  bool _loading = false;
  bool _uploading = false;
  bool isFilled = false;

  int count = 0;
  int noQuantity = 0;

  _getData(){
    inv = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _prd = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _spplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    inv = inv.where((element) => element.eid == widget.entity.eid).toList();
    _prd = _prd.where((element) => element.eid == widget.entity.eid).toList();
    _filteredPrdcts = _prd.where((prd) => inv.any((invento) => prd.prid == invento.productid)).toList();
    List<ProductModel> itemsToRemove = _filteredPrdcts.where((a) => widget.products.any((b) => b.prid == a.prid)).toList();
    _filteredPrdcts.removeWhere((a) => itemsToRemove.contains(a));
    _spplr = _spplr.where((element) => element.eid == widget.entity.eid).toList();
    setState(() {

    });
  }

  _addPurchase()async{
    widget.addProducts(_newprd, _purchase);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
          content: Text("${_newprd.length} Products Added to Purchase list")
      )
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }


  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final revers =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final reverse1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      _filteredPrdcts.forEach((item) {
        if (item.name.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.category.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.supplier.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _filteredPrdcts;
    }
    final size = MediaQuery.of(context).size;
    return inv.length == 0
        ? Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: reverse1,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Icon(CupertinoIcons.bell_fill),
          ),
          Text("Attention", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
          Text(
            "Your inventory list is currently empty. Please add products to your inventory list to enable purchase recording.",
            style: TextStyle(color: secondaryColor, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10,),
          MaterialButton(
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
            ),
            splashColor: CupertinoColors.activeBlue,
            minWidth: 300,
            padding: EdgeInsets.all(20),
            onPressed: (){Navigator.pop(context);},
            child: Text("Close", style: TextStyle(color: Colors.white)),
            color: Colors.black,
          ),
        ],
      ),
    )
        : Column(
      children: [
        Text('Enter details based on your items inorder to promote better user experience',
          textAlign: TextAlign.center,
          style: TextStyle(color: secondaryColor, fontSize: 12),
        ),
        SizedBox(height: 8,),
        TextFormField(
          controller: _search,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: "Search",
            fillColor: color1,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(5)
              ),
              borderSide: BorderSide.none,
            ),
            hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
            prefixIcon: Icon(CupertinoIcons.search, size: 20,color: secondaryColor),
            prefixIconConstraints: BoxConstraints(
                minWidth: 40,
                minHeight: 30
            ),
            suffixIcon: isFilled?InkWell(
                onTap: (){
                  _search.clear();
                  setState(() {
                    isFilled = false;
                  });
                },
                borderRadius: BorderRadius.circular(100),
                child: Icon(Icons.cancel, size: 20,color: secondaryColor)
            ) :SizedBox(),
            suffixIconConstraints: BoxConstraints(
                minWidth: 40,
                minHeight: 30
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
            filled: true,
            isDense: true,
          ),
          onChanged:  (value) => setState((){
            if(value.isNotEmpty){
              isFilled = true;
            } else {
              isFilled = false;
            }
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end  ,
          children: [
            filteredList.length == 0
                ? SizedBox()
                : TextButton(
                onPressed: (){
                  setState(() {
                    isAllSelected = !isAllSelected;
                    if (isAllSelected) {
                      for (var index = 0; index < _filteredPrdcts.length; index++) {
                        _filteredPrdcts[index].isChecked = true;
                        const uuid = Uuid();
                        prcid = uuid.v1();
                        if(_purchase.any((element) => element.productid.toString() == _filteredPrdcts[index].prid)){
                        } else {
                          _newprd.add(_filteredPrdcts[index]);
                          _purchase.add(
                              PurchaseModel(
                                purchaseid: widget.purchaseId,
                                amount: '0.0',
                                prcid: prcid+index.toString(),
                                eid: widget.entity.eid,
                                pid: widget.entity.pid,
                                purchaser: currentUser.uid,
                                productid: _filteredPrdcts[index].prid,
                                quantity: "1",
                                bprice: _filteredPrdcts[index].buying,
                                paid: '0.0',
                                type: '',
                                checked: 'false',
                                due: DateTime.now().toString(),
                                time: DateTime.now().toString(),
                                date: DateTime.now().toString(),
                              )
                          );
                        };
                      }
                    } else {
                      for (var item in _filteredPrdcts) {
                        item.isChecked = false;
                      }
                      _purchase.clear();
                      _newprd.clear();
                    }
                  });
                },
                child: Text(isAllSelected? "Select None" : "Select All", style: TextStyle(color: secBtn),))
          ],
        ),
        Expanded(
          child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index){
                ProductModel product = filteredList[index];
                _fltSpplr = _spplr.where((sup) => sup.sid == product.supplier).toList();
                filtInv = inv.where((element) => element.productid == product.prid).toList();
                var qnty = filtInv.isEmpty? 0: int.parse(filtInv.first.quantity!);
                var supplier = _fltSpplr.isEmpty? "N/A" : _fltSpplr.first.name;
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white12,
                              child: Center(child: LineIcon.box(color: normal,)),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(product.name.toString(), style: TextStyle(color: normal, fontWeight: FontWeight.w600),),
                                      SizedBox(width: 10,),
                                      Text('${product.category}, ', style: TextStyle(color: color5, fontSize: 11),),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 5,
                                    children: [
                                      Text('Volume : ${product.volume},', style: TextStyle(fontSize: 11, color: normal)),
                                      Text('Supplier : ${supplier}', style: TextStyle(fontSize: 11, color: normal),),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Text('quantity :  ${qnty}',style: TextStyle(color: normal, fontSize: 11, fontWeight: FontWeight.w700),),
                            // _prch.length != 0 ? SizedBox()
                            //     :IconButton(
                            //     onPressed: (){
                            //       _addInventory(_inventories.first);
                            //
                            //     },
                            //     icon: Icon(Icons.add)
                            // )
                          ],
                        ),
                      ),
                    ),
                    CupertinoCheckbox(
                        value: product.isChecked,
                        activeColor: Colors.cyanAccent,
                        checkColor: Colors.black,
                        onChanged: (value){
                          setState(() {
                            product.isChecked = value ?? false;
                            isAllSelected = false;
                            const uuid = Uuid();
                            prcid = uuid.v1();
                            PurchaseModel purchaseModel = PurchaseModel(
                              purchaseid: widget.purchaseId,
                              amount: '0.0',
                              prcid: prcid+index.toString(),
                              eid: widget.entity.eid,
                              pid: widget.entity.pid,
                              purchaser: currentUser.uid,
                              productid: product.prid,
                              quantity: "1",
                              bprice: product.buying,
                              paid: '0.0',
                              type: '',
                              due: DateTime.now().toString(),
                              time: DateTime.now().toString(),
                              checked: "false",
                            );
                            if(product.isChecked==true){
                              _newprd.add(product);
                              _purchase.add(purchaseModel);
                            } else {
                              _newprd.removeWhere((element) => element.prid == product.prid);
                              _purchase.removeWhere((element) => element.productid == product.prid);
                            }
                          });
                        })
                  ],
                );
              }),
        ),
        _purchase.length == 0
            ? SizedBox()
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
          child: InkWell(
            onTap: (){
              if(_uploading){

              } else {
                _addPurchase();
              }
            },
            child: Container(
              width: size.width,
              padding: EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                  color: secBtn,
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _uploading?SizedBox(width:15, height: 15,child: CircularProgressIndicator(color: Colors.black,strokeWidth: 1,)):SizedBox(),
                  SizedBox(width: _uploading?10:0,),
                  _uploading
                      ? Text("UPLOADING ${_purchase.length} ITEMS", style: TextStyle(color: Colors.black), )
                      : Text("ADD ${_purchase.length} ITEMS", style: TextStyle(color: Colors.black),),
                ],
              ),
            ),
          ),
        )

      ],
    );
  }
}
