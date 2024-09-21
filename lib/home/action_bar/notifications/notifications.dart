import 'dart:convert';

import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/notifications.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Widget/items/notifications/item_notification.dart';
import '../../../Widget/items/notifications/item_permission.dart';
import '../../../resources/socket.dart';


class Notifications extends StatefulWidget {
  final Function getEntity;
  final Function updateCount;
  const Notifications({super.key, required this.getEntity, required this.updateCount});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late ScrollController _scrollcontroller;
  late GlobalKey<AnimatedListState> _key;
  final socketManager = Get.find<SocketManager>();
  List<NotifModel> _notifs = [];
  List<NotifModel> _notif = [];
  bool _loading = false;

  _getDetails()async{
    _notif = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();
    await Data().checkNotifications(_notif, (){});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollcontroller = ScrollController();
    _key = GlobalKey();
    SocketManager().getDetails();
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
    final socketManager = Get.find<SocketManager>();
    List<NotifModel> mynotifs = socketManager.notifications;

    return Scaffold(
      backgroundColor: normal,
      appBar: AppBar(
        backgroundColor: normal,
        foregroundColor: reverse,
        actions: [
          IconButton(
            onPressed: (){},
            icon: Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: (){},
            icon: Icon(Icons.more_vert),
          )
        ],
      ),
      body: Column(
        children: [
          Row(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                width: 450,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notifications', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                    SizedBox(height: 10,),
                    Expanded(
                        child: Obx((){
                          if (mounted && _key.currentState != null) {
                            int itemIndex = 0;
                            if (itemIndex >= 0 && itemIndex <= mynotifs.length) {
                              _key.currentState!.insertItem(itemIndex, duration: Duration(milliseconds: 800));
                            } else {
                            }
                          }
                          void _remove(NotifModel notif){
                            mynotifs.removeWhere((test) => test.nid == notif.nid);
                          }

                          return AnimatedList(
                            key: _key,
                            controller: _scrollcontroller,
                            physics: BouncingScrollPhysics(),
                            initialItemCount: mynotifs.length,
                            itemBuilder: (context, index, animation) {
                              NotifModel notification = NotifModel(nid: "");
                              if (index >= 0 && index < mynotifs.length) {
                                int newIndex = mynotifs.length - 1 - index;
                                notification = mynotifs[newIndex];
                              }
                              return FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  key: UniqueKey(),
                                  sizeFactor: animation,
                                  child:  notification.type == 'RQMNG'
                                      ? ItemNotif(notif: notification, getEntity: widget.getEntity, remove: _remove,)
                                      : notification.type == 'PERMISSION'
                                      ? ItemPermission(notif: notification, getEntity: widget.getEntity, remove: _remove,)
                                      : SizedBox(),
                                ),
                              );
                            },
                          );
                        })
                    )
                  ],
                ),
              ),
            ),
          ),
          Text(Data().message,
            style: TextStyle(color: secondaryColor, fontSize: 11),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
