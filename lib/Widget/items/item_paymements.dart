
import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/logos/prop_logo.dart';
import 'package:TallyApp/Widget/profile_images/current_profile.dart';
import 'package:TallyApp/Widget/profile_images/user_profile.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/payments.dart';
import 'package:TallyApp/models/users.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

import '../../home/action_bar/chats/message_screen.dart';
import '../../home/action_bar/chats/web_chat.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/messages.dart';
import '../../utils/colors.dart';
import '../dialogs/dialog_title.dart';
import '../shimmer_widget.dart';

class ItemPayments extends StatefulWidget {
  final PaymentModel payment;
  final String? from;
  const ItemPayments({super.key, required this.payment, this.from});

  @override
  State<ItemPayments> createState() => _ItemPaymentsState();
}

class _ItemPaymentsState extends State<ItemPayments> {
  List<EntityModel> _enty = [];
  List<EntityModel> _newEntity = [];
  List<UserModel> _user = [];
  List<UserModel> _newUser = [];
  UserModel user = UserModel(uid: "", image: "", username: "");
  EntityModel entity = EntityModel(eid: "", image: "", title: "");
  bool _loading = false;
  bool _isExpanded = false;

  _getEntities()async{
    _getData();
    _newEntity = await Services().getCurrentEntity(currentUser.uid);
    _newUser = await Services().getCrntUsr(widget.payment.payerid!);
    Data().addOrUpdateEntity(_newEntity);
    Data().addOrUpdateUserList(_newUser);
    _getData();
  }

  _getData(){
    _enty = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    user = widget.payment.payerid == currentUser.uid
        ? currentUser
        : _user.firstWhere((element) => element.uid == widget.payment.payerid, orElse: () => UserModel(uid: "", image: "", username: "N/A"));
    entity = _enty.firstWhere((element) => element.eid == widget.payment.eid, orElse: ()=> EntityModel(eid: "", image: "", title: "N/A"));
    setState(() {
    });
  }

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getEntities();
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return  Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: (){dialogStatement(context);},
        hoverColor: color1,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: color1,
          ),
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(widget.payment.type.toString(),
                    style: TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    hoverColor: color1,
                    borderRadius: BorderRadius.circular(5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 5),
                        Text("${DateFormat.Hms().format(DateTime.parse(widget.payment.time.toString()))}" , style: TextStyle(fontSize: 13)),
                        SizedBox(width: 10),
                        AnimatedRotation(
                          duration: Duration(milliseconds: 500),
                          turns: _isExpanded ? 0.5 : 0.0,
                          child: Icon(Icons.keyboard_arrow_down),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              SizedBox(height: 5,),
              Row(
                children: [
                  user.uid == ""
                      ? ShimmerWidget.circular(width: 50, height: 50)
                      : widget.from == "Entity"
                      ? user.uid==currentUser.uid? CurrentImage(radius: 25,) :  UserProfile(image: user.image.toString(), radius: 25,)
                      : PropLogo(entity: entity, radius: 25,),
                  SizedBox(width: 15,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            user.uid == "" || entity.eid == ""
                                ? Container(margin: EdgeInsets.only(bottom: 5) ,child: ShimmerWidget.rectangular(width: 100, height: 10))
                                : widget.from == "Entity"
                                ? Expanded(child: Text(user.username.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: reverse),))
                                : Expanded(child: Text(entity.title.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: reverse),)),
                            Text(
                              '${widget.payment.type == "SALE" || widget.payment.type == "RECEIVABLE"? "+":"-"}Ksh.${formatNumberWithCommas(double.parse(widget.payment.paid.toString()))}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: widget.payment.type == "SALE" || widget.payment.type == "RECEIVABLE"? CupertinoColors.activeBlue : Colors.orange
                              ),
                            ),
                          ],
                        ),

                        RichText(
                            maxLines: _isExpanded?100:1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                style: TextStyle(fontSize: 12, color: reverse),
                                children: <TextSpan>[
                                  widget.payment.type == "PURCHASE"
                                      ? TextSpan(
                                    text: 'Confirm purchase payment of ',
                                  )
                                      : widget.payment.type == "SALE"
                                      ? TextSpan(
                                    text: 'Confirm sale payment of ',
                                  )
                                      : widget.payment.type == "PAYABLE"
                                      ? TextSpan(
                                    text: 'Confirm payable payment of ',
                                  )
                                      : widget.payment.type == "RECEIVABLE"
                                      ?TextSpan(
                                    text: 'Confirm receivable payment of ',
                                  )
                                      : TextSpan(
                                    text: '',
                                  ),
                                  TextSpan(
                                      text: 'Ksh.${formatNumberWithCommas(double.parse(widget.payment.paid.toString()))} ',
                                      style: TextStyle(fontWeight: FontWeight.w700)
                                  ),
                                  TextSpan(
                                    text: double.parse(widget.payment.amount!)-double.parse(widget.payment.paid!) == 0? "" :  "with a balance of "
                                  ),
                                  TextSpan(
                                      text: double.parse(widget.payment.amount!)-double.parse(widget.payment.paid!) == 0? "" : 'Ksh.${formatNumberWithCommas(double.parse(widget.payment.amount!)-double.parse(widget.payment.paid!))} ',
                                      style: TextStyle(fontWeight: FontWeight.w700)
                                  ),
                                  TextSpan(
                                    text: 'made at ',
                                  ),
                                  TextSpan(
                                      text: '${DateFormat.Hm().format(DateTime.parse(widget.payment.time.toString()))} ',
                                      style: TextStyle(fontWeight: FontWeight.w700,)
                                  ),
                                  TextSpan(
                                    text: 'for ',
                                  ),
                                  TextSpan(
                                      text: '${widget.payment.items} items.',
                                      style: TextStyle(fontWeight: FontWeight.w700,)
                                  ),
                                  TextSpan(
                                    text: ' Transaction carried out by ',
                                  ),
                                  TextSpan(
                                      text: '${user.username}',
                                      style: TextStyle(fontWeight: FontWeight.w700,)
                                  ),
                                  TextSpan(
                                    text: ' via ',
                                  ),
                                  TextSpan(
                                      text: '${widget.payment.method}',
                                      style: TextStyle(fontWeight: FontWeight.w700,)
                                  ),
                                ]
                            )
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15,),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                children: [
                  Expanded(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          entity.eid =="" || user.uid ==""
                              ?  ShimmerWidget.rectangular(width: 70, height: 20, borderRadius: 5,)
                              :  Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: color1, width: 0.5)
                            ),
                            child: Text(widget.from == "Entity"
                                ? entity.title.toString()
                                : user.username.toString(), style: TextStyle(fontSize: 11),),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: color1, width: 0.5)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LineIcon.box(size: 11,),
                                SizedBox(width: 5,),
                                Text("${widget.payment.items.toString()} Items", style: TextStyle(fontSize: 11, ),)
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: color1, width: 0.5)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LineIcon.wallet(size: 11,),
                                SizedBox(width: 5,),
                                Text(widget.payment.method.toString(), style: TextStyle(fontSize: 11, ),)
                              ],
                            ),
                          ),
                          double.parse(widget.payment.amount!)-double.parse(widget.payment.paid!) == 0? SizedBox() :  Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: color1, width: 0.5)
                            ),
                            child: Text("Ksh.${formatNumberWithCommas(double.parse(widget.payment.amount!)-double.parse(widget.payment.paid!))}", style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600),),
                          ),
                        ],
                      )
                  ),
                  entity.eid =="" || user.uid ==""
                      ? SizedBox()
                      : PopupMenuButton(
                      icon: widget.payment.checked.toString() == "false"
                          ?Icon(Icons.cloud_upload, color: Colors.red, size: 20)
                          :widget.payment.checked.toString().contains("DELETE") || widget.payment.checked.toString().contains("REMOVED")
                          ?Icon(CupertinoIcons.delete, color: Colors.red, size: 20)
                          : widget.payment.checked.toString().contains("EDIT")
                          ? Icon(Icons.edit,color: Colors.red, size: 20)
                          : Icon(CupertinoIcons.ellipsis, size: 20,),
                      padding: EdgeInsets.all(0),
                      itemBuilder: (context){
                        return [
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.delete),
                                SizedBox(width: 10,),
                                Text("Delete")
                              ],
                            ),
                            onTap: (){

                            },
                          ),
                          if(user.uid != currentUser.uid)
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.ellipses_bubble),
                                  SizedBox(width: 10,),
                                  Text("Message")
                                ],
                              ),
                              onTap: (){
                                Platform.isIOS || Platform.isAndroid
                                    ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: user,), transition: Transition.rightToLeft)
                                    : Get.to(() => WebChat(selected: user,), transition: Transition.rightToLeft);
                              },
                            ),
                          if(user.uid != currentUser.uid)
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.phone),
                                  SizedBox(width: 10,),
                                  Text("Call")
                                ],
                              ),
                              onTap: (){

                              },
                            ),

                        ];
                      })
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
  _updateCount(){}
  _changeMess(MessModel mess){}
  void dialogStatement(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final style = TextStyle(color: secondaryColor);
    showDialog(context: context, builder: (context){
      return Dialog(
        backgroundColor: dilogbg,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20,),
              widget.from=="entity"
                  ?user.image == ""
                  ? CircleAvatar(
                radius: 25,
                backgroundColor: color,
                child: LineIcon.user(color: reverse,),
              )
                  : CachedNetworkImage(
                cacheManager: customCacheManager,
                imageUrl: '${Services.HOST}profile/' +user.image.toString(),
                key: UniqueKey(),
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.transparent,
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) =>
                    Container(
                      height: 50,
                      width: 50,
                    ),
                errorWidget: (context, url, error) => Container(
                  height: 50,
                  width: 50,
                  child: Center(child: Icon(Icons.error_outline_rounded, size: 20,),
                  ),
                ),
              )
                  :entity.image == ""
                  ? CircleAvatar(
                radius: 25,
                backgroundColor: color,
                child: LineIcon.moneyBill(color: reverse,),
              )
                  : CachedNetworkImage(
                cacheManager: customCacheManager,
                imageUrl: '${Services.HOST}logos/' +entity.image.toString(),
                key: UniqueKey(),
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.transparent,
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) =>
                    Container(
                      height: 50,
                      width: 50,
                    ),
                errorWidget: (context, url, error) => Container(
                  height: 50,
                  width: 50,
                  child: Center(child: Icon(Icons.error_outline_rounded, size: 20,),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(),
                        SizedBox(height: 10,),
                        Text("Entity : ",style: style),
                        Text("Transaction Type : ",style: style),
                        Text("Amount : ",style: style),
                        Text("Cashier : ",style: style),
                        Text("Payment Method : ",style: style),
                        Text("Time : ",style: style),
                      ],
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(),
                          SizedBox(height: 10,),
                          Text(entity.title!),
                          Text(widget.payment.type!),
                          Text('Kshs.${formatNumberWithCommas(double.parse(widget.payment.amount!))}'),
                          Text(user.username!),
                          Text(widget.payment.method!),
                          Text(DateFormat.Hm().format(DateTime.parse(widget.payment.time.toString()))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DialogTitle(title: '${DateFormat.yMMMd().format(DateTime.parse(widget.payment.time.toString()))}')
            ],
          ),
        ),
      );
    });
  }
}
