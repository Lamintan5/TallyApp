import 'dart:convert';

import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/products.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/suppliers.dart';
import '../../utils/colors.dart';
import '../text/text_format.dart';
import '../text_filed_input.dart';

class DialogAddProduct extends StatefulWidget {
  final EntityModel entity;
  final Function addProduct;
  const DialogAddProduct({super.key, required this.entity, required this.addProduct});

  @override
  State<DialogAddProduct> createState() => _DialogAddProductState();
}

class _DialogAddProductState extends State<DialogAddProduct> {
  TextEditingController _name  = TextEditingController();
  TextEditingController _qnty  = TextEditingController();
  TextEditingController _buy  = TextEditingController();
  TextEditingController _sell  = TextEditingController();

  final formKey = GlobalKey<FormState>();
  String? category;

  bool _isLoading = false;
  List<String> items = ['Gin', 'Whiskey', 'Vodka', 'Red wines' , 'Brandy','White wines','Cream liquor','Herbal liquor','Foreign beer','Beer','Soft Drinks', 'Ceders', 'Tequila', 'Ram', 'Liqueur', 'Martini', 'Cabernet sauvignon', 'Spirits'];
  List<String> volumesList = ['225ml','250ml', '300ml', '330ml', '350ml','375ml','400ml','500ml', '700ml', '750ml' , '1ltr','1.25ltrs','1.5ltrs', '2L', '3L', '4L','5L'];
  String? volume;

  List<SupplierModel> _sppler = [];
  List<SupplierModel> _newSppler = [];
  bool _loadSupp = false;
  SupplierModel? selectedSupplier;

  List<ProductModel> _newProduct = [];
  String prid = '';

  _getDetails()async{
    _getData();
    _newSppler = await Services().getMySuppliers(currentUser.uid);
    await Data().addOrUpdateSuppliersList(_newSppler);
    _getData();
  }

  _getData(){
    _sppler = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _sppler = _sppler.where((element) => element.eid == widget.entity.eid && !element.checked.toString().contains("REMOVED")).toList();
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
        ? Colors.white12
        : Colors.black12;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final dropColor =  Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFieldInput(
                textEditingController: _name,
                textInputType: TextInputType.text,
                labelText: 'Product Name',
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Please Enter Product Name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5,),
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
              SizedBox(height: 10,),
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
              Text(_loadSupp? 'Loading...' : ' Suppliers :  ', style: TextStyle(color: secondaryColor),),
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
                  child: _loadSupp? Text('Fetching Suppliers. Please wait.', style: TextStyle(color: secondaryColor),)
                      : _sppler.length==0
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
                          child: Text(TFormat().decryptField(supplier.name.toString(), widget.entity.eid.toString()),),
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
              SizedBox(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFieldInput(
                      textEditingController: _buy,
                      textInputType: TextInputType.number,
                      labelText: 'Buying Price (Ksh.)',
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Please Enter The Buying Price';
                        }
                        if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return null; // Valid input (contains only digits)
                        } else {
                          return 'Please enter a valid number';
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: TextFieldInput(
                      textEditingController: _sell,
                      textInputType: TextInputType.number,
                      labelText: 'Selling Price (Ksh.)',
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Please Enter The Selling Price';
                        }
                        if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return null; // Valid input (contains only digits)
                        } else {
                          return 'Please enter a valid number';
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    thickness: 0.2,
                    color: reverse,
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                            child: InkWell(
                              onTap: (){_clear();},
                              child: SizedBox(height: 40,
                                child: Center(
                                  child: Text(
                                    'Clear',
                                    style: TextStyle(color: CupertinoColors.activeBlue, fontSize: 15, fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,),
                                ),
                              ),
                            )
                        ),
                        VerticalDivider(
                          thickness: 0.2,
                          color: reverse,
                        ),
                        Expanded(
                            child: InkWell(
                              onTap: (){
                                final isValidform = formKey.currentState!.validate();
                                if(isValidform){
                                  Uuid uuid = Uuid();
                                  prid = uuid.v1();
                                  ProductModel product = ProductModel(
                                      prid: prid,
                                      eid: widget.entity.eid.toString(),
                                      pid: widget.entity.pid.toString(),
                                      name: TFormat().encryptText(_name.text.trim(), widget.entity.eid.toString()),
                                      category: TFormat().encryptText(category.toString(), widget.entity.eid.toString()),
                                      quantity:  TFormat().encryptText('0', widget.entity.eid.toString()),
                                      volume: TFormat().encryptText(volume.toString(), widget.entity.eid.toString()),
                                      supplier: selectedSupplier!.sid.toString(),
                                      buying: TFormat().encryptText(_buy.text.trim(), widget.entity.eid.toString()),
                                      selling: TFormat().encryptText(_sell.text.trim(), widget.entity.eid.toString()),
                                      checked: 'false',
                                      type: TFormat().encryptText('PRODUCT', widget.entity.eid.toString()),
                                      time: DateTime.now().toString()
                                  );
                                  print("This is ${product.buying}");
                                  widget.addProduct(product);
                                  _clear();
                                }
                              },
                              child: SizedBox(height: 40,
                                child: Center(
                                  child: Text(
                                    "Add",
                                    style: TextStyle(color: CupertinoColors.activeBlue, fontSize: 15, fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,),
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
        ),
      ),
    );
  }
  _clear(){
    _name.text = '';
    _qnty.text = '1';
    volume = null;
    category = null;
    _buy.text = '';
    _sell.text = '';
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
    ),
  );
}
