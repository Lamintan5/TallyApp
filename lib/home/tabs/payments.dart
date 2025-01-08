import 'dart:convert';

import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/Widget/dialogs/dialog_title.dart';
import 'package:TallyApp/Widget/logos/prop_logo.dart';
import 'package:TallyApp/Widget/profile_images/user_profile.dart';
import 'package:TallyApp/home/tabs/receipt.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/buttons/card_button.dart';
import '../../Widget/items/item_paymements.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Widget/text/text_format.dart';
import '../../models/data.dart';
import '../../models/payments.dart';
import '../../models/users.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';

class Payments extends StatefulWidget {
  final EntityModel entity;
  const Payments({super.key, required this.entity});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  List<String> title = ['In-Payments', 'Out-Payments', 'Transactions', 'Units Sold','Units Purchased', 'Customers'];
  List<PaymentModel> _pay = [];
  List<PaymentModel> _newpay = [];
  List<PaymentModel> _sale = [];
  List<PaymentModel> _purchase = [];
  List<EntityModel> _newEnt = [];
  List<EntityModel> _entity = [];
  List<UserModel> _users = [];
  List<UserModel> _newUser = [];


  bool _loading = false;
  bool _reloading = false;
  bool close = true;

  double inPay = 0;
  double outPay = 0;

  int removed = 0;

  _getDetails()async{
    _getData();
    _newpay = await Services().getMyPayments(currentUser.uid);
    _newEnt = await Services().getCurrentEntity(currentUser.uid);
    await Data().addOrUpdatePayments(_newpay);
    await Data().addOrUpdateEntity(_newEnt);
    _getData();
  }



  _getData(){
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _pay = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();
    _users = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();

    if(!_users.contains(currentUser)){
      _users.add(currentUser);
    }

    for (int index = 0; index < _pay.length; index++) {
      final pay = _pay[index];
      if (!_users.any((usr) => usr.uid == pay.payid)) {
        _getUser(pay.payerid.toString());
        if(index==_pay.length - 1){
          setState(() {
          });
        }
      }
    }

    _pay = _pay.where((test) {
      bool eidFilter = widget.entity.eid.isNotEmpty ? test.eid == widget.entity.eid : true;
      bool adminOrPayerFilter = test.admin.toString().contains(currentUser.uid) || test.payerid == currentUser.uid;

      return eidFilter && adminOrPayerFilter;
    }).toList();

    _sale = _pay.where((element) => element.type == "SALE" || element.type == "RECEIVABLE").toList();
    _purchase = _pay.where((element) => element.type == "PURCHASE" || element.type == "PAYABLE").toList();
    inPay = _sale.fold(0, (previousValue, element) => previousValue + double.parse(element.paid.toString()));
    outPay = _purchase.fold(0, (previousValue, element) => previousValue + double.parse(element.paid.toString()));
    _pay.sort((a, b) => DateTime.parse(a.time.toString()).compareTo(DateTime.parse(b.time.toString())));
    removed = _pay.where((element) => element.checked == "REMOVED").length;
    close = removed > 0 ?false: true;
    setState(() {
    });
  }

  _getUser(String uid)async{
    _newUser = await Services().getCrntUsr(uid);
    await Data().addOrUpdateUserList(_newUser);

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  widget.entity.eid == ""? SizedBox() : Container(
                    margin: EdgeInsets.only(right: 10),
                    child: InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(5),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_back),
                        )
                    ),
                  ),
                  Text(" Payments", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30),),
                ],
              ),
              SizedBox(height: 10,),
              Expanded(child:
                SingleChildScrollView(
                  child: Column(
                    children: [
                      GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:  const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              childAspectRatio: 3 / 2,
                              crossAxisSpacing: 1,
                              mainAxisSpacing: 1
                          ),
                          itemCount: title.length,
                          itemBuilder: (context, index){
                            return Card(
                              elevation: 3,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(title[index], style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black),),
                                  Text(
                                    index==0
                                        ?'Ksh.${formatNumberWithCommas(inPay)}'
                                        : index==1
                                        ? 'Ksh.${formatNumberWithCommas(outPay)}'
                                        : index==2
                                        ? _pay.length.toString()
                                        : index==3
                                        ?_sale.length.toString()
                                        : index==4
                                        ?_purchase.length.toString()
                                        :"0",
                                    style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),
                                  )
                                ],
                              ),
                            );
                          }),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          _reloading || _loading
                              ? SizedBox(
                              width: 15, height: 15,
                              child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2,))
                              : SizedBox(),
                          Expanded(child: SizedBox()),
                          CardButton(
                            text:'FILTER',
                            backcolor: Colors.white,
                            icon: Icon(Icons.filter_list, size: 19, color: Colors.black,), forecolor: Colors.black,
                            onTap: () {

                            },
                          ),
                          CardButton(
                            text:'RELOAD',
                            backcolor: screenBackgroundColor,
                            icon: Icon(Icons.refresh, size: 19, color: Colors.white,), forecolor: Colors.white,
                            onTap: (){_getDetails();},
                          ),
                        ],
                      ),
                      close == false
                          ? ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 400,
                          maxWidth: 600,
                        ),
                        child: Card(
                          color: Colors.white,
                          elevation: 8,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.delete, size: 30, color: Colors.red,),
                                SizedBox(width: 15,),
                                Expanded(
                                  child: RichText(
                                      text: TextSpan(
                                          style: TextStyle(fontSize: 13),
                                          children: [
                                            TextSpan(
                                                text: "Attention: ",
                                                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)
                                            ),
                                            TextSpan(
                                                text: "${removed.toString()} ",
                                                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)
                                            ),
                                            TextSpan(
                                                text: removed > 1? "payment records have " : "payment record has ",
                                                style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                            ),
                                            TextSpan(
                                                text: "been removed from our server by one of the managers. This change may impact your data. Would you like to update your list to reflect these changes? ",
                                                style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                            ),
                                            WidgetSpan(
                                                child: InkWell(
                                                    onTap: (){
                                                      _removeAll();
                                                    },
                                                    child: Text("Remove All", style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.bold),)
                                                )
                                            )
                                          ]
                                      )
                                  ),
                                ),
                                InkWell(
                                    onTap: (){
                                      setState(() {
                                        close = true;
                                      });
                                    },
                                    child: Icon(Icons.close, size: 30,color: Colors.black,)
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                          : SizedBox(),
                      SizedBox(height: 10,),
                      Container(
                        constraints: BoxConstraints(
                          minWidth: 400,
                          maxWidth: 500,
                        ),
                        child: GroupedListView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.all(5),
                          order: GroupedListOrder.DESC,
                          elements: _pay,
                          groupBy: (payment) => DateTime(
                            DateTime.parse(payment.time.toString()).year,
                            DateTime.parse(payment.time.toString()).month,
                            DateTime.parse(payment.time.toString()).day,
                          ),
                          groupHeaderBuilder: (PaymentModel payment) {
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            final yesterday = today.subtract(Duration(days: 1));
                            final time = DateTime.parse(payment.time.toString());
                            return Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: color1,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  time.year == now.year && time.month == now.month && time.day == now.day
                                      ? 'Today'
                                      : time.year == yesterday.year && time.month == yesterday.month && time.day == yesterday.day
                                      ? 'Yesterday'
                                      : DateFormat.yMMMd().format(time),
                                  style: TextStyle(fontSize: 9),
                                ),
                              ),
                            );
                          },
                          itemComparator: (item1, item2) => DateTime.parse(item1.time.toString()).compareTo(DateTime.parse(item2.time.toString())),
                          indexedItemBuilder : (BuildContext context, PaymentModel payment, int index) {
                            EntityModel entity = _entity.firstWhere((test) => test.eid == payment.eid, orElse: () =>
                                EntityModel(eid: "", title: "--", image: ""));
                            bool _isAdmin = entity.admin.toString().contains(currentUser.uid);
                            UserModel cashier = _users.firstWhere((test) => test.uid ==payment.payerid!, orElse: () => UserModel(uid: "", image: "", username: "--"));
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Slidable(
                                endActionPane:  ActionPane(
                                  motion: ScrollMotion(),
                                  children: [
                                    SizedBox(width: _isAdmin? 5 : 0,),
                                    _isAdmin? SlidableAction(
                                      onPressed: (context){
                                        dialogDelete(context,payment);
                                      },
                                      backgroundColor: CupertinoColors.systemRed.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(25),
                                      foregroundColor: CupertinoColors.systemRed,
                                      icon: CupertinoIcons.delete,
                                    ) : SizedBox(),
                                    SizedBox(width: 5,),
                                    SlidableAction(
                                      onPressed: (context){
                                        Get.to(() => Receipt(payment: payment), transition: Transition.rightToLeft);
                                      },
                                      backgroundColor: color1,
                                      borderRadius: BorderRadius.circular(25),
                                      foregroundColor: reverse,
                                      icon: CupertinoIcons.doc_plaintext,
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: (){
                                    Get.to(() => Receipt(payment: payment), transition: Transition.rightToLeft);
                                  },
                                  borderRadius: BorderRadius.circular(25),
                                  splashColor: secBtn,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                    decoration: BoxDecoration(
                                        color: color1,
                                        borderRadius: BorderRadius.circular(25)
                                    ),
                                    child: Row(
                                      children: [
                                        entity.eid == ""
                                            ? ShimmerWidget.circular(width: 40, height: 40)
                                            : widget.entity.eid == ""
                                            ? PropLogo(entity: entity)
                                            : UserProfile(image: cashier.image.toString()),
                                        SizedBox(width: 15,),
                                        Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                widget.entity.eid == ""
                                                    ?Text(entity.title.toString(), style: TextStyle(fontSize: 16))
                                                    :Text(cashier.username.toString(), style: TextStyle(fontSize: 16)) ,
                                                Text(
                                                    '${TFormat().toCamelCase(payment.type.toString())} ● ${payment.items} Items',
                                                    style: TextStyle(color: secondaryColor)
                                                ),
                                              ],
                                            )
                                        ),

                                        Text(
                                          '${payment.type.toString() == "PURCHASE"||payment.type.toString() =="PAYABLE"?'-':'+'}${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(payment.amount.toString()))}',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: payment.type.toString() == "PURCHASE"||payment.type.toString() =="PAYABLE"? CupertinoColors.activeOrange : CupertinoColors.activeGreen
                                          ),
                                        ),
                                        payment.checked == "true"? SizedBox() : Container(
                                          margin: EdgeInsets.only(left: 10),
                                            child: Icon(
                                                payment.checked.toString().toLowerCase().contains("removed") || payment.checked.toString().toLowerCase().contains("delete")
                                                    ? CupertinoIcons.delete
                                                    :  payment.checked.toString().toLowerCase().contains("false")
                                                    ? Icons.cloud_upload
                                                    : payment.checked.toString().toLowerCase().contains("edit")
                                                    ? Icons.edit
                                                    : CupertinoIcons.question,
                                              color: CupertinoColors.systemRed,
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  void dialogDelete(BuildContext context, PaymentModel payment){
    showDialog(
        context: context,
        builder: (BuildContext context){
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTitle(title: "D E L E T E"),
              Text(
                "Are sure you want to delete this payment? If so press the delete button to proceed.",
                style: TextStyle(color: secondaryColor),
                textAlign: TextAlign.center,
              ),
              DoubleCallAction(
                  action: (){
                    Navigator.pop(context);
                    _delete(payment);
                  },
                  title: "Delete",
                  titleColor: CupertinoColors.systemRed,
              )
            ],
          ),
        ),
      );
    });
  }

  _delete(PaymentModel payment){
    Data().removePayment(payment, _getData, context).then((value){

    });

  }


  _removeAll()async{
    List<String> uniquePayment = [];
    List<PaymentModel> _payments = [];

    List<PaymentModel> payToRemove = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _payments = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();

    _payments.where((test)=>test.checked.toString().contains("REMOVED")).forEach((payment){
      payToRemove.add(payment);
    });

    for (var payment in payToRemove) {
      _payments.removeWhere((element) => element.payid == payment.payid);
    }

    uniquePayment  = _payments.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypayments', uniquePayment);
    myPayments = uniquePayment;
    _getData();
  }
  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
