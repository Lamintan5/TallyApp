import 'dart:convert';

import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/suppliers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:uuid/uuid.dart';

import '../../models/data.dart';
import '../../models/inventories.dart';
import '../../models/products.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';
import '../items/item_products.dart';
import '../text/text_format.dart';

class DialogAddInv extends StatefulWidget {
  final EntityModel entity;
  final Function addInv;
  final List<ProductModel> products;
  const DialogAddInv({super.key, required this.entity, required this.addInv, required this.products});

  @override
  State<DialogAddInv> createState() => _DialogAddInvState();
}

class _DialogAddInvState extends State<DialogAddInv> {
  TextEditingController _search = TextEditingController();
  List<ProductModel> prd = [];
  List<ProductModel> _newPrd = [];
  List<InventModel> _inv = [];
  List<SupplierModel> _newSpplr = [];
  List<SupplierModel> _spplr = [];
  String iid = "";
  bool _loading = false;
  bool _uploading = false;
  bool isAllSelected  = false;
  bool isFilled = false;

  int count = 0;

  _getDetails()async{
    _getData();
    await Data().checkProducts(prd, (){});
    _newPrd = await Services().getMyPrdct(currentUser.uid);
    _newSpplr = await Services().getMySuppliers(currentUser.uid);
    await Data().addOrUpdateProductsList(_newPrd);
    await Data().addOrUpdateSuppliersList(_newSpplr).then((response){});
    _getData();
  }

  _getData()async{
    prd = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _spplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    prd = prd.where((element) => element.eid == widget.entity.eid).toList();
    List<ProductModel> itemsToRemove = prd.where((a) => widget.products.any((b) => b.prid == a.prid)).toList();
    prd.removeWhere((a) => itemsToRemove.contains(a));
    setState(() {

    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final revers =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      prd.forEach((item) {
        if (TFormat().decryptField(item.name.toString(), widget.entity.eid).toLowerCase().contains(_search.text.toString().toLowerCase())
            || TFormat().decryptField(item.category.toString(), widget.entity.eid).toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = prd;
    }
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        prd.isEmpty
            ? SizedBox()
            : Text('Select an item from the products list below and add to inventory list in order to start monetization.',
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryColor, fontSize: 12),
              ),
        prd.isEmpty
            ? SizedBox()
            : TextFormField(
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
        prd.isEmpty
            ? SizedBox()
            : Row(
          mainAxisAlignment: MainAxisAlignment.end  ,
          children: [
            filteredList.length == 0
                ? SizedBox()
                : TextButton(
                onPressed: (){
                  setState(() {
                    isAllSelected = !isAllSelected;
                    if (isAllSelected) {
                      for (var index = 0; index < prd.length; index++) {;
                      prd[index].isChecked = true;
                      const uuid = Uuid();
                      iid = uuid.v1();
                      if(_inv.any((element) => element.productid == prd[index].prid)){

                      } else {
                        _inv.add(InventModel(
                            iid: iid+index.toString(),
                            eid: widget.entity.eid.toString(),
                            pid: widget.entity.pid,
                            productid: prd[index].prid,
                            quantity: TFormat().encryptText('1', widget.entity.eid),
                            type: TFormat().encryptText('PRODUCT', widget.entity.eid),
                            checked: 'false',
                            time: DateTime.now().toString()
                        ));
                      }
                      }

                    } else {
                      for (var item in prd) {
                        item.isChecked = false;
                      }
                      _inv.clear();
                    }
                  });
                },
                child: Text(isAllSelected? "Select None" : "Select All"))
          ],
        ),
        prd.isEmpty
            ? Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/add/box.png"),
                  Text("You do not have any items yet",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  Text("Please navigate to the products section and add items to your list.",
                    style: TextStyle(color: secondaryColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
            : Expanded(
          child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index){
                ProductModel product = filteredList[index];
                String name = TFormat().decryptField(product.name.toString(), widget.entity.eid.toString());
                String category = TFormat().decryptField(product.category.toString(), widget.entity.eid.toString());
                String volume = TFormat().decryptField(product.volume.toString(), widget.entity.eid.toString());
                String supplier = _spplr.isEmpty
                    ? 'Supplier not available'
                    :  TFormat().decryptField(_spplr.firstWhere((sup) => sup.sid == product.supplier).name.toString(), widget.entity.eid.toString());
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white12,
                              child: Center(child: LineIcon.box(color: Colors.white,)),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
                                      SizedBox(width: 10,),
                                      Text('${category}', style: TextStyle(color: Colors.white54, fontSize: 11),),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 5,
                                    children: [
                                      Text("Volume : ${volume}",style: TextStyle(fontSize: 11, color: Colors.white)),
                                      _loading
                                          ? Text('Loading Suppliers...', style: TextStyle(fontSize: 11, color: secondaryColor, fontStyle: FontStyle.italic),)
                                          : Text('Supplier : ${supplier}', style: TextStyle(fontSize: 11, color: Colors.white),)
                                    ],
                                  ),

                                ],
                              ),
                            ),

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
                            iid = uuid.v1();
                            InventModel invent = InventModel(
                                iid: iid,
                                eid: widget.entity.eid.toString(),
                                pid: widget.entity.pid,
                                productid: product.prid,
                                quantity: TFormat().encryptText('1', widget.entity.eid),
                                type: TFormat().encryptText('PRODUCT', widget.entity.eid),
                                checked: 'false',
                                time: DateTime.now().toString()
                            );
                            if(product.isChecked==true){
                              _inv.add(invent);
                            } else {
                              _inv.removeWhere((element) => element.productid == product.prid);
                            }
                          });
                        })
                  ],
                );
              })
        ),
        _inv.length == 0? SizedBox()
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
          child: InkWell(
            onTap: (){
             widget.addInv(_inv);
             Navigator.pop(context);
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
                      ? Text("UPLOADING ${_inv.length} ITEMS", style: TextStyle(color: Colors.black), )
                      : Text("ADD ${_inv.length} ITEMS", style: TextStyle(color: Colors.black),),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
