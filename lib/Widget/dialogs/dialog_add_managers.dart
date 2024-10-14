import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/notifications.dart';
import 'package:TallyApp/models/users.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../resources/socket.dart';
import '../../utils/colors.dart';
import '../buttons/bottom_call_buttons.dart';
import '../loading_screen.dart';
import '../profile_images/user_profile.dart';
import 'call_actions/double_call_action.dart';
import 'dialog_title.dart';

class DialogAddManagers extends StatefulWidget {
  final EntityModel entity;
  const DialogAddManagers({super.key, required this.entity});

  @override
  State<DialogAddManagers> createState() => _DialogAddManagersState();
}

class _DialogAddManagersState extends State<DialogAddManagers> {
  TextEditingController _search = TextEditingController();
  List<UserModel> _user = [];
  List<UserModel> _filtUser = [];
  List<EntityModel> _entity = [];
  List<String> pidListAsList = [];
  String pidList = "";
  String selectedID = "";
  bool _loading = false;
  bool _isLoading = false;
  bool isFilled = false;

  _getUsers()async{
    setState(() {
      _loading = true;
    });
    _user = await Services().getAllUser();
    _entity = await Services().getOneEntity(widget.entity.eid);
    pidList = _entity.first.pid.toString();
    pidListAsList = pidList.split(",");
    setState(() {
      _filtUser = _user.where((usr) => !pidListAsList.contains(usr.uid)).toList();
      _loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUsers();
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    List filteredList = [];
    if(_search.text.isNotEmpty){
      _filtUser.forEach((item) {
        if(item.username.toString().toLowerCase().contains(_search.text.toString())
            || item.firstname.toString().toLowerCase().contains(_search.text.toString())
            || item.lastname.toString().toLowerCase().contains(_search.text.toString()))
          filteredList.add(item);
      });
    } else {
      filteredList = _filtUser;
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
            TextFormField(
            controller: _search,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "Search",
              fillColor: color1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(5)
                ),
                borderSide: BorderSide.none,
              ),
              hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
              prefixIcon: Icon(CupertinoIcons.search, size: 20,color: secondaryColor),
              prefixIconConstraints: BoxConstraints(
                  minWidth: 40,
                  minHeight: 30
              ),
              suffixIcon: isFilled?InkWell(
                  onTap: (){
                    _search.clear();
                    setState(() {
                      isFilled = false;
                    });
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: Icon(Icons.cancel, size: 20,color: secondaryColor)
              ) :SizedBox(),
              suffixIconConstraints: BoxConstraints(
                  minWidth: 40,
                  minHeight: 30
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
              filled: true,
              isDense: true,
            ),
            onChanged:  (value) => setState((){
              if(value.isNotEmpty){
                isFilled = true;
              } else {
                isFilled = false;
              }
            }),
          ),
          _isLoading?LinearProgressIndicator(color: reverse,backgroundColor: color1,):SizedBox(),
          Expanded(
            child: _loading
                ?LoadingScreen()
                :ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  UserModel user = filteredList[index];
                  return  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0,),
                    child: InkWell(
                      onTap: (){dialogSendRequest(context, user);},
                      borderRadius: BorderRadius.circular(5),
                      hoverColor: color1,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Row(
                          children: [
                            UserProfile(image: user.image.toString()),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text( user.username.toString()),
                                  Text('${user.firstname} ${user.lastname}', style: TextStyle(color: secondaryColor, fontSize: 12),),
                                ],
                              ),
                            ),
                            _loading
                                ? SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: color2, strokeWidth: 2,))
                                : SizedBox(),
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
  }
  void dialogSendRequest(BuildContext context, UserModel user) {
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
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
                DialogTitle(title: "R E Q U E S T"),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Send a request to ",
                              style: style
                          ),
                          TextSpan(
                              text: "${user.username} ",
                              style: bold
                          ),
                          TextSpan(
                              text: "inorder to commence managing ",
                              style: style
                          ),
                          TextSpan(
                              text: "${widget.entity.title}.",
                              style: bold
                          ),
                        ]
                    )
                ),
                DoubleCallAction(action: (){
                  Navigator.pop(context);
                  _addNotif(user);
                })
              ],
            ),
          ),
        ),
      );
    });
  }
  _addNotif(UserModel user)async{
    String nid = "";
    String message = "";
    setState(() {
      Uuid uuid = Uuid();
      nid = uuid.v1();
      message = "${currentUser.username} has sent you a request to join ${widget.entity.title.toString().toLowerCase()} as a amanager";
      _isLoading = true;
    });
    NotifModel notitifcation = NotifModel(
        nid: nid,
        sid: currentUser.uid,
      rid: user.uid,
      eid: widget.entity.eid,
      pid: widget.entity.pid,
      text: "",
      actions: "",
      message: message,
      type: "RQMNG",
      seen: currentUser.uid,
      checked: "true",
        deleted: "",
      time: DateTime.now().toString()
    );
    Services.addNotification(notitifcation).then((response) async{
      print(response);
      if(response=="Success"){
        _socketSend(user, nid, message);
        setState((){_isLoading = false;});
        await Data().addNotification(notitifcation);
        SocketManager().notifications.add(notitifcation);
        Get.snackbar(
            maxWidth: 500,
            'Success',
            'Request Sent Successfully',
            shouldIconPulse: true,
            icon: Icon(Icons.check, color: Colors.green,)
        );
      } else if(response=='Exists') {
        setState((){_isLoading = false;});
        Get.snackbar(
            maxWidth: 500,
            'Pending',
            'Request pending response from receiver...',
            shouldIconPulse: true,
            icon: Icon(Icons.watch_later, color: Colors.blue,)
        );
      } else if(response=='Failed') {
        setState((){_isLoading = false;});
        Get.snackbar(
            maxWidth: 500,
            'Failed',
            'Request was not sent please try again',
            shouldIconPulse: true,
            icon: Icon(Icons.close, color: Colors.red,)
        );
      } else {
        setState((){_isLoading = false;});
        Get.snackbar(
            maxWidth: 500,
            'Error',
            'mmhmm🤔 something went wrong. Please try again',
            shouldIconPulse: true,
            icon: Icon(Icons.error, color: Colors.red,)
        );
      }
    });
  }

  void _socketSend(UserModel user,String nid, String message) {
    var tokens = user.token.toString().split(",");
    tokens.remove("");
    SocketManager().socket.emit("notif", {
      "nid": nid,
      "sourceId":currentUser.uid,
      "targetId":user.uid,
      "eid":widget.entity.eid,
      "pid":user.uid.split(","),
      "message": message,
      "time":DateTime.now().toString(),
      "type":"RQMNG",
      "actions":"",
      "text":"",
      "title": widget.entity.title,
      "token": tokens,
      "profile": "${Services.HOST}logos/${widget.entity.image}",
    });
  }
}
