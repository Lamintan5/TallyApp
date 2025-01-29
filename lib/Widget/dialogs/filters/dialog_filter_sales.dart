import 'dart:convert';

import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/products.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

import '../../../main.dart';
import '../../../models/sales.dart';
import '../../../models/users.dart';
import '../../../utils/colors.dart';
import '../../text/text_format.dart';
import '../../text_filed_input.dart';
import '../dialog_selecting_product.dart';
import '../dialog_title.dart';

class DialogFilterSales extends StatefulWidget {
  final EntityModel entity;
  final Function filter;
  final String from;
  const DialogFilterSales({super.key, required this.entity, required this.filter, required this.from});

  @override
  State<DialogFilterSales> createState() => _DialogFilterSalesState();
}

class _DialogFilterSalesState extends State<DialogFilterSales> {
  final formKey = GlobalKey<FormState>();

  TextEditingController _pay = TextEditingController();


  List<String> items = ['Cash', 'Electronic'];

  List<SaleModel> _sale = [];
  List<SaleModel> _newSale = [];
  List<SaleModel> _filtNewSale = [];
  List<UserModel> _user = [];


  UserModel? selectedUser;
  ProductModel? selectedProduct;

  String? method;
  String cName = "";
  String cPhone = '';
  String fDate = '';
  String tDate = '';
  String dDate = '';
  String sellerUid = "";

  bool isCustom = true;


  DateTime _dateTime = DateTime.now();
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  _getData(){
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();

    _sale = _sale.where((element) => element.eid == widget.entity.eid).toList();
    _user = _user.where((user) => _sale.any((sale) => user.uid==sale.sellerid)).toList();
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
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
            labelStyle: TextStyle(color: secondaryColor),
            textAlign: TextAlign.center,
            validator: (value){
              if (value == null || value.isEmpty) {
                return null;
              } else if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              } else {
                return null;
              }
            },
          ),
          // Text(' Products  ', style: TextStyle(color: secondaryColor),),
          // InkWell(
          //   onTap: (){
          //     dialogSelectProduct(context);
          //   },
          //   child: Container(
          //     width: double.infinity,
          //     padding: EdgeInsets.symmetric(horizontal: 12, vertical:15),
          //     decoration: BoxDecoration(
          //         color: color,
          //         borderRadius: BorderRadius.circular(5),
          //         border: Border.all(
          //             width: 1,
          //             color: isCustom?color:Colors.red
          //         )
          //     ),
          //     child: selectedProduct == null
          //         ? Text("Press here to select product", style: TextStyle(color: isCustom?secondaryColor:Colors.red, fontSize: 13),)
          //         : Text(selectedProduct!.name.toString()),
          //   ),
          // ),
          Text(' Payment method ', style: TextStyle(color: secondaryColor),),
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
          Text(' Customer  ', style: TextStyle(color: secondaryColor),),
          InkWell(
            onTap: (){
              dialogSelectCustomer(context);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical:15),
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      width: 1,
                      color: isCustom?color:Colors.red
                  )
              ),
              child: cName.toString() == ""
                  ? Text("Press here to select customer", style: TextStyle(color: isCustom?secondaryColor:Colors.red, fontSize: 13),)
                  : Text(cName),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(" From", style: TextStyle(color: secondaryColor),),
                    InkWell(
                      onTap: (){
                        _showFromDatePicker();
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
                        child: Text(fDate==""?"":DateFormat.yMMMd().format(DateTime.parse(fDate)), style: TextStyle( fontSize: 13),),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("To", style: TextStyle(color: secondaryColor),),
                    InkWell(
                      onTap: (){
                        _showToDatePicker();
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
                        child: Text(tDate==""?"":DateFormat.yMMMd().format(DateTime.parse(tDate)), style: TextStyle( fontSize: 13),),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          widget.from=="SALES"? SizedBox() : SizedBox(width: 5,),
          widget.from=="SALES"? SizedBox() : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(" Due Date", style: TextStyle(color: secondaryColor),),
              InkWell(
                onTap: (){
                  _showDueDatePicker();
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
                  child: Text(dDate==""?"":DateFormat.yMMMd().format(DateTime.parse(dDate)), style: TextStyle( fontSize: 13),),
                ),
              ),
            ],
          ),
          _user.isEmpty ? SizedBox() : Text(' Seller  ', style: TextStyle(color: secondaryColor),),
          _user.isEmpty ? SizedBox() : Container(width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12,),
              decoration: BoxDecoration(
                  color: color1,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      width: 1,
                      color: color1
                  )
              ),
              child:  DropdownButtonHideUnderline(
                child: DropdownButton<UserModel>(
                  value: selectedUser,
                  dropdownColor: dilogbg,
                  icon: Icon(Icons.arrow_drop_down, color: reverse),
                  isExpanded: true,
                  items: _user.map((UserModel user) {
                    return DropdownMenuItem<UserModel>(
                      value: user,
                      child: Text(user.username.toString(),style: TextStyle(fontWeight: FontWeight.normal),),
                    );
                  }).toList(),
                  onChanged: (UserModel? newValue) {
                    setState(() {
                      selectedUser = newValue;
                      sellerUid = newValue!.uid;
                    });
                  },
                ),
              )
          ),
          DoubleCallAction(
            title: "Filter",
            action: (){
              Navigator.pop(context);
              widget.filter(
                  _pay.text.toString()==""?0.0:double.parse(_pay.text.toString()),
                  method==null?"":method,
                  fDate,
                  tDate,
                  dDate,
                  sellerUid,
                  cName,
                  cPhone,
              );
            },
          )
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
                DialogTitle(title: 'C U S T O M E R'),
                Text('Select customer by clicking on any customers below',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                Expanded(
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: _newSale.length,
                      itemBuilder: (context, index){
                        SaleModel customer = _newSale[index];
                        String custName = _newSale.isEmpty? "" : customer.customer.toString();
                        String custPhone = _newSale.isEmpty? "" : customer.phone.toString();
                        List<SaleModel> _filtSale = _sale.where((element) => element.customer.toString().trim() == customer.customer.toString().trim() && element.phone.toString().trim() == customer.phone.toString().trim()).toList();
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
                                      Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(revenue)}"),
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
  void dialogSelectProduct(BuildContext context) {

    final size = MediaQuery.of(context).size;

    showModalBottomSheet(
        context: context,
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
                DialogTitle(title: 'P R O D U C T'),
                Text(
                  'Select product by clicking on any products below',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                Expanded(child: SelectProduct(selectingProduct: _selectingProduct, entity: widget.entity))

              ],
            ),
          );
        });
  }

  void _showFromDatePicker(){
    showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        _fromDate = value!;
        fDate = _fromDate.toString();
        if(tDate.isEmpty){
          tDate = fDate;
          _toDate = value;
        }
      });
    });
  }
  void _showToDatePicker(){
    showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        _toDate = value!;
        tDate = _toDate.toString();
      });
    });
  }
  void _showDueDatePicker(){
    showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((value) {
      setState(() {
        _dateTime = value!;
        dDate = _dateTime.toString();
      });
    });
  }

  void _selectingProduct(ProductModel product){
    setState(() {
      selectedProduct = product;
    });
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      '${item} Transaction',
    ),
  );
}



