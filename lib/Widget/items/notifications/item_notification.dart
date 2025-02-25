import 'dart:convert';
import 'dart:io';
import 'dart:io';

import 'package:TallyApp/Widget/logos/prop_logo.dart';
import 'package:TallyApp/Widget/shimmer_widget.dart';
import 'package:TallyApp/home/action_bar/chats/message_screen.dart';
import 'package:TallyApp/home/action_bar/chats/web_chat.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/messages.dart';
import 'package:TallyApp/models/notifications.dart';
import 'package:TallyApp/models/users.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import '../../../models/data.dart';
import '../../../models/duties.dart';
import '../../profile_images/user_profile.dart';
import '../../text/text_format.dart';


class ItemNotif extends StatefulWidget {
  final NotifModel notif;
  final Function getEntity;
  final Function remove;
  const ItemNotif({super.key, required this.notif, required this.getEntity, required this.remove});

  @override
  State<ItemNotif> createState() => _ItemNotifState();
}

class _ItemNotifState extends State<ItemNotif> {
  List<EntityModel> _entity = [];
  List<EntityModel> _newEntity = [];
  List<EntityModel> _notMyEntity = [];
  List<EntityModel> _crrntEntity = [];
  List<UserModel> _users = [];
  List<UserModel> _newUsers = [];
  List<String> activityList = [];
  List<DutiesModel> _duties = [];
  List<String> dutiesList = [];
  List<String> pidList = [];
  NotifModel notifModel = NotifModel(nid: "");
  List<String> uidList = [];

  String did = '';
  bool _loading = false;
  bool _isExpanded = true;

  EntityModel entity = EntityModel(eid: "", title: "N/A");
  UserModel user = UserModel(uid: "", username: "N/A");
  UserModel sender = UserModel(uid: "", username: "", image: "");
  UserModel receiver = UserModel(uid: "", username: "", image: "");
  DutiesModel dutyModel = DutiesModel(did: "");


  _getDetails()async{
    _getData();
    _newEntity = await Services().getCurrentEntity(currentUser.uid);
    _newUsers = await Services().getCrntUsr(uidList.first);
    _crrntEntity = await Services().getOneEntity(notifModel.eid.toString());
    await Data().addOrUpdateUserList(_newUsers);
    await Data().addOrUpdateEntity(_newEntity);
    await Data().addOrUpdateNotMyEntity(_crrntEntity);
    await Data().updateSeen(notifModel);
    _getData();
  }

  _getData(){
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _notMyEntity = notMyEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _users = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    entity = _notMyEntity.firstWhere((test) => test.eid == notifModel.eid, orElse: ()=> EntityModel(eid: "", title: "N/A"));

    uidList.add(notifModel.sid.toString());
    uidList.add(notifModel.rid.toString());
    uidList.remove(currentUser.uid);

    user = _users.firstWhere((element) => element.uid == uidList.first, orElse: () => UserModel(uid: "", username: "", image: ""));
    sender = _users.firstWhere((element) => element.uid == notifModel.sid, orElse: () => UserModel(uid: "", username: "", image: ""));
    receiver = _users.firstWhere((element) => element.uid == notifModel.rid, orElse: () => UserModel(uid: "", username: "", image: ""));
    dutyModel = _duties.isEmpty? DutiesModel(did: ""):_duties.first;
    pidList = entity.pid.toString().split(",");
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
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
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
                    Icon(CupertinoIcons.arrow_up_right_circle, size: 12,color: secondaryColor,),
                    SizedBox(width: 5,),
                    Text("REQUEST ", style: TextStyle(color: secondaryColor),),
                    notifModel.actions == ""? SizedBox() :  Text("●  ${TFormat().toCamelCase("${notifModel.actions}")}", style: TextStyle(color: secondaryColor),),
                    Expanded(child: SizedBox()),
                    notifModel.actions.toString() == ""
                        ? InkWell(
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
                          AnimatedRotation(
                            duration: Duration(milliseconds: 500),
                            turns: _isExpanded ? 0.5 : 0.0,
                            child: Icon(Icons.keyboard_arrow_down),
                          ),
                        ],
                      ),
                    ):Text(timeago.format(DateTime.parse(notifModel.time.toString())), style: TextStyle(fontSize: 13)),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    user.uid == "" || entity.eid == ""
                        ? ShimmerWidget.circular(width: 50, height: 50)
                        : notifModel.actions == ""
                        ? UserProfile(image: user.image.toString(), radius: 25,)
                        : PropLogo(entity: entity),
                    SizedBox(width: 15,),
                    Expanded(
                        child: user.uid == "" || entity.eid == ""
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
                            Text(notifModel.actions == ""? user.username.toString() : entity.title.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: reverse),),
                            notifModel.actions == ""
                                ? RichText(
                                maxLines: _isExpanded?100:1,
                                overflow: TextOverflow.ellipsis,
                                text: widget.notif.rid == currentUser.uid ? TextSpan(
                                    children: [
                                      TextSpan(
                                          text: "You have received an invitation to join ",
                                          style: style
                                      ),
                                      TextSpan(
                                          text: '${entity.title} ',
                                          style: bold
                                      ),
                                      TextSpan(
                                          text: "as a ",
                                          style: style
                                      ),
                                      WidgetSpan(
                                          child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                              decoration: BoxDecoration(
                                                  color:Colors.lightBlueAccent.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                              child: Text("Manager", style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w700),)
                                          )
                                      )
                                    ]
                                ) : TextSpan(
                                    children: [
                                      TextSpan(
                                          text: 'An invitation has been sent to ',
                                          style: style
                                      ),
                                      TextSpan(
                                          text: "${receiver.username.toString()} ",
                                          style: bold
                                      ),
                                      TextSpan(
                                          text: 'to commence managing ',
                                          style: style
                                      ),
                                      TextSpan(
                                          text: '${entity.title.toString()}. ',
                                          style: bold
                                      ),
                                      TextSpan(
                                          text: 'This request was submitted by ',
                                          style: style
                                      ),
                                      TextSpan(
                                          text: '${sender.username.toString()} ',
                                          style: bold
                                      ),
                                      TextSpan(
                                          text: 'and is currently awaiting a response from the recipient.',
                                          style: style
                                      ),
                                    ]
                                )
                            )
                                : notifModel.actions == "ACCEPTED"
                                ? RichText(
                                text:widget.notif.rid == currentUser.uid ? TextSpan(
                                    children: [
                                      TextSpan(
                                          text: "You have joined ",
                                          style: style
                                      ),
                                      TextSpan(
                                          text: '${entity.title.toString()} ',
                                          style: bold
                                      ),
                                      TextSpan(
                                          text: "as a ",
                                          style: style
                                      ),
                                      WidgetSpan(
                                          child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                              decoration: BoxDecoration(
                                                  color:Colors.green.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                              child: Text("Manager", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700),)
                                          )
                                      )
                                    ]
                                ) : TextSpan(
                                    children: [
                                      TextSpan(
                                          text: '${user.username.toString()} ',
                                          style: bold
                                      ),
                                      TextSpan(
                                        text: "has accepted to join ",
                                        style: style,
                                      ) ,
                                      TextSpan(
                                          text: '${entity.title.toString()} ',
                                          style: bold
                                      ),
                                      TextSpan(
                                          text: "as a ",
                                          style: style
                                      ),
                                      WidgetSpan(
                                          child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                              decoration: BoxDecoration(
                                                  color:Colors.green.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                              child: Text("Manager", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700),)
                                          )
                                      )
                                    ]
                                )
                            )
                                : RichText(
                                text:widget.notif.rid == currentUser.uid ? TextSpan(
                                    children: [
                                      TextSpan(
                                          text: "You have declined to join ",
                                          style: style
                                      ),
                                      TextSpan(
                                          text: '${entity.title.toString()} ',
                                          style: bold
                                      ),
                                      TextSpan(
                                          text: "as a ",
                                          style: style
                                      ),
                                      WidgetSpan(
                                          child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                              decoration: BoxDecoration(
                                                  color:Colors.red.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                              child: Text("Manager", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),)
                                          )
                                      )
                                    ]
                                ) : TextSpan(
                                    children: [
                                      TextSpan(
                                          text: '${user.username.toString()} ',
                                          style: bold
                                      ),
                                      TextSpan(
                                        text: "has declined to join ",
                                        style: style,
                                      ) ,
                                      TextSpan(
                                          text: '${entity.title.toString()} ',
                                          style: bold
                                      ),
                                      TextSpan(
                                          text: "as a ",
                                          style: style
                                      ),
                                      WidgetSpan(
                                          child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                              decoration: BoxDecoration(
                                                  color:Colors.red.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                              child: Text("Manager", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),)
                                          )
                                      )
                                    ]
                                )
                            ),
                          ],
                        )
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
                            onTap: (){_actionUpdate("ACCEPTED");},
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
                              :  Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: color1, width: 0.5)
                            ),
                            child: Text("${notifModel.actions == ""
                                ? entity.title.toString()
                                : user.username.toString()}", style: TextStyle(fontSize: 11),),
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
                                onTap: _undo,
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
  _undo(){
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
      actions: "",
    );
    Services.updateNotification(notification).then((response){
      widget.getEntity();
      if(response=='success'){
        setState(() {
          notifModel.actions = '';
          Services.updateEntityPID(notifModel.eid.toString(), pidList);
          _entityAction("remove");
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: dilogbg,
            content: Text('mmhmm🤔 something went wrong.', style: TextStyle(color: reverse,)),
          ),
        );
      }
    });
  }

  _actionUpdate(String action)async{
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    List<String> uniqueNotif= [];
    List<NotifModel> _notifs = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _notifs = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();

    _notifs.firstWhere((test) => test.nid == notifModel.nid).actions = action;
    _notifs.firstWhere((test) => test.nid == notifModel.nid).checked = action;
    notifModel.actions = action;
    notifModel.actions = action;

    uniqueNotif = _notifs.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mynotif', uniqueNotif);
    myNotif = uniqueNotif;

    NotifModel notification = NotifModel(
      nid: notifModel.nid,
      text: notifModel.text,
      type: notifModel.type,
      actions: action,
    );

    Services.updateNotification(notification).then((response){
      if(response=="success"){
        if(action=='ACCEPTED'){
          Uuid uuid = Uuid();
          notifModel.actions = 'ACCEPTED';
          if(pidList.contains(currentUser.uid)){} else {pidList.add(currentUser.uid);}
          Services.updateEntityPID(notifModel.eid.toString(), pidList).then((response) {
            print("response : ${response}");
            if(response=='success'){
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Request was accepted successfully', style: TextStyle(color: reverse,),),
                    showCloseIcon: true,
                  )
              );
              did = uuid.v1();
              _entityAction("add");
              Services.addDuties(did, notifModel.eid!, currentUser.uid, Data().dutiesList);
              setState(() {

              });
            }
          });
        } else if(action=='REJECTED'){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Request was rejected successfully', style: TextStyle(color: reverse,),),
                showCloseIcon: true,
              )
          );
          setState(() {
            notifModel.actions = 'REJECTED';
          });
        }
      }
      else if(response=='failed'){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request was not sent', style: TextStyle(color: reverse,),),
            action: SnackBarAction(
              onPressed: _actionUpdate(action),
              label: 'Try Again',
            ),
          ),
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('mmhmm🤔 something went wrong.', style: TextStyle(color: reverse,)),
          ),
        );
      }
    });
  }
  _entityAction(String action)async{
    List<EntityModel> _entity = [];
    List<DutiesModel> _duty = [];
    List<String> uniqueEntities = [];
    List<String> uniqueDuties= [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _duty = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    List<String> pids = [];
    pids = entity.admin.toString().split(",");
    DutiesModel dutiesModel = DutiesModel(
        did: did,
        eid: notifModel.eid,
        pid: currentUser.uid,
        duties: Data().dutiesList.join(","),
        checked: "true"
    );

    if(action == "add"){
      pids.add(currentUser.uid);
      if(_entity.any((test) => test.eid == entity.eid)){
        _entity.firstWhere((e) => e.eid == entity.eid).pid = pids.join(",");
        _entity.firstWhere((e) => e.eid == entity.eid).admin  = entity.admin ;
        _entity.firstWhere((e) => e.eid == entity.eid).title = entity.title;
        _entity.firstWhere((e) => e.eid == entity.eid).category = entity.category;
        _entity.firstWhere((e) => e.eid == entity.eid).image = entity.image;
        _entity.firstWhere((e) => e.eid == entity.eid).checked = "true";
      } else {
        _entity.add(entity);
      }
      _duty.add(dutiesModel);
      print("Adding ${entity.title}");
    } else {
      _entity.removeWhere((test) => test.eid == entity.eid);
      _duty.removeWhere((test) => test.did == dutiesModel.did);
      print("Removing ${entity.title}");
    }

    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    uniqueDuties = _duty.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    sharedPreferences.setStringList('myduties', uniqueDuties);
    myEntity = uniqueEntities;
    myDuties = uniqueDuties;
    widget.getEntity();
  }

  _updateCount(){}
  _changeMess(MessModel mess){}
  _callNumber(String number) async{
  }
}
