import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:TallyApp/Widget/profile_images/user_profile.dart';
import 'package:TallyApp/home/action_bar/chats/message_screen.dart';
import 'package:TallyApp/home/action_bar/chats/web_chat.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/users.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/duties.dart';
import '../../models/messages.dart';
import '../../utils/colors.dart';
import '../../views/entity_options/duties.dart';
import '../buttons/bottom_call_buttons.dart';
import '../dialogs/call_actions/double_call_action.dart';
import '../dialogs/dialog_title.dart';

class ItemManagers extends StatefulWidget {
  final UserModel user;
  final EntityModel entity;
  final Function getManagers;
  final Function remove;
  const ItemManagers(
      {super.key,
      required this.user,
      required this.entity,
      required this.getManagers, required this.remove});

  @override
  State<ItemManagers> createState() => _ItemManagersState();
}

class _ItemManagersState extends State<ItemManagers> {
  List<DutiesModel> _duties = [];
  List<DutiesModel> _bewDuties = [];
  DutiesModel dutiesModel = DutiesModel(did: "");
  List<String> pidList = [];
  List<String> admin = [];
  bool _loading = false;
  bool _expanded = false;

  _getDetails() async {
    _getData();
    _bewDuties = await Services().getCrntDuties(widget.entity.eid, widget.user.uid);
    await Data().addOrUpdateDutyList(_bewDuties);
    _getData();
  }

  _getData() {
    _duties = myDuties
        .map((jsonString) => DutiesModel.fromJson(json.decode(jsonString)))
        .toList();
    dutiesModel = _duties.firstWhere(
        (test) => test.eid == widget.entity.eid && test.pid == widget.user.uid,
        orElse: () => DutiesModel(did: ""));
    admin = widget.entity.admin.toString().split(",");
    pidList = widget.entity.pid.toString().split(",");
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

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            hoverColor: color1,
            borderRadius: BorderRadius.circular(5),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: Row(
                children: [
                  UserProfile(image: widget.user.image.toString()),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.user.username.toString()),
                        Text(
                          '${widget.user.firstname} ${widget.user.lastname}',
                          style: TextStyle(color: secondaryColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                      admin.contains(widget.user.uid)? "Admin" : "",
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                  SizedBox(width: 10,),
                  _loading
                      ? Container(
                          margin: EdgeInsets.only(right: 10),
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: reverse, strokeWidth: 3)
                      )
                      : SizedBox(),
                  widget.user.uid==currentUser.uid
                      ? SizedBox()
                      : AnimatedRotation(
                    duration: Duration(milliseconds: 500),
                    turns: _expanded ? 0.5 : 0.0,
                    child: Icon(Icons.keyboard_arrow_down, color: secondaryColor,),
                  ),
                ],
              ),
            ),
          ),
          widget.user.uid==currentUser.uid
              ?  SizedBox()
              : AnimatedSize(
                duration: Duration(milliseconds: 500),
                alignment: Alignment.topCenter,
                curve: Curves.easeInOut,
                child: _expanded
                    ? Column(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          admin.contains(widget.user.uid)
                              ? SizedBox()
                              : BottomCallButtons(
                              onTap: () {
                                Get.to(() => Duties(
                                    duties: dutiesModel,
                                    getDuties: _getDetails,
                                    eid: widget.entity.eid,
                                    pid: widget.entity.pid.toString()
                                ),
                                    transition: Transition.rightToLeft);
                              },
                              icon: Icon(Icons.workspaces_rounded,
                                  color: secondaryColor),
                              actionColor: secondaryColor,
                              backColor: Colors.transparent,
                              title: "Permissions"
                          ),
                          admin.contains(widget.user.uid) ? SizedBox()
                              : Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: VerticalDivider(
                              thickness: 1,
                              width: 15,
                              color: secondaryColor,
                            ),
                          ),
                          !admin.contains(currentUser.uid) || admin.first.toString() == widget.user.uid
                              ? SizedBox()
                              : BottomCallButtons(
                              onTap: () {
                                if(admin.contains(widget.user.uid)){
                                  dialogAdmin(context,"Remove");
                                } else {
                                  dialogAdmin(context, "Add");
                                }
                              },
                              icon: Icon(CupertinoIcons.checkmark_seal,
                                  color: secondaryColor),
                              actionColor: secondaryColor,
                              backColor: Colors.transparent,
                              title: admin.contains(widget.user.uid)?"-Admin":"+Admin"
                          ),
                          !admin.contains(currentUser.uid) || admin.first.toString() == widget.user.uid ? SizedBox()
                              : Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: VerticalDivider(
                              thickness: 1,
                              width: 15,
                              color: secondaryColor,
                            ),
                          ),
                          !admin.contains(currentUser.uid) || admin.first.toString() == widget.user.uid
                              ? SizedBox()
                              : BottomCallButtons(
                              onTap: () {
                                dialogRemove(context);
                              },
                              icon: LineIcon.removeUser(color: secondaryColor,),
                              actionColor: secondaryColor,
                              backColor: Colors.transparent,
                              title: "Remove"
                          ),
                          !admin.contains(currentUser.uid) || admin.first.toString() == widget.user.uid? SizedBox()
                              : Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: VerticalDivider(
                              thickness: 1,
                              width: 15,
                              color: secondaryColor,
                            ),
                          ),
                          Platform.isAndroid || Platform.isIOS?  BottomCallButtons(
                              onTap: () {
                                if(widget.user.phone.toString()==""){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(Data().noPhone),
                                        width: 500,
                                        showCloseIcon: true,
                                      )
                                  );
                                }else {
                                  _callNumber(widget.user.phone.toString());
                                }
                              },
                              icon: Icon(
                                CupertinoIcons.phone,
                                color: secondaryColor,
                              ),
                              actionColor: secondaryColor,
                              backColor: Colors.transparent,
                              title: "Call") : SizedBox(),
                          Platform.isAndroid || Platform.isIOS?  Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: VerticalDivider(
                              thickness: 1,
                              width: 15,
                              color: secondaryColor,
                            ),
                          ) : SizedBox(),
                          BottomCallButtons(
                              onTap: () {
                                Platform.isAndroid || Platform.isIOS
                                    ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: widget.user), transition: Transition.rightToLeft)
                                    : Get.to(() => WebChat(selected: widget.user), transition: Transition.rightToLeft);
                              },
                              icon: Icon(
                                CupertinoIcons.ellipses_bubble,
                                color: secondaryColor,
                              ),
                              actionColor: secondaryColor,
                              backColor: Colors.transparent,
                              title: "Message"
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                    : SizedBox(),
              )
        ],
      ),
    );
  }

  void dialogRemove(BuildContext context) {
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    showDialog(
        context: context,
        builder: (context) => Dialog(
              alignment: Alignment.center,
              backgroundColor: dilogbg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                width: 450,
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DialogTitle(title: 'D E L E T E'),
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(
                              text:
                                  "Are you certain you want to proceed with this action? Please be aware that once ",
                              style: TextStyle(
                                  fontSize: 13, color: secondaryColor)),
                          TextSpan(
                              text: "${widget.user.username} ",
                              style: TextStyle(fontSize: 13, color: reverse)),
                          TextSpan(
                              text:
                                  "is removed from your list of managers, they will no longer have access to the data for ",
                              style: TextStyle(
                                  fontSize: 13, color: secondaryColor)),
                          TextSpan(
                              text: "${widget.entity.title}.",
                              style: TextStyle(fontSize: 13, color: reverse))
                        ])),
                    DoubleCallAction(
                      action: () async {
                        Navigator.pop(context);
                        _remove();
                        await Data().removeAdmin(context, widget.entity, widget.user, _reload);
                      },
                      title: "Remove",
                      titleColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ));
  }

  _remove()async{
    setState(() {
      _loading = true;
    });
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();

    pidList.remove(widget.user.uid);

    _entity.firstWhere((element) => element.eid == widget.entity.eid).pid = pidList.join(",");
    _entity.firstWhere((element) => element.eid == widget.entity.eid).checked = widget.entity.checked.contains("EDIT")
        ? widget.entity.checked
        : "${widget.entity.checked}, EDIT";

    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    widget.remove(widget.user);

    Services.updateEntityPID(widget.entity.eid.toString(), pidList).then((response) {
      if(response=="success"){
        _entity.firstWhere((element) => element.eid == widget.entity.eid).checked = "true";

        uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myentity', uniqueEntities);
        myEntity = uniqueEntities;
      }
    });
    setState(() {
      _loading = false;
    });
  }
  void dialogAdmin(BuildContext context, String action) {
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final style = TextStyle(fontSize: 13, color: secondaryColor);
    final bold = TextStyle(fontSize: 13, color: revers);
    showDialog(context: context, builder: (context){
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "A D M I N"),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                              text: action=="Remove"?"Are you sure you want to remove " : "Are you sure you want to assign ",
                              style: style
                          ),
                          TextSpan(
                              text: "${widget.user.username} ",
                              style: bold
                          ),
                          TextSpan(
                              text: "as the entity's admin? ",
                              style: style
                          ),
                          TextSpan(
                              text: action=="Remove"?"":"This action will grant them full access to manage all data related to  ",
                              style: style
                          ),
                          TextSpan(
                              text: action=="Remove"?"":"${widget.entity.title}.",
                              style: bold
                          ),
                        ]
                    )
                ),
                DoubleCallAction(action: ()async{
                  Navigator.pop(context);
                  setState(() {
                    _loading = true;
                  });
                  if(action=="Remove"){
                    await Data().removeAdmin(context, widget.entity, widget.user, _reload).then((value){
                      setState(() {
                        _loading = value;
                      });
                    });
                  } else {
                    await Data().makeAdmin(context, widget.entity, widget.user, _reload).then((value){
                      setState(() {
                        _loading = value;
                      });
                    });
                  }

                })
              ],
            ),
          ),
        ),
      );
    });
  }
  void _reload(UserModel user, String action){
    if(action=="Add"){
      if(!admin.contains(user.uid)){
        admin.add(user.uid);
        print("Adding : ${user.username}");
      }
    } else {
      if(admin.contains(user.uid)){
        admin.remove(user.uid);
        print("Removing : ${user.username}");
      }
    }

    widget.getManagers();
    setState(() {

    });
  }
  _updateCount() {}
  _changeMess(MessModel newMess) {
  }

  _callNumber(String number) async{
  }
}
