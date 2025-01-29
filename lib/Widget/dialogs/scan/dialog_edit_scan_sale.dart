import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

import '../../../main.dart';
import '../../../models/data.dart';
import '../../../models/inventories.dart';
import '../../../models/sales.dart';
import '../../../resources/services.dart';
import '../../../utils/colors.dart';
import '../../text/text_format.dart';
import '../../text_filed_input.dart';
import '../call_actions/double_call_action.dart';
import '../dialog_title.dart';

class DialogEditScanSale extends StatefulWidget {
  final SaleModel sale;
  final double amount;
  final Function update;
  const DialogEditScanSale({super.key, required this.sale, required this.update, required this.amount});

  @override
  State<DialogEditScanSale> createState() => _DialogEditScanSaleState();
}

class _DialogEditScanSaleState extends State<DialogEditScanSale> {
  final formKey = GlobalKey<FormState>();
  final formKeyTwo = GlobalKey<FormState>();

  TextEditingController _pay = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _phone = TextEditingController();

  List<String> items = ['Cash', 'Electronic'];

  List<SaleModel> _sale = [];
  List<SaleModel> _newSale = [];
  List<SaleModel> _filtSale = [];
  List<SaleModel> _filtNewSale = [];
  List<InventModel> _inv = [];
  List<InventModel> _newInv = [];

  DateTime _dateTime = DateTime.now();
  DateTime _saleDate = DateTime.now();

  double amount = 0.0;

  bool isCustom = true;
  bool isComp = true;
  bool _loading = false;

  String cName = "";
  String cPhone = '';
  String? method;

  bool isToday(DateTime date) {
    DateTime today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  _getCustomers(){
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _filtNewSale = _sale.where((element) => element.customer != "" && element.phone != "").toList();
    setState(() {
      for (var sales in _filtNewSale) {
        bool idExists = _newSale.any((element) => element.customer == sales.customer && element.phone == sales.phone);
        if (!idExists) {
          _newSale.add(sales);
        }
      }
    });
  }

  _getInventory()async{
    _getData();
    _newInv = await Services().getMyInv(currentUser.uid);
    await Data().addOrUpdateInvList(_newInv);
    _getData();
  }

  _getData(){
    _inv = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    setState(() {

    });
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the correct amount';
    } else if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    } else {
      double enteredAmount = double.parse(value);
      if (enteredAmount > amount) {
        return 'Amount is more than ${TFormat().getCurrency()}${formatNumberWithCommas(amount)}';
      }
    }
    return null;
  }

  void _handlePaymentChange() {
    final value = _pay.text;
    if (value.isNotEmpty && double.tryParse(value) != null) {
      double enteredAmount = double.parse(value);
      if (enteredAmount < amount) {
        setState(() {
          isComp = false;
        });
      } else if (enteredAmount == amount) {
        setState(() {
          isComp = true;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCustomers();
    amount =  widget.amount;
    _pay.text = widget.sale.paid.toString() =="0.0"? widget.amount.toString() :widget.sale.paid.toString();
    method = widget.sale.method.toString() == "" ? "Cash" : widget.sale.method.toString();
    cName = widget.sale.customer.toString();
    _name.text = widget.sale.customer.toString();
    cPhone = widget.sale.phone.toString();
    _phone.text = widget.sale.phone.toString();
    cPhone = widget.sale.phone.toString();
    _saleDate = DateTime.parse(widget.sale.date.toString());
    _dateTime = DateTime.parse(widget.sale.due.toString());
    isComp = amount==double.parse(_pay.text.toString()) ? true : false;
    _getInventory();
    _pay.addListener(_handlePaymentChange);
  }

  @override
  void dispose() {
    _pay.removeListener(_handlePaymentChange);
    _pay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final hours = _saleDate.hour.toString().padLeft(2, '0');
    final minutes = _saleDate.minute.toString().padLeft(2, '0');
    return Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldInput(
              textEditingController: _pay,
              textInputType: TextInputType.numberWithOptions(decimal: true),
              labelText: 'Amount Paid',
              textAlign: TextAlign.center,
              validator: _validateAmount,
            ),
            SizedBox(height: 5,),
            Text(' Payment method :  ', style: TextStyle(color: secondaryColor),),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12,),
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      width: 1,
                      color: color
                  )
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: method,
                  dropdownColor: dilogbg,
                  icon: Icon(Icons.arrow_drop_down, color: normal),
                  isExpanded: true,
                  items: items.map(buildMenuItem).toList(),
                  onChanged: (value) => setState(() => this.method = value),
                ),
              ),
            ),
            SizedBox(height: 5,),
            _newSale.length == 0
                ?Column(
              children: [
                TextFieldInput(
                  textEditingController: _name,
                  textInputType: TextInputType.text,
                  labelText: 'Customer Name',
                  labelStyle: TextStyle(color: secondaryColor),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Please Enter Customer Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 5,),
                TextFieldInput(
                  textEditingController: _phone,
                  textInputType: TextInputType.text,
                  labelText: 'Customer Phone Number',
                  labelStyle: TextStyle(color: secondaryColor),
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
              ],
            )
                :Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(' Customer :  ', style: TextStyle(color: isCustom?secondaryColor:Colors.red)),
                    cName ==""?SizedBox() : TextButton(
                        onPressed: (){
                          setState(() {
                            cName = "";
                            cPhone = "";
                          });
                        },
                        child: Text("Remove", style: TextStyle(color: CupertinoColors.activeBlue),)
                    )
                  ],
                ),
                InkWell(
                  onTap: (){
                    dialogSelectCustomer(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: cName==""?10:15),
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            width: 1,
                            color: isCustom?color:Colors.red
                        )
                    ),
                    child: cName.toString() == ""
                        ? Text("Press here to select frequent customer or create a new customer", style: TextStyle(color: isCustom?secondaryColor:Colors.red, fontSize: 13),)
                        : Text(cName),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5,),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Sale Date :", style: TextStyle(color: secondaryColor),),
                      InkWell(
                        onTap: (){
                          _showSaleDatePicker();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                          decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  width: 1,
                                  color: color
                              )
                          ),
                          child: Text(DateFormat.yMMMd().format(_saleDate), style: TextStyle( fontSize: 13),),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Time :", style: TextStyle(color: secondaryColor),),
                      InkWell(
                        onTap: ()async{
                          final time =await pickTime();
                          if(time==null){
                            return;
                          } else {
                            final newDateTime = DateTime(
                                _saleDate.year,
                                _saleDate.month,
                                _saleDate.day,
                                time.hour,
                                time.minute
                            );
                            setState(() {
                              _saleDate = newDateTime;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                          decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  width: 1,
                                  color: color
                              )
                          ),
                          child: Text('$hours:$minutes', style: TextStyle( fontSize: 13),),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            isComp
                ? SizedBox()
                : Text('Due Date', style: TextStyle(color: isToday(_dateTime)
                ?Colors.red
                :secondaryColor)),
            isComp
                ? SizedBox()
                : InkWell(
              onTap: _showDatePicker,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    color: _dateTime.isBefore(justToday)?Colors.red.withOpacity(0.5):color1,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: isToday(_dateTime)
                            ?Colors.red
                            :color1,
                        width: 1
                    )
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Center(
                            child: Text(
                              DateFormat.yMMMd().format(_dateTime),
                              style: TextStyle(color: isToday(_dateTime)
                                  ?Colors.red
                                  :null),
                            )
                        )
                    ),
                    LineIcon.calendar(color: isToday(_dateTime)
                        ?Colors.red
                        :null,
                    ),

                  ],
                ),
              ),
            ),
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
                              'Cancel',
                              style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w700, fontSize: 15),
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
                          final isValidform = formKey.currentState!.validate();
                          if(isValidform){
                            if(cName!="" || _name.text.toString() != ""){
                              setState(() {
                                _loading = true;
                              });
                              if(isComp){
                                widget.update(
                                    widget.sale,
                                    amount.toString(),
                                    _pay.text.toString(),
                                    method.toString(),
                                    cName,cPhone,
                                    _saleDate.toString(),
                                    _dateTime.toString()
                                );
                                Navigator.pop(context);
                              } else if (!isComp && _dateTime.isAfter(justToday)){
                                widget.update(
                                  widget.sale,
                                  amount.toString(),
                                  _pay.text.toString(),
                                  method.toString(),
                                  cName,cPhone,
                                  _saleDate.toString(),
                                  _dateTime.toString()
                                );
                                Navigator.pop(context);
                              }
                            }else {
                              setState(() {
                                isCustom = false;
                              });
                            }
                          }
                        },
                        child: SizedBox(height: 40,
                          child: Center(
                            child: _loading
                                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: CupertinoColors.systemBlue,strokeWidth: 2,))
                                : Text(
                              "Change",
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
    );
  }
  void dialogSelectCustomer(BuildContext context) {
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        backgroundColor: dilogbg,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        constraints: BoxConstraints(
            maxHeight: size.height - 100,
            minHeight: size.height - 100,
            maxWidth: 500,minWidth: 450
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            )
        ),
        builder: (context){
          return  SizedBox(width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                DialogTitle(title: 'S E L E C T  P R O D U C T'),
                Text('Select customer by clicking on any customers below',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                          dialogAddCustomer(context);
                        },
                        child: Text('New Customer', style: TextStyle(color: CupertinoColors.activeBlue),))
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: _newSale.length,
                      itemBuilder: (context, index){
                        SaleModel customer = _newSale[index];
                        String custName = _newSale.isEmpty? "" : customer.customer.toString();
                        String custPhone = _newSale.isEmpty? "" : customer.phone.toString();
                        _filtSale = _sale.where((element) => element.customer.toString().trim() == customer.customer.toString().trim() && element.phone.toString().trim() == customer.phone.toString().trim()).toList();
                        List<SaleModel> salesList = _filtSale.isEmpty? [] :_filtSale;
                        var revenue = salesList.isEmpty? 0.0 : salesList.fold(0.0, (previousValue, element) => previousValue + double.parse(element.sprice.toString()) * double.parse(element.quantity.toString()));
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                isCustom = true;
                                cName = custName;
                                cPhone = custPhone;
                              });
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(5),
                            hoverColor: color1,
                            child: Container(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: color1,
                                    radius: 20,
                                    child: LineIcon.user(color: revers,),
                                  ),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(custName.toString()),
                                        Text(custPhone.toString())
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text("${TFormat().getCurrency()}${formatNumberWithCommas(revenue)}"),
                                      Text("Revenue", style: TextStyle(color: secondaryColor),),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          );
        });
  }
  void dialogAddCustomer(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    showDialog(context: context, builder: (context){
      return Dialog(
        backgroundColor: dilogbg,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formKeyTwo,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTitle(title: "C U S T O M E R"),
                  Column(
                    children: [
                      Text(
                        'Please enter all the fields below and press continue to enter new customer details.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryColor, fontSize: 12),
                      ),
                      SizedBox(height: 5,),
                      TextFieldInput(
                        textEditingController: _name,
                        textInputType: TextInputType.text,
                        labelText: 'Customer Name',
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return 'Please Enter Customer Name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5,),
                      TextFieldInput(
                        textEditingController: _phone,
                        textInputType: TextInputType.text,
                        labelText: 'Customer Phone Number',
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
                    ],
                  ),
                  SizedBox(height: 5,),
                  DoubleCallAction(action: (){
                    final isValidform = formKey.currentState!.validate();
                    if(isValidform){
                      setState(() {
                        isCustom = true;
                        cName = _name.text.trim();
                        cPhone = _phone.text.trim();
                      });
                      Navigator.pop(context);
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
  Future<TimeOfDay?> pickTime() => showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: _saleDate.hour, minute: _saleDate.minute),
  );
  void _showDatePicker(){
    showDatePicker(
      context: context,
      initialDate: _dateTime.isBefore(justToday)? DateTime.now() :  _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    ).then((value) {
      setState(() {
        _dateTime = value!;
      });
    });
  }
  void _showSaleDatePicker(){
    showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        _saleDate = value!;
      });
    });
  }
  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      '${item} Transaction',
    ),
  );
}
