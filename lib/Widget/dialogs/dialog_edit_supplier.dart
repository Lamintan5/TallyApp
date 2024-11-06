import 'package:TallyApp/Widget/text/text_format.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/suppliers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../emailTextFormWidget.dart';
import '../text_filed_input.dart';

class DialogEditSupplier extends StatefulWidget {
  final SupplierModel supplier;
  final Function getData;
  const DialogEditSupplier({super.key, required this.supplier, required this.getData});

  @override
  State<DialogEditSupplier> createState() => _DialogEditSupplierState();
}

class _DialogEditSupplierState extends State<DialogEditSupplier> {
  TextEditingController _name  = TextEditingController();
  TextEditingController _company  = TextEditingController();
  TextEditingController _phone  = TextEditingController();
  TextEditingController _email  = TextEditingController();
  SupplierModel supplier = SupplierModel(sid: "");
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String? category;
  List<String> items = ['Raw Materials', 'Components', 'Finished Goods', 'Service Provider' , 'Equipment',
    'Packaging','Office Supplies', 'IT and Technology', 'MRO', 'Logistics and Transportation',
    'Construction', 'Food and Beverage', 'Pharmaceutical', 'Clothing and Textile', 'Energy',
    'Chemical', 'Agricultural', 'Printing and Publishing', 'Consulting Services', 'Healthcare '];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _name.text = TFormat().decryptField(widget.supplier.name.toString(), widget.supplier.eid.toString());
    _company.text = TFormat().decryptField(widget.supplier.company.toString(), widget.supplier.eid.toString());
    _phone.text = TFormat().decryptField(widget.supplier.phone.toString(), widget.supplier.eid.toString());
    _email.text = TFormat().decryptField(widget.supplier.email.toString(), widget.supplier.eid.toString());
    category = TFormat().decryptField(widget.supplier.category.toString(), widget.supplier.eid.toString());
    setState(() {

    });
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
            SizedBox(height: 10,),
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
                  thickness: 0.2,
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
                                  style: TextStyle(color: CupertinoColors.activeBlue),
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
                            onTap: ()async{
                              setState(() {
                                _isLoading = true;
                              });
                              supplier = SupplierModel(
                                  sid: widget.supplier.sid,
                                  eid: widget.supplier.eid,
                                  pid: widget.supplier.pid,
                                  name: TFormat().encryptText(_name.text.toString().trim(), widget.supplier.eid.toString()),
                                  category: TFormat().encryptText(category.toString(), widget.supplier.eid.toString()),
                                  company: TFormat().encryptText(_company.text.toString().trim(), widget.supplier.eid.toString()),
                                  email: TFormat().encryptText(_email.text.toString().trim(), widget.supplier.eid.toString()),
                                  phone: TFormat().encryptText(_phone.text.toString().trim(), widget.supplier.eid.toString()),
                                  time: widget.supplier.time,
                                  checked: widget.supplier.checked,
                              );
                              await Data().editSupplier(supplier, context, widget.getData).then((response){
                                setState(() {
                                  _isLoading = response;
                                });
                              });
                              Navigator.pop(context);
                            },
                            child: SizedBox(height: 40,
                              child: Center(
                                child:
                                    _isLoading
                                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: CupertinoColors.activeBlue,strokeWidth: 2,))
                                        : Text(
                                          'Update',
                                          style: TextStyle(color: CupertinoColors.activeBlue),
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
