import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../models/entities.dart';
import '../../../models/suppliers.dart';
import '../../../utils/colors.dart';
import '../../text_filed_input.dart';
import '../call_actions/double_call_action.dart';

class DialogFilterInv extends StatefulWidget {
  final EntityModel entity;
  final Function filter;
  const DialogFilterInv({super.key, required this.entity, required this.filter});

  @override
  State<DialogFilterInv> createState() => _DialogFilterInvState();
}

class _DialogFilterInvState extends State<DialogFilterInv> {
  late TextEditingController _quantity;
  late TextEditingController _bprice;
  late TextEditingController _sprice;

  final formKey = GlobalKey<FormState>();

  List<String> items = ['Gin', 'Whiskey', 'Vodka', 'Red wines' , 'Brandy','White wines','Cream liquor','Herbal liquor','Foreign beer','Beer','Soft Drinks', 'Ceders', 'Tequila', 'Ram', 'Liqueur', 'Martini', 'Cabernet sauvignon', 'Spirits'];
  List<String> volumesList = ['225ml','250ml', '300ml', '330ml', '350ml','375ml','400ml','500ml', '700ml', '750ml' , '1ltr','1.25ltrs','1.5ltrs', '2L', '3L', '4L','5L'];

  List<SupplierModel> _sppler = [];

  SupplierModel? selectedSupplier;

  String? category;
  String? volume;

  int quantityNo = 1;

  _getData(){
    _sppler= mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).where((test) => test.eid == widget.entity.eid).toList();
    setState(() {
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bprice = TextEditingController();
    _sprice = TextEditingController();
    _quantity = TextEditingController();
    _getData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _bprice.dispose();
    _sprice.dispose();
    _quantity.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final dropColor =  Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   "Please filter the product data by specifying either the category, volume, or suppliers in the form below.",
          //   style: TextStyle(color: secondaryColor, fontSize: 13),
          //   textAlign: TextAlign.center,
          // ),
          SizedBox(height: 5,),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(' Category :  ', style: TextStyle(color: secondaryColor),),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12,),
                      decoration: BoxDecoration(
                          color: color1,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              width: 1,
                              color: color1
                          )
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: category,
                          dropdownColor: dropColor,
                          icon: Icon(Icons.arrow_drop_down, color: reverse),
                          isExpanded: true,
                          items: items.map(buildMenuItem).toList(),
                          onChanged: (value) => setState(() => this.category = value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(' Volume :  ', style: TextStyle(color: secondaryColor),),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12,),
                      decoration: BoxDecoration(
                          color: color1,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              width: 1,
                              color: color1
                          )
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: volume,
                          dropdownColor: dropColor,
                          icon: Icon(Icons.arrow_drop_down, color: reverse),
                          isExpanded: true,
                          items: volumesList.map(buildMenuItem).toList(),
                          onChanged: (value) => setState(() => this.volume = value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5,),
          Text(' Suppliers :  ', style: TextStyle(color: secondaryColor),),
          Container(width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12,),
              decoration: BoxDecoration(
                  color: color1,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      width: 1,
                      color: color1
                  )
              ),
              child:  _sppler.length==0
                  ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text('No suppliers for this Entity please add new suppliers to your list.', style: TextStyle(color: secondaryColor, fontSize: 12),),
              )
                  : DropdownButtonHideUnderline(
                child: DropdownButton<SupplierModel>(
                  value: selectedSupplier,
                  dropdownColor: dropColor,
                  icon: Icon(Icons.arrow_drop_down, color: reverse),
                  isExpanded: true,
                  items: _sppler.map((SupplierModel supplier) {
                    return DropdownMenuItem<SupplierModel>(
                      value: supplier, // Use the unique SupplierModel as the value
                      child: Text(supplier.name.toString(),style: TextStyle(fontWeight: FontWeight.normal),),
                    );
                  }).toList(),
                  onChanged: (SupplierModel? newValue) {
                    setState(() {
                      selectedSupplier = newValue;
                    });
                  },
                ),
              )
          ),
          SizedBox(height: 5,),
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
                        return null;
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
                        child: Icon(Icons.keyboard_arrow_up_outlined, size: 19,),
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
                        child: Icon(Icons.keyboard_arrow_down_outlined, size: 19,),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 5,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child:TextFieldInput(
                    textEditingController: _bprice,
                    textInputType: TextInputType.number,
                    labelText: 'Buy Price',
                    labelStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if(value==null || value.isEmpty){
                        return null;
                      }
                      if (RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(value)) {
                        return null;
                      } else {
                        return 'Please enter a valid number';
                      }
                    },
                  ),
              ),
              SizedBox(width: 5,),
              Expanded(
                  child: TextFieldInput(
                    textEditingController: _sprice,
                    textInputType: TextInputType.number,
                    labelText: 'Sell Price',
                    labelStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if(value==null || value.isEmpty){
                        return null;
                      }
                      if (RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(value)) {
                        return null;
                      } else {
                        return 'Please enter a valid number';
                      }
                    },
                  ),
              )
            ],
          ),
          DoubleCallAction(
            action: ()async{
              Navigator.pop(context);
              widget.filter(
                  category,
                  volume,
                  selectedSupplier?.sid,
                  _quantity.text.toString(),
                  _bprice.text.toString(),
                  _sprice.text.toString()
              );
            },
            title: "Filter",
          ),
        ],
      ),
    );
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: TextStyle(fontWeight: FontWeight.normal),
    ),
  );
}
