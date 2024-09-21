import 'dart:convert';

import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/sales.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:flutter/material.dart';

import '../../models/inventories.dart';
import '../text_filed_input.dart';

class DialogEditSaleQnty extends StatefulWidget {
  final SaleModel sale;
  final Function updateQuantity;
  const DialogEditSaleQnty({super.key, required this.sale, required this.updateQuantity});

  @override
  State<DialogEditSaleQnty> createState() => _DialogEditSaleQntyState();
}

class _DialogEditSaleQntyState extends State<DialogEditSaleQnty> {
  TextEditingController _quantity = TextEditingController();
  TextEditingController _sprice = TextEditingController();
  List<InventModel> _inv = [];
  List<InventModel> _newInv = [];
  int quantityNo = 1;
  int stockQantity = 1;
  bool _editing = false;
  double newAmount = 0;
  double finalAmount = 0;
  double amount = 0;
  int quantityDiff = 0;
  int finalQnty = 0;
  final formKey = GlobalKey<FormState>();
  int invqnty = 0;

  _getDetails()async{
    _getData();
    _newInv = await Services().getMyInv(currentUser.uid);
    await Data().addOrUpdateInvList(_newInv);
    _getData();
  }

  _getData(){
    _inv = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).where((element) => element.productid == widget.sale.productid).toList();
    stockQantity = int.parse(_inv.first.quantity.toString());
    setState(() {

    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _quantity.text = widget.sale.quantity.toString();
    _sprice.text = widget.sale.sprice.toString();
    _getDetails();
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
          TextFieldInput(
            textEditingController: _sprice,
            textInputType: TextInputType.number,
            textAlign: TextAlign.center,
            labelText: 'Selling Price',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the correct amount';
              } else if (RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(value)) {
                return null;
              } else {
                return 'Please enter a valid number';
              }
            },
          ),
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
                      if (value == null || value.isEmpty) {
                        return 'Please Enter The Quantity';
                      } else if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                        int vQuantity = int.parse(value);
                        if(int.parse(_quantity.text) > stockQantity){
                          if (vQuantity > invqnty + 1) {
                            return 'Quantity selected is more than the quantity in stock';
                          } else {
                            return null; // Valid input (contains only digits and within stock limit)
                          }
                        }
                        if(vQuantity==0){
                          return 'The quantity cannot be zero';
                        }

                      } else {
                        return 'Please enter a valid number';
                      }
                      return null;

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
          SizedBox(height: 10,),
          DoubleCallAction(
              action: (){
                final isValidform = formKey.currentState!.validate();
                if(isValidform){
                  widget.updateQuantity(widget.sale, _sprice.text.toString(), _quantity.text);
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
