import 'dart:convert';

import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/inventories.dart';
import 'package:TallyApp/models/sales.dart';
import 'package:flutter/material.dart';

import '../../models/data.dart';
import '../../resources/services.dart';

class DialogRmvSlItm extends StatefulWidget {
  final EntityModel entity;
  final SaleModel sale;
  final Function checkRemoved;
  final Function updateChecked;
  const DialogRmvSlItm({super.key, required this.entity, required this.sale, required this.checkRemoved, required this.updateChecked});

  @override
  State<DialogRmvSlItm> createState() => _DialogRmvSlItmState();
}

class _DialogRmvSlItmState extends State<DialogRmvSlItm> {
  bool _loading = false;
  List<InventModel> _inventories = [];
  List<InventModel> _newInv = [];
  int noQuantity = 0;
  int stockQnty = 0;
  double newAmount = 0;
  InventModel invent = InventModel(iid: "", quantity: '0');
  List<SaleModel> _sale = [];

  _getInv()async{
    _getData();
    _newInv = await Services().getMyInv(currentUser.uid);
    await Data().addOrUpdateInvList(_newInv);
    _getData();
  }

  _getData(){
    _inventories = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _inventories = _inventories.where((element) => element.productid == widget.sale.productid).toList();
    stockQnty = _inventories.isEmpty ? 0 : int.parse(_inventories.first.quantity.toString());
    setState(() {

    });
  }

  _delete()async{
    setState(() {
      _loading = true;
      noQuantity = stockQnty + int.parse(widget.sale.quantity!);
      newAmount = double.parse(widget.sale.amount!) - (double.parse(widget.sale.bprice!) * int.parse(widget.sale.quantity!));
      invent = _inventories.isEmpty? InventModel(iid: "", quantity: '0') : _inventories.first;
    });
    InventModel inventModel = InventModel(
      iid: invent.iid,
      quantity: noQuantity <0? '0' : noQuantity.toString(),
      type: invent.type,
    );
    await Services.deleteSale(widget.sale.saleid, widget.sale.productid!).then((response)async{
      if(response=="success"){
        Services.updateSalesAmount(widget.sale.saleid, widget.sale.paid!, newAmount.toString(), widget.sale.due!, widget.sale.customer!, widget.sale.phone!, widget.sale.method!, widget.sale.time!);
        Services.updateInventory(inventModel).then((response){});
        widget.checkRemoved("Removed",widget.sale.productid);
        _sale.add(widget.sale);
        await Data().removeSaleList(_sale, newAmount);
        Navigator.pop(context);
        setState(() {
          _loading = false;
        });
      }else {
        _sale.add(widget.sale);
        await Data().removeSaleList(_sale, newAmount);
        widget.updateChecked("DELETED", widget.sale.productid);
        Navigator.pop(context);
        setState(() {
          _loading = false;
        });

      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getInv();
  }

  @override
  Widget build(BuildContext context) {
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    return Column(
      children: [
        SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: (){
                    _delete();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                        color: secBtn,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Center(child:_loading
                        ? SizedBox(width:15, height: 15,child: CircularProgressIndicator(color: Colors.black,strokeWidth: 1,))
                        : Text("REMOVE", style: TextStyle(color: Colors.black),)),
                  ),
                ),
              ),
              SizedBox(width: 5,),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  width: 150,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          width: 1, color: secBtn
                      )
                  ),
                  child: Center(child: Text("CANCEL", style: TextStyle(color: secBtn),)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),
      ],
    );
  }
}
