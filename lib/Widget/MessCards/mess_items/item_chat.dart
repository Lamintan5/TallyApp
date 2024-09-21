import 'dart:convert';

import 'package:TallyApp/Widget/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:badges/badges.dart' as badges;

import '../../../home/action_bar/chats/message_screen.dart';
import '../../../main.dart';
import '../../../models/chats.dart';
import '../../../models/data.dart';
import '../../../models/messages.dart';
import '../../../models/users.dart';
import '../../../resources/services.dart';
import '../../../resources/socket.dart';
import '../../../utils/colors.dart';
import '../../profile_images/user_profile.dart';

class ItemChat extends StatefulWidget {
  final ChatsModel chatmodel;
  final String from;
  const ItemChat({super.key, required this.chatmodel, this.from = ""});

  @override
  State<ItemChat> createState() => _ItemChatState();
}

class _ItemChatState extends State<ItemChat> {
  MessModel message = MessModel(mid: "");
  late IO.Socket socket;
  List<MessModel> mess = [];
  List<MessModel> messages = [];
  List<UserModel> _user = [];
  List<ChatsModel> _chat = [];
  UserModel user = UserModel(uid: "", image: "", username: "");
  String sourceid = "";
  int countMess = 0;

  _getDetails()async{
    setState(() {
      _getData();
    });
    _user = await Services().getCrntUsr(sourceid);
    await Data().addOrUpdateUserList(_user);
    _chat.add(ChatsModel(
          cid: widget.chatmodel.cid.toString(),
        title: _user.first.username.toString(),
      time: "new"
      ),);
    await Data().addOrUpdateChats(_chat);
    _getData();
  }

  _getData(){
    List<String> uids = widget.chatmodel.cid.split(",");
    uids.remove(currentUser.uid);
    sourceid = uids.first;
    user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).firstWhere(
          (element) => element.uid == sourceid, orElse: () => UserModel(uid: "", image: "", username: ""),
    );
    setState(() {

    });
  }

  void changeMessage(MessModel newMess){
    print("Changing last message");
    if(newMess.gid!.contains(currentUser.uid) && newMess.gid!.contains(sourceid)){
      if (mounted) {
        setState(() {
          message = newMess;
        });
      }
    }
  }

  void setMessage(String mid, String gid,String sourceId, String targetId, String message, String path, String time){
    MessModel messageModel = MessModel(
      mid: mid,
      gid: gid,
      targetId: targetId,
      sourceId: sourceId,
      message: message,
      time: time,
      path: path,
      type: "",
      deleted: "",
      seen: "",
      delivered: "",
      checked: "false",
    );
    messages.add(messageModel);
    changeMessage(messageModel);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    final socketManager = Get.find<SocketManager>();
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return user.uid == ""
        ? Container(
         child:Row(
           children: [
             ShimmerWidget.circular(width: 40, height: 40),
             SizedBox(width: 10,),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   ShimmerWidget.rectangular(width: 100, height: 10),
                   SizedBox(height: 8,),
                   ShimmerWidget.rectangular(width: double.infinity, height: 10),
                 ],
               ),
             )
           ],
         ),
        )
        :ListTile(
          onTap: (){
            widget.from == "WEB"
                ? null
                : Get.to(() => MessageScreen(receiver: user, changeMess: changeMessage, updateCount: _updateCount,), transition: Transition.rightToLeftWithFade);
          },
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          leading: Stack(
            children: [
              UserProfile(image: user.image!),
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(Icons.online_prediction, size: 15, color: Colors.green,),
              ),
            ],
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(user.username.toString()),
              Obx((){
                   MessModel messmodel = socketManager.messages.lastWhere((msg) => msg.gid!.contains(currentUser.uid) && msg.gid!.contains(sourceid), 
                    orElse: ()=>MessModel(mid: ""));
                    if(messmodel.mid==""){
                      return Text("");
                    } else {

                      return Text(timeago.format(DateTime.parse(messmodel.time.toString())), style: TextStyle(
                          color: messmodel.sourceId == currentUser.uid
                              ? secondaryColor
                              :countMess == 0
                              ?secondaryColor:reverse,
                          fontSize: 11));
                    }
                  }
              )
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Obx(
                      (){
                        List<MessModel> _count = socketManager.messages.where((msg) => msg.sourceId!.contains(sourceid) && msg.gid!.contains(sourceid) && msg.type.toString()=='individual' && msg.seen =="").toList();
                        MessModel messmodel = socketManager.messages.lastWhere((msg) => msg.gid!.contains(currentUser.uid) && msg.gid!.contains(sourceid) && msg.type.toString()=='individual',
                          orElse: ()=> MessModel(mid: ""));
                        countMess = _count.length;
                        if(messmodel.mid==""){
                          return Text("");
                        } else {

                          return RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  messmodel.path==""
                                      ?TextSpan()
                                      :WidgetSpan(
                                      child: Icon(
                                          Icons.image,
                                        size: 15,
                                        color: messmodel.sourceId == currentUser.uid ?secondaryColor:countMess == 0?secondaryColor :reverse,
                                      )
                                  ),
                                  TextSpan(text: " "),
                                  TextSpan(
                                    text: messmodel.path !="" && messmodel.message ==""? "Media" : messmodel.message.toString(),
                                    style: TextStyle(color:
                                    messmodel.sourceId == currentUser.uid
                                        ? secondaryColor:countMess == 0
                                        ?secondaryColor
                                        :reverse,
                                        fontSize: 12,
                                      fontWeight: messmodel.sourceId == currentUser.uid
                                          ?FontWeight.normal
                                          : countMess == 0
                                          ?FontWeight.normal
                                          :FontWeight.w700,
                                    )
                                  )
                                ]
                              )
                          );
                        }
                      }
                  )
              ),
              SizedBox(width: 10,),
              Obx(() {
                List<MessModel> _count = socketManager.messages.where((msg) => msg.sourceId!.contains(sourceid) && msg.gid!.contains(sourceid) && msg.type.toString()=='individual' && msg.seen =="").toList();
                countMess = _count.length;
                return  Row(
                  children: [
                    badges.Badge(
                      badgeStyle: badges.BadgeStyle(
                          badgeColor: Colors.tealAccent,
                          shape: badges.BadgeShape.square,
                          borderRadius: BorderRadius.circular(30),
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5)
                      ),
                      badgeContent: Text(NumberFormat.compact().format(countMess), style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600),),
                      showBadge: countMess == 0? false : true,
                      position: badges.BadgePosition.topEnd(end: 0, top: 0),
                    ),
                  ],
                );
              })
            ],
          ),
          hoverColor: color1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        );
  }
  _updateCount(){
    countMess = 0;
    setState(() {

    });
  }
}
