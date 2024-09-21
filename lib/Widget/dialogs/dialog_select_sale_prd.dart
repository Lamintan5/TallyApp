import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../models/entities.dart';
import '../../models/inventories.dart';
import '../../models/products.dart';
import '../../models/sales.dart';
import '../../models/suppliers.dart';
import '../../utils/colors.dart';
import '../items/item_select_sale.dart';

class DialogSelectSalesPrd extends StatefulWidget {
  final Function addSale;
  final String saleId;
  final EntityModel entity;
  final List<ProductModel> products;
  const DialogSelectSalesPrd({super.key, required this.addSale, required this.saleId, required this.entity, required this.products});

  @override
  State<DialogSelectSalesPrd> createState() => _DialogSelectSalesPrdState();
}

class _DialogSelectSalesPrdState extends State<DialogSelectSalesPrd> {
  TextEditingController _search = TextEditingController();
  List<ProductModel> _prd = [];
  List<ProductModel> _filteredPrdcts = [];
  List<ProductModel> _newprd = [];
  List<SaleModel> _sale = [];
  List<InventModel> inv = [];
  List<InventModel> newInv = [];
  List<InventModel> filtInv = [];
  List<SupplierModel> _spplr = [];
  List<SupplierModel> _fltSpplr = [];

  String sid = '';

  bool isAllSelected  = false;
  bool _loading = false;
  bool _uploading = false;

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

  _addSale()async{
    widget.addSale(_newprd, _sale);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            showCloseIcon: true,
            content: Text("${_newprd.length} Products Added to Sales list")
        )
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
    String uuid = Uuid().v1();
    sid = uuid;
  }

  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final reverse1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
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
    return  inv.length == 0
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
            "Your inventory list is currently empty. Please add products to your inventory list to enable sale recording.",
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
        SizedBox(height: 8,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: TextFormField(
            controller: _search,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "🔎  Search for Products...",
              fillColor: color1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(5)
                ),
                borderSide: BorderSide.none,
              ),
              filled: true,
              isDense: true,
              contentPadding: EdgeInsets.all(10),
            ),
            onChanged:  (value) => setState((){}),
          ),
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
                          String iid = inv.firstWhere((element) => element.productid == _filteredPrdcts[index].prid).iid;
                          int quantity = int.parse(inv.firstWhere((element) => element.productid == _filteredPrdcts[index].prid).quantity!);
                          _filteredPrdcts[index].isChecked = true;
                          const uuid = Uuid();
                          sid = uuid.v1();
                          if(_sale.any((element) => element.productid == _filteredPrdcts[index].prid)){

                          } else {
                            SaleModel saleModel = SaleModel(
                              saleid: widget.saleId,
                              sid: sid+index.toString(),
                              iid: iid,
                              eid: widget.entity.eid,
                              pid: widget.entity.pid,
                              sellerid: currentUser.uid,
                              productid: _filteredPrdcts[index].prid,
                              customer: "",
                              phone: "",
                              bprice: _filteredPrdcts[index].buying,
                              sprice: _filteredPrdcts[index].selling,
                              amount: "0.0",
                              paid: '0.0',
                              method: '',
                              quantity: "1",
                              date: "",
                              due: "",
                              checked: 'false',
                              time: DateTime.now().toString(),
                            );
                            if(quantity < 1){

                            } else {
                              _sale.add(saleModel);
                              _newprd.add(_filteredPrdcts[index]);
                            }
                          };
                        }
                      } else {
                        for (var item in _filteredPrdcts) {
                          item.isChecked = false;
                        }
                        _sale.clear();
                      }
                    });
                  },
                  child: Text(isAllSelected? "Select None" : "Select All", style: TextStyle(color: secBtn),)
                )
          ],
        ),
        Expanded(
          child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index){
                ProductModel product = filteredList[index];
                filtInv = inv.where((element) => element.productid == product.prid).toList();
                _fltSpplr = _spplr.where((sup) => sup.sid == product.supplier).toList();
                var qnty = filtInv.isEmpty? 0: int.parse(filtInv.first.quantity!);
                var invid = filtInv.isEmpty? "" : filtInv.first.iid;
                var supplier = _fltSpplr.isEmpty? "N/A" : _fltSpplr.first.name;
                return Row(
                  children: [
                    Expanded(
                      child: ItemSlctPrdSle(
                        entity: widget.entity,
                        product: product,
                        saleId: widget.saleId,
                        quantity: qnty,
                        supplier: supplier!,
                      ),
                    ),
                    qnty < 1
                        ? SizedBox()
                        : CupertinoCheckbox(
                        value: product.isChecked,
                        activeColor: Colors.cyanAccent,
                        checkColor: Colors.black,
                        onChanged: (value){
                          setState(() {
                            product.isChecked = value ?? false;
                            isAllSelected = false;
                            const uuid = Uuid();
                            sid = uuid.v1();
                            SaleModel saleModel = SaleModel(
                              saleid: widget.saleId,
                              sid: sid,
                              iid: invid,
                              eid: widget.entity.eid,
                              pid: widget.entity.pid,
                              sellerid: currentUser.uid,
                              productid: product.prid,
                              customer: "",
                              phone: "",
                              bprice: product.buying,
                              sprice: product.selling,
                              amount: "0.0",
                              paid: '0.0',
                              method: '',
                              quantity: "1",
                              date: "",
                              due: "",
                              checked: 'false',
                              time: DateTime.now().toString()
                            );
                            if(product.isChecked==true){
                              _sale.add(saleModel);
                              _newprd.add(product);
                            } else {
                              _newprd.removeWhere((element) => element.prid == product.prid);
                              _sale.removeWhere((element) => element.productid == product.prid);
                            }
                          });
                        })
                  ],
                );
              }),
        ),
        _sale.length == 0
            ? SizedBox()
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
          child: InkWell(
            onTap: (){
              _addSale();
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
                      ? Text("UPLOADING ${_sale.length} ITEMS", style: TextStyle(color: Colors.black), )
                      : Text("ADD ${_sale.length} ITEMS", style: TextStyle(color: Colors.black),),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
