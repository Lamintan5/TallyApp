import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/models/purchases.dart';
import 'package:flutter/material.dart';

import '../../models/data.dart';
import '../../models/inventories.dart';
import '../../resources/services.dart';

class DialogRemovePrch extends StatefulWidget {
  final PurchaseModel purchase;
  final Function getPurchase;
  final Function checkRemoved;
  final Function updateChecked;
  final int quantity;
  final double tAmount;
  final double bPrice;
  const DialogRemovePrch({super.key, required this.purchase, required this.getPurchase, required this.checkRemoved, required this.quantity, required this.tAmount, required this.bPrice, required this.updateChecked});

  @override
  State<DialogRemovePrch> createState() => _DialogRemovePrchState();
}

class _DialogRemovePrchState extends State<DialogRemovePrch> {
  bool _loading = false;
  List<InventModel> _inventories = [];
  List<PurchaseModel> _purchase = [];
  int noQuantity = 0;
  int stockQnty = 0;
  double newAmount = 0;
  InventModel invent = InventModel(iid: "", quantity: '0');

  _getInv()async{

    _inventories = await Services().getInvByPrd(widget.purchase.productid!);
    setState(() {
      stockQnty = _inventories.isEmpty ? 0 : int.parse(_inventories.first.quantity.toString());
      });
  }

  _delete()async{
    setState(() {
      _loading = true;
      noQuantity = stockQnty - widget.quantity;
      newAmount = widget.tAmount - (widget.bPrice* widget.quantity);
      invent = _inventories.isEmpty? InventModel(iid: "", quantity: '0') : _inventories.first;
    });
    InventModel inventModel = InventModel(
      iid: invent.iid,
      quantity: noQuantity <0? '0' : noQuantity.toString(),
      type: invent.type,
    );
    await Services.deletePurchase(widget.purchase.purchaseid, widget.purchase.productid!).then((response)async{
      if(response=="success"){
        Services.updateAllPrchAmount(widget.purchase.purchaseid, newAmount.toString());
        Services.updateInventory(inventModel).then((response){});
        widget.checkRemoved("Removed",widget.purchase.productid);
        _purchase.add(widget.purchase);
        await Data().removePurchaseList(_purchase, newAmount);
        Navigator.pop(context);
        setState(() {
          _loading = false;
        });
      }else {
        _purchase.add(widget.purchase);
        await Data().removePurchaseList(_purchase, newAmount);
        widget.updateChecked("DELETED", widget.purchase.productid);
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
        DoubleCallAction(action: _delete, title: 'Remove', titleColor: Colors.red,)
      ],
    );
  }
}
