import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:TallyApp/Widget/profile_images/user_profile.dart';
import 'package:TallyApp/Widget/shimmer_widget.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/notifications.dart';
import 'package:TallyApp/models/users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../home/action_bar/chats/message_screen.dart';
import '../../../home/action_bar/chats/web_chat.dart';
import '../../../models/duties.dart';
import '../../../models/messages.dart';
import '../../../resources/services.dart';
import '../../../utils/colors.dart';
import '../../logos/prop_logo.dart';
import '../../text/text_format.dart';

class ItemPermission extends StatefulWidget {
  final NotifModel notif;
  final Function getEntity;
  final Function remove;
  const ItemPermission({super.key, required this.notif, required this.getEntity, required this.remove});

  @override
  State<ItemPermission> createState() => _ItemPermissionState();
}

class _ItemPermissionState extends State<ItemPermission>  {
  List<EntityModel> _entity = [];
  List<EntityModel> _newEntity = [];
  List<UserModel> _users = [];
  List<UserModel> _newUsers = [];
  List<DutiesModel> _duties = [];
  List<DutiesModel> _newDuties = [];

  List<String> pidList = [];
  List<String> dutiesList = [];
  List<String> activityList = [];
  List<String> uidList = [];

  EntityModel entity = EntityModel(eid: "", title: "");
  UserModel user = UserModel(uid: "", username: "User");
  DutiesModel dutyModel = DutiesModel(did: "");
  NotifModel notifModel = NotifModel(nid: "");

  String activitiesString = "";
  String action = "";
  String account = "";
  String admin = "";

  bool _isExpanded = false;
  bool _loading = false;

  _getDetails()async{
    _getData();
    _newEntity = await Services().getCurrentEntity(currentUser.uid);
    _newUsers = await Services().getCrntUsr(notifModel.sid.toString());
    _newDuties = await Services().getCrntDuties(widget.notif.eid.toString(), widget.notif.sid.toString());
    await Data().addOrUpdateUserList(_newUsers);
    await Data().addOrUpdateEntity(_newEntity);
    await Data().addOrUpdateDutyList(_newDuties);
    await Data().updateSeen(notifModel);
    _getData();
  }
  _getData(){
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _users = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    entity = _entity.firstWhere((test) => test.eid == notifModel.eid, orElse: ()=> EntityModel(eid: "", title: ""));

    uidList.add(notifModel.sid.toString());
    uidList.add(notifModel.rid.toString());
    uidList.remove(currentUser.uid);

    user = _users.firstWhere((element) => element.uid == uidList.first, orElse: () => UserModel(uid: "", username: "", image: ""));

    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    dutyModel = _duties.firstWhere((test) => test.eid == entity.eid && test.pid == user.uid, orElse: ()=> DutiesModel(did: "", duties: ""));
    pidList = entity.pid.toString().split(",");
    activitiesString = notifModel.text.toString();
    activityList = activitiesString.split(",");
    admin = pidList.first;
    action = activityList[0];
    account = activityList[1];
    Future.delayed(Duration.zero).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notifModel = widget.notif;
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final bold = TextStyle(fontWeight: FontWeight.w800,fontSize: 13,color: reverse);
    final style = TextStyle(fontSize: 13, color: reverse);
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color1,
        borderRadius: BorderRadius.circular(5)
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, right: 8, top: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.lock, size: 12,color: secondaryColor,),
                    SizedBox(width: 5,),
                    Text("PERMISSION ", style: TextStyle(color: secondaryColor),),
                    notifModel.actions == ""? SizedBox() :  Text("●  ${TFormat().toCamelCase("${notifModel.actions}")}", style: TextStyle(color: secondaryColor),),
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
                          Text(timeago.format(DateTime.parse(notifModel.time.toString())), style: TextStyle(fontSize: 13)),
                          SizedBox(width: 10),
                          notifModel.actions.toString() != ""? SizedBox() :AnimatedRotation(
                            duration: Duration(milliseconds: 500),
                            turns: _isExpanded ? 0.5 : 0.0,
                            child: Icon(Icons.keyboard_arrow_down),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    user.uid == "" || entity.eid ==""
                        ? ShimmerWidget.circular(width: 50, height: 50)
                        : notifModel.rid == currentUser.uid
                        ? UserProfile(image: user.image.toString(), radius: 25,)
                        : PropLogo(entity: entity),
                    SizedBox(width: 15,),
                    Expanded(
                      child: user.uid == ""
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerWidget.rectangular(width: 100, height: 10),
                          SizedBox(height: 5,),
                          ShimmerWidget.rectangular(width: double.infinity, height: 10),
                          SizedBox(height: 5,),
                          ShimmerWidget.rectangular(width: double.infinity, height: 10),
                        ],
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(notifModel.rid == currentUser.uid? user.username.toString() : entity.title.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: reverse),),
                            notifModel.actions == ""
                                ? RichText(
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text: notifModel.rid == currentUser.uid
                                  ? TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'You have received a request to grant permission to',
                                        style: style
                                    ),
                                    TextSpan(
                                        text: " ${action.toLowerCase()} ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: account.toLowerCase(),
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: ' data to ',
                                        style: style
                                    ),
                                    TextSpan(
                                        text: "${account.toLowerCase()}'s",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: ' list in ',style: style
                                    ),
                                    TextSpan(
                                        text: entity.title.toString(),
                                        style: bold
                                    ),

                                  ]
                              )
                                  : TextSpan(
                                children: [
                                  TextSpan(
                                      text: 'Request to grant permission to start',
                                      style: style
                                  ),
                                  TextSpan(
                                      text: " ${action.toLowerCase()}ing",
                                      style: bold
                                  ),
                                  TextSpan(
                                      text: ' data to ',
                                      style: style
                                  ),
                                  TextSpan(
                                      text: "${account.toLowerCase()}'s",
                                      style: bold
                                  ),
                                  TextSpan(
                                      text: ' list has been sent. Please await respond from recipient ',style: style
                                  ),
                                ]
                              ),
                            )
                                : notifModel.actions == "ACCEPTED"
                                ? RichText(
                              text:notifModel.rid == currentUser.uid
                                  ? TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: user.username.toString(),
                                        style: bold
                                      ),
                                      TextSpan(
                                        text: ' has been granted permission to ',style: style
                                      ),
                                      TextSpan(
                                        text: action.toLowerCase(),
                                        style: bold
                                      ),
                                      TextSpan(
                                        text: " ${account.toLowerCase()}",
                                        style: bold
                                      ),
                                      TextSpan(
                                        text: ' data for ',style: style
                                      ),
                                      TextSpan(
                                        text: entity.title.toString(),
                                        style: bold
                                      ),

                                    ]
                                  )
                                  : TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'You have been granted permission to ',style: style
                                    ),
                                    TextSpan(
                                        text: action.toLowerCase(),
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: " ${account.toLowerCase()}",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: ' data for ',style: style
                                    ),
                                    TextSpan(
                                        text: entity.title.toString(),
                                        style: bold
                                    ),

                                  ]
                              ),
                            )
                                : notifModel.actions == "REJECTED"
                                ? RichText(
                              text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'Request to grant permission to ',style: style
                                    ),
                                    TextSpan(
                                        text: action.toLowerCase(),
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: " ${account.toLowerCase()}",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: ' data was denied',style: style
                                    ),
                                  ]
                              ),
                            )
                                : SizedBox(),
                        ],
                      ),
                    ),
                    SizedBox(width: 15,),
                  ],
                ),
                notifModel.actions.toString() == "" && notifModel.rid == currentUser.uid
                    ? AnimatedSize(
                  duration: Duration(milliseconds: 500),
                  alignment: Alignment.topCenter,
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        entity.eid == ""
                            ?  Expanded(child: ShimmerWidget.rectangular(width: 10, height: 30, borderRadius: 5,))
                            :  Expanded(
                          child: InkWell(
                            onTap: (){
                              if(pidList.contains(user.uid)){
                                _actionUpdate("ACCEPTED");
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                    content: Text("${user.username} is no longer exists in your list of managers."),
                                      showCloseIcon: true,
                                    )
                                );
                              }

                            },
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  color: color1,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: color1, width: 1)
                              ),
                              child: Center(child: Text("Accept")),
                            ),
                          ),
                        ),
                        SizedBox(width: 5,),
                        entity.eid == ""
                            ?  Expanded(child: ShimmerWidget.rectangular(width: 10, height: 30, borderRadius: 5))
                            :  Expanded(
                          child: InkWell(
                            onTap: (){_actionUpdate("REJECTED");},
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  color: color1,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: color1, width: 1)
                              ),
                              child: Center(child: Text("Reject")),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      : SizedBox(),
                )
                    : SizedBox(),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          entity.eid ==""
                              ? ShimmerWidget.rectangular(width: 100, height: 10, borderRadius: 5,)
                              : Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: color1, width: 0.5)
                            ),
                            child: Text(notifModel.rid == currentUser.uid? entity.title.toString() : account, style: TextStyle(fontSize: 11),),
                          ),
                          notifModel.rid.toString() == currentUser.uid && notifModel.actions.toString() == ""
                              ?Container(
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: color1, width: 0.5)
                              ),
                              child: Text("Action Required", style: TextStyle(fontSize: 11, color: Colors.green))
                          )
                              : SizedBox()
                        ],
                      ),
                    ),

                    PopupMenuButton(
                        icon: Icon(Icons.more_horiz),
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
                              onTap: ()async{
                                await Data().deleteNotif(context, notifModel, widget.remove);
                              },
                            ),
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
                            if(user.phone.toString()!=""||Platform.isAndroid||Platform.isIOS)
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.phone),
                                    SizedBox(width: 10,),
                                    Text("Call")
                                  ],
                                ),
                                onTap: (){
                                  if(user.phone==""||user.phone==null){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(Data().noPhone),
                                          width: 500,
                                          showCloseIcon: true,
                                        )
                                    );
                                  } else {
                                    _callNumber(user.phone.toString());
                                  }
                                },
                              ),

                            if(notifModel.rid==currentUser.uid && notifModel.actions=="REJECTED")
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.restart),
                                    SizedBox(width: 10,),
                                    Text("Undo")
                                  ],
                                ),
                                onTap: (){
                                  notifModel.actions = '';
                                  dutiesList.remove(notifModel.text.toString().split(",").last);
                                  _undo();
                                },
                              ),
                          ];
                        }),
                  ],
                ),
              ],
            ),
          ),
          _loading ? LinearProgressIndicator(color: secBtn, minHeight: 2,) : SizedBox()
        ],
      ),
    );
  }

  _actionUpdate(String action)async{
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    NotifModel notification = NotifModel(
      nid: notifModel.nid,
      text: notifModel.text,
      type: notifModel.type,
      actions: action,
    );
    setState(() {
      _loading = true;
    });
    Services.updateNotification(notification).then((response){
      if(response=='success'){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: dilogbg,
            content: Text(action=="ACCEPTED"?'Request Accepted Successfully':'Request Rejected', style: TextStyle(color: reverse,)),
            action: SnackBarAction(
              onPressed: (){
                notifModel.actions = '';
                dutiesList.remove(notification.text.toString().split(",").last);
                _undo();
              },
              label: 'Undo',
            ),
            showCloseIcon: true,
          ),
        );
        if(action=='ACCEPTED'){
          notifModel.actions = 'ACCEPTED';
          dutiesList = dutyModel.duties.toString().split(",");
          if(dutiesList.contains(notification.text.toString().split(",").last)){

          } else {
            dutiesList.add(notification.text.toString().split(",").last);
          }
          Services.updateDuties(dutyModel.did, dutiesList).then((value){
            print("Value : $value $dutiesList");
          });
          _updateNotif();
          _updateDuty();
          setState(() {
            _loading = false;
          });
        } else if(action=='REJECTED'){
          setState(() {
            _loading = false;
            notifModel.actions = 'REJECTED';
          });
        }
      } else if(response=='failed'){
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: dilogbg,
            content: Text('Request was not sent', style: TextStyle(color: reverse,),),
            showCloseIcon: true,
            action: SnackBarAction(
              onPressed: _actionUpdate(action),
              label: 'Try Again',
            ),
          ),
        );
      } else {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: dilogbg,
            content: Text('mmhmm🤔 something went wrong.', style: TextStyle(color: reverse,)),
            showCloseIcon: true,
          ),
        );
      }
    });
  }
  _updateNotif()async{
    List<String> uniqueNotif= [];
    List<NotifModel> _notifs = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _notifs = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();

    _notifs.firstWhere((test) => test.nid == notifModel.nid).actions = notifModel.actions;

    uniqueNotif = _notifs.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mynotif', uniqueNotif);
    myNotif = uniqueNotif;
  }
  _updateDuty()async{
    List<String> uniqueDuties= [];
    List<DutiesModel> _duty = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _duty = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();

    _duty.firstWhere((test) => test.eid == notifModel.eid && test.pid == user.uid).duties = dutiesList.join(",");

    uniqueDuties = _duty.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myduties', uniqueDuties);
    myDuties = uniqueDuties;
  }

  _undo(){
    NotifModel notification = NotifModel(
      nid: notifModel.nid,
      text: notifModel.text,
      type: notifModel.type,
      actions: "",
    );
    setState(() {
      _loading = true;
    });
    Services.updateNotification(notification).then((response){
      if(response=="success"){
        Services.updateDuties(dutyModel.did, dutiesList);
        _updateDuty();
        _updateNotif();
        setState(() {
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  _updateCount(){}
  _changeMess(MessModel mess){}
  _callNumber(String number) async{
    await FlutterPhoneDirectCaller.callNumber(number);
  }
}
