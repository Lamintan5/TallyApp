import 'dart:convert';

import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../models/notifications.dart';
import '../../models/users.dart';
import '../../resources/services.dart';
import '../../resources/socket.dart';

class DialogRequest extends StatefulWidget {
  final String action;
  final String account;
  final EntityModel entity;

  const DialogRequest({super.key, required this.account, required this.action, required this.entity});

  @override
  State<DialogRequest> createState() => _DialogRequestState();
}

class _DialogRequestState extends State<DialogRequest> {
  List<UserModel> _user = [];
  List<UserModel> _newUser = [];
  late UserModel admin;
  String nid = "";
  String message = "";
  bool _isLoading = false;
  List<String> _pids = [];

  _getDetails()async{
    _getData();
    _newUser = await Services().getCrntUsr(widget.entity.pid.toString().split(",").first);
    await Data().addOrUpdateUserList(_newUser);
    _getData();
  }
  _getData(){
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    admin = _user.firstWhere((test) => test.uid == widget.entity.pid.toString().split(",").first, orElse: ()=>
        UserModel(uid: "", username: "", token: ""));
    setState(() {

    });
  }

  _addNotification()async{
    setState(() {
      Uuid uuid = Uuid();
      nid = uuid.v1();
      _pids = widget.entity.pid!.split(",");
      _pids.remove(currentUser.uid);
      _pids.remove("");
      message = "${currentUser.username} has sent a request to start ${widget.action.toLowerCase()}ing data to ${widget.account.toLowerCase()} list";
      _isLoading = true;
    });
    NotifModel notitifcation = NotifModel(
        nid: nid,
        sid: currentUser.uid,
        rid: admin.uid,
        eid: widget.entity.eid,
        pid: widget.entity.pid,
        text: "${widget.action},${widget.account}",
        actions: "",
        message: message,
        type: "PERMISSION",
        seen: currentUser.uid,
        checked: "true",
        deleted:"",
        time: DateTime.now().toString()
    );
    Services.addNotification(notitifcation) .then((response)async {
          print("Response : ${response}");
      if(response=="Success"){
        _socketSend();
        await Data().addNotification(notitifcation);
        SocketManager().notifications.add(notitifcation);
        Navigator.pop(context);
        Get.snackbar(
            'Success',
            'Request Sent Successfully',
            shouldIconPulse: true,
            icon: Icon(Icons.check, color: Colors.green,),
            maxWidth: 500,
        );
      } else if(response=='Exists') {
        Get.snackbar(
            'Pending',
            'Request pending response from receiver...',
            shouldIconPulse: true,
            icon: Icon(Icons.watch_later, color: Colors.blue,),
            maxWidth: 500,
        );
        Navigator.pop(context);
      } else if(response=='Failed') {
        Get.snackbar(
            'Failed',
            'Request was not sent please try again',
            shouldIconPulse: true,
            icon: Icon(Icons.close, color: Colors.red,),
            maxWidth: 500,
        );
      } else {
        Get.snackbar(
            'Error',
            'mmhmm🤔 something went wrong. Please try again',
            shouldIconPulse: true,
            icon: Icon(Icons.error, color: Colors.red,),
            maxWidth: 500,
        );
      }
    });
    setState(() {_isLoading = false;});
  }

  void _socketSend() {
    SocketManager().socket.emit("notif", {
      "nid": nid,
      "sourceId":currentUser.uid,
      "targetId":admin.uid,
      "eid":widget.entity.eid,
      "pid":_pids,
      "message": message,
      "time":DateTime.now().toString(),
      "type":"PERMISSION",
      "actions":"",
      "text":"${widget.action},${widget.account}",
      "title": widget.entity.title,
      "token": admin.token.toString().split(","),
      "profile": widget.entity.image.toString().isEmpty? "" : "${Services.HOST}logos/${widget.entity.image}",
    });
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
    final style = TextStyle(fontSize: 13, color: secondaryColor);
    final bold = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "You do not have permission to ",
                  style: style
                ),
                TextSpan(
                  text: "${widget.action.toLowerCase()} ${widget.account.toLowerCase()} ",
                  style: bold
                ),
                TextSpan(
                  text: "records. Would you like to send a request for permission to make these changes?",
                  style: style
                )
              ]
            )
        ),
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
                    onTap: (){
                      _addNotification();
                    },
                    child: SizedBox(height: 40,
                      child: Center(
                        child: _isLoading
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2,))
                            :Text(
                          "Continue",
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
    );
  }
}
