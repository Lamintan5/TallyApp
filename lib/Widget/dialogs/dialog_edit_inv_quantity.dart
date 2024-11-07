import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/models/inventories.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/data.dart';
import '../text/text_format.dart';

class DialogEditInvQuantity extends StatefulWidget {
  final InventModel inventory;
  final Function reload;
  const DialogEditInvQuantity({super.key, required this.inventory, required this.reload});

  @override
  State<DialogEditInvQuantity> createState() => _DialogEditInvQuantityState();
}

class _DialogEditInvQuantityState extends State<DialogEditInvQuantity> {
  TextEditingController _quantity = TextEditingController();
  int quantityNo = 1;
  bool _loading = false;
  final formKey = GlobalKey<FormState>();
  List<InventModel> inv = [];
  List<InventModel> filtInv = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _quantity.text =  TFormat().decryptField(widget.inventory.quantity.toString(), widget.inventory.eid.toString());
  }

  @override
  Widget build(BuildContext context) {
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final reverse =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            decoration: BoxDecoration(
              color: color1,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantity,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        hintText: "Quantity",
                        hintStyle: TextStyle(color: Colors.black),
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none
                        )
                    ),
                    onChanged:  (value) => setState((){}),
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please Enter The Quantity';
                      }
                      if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return null; // Valid input (contains only digits)
                      } else {
                        return 'Please enter a valid number';
                      }
                    },
                  ),
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: (){
                        setState(() {
                          quantityNo = int.parse(_quantity.text.toString());
                          quantityNo++;
                          _quantity.text = quantityNo.toString();
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        decoration: BoxDecoration(
                            color: color1,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                            )
                        ),
                        child: Icon(Icons.keyboard_arrow_up_outlined),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                          if(int.parse(_quantity.text) >0){
                            quantityNo = int.parse(_quantity.text.toString());
                            quantityNo--;
                            _quantity.text = quantityNo.toString();
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        decoration: BoxDecoration(
                            color: color1,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(5),
                            )
                        ),
                        child: Icon(Icons.keyboard_arrow_down_outlined),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                thickness: 0.1,
                color: reverse,
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                        child: InkWell(
                          onTap: (){Navigator.pop(context);},
                          child: SizedBox(height: 40,
                            child: Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: CupertinoColors.activeBlue,fontWeight: FontWeight.w700, fontSize: 15),
                                textAlign: TextAlign.center,),
                            ),
                          ),
                        )
                    ),
                    VerticalDivider(
                      thickness: 0.1,
                      color: reverse,
                    ),
                    Expanded(
                        child: InkWell(
                          onTap: ()async{
                            setState(() {
                              _loading = true;
                            });
                            await Data().editInventory(widget.inventory, context, widget.reload, TFormat().encryptText(_quantity.text, widget.inventory.eid.toString())).then((response){
                              setState(() {
                                _loading = response;
                              });
                            });
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                            height: 40,
                            child: Center(
                              child:
                              _loading
                                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: CupertinoColors.activeBlue,strokeWidth: 2,))
                                  : Text(
                                'Update',
                                style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w700, fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
