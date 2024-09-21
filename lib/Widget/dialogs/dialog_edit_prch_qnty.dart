import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/products.dart';
import 'package:TallyApp/models/purchases.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:flutter/material.dart';

import '../../models/inventories.dart';
import '../../resources/services.dart';

class DialogEditPrchQnty extends StatefulWidget {
  final PurchaseModel purchase;
  final int quantity;
  final Function updateQuantity;
  final String from;
  const DialogEditPrchQnty({super.key, required this.purchase, required this.quantity, required this.updateQuantity, required this.from});

  @override
  State<DialogEditPrchQnty> createState() => _DialogEditPrchQntyState();
}

class _DialogEditPrchQntyState extends State<DialogEditPrchQnty> {
  TextEditingController _quantity = TextEditingController();
  final formKey = GlobalKey<FormState>();
  int quantityNo = 1;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _quantity.text = widget.quantity.toString();

  }

  @override
  Widget build(BuildContext context) {
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
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
                SizedBox(width: 40, height: 40,),
                Expanded(
                  child: TextFormField(
                    controller: _quantity,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        hintText: "Quantity",
                        hintStyle: TextStyle(color: secondaryColor),
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
                          if(int.parse(_quantity.text) >1){
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
          SizedBox(height: 5,),
          DoubleCallAction(
            action: (){
              final isValidform = formKey.currentState!.validate();
              if(isValidform && int.parse(_quantity.text.toString()) != int.parse(widget.quantity.toString())){
                widget.updateQuantity(widget.purchase, _quantity.text);
                Navigator.pop(context);
              }
            },
            title: "Change",
          ),
        ],
      ),
    );
  }
}
