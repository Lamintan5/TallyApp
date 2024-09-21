import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:badges/badges.dart' as badges;

import '../../../main.dart';
import '../../../models/chats.dart';
import '../../../models/data.dart';
import '../../../models/entities.dart';
import '../../../models/messages.dart';
import '../../../models/users.dart';
import '../../../resources/socket.dart';
import '../../../utils/colors.dart';
import '../../logos/prop_logo.dart';
import '../../shimmer_widget.dart';

class ItemChatGroup extends StatefulWidget {
  final ChatsModel chats;
  final String from;
  const ItemChatGroup({super.key, required this.chats, required this.from});

  @override
  State<ItemChatGroup> createState() => _ItemChatGroupState();
}

class _ItemChatGroupState extends State<ItemChatGroup> {
  late MessModel message;
  // late IO.Socket socket;
  List<MessModel> mess = [];
  List<MessModel> messages = [];
  EntityModel entity = EntityModel(eid: "", title: "");
  List<ChatsModel> _chat = [];
  int countMess = 0;

  _getDetails()async{
    entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).firstWhere((element) => element.eid == widget.chats.cid, orElse: () => EntityModel(eid: "", title: ""),);
    _chat.add(ChatsModel(
        cid: widget.chats.cid.toString(),
        title: entity.title.toString(),
        time: "new"
    ),);
    await Data().addOrUpdateChats(_chat);
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messages = mess.where((element) => element.gid == widget.chats.cid).toList();
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final socketManager = Get.find<SocketManager>();
    return entity.eid == ""
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
        : ListTile(
          onTap: (){
            // widget.from == "WEB"
            //     ? null
            //     : Get.to(()=>Community(entity: entity, changeMess: changeMessage, updateCount: _updateCount,), transition: Transition.rightToLeftWithFade);
          },
          contentPadding: EdgeInsets.only(bottom: 5),
          leading: PropLogo(entity: entity,),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entity.title.toString()),
              Obx((){
                MessModel messmodel = socketManager.messages.lastWhere((msg) => msg.gid == widget.chats.cid);
                  if(messmodel.mid==""){
                    return Text("");
                  } else {

                    return Text(timeago.format(DateTime.parse(messmodel.time.toString())),
                        style: TextStyle(color: messmodel.sourceId == currentUser.uid
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
            children: [
              Expanded(
                child: Obx(
                  (){
                    List<MessModel> _count = socketManager.messages.where((msg) => msg.gid.toString() == widget.chats.cid && msg.type=="group" && msg.sourceId != currentUser.uid && msg.seen=="").toList();
                    countMess = _count.length;
                    MessModel messmodel = socketManager.messages.lastWhere((msg) => msg.gid == widget.chats.cid);
                    UserModel user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString)))
                        .firstWhere((usr) => usr.uid == messmodel.sourceId, orElse: (){return UserModel(uid: "", username: "");});
                    if(messmodel.mid==""){
                      return Text("");
                    } else {
                      return RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                              children: [
                                TextSpan(
                                  text: messmodel.sourceId == currentUser.uid
                                      ? "Me : "
                                      : user.uid == "" ||user.uid == null
                                      ? "User : ": "${user.username} : ",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: messmodel.sourceId == currentUser.uid
                                        ? secondaryColor
                                        :countMess == 0
                                        ?secondaryColor:reverse,
                                    fontWeight: messmodel.sourceId == currentUser.uid
                                        ?FontWeight.normal
                                        : countMess == 0
                                        ?FontWeight.normal
                                        :FontWeight.w700,
                                  )
                                ),
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
                                    style: TextStyle(
                                        color: messmodel.sourceId == currentUser.uid
                                            ? secondaryColor
                                            :countMess == 0
                                            ?secondaryColor:reverse,
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
              Obx((){
                List<MessModel> _count = socketManager.messages.where((msg) => msg.gid.toString() == widget.chats.cid && msg.type=="group" && msg.sourceId != currentUser.uid && msg.seen=="").toList();
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
  void _updateCount(){
    countMess = 0;
    setState(() {

    });
  }
  void changeMessage(MessModel newMess){
    if(newMess.gid == widget.chats.cid){
      if (mounted) {
        setState(() {
          message = newMess;
        });
      }
    }
  }
}

