import 'dart:convert';

import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/products.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/data.dart';
import '../../models/suppliers.dart';
import '../../utils/colors.dart';
import '../text_filed_input.dart';

class DialogEditProduct extends StatefulWidget {
  final ProductModel product;
  final Function getData;
  const DialogEditProduct({super.key, required this.product, required this.getData});

  @override
  State<DialogEditProduct> createState() => _DialogEditProductState();
}

class _DialogEditProductState extends State<DialogEditProduct> {
  TextEditingController _name  = TextEditingController();
  TextEditingController _buy  = TextEditingController();
  TextEditingController _sell  = TextEditingController();
  List<String> items = ['Gin', 'Whiskey', 'Vodka', 'Red wines' , 'Brandy','White wines','Cream liquor','Herbal liquor','Foreign beer','Beer','Soft Drinks', 'Ceders', 'Tequila', 'Ram', 'Liqueur', 'Martini', 'Cabernet sauvignon', 'Spirits'];
  List<String> volumesList = ['225ml','250ml', '300ml', '330ml', '350ml','375ml','400ml','500ml', '700ml', '750ml' , '1ltr','1.25ltrs','1.5ltrs', '2L', '3L', '4L','5L'];

  String? volume;
  final formKey = GlobalKey<FormState>();
  String? category;
  bool _loading = false;
  bool _isLoading = false;
  List<SupplierModel> _suppliers = [];
  List<SupplierModel> _filterSupplier = [];
  SupplierModel? selectedSupplier;

  _getSupplier()async{
    setState(() {
      _loading = true;
    });
    _suppliers = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.product.eid && !element.checked.toString().contains("REMOVED")).toList();;
    setState(() {
      _filterSupplier = _suppliers.where((element) => element.sid == widget.product.supplier).toList();
      if(_filterSupplier.length != 0){
        selectedSupplier = _filterSupplier.first;
      }
      _loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _name.text = widget.product.name.toString();
    volume = widget.product.volume == null
        ? "225ml"
        : widget.product.volume.toString();
        //:widget.product.volume.toString();
    _buy.text = widget.product.buying.toString();
    _sell.text = widget.product.selling.toString();
    category = widget.product.category == null
        ? 'Whiskey'
        : widget.product.category.toString();
        //: widget.product.category;
    _getSupplier();
  }

  @override
  Widget build(BuildContext context) {
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final normal =  Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final reverse =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final dgColor =  Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  dropdownColor: dgColor,
                  value: category,
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
                  dropdownColor: dgColor,
                  icon: Icon(Icons.arrow_drop_down, color: reverse),
                  isExpanded: true,
                  items: volumesList.map(buildMenuItem).toList(),
                  onChanged: (value) => setState(() => this.volume = value),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Text(_loading
                ? 'Loading...'
                : _suppliers.length == 0? ' No suppliers for this entity'
                : 'Select  Supplier :  ',
              style: TextStyle(
                  color:selectedSupplier == null? Colors.red :  secondaryColor,
                  fontWeight: selectedSupplier == null? FontWeight.w700 : FontWeight.w400
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: _suppliers.length == 0? 15: 0),
              decoration: BoxDecoration(
                  color: color1,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      width: 1,
                      color: selectedSupplier == null? Colors.red : color1
                  )
              ),
              child:_loading
                  ? Text('Loading supplier')
                  : _suppliers.length == 0
                  ? Text('Please create suppliers in suppliers list', style: TextStyle(color: secondaryColor),)
                  : DropdownButtonHideUnderline(
                child: DropdownButton<SupplierModel>(
                  dropdownColor: dgColor,
                  value: selectedSupplier,
                  icon: Icon(Icons.arrow_drop_down, color: selectedSupplier == null? Colors.red : reverse),
                  isExpanded: true,
                  items: _suppliers.map((SupplierModel supplier) {
                    return DropdownMenuItem<SupplierModel>(
                      value: supplier,
                      child: Text(supplier.name.toString()),
                    );
                  }).toList(),
                  onChanged: (SupplierModel? newValue) {
                    setState(() {
                      selectedSupplier = newValue;
                    });
                  },
                ),
              ),
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
                              'Cancel',
                              style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.w700, fontSize: 15),
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
                            _isLoading = true;
                          });
                          final isValidform = formKey.currentState!.validate();
                          if(isValidform && selectedSupplier != null){
                            ProductModel product = ProductModel(
                              prid: widget.product.prid,
                              eid: widget.product.eid,
                              pid: widget.product.pid,
                              name: _name.text.toString(),
                              category: category.toString(),
                              type: widget.product.type,
                              quantity: '0',
                              volume: volume.toString(),
                              supplier: selectedSupplier!.sid.toString(),
                              buying: _buy.text.toString(),
                              selling: _sell.text.toString(),
                            );
                            await Data().editProduct(product, context, widget.getData).then((response){
                              Navigator.pop(context);
                              setState(() {
                                _isLoading = response;
                              });
                            });
                          } else {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        child: SizedBox(height: 40,
                          child: Center(
                            child: _isLoading
                                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: CupertinoColors.activeBlue,strokeWidth: 2,))
                                : Text(
                              "Update",
                              style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.w700, fontSize: 15),
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
      ),
    );
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
    ),
  );
}
