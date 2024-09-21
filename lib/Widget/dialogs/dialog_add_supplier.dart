import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/suppliers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../utils/colors.dart';
import '../emailTextFormWidget.dart';
import '../text_filed_input.dart';

class DialogAddSupplier extends StatefulWidget {
  final EntityModel entity;
  final Function addSupplier;
  const DialogAddSupplier({super.key, required this.entity, required this.addSupplier});

  @override
  State<DialogAddSupplier> createState() => _DialogAddSupplierState();
}

class _DialogAddSupplierState extends State<DialogAddSupplier> {
  TextEditingController _name  = TextEditingController();
  TextEditingController _company  = TextEditingController();
  TextEditingController _phone  = TextEditingController();
  TextEditingController _email  = TextEditingController();
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String? category;
  List<String> items = ['Raw Materials', 'Components', 'Finished Goods', 'Service Provider' , 'Equipment',
  'Packaging','Office Supplies', 'IT and Technology', 'MRO', 'Logistics and Transportation',
  'Construction', 'Food and Beverage', 'Pharmaceutical', 'Clothing and Textile', 'Energy',
  'Chemical', 'Agricultural', 'Printing and Publishing', 'Consulting Services', 'Healthcare '];
  String sid = "";

  _clear(){
    _name.text = '';
    _company.text = '';
    _phone.text = '';
    _email.text = '';
  }

  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final reverse =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final dropColor =  Theme.of(context).brightness == Brightness.dark
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
              labelText: 'Supplier Name',
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please Enter Product Name';
                }
                return null;
              },
            ),
            SizedBox(height: 10,),
            TextFieldInput(
              textEditingController: _company,
              textInputType: TextInputType.text,
              labelText: 'Company Name',
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please Enter Product Name';
                }
                return null;
              },
            ),
            SizedBox(height: 10,),
            Text(' Supplier Type :  ', style: TextStyle(color: secondaryColor),),
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
            TextFieldInput(
              textEditingController: _phone,
              textInputType: TextInputType.number,
              labelText: 'Phone',
              validator: (value){
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number.';
                }
                if (value.length < 8) {
                  return 'phone number must be at least 8 characters long.';
                }
                if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
                  return null; // Valid input (contains only digits)
                } else {
                  return 'Please enter a valid phone number';
                }
              },
            ),
            SizedBox(height: 10,),
            EmailTextFormWidget(controller: _email),
            SizedBox(height: 10,),
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
                            onTap: (){_clear();},
                            child: SizedBox(height: 40,
                              child: Center(
                                child: Text(
                                  "Clear",
                                  style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w700, fontSize: 15),
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
                            onTap: (){
                              final isValidform = formKey.currentState!.validate();
                              if(isValidform){
                                Uuid uuid = Uuid();
                                sid = uuid.v1();
                                SupplierModel supplier = SupplierModel(
                                    sid: sid,
                                    eid: widget.entity.eid,
                                    pid: widget.entity.pid,
                                    name: _name.text.toString().trim(),
                                    category: category!,
                                    company: _company.text.toString().trim(),
                                    phone: _phone.text.toString().trim(),
                                    email: _email.text.toString().trim(),
                                    time: DateTime.now().toString(),
                                    checked: 'false'
                                );
                                widget.addSupplier(supplier);
                                _clear();
                              }
                            },
                            child: SizedBox(height: 40,
                              child: Center(
                                child: Text(
                                  'Add',
                                  style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w700, fontSize: 15),
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
    );
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
    ),
  );
}
