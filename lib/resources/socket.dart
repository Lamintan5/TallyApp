import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:TallyApp/resources/services.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../api/api_service.dart';
import '../api/config.dart';
import '../main.dart';
import '../models/billing.dart';
import '../models/chats.dart';
import '../models/data.dart';
import '../models/duties.dart';
import '../models/entities.dart';
import '../models/inventories.dart';
import '../models/messages.dart';
import '../models/notifications.dart';
import '../models/payments.dart';
import '../models/products.dart';
import '../models/purchases.dart';
import '../models/sales.dart';
import '../models/suppliers.dart';

class SocketManager extends GetxController  {
  late IO.Socket _socket;
  RxList<MessModel> messages = <MessModel>[].obs;
  RxList<ChatsModel> chats = <ChatsModel>[].obs;
  RxList<NotifModel> notifications = <NotifModel>[].obs;


  List<EntityModel> _entity = [];
  List<SupplierModel> _suppliers = [];
  List<SaleModel> _sales = [];
  List<DutiesModel> _duties = [];
  List<ProductModel> _products = [];
  List<PurchaseModel> _purchases = [];
  List<PaymentModel> _payments = [];
  List<InventModel> _inventory = [];
  List<NotifModel> _notifications = [];

  List<MessModel> _mess = [];
  List<MessModel> _newmess = [];
  List<ChatsModel> _chat = [];
  List<NotifModel> _newNotif = [];
  List<BillingModel> _bill = [];

  SocketManager._();

  static final SocketManager _instance = SocketManager._();

  factory SocketManager() {
    return _instance;
  }

  IO.Socket get socket => _socket;
  bool isConnected = false;

  // Connect method
  void connect() {
    setData();
    _socket = IO.io("http://tally.studio5ive.org:4000" , <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    _socket.connect();
    _socket.on("connect", (data) {
      print("Connected");
      _socket.emit("signin", currentUser.uid);
    });
    _socket.on("message", (msg) {
      print(msg);
      setMessage(
        msg['mid'],
        msg['gid'],
        msg['sourceId'],
        msg['targetId'],
        msg['message'],
        msg["path"],
        msg['time'],
        msg['type'],
      );
    });
    _socket.on("group", (gmsg) {
      print(gmsg);
      setMessage(
        gmsg['mid'],
        gmsg['gid'],
        gmsg['sourceId'],
        gmsg['targetId'].join(','),
        gmsg['message'],
        gmsg["path"],
        gmsg['time'],
        gmsg['type'],
      );
    });
    _socket.on("notif", (notif){
      print(notif);
      setNotif(
        notif['nid'],
        notif['sourceId'],
        notif['targetId'],
        notif['message'],
        notif['eid'],
        notif['pid'].join(",").toString(),
        notif['time'],
        notif['type'],
        notif['actions'],
        notif['text'],
      );
    });
    _socket.on("disconnect", (_) {
      if(currentUser.uid!=""){
        print("Disconnected. Reconnecting : ${DateTime.now().toString().substring(10, 16)}");
        Future.delayed(Duration(seconds: 1), () {
          _socket.connect();
        });
      }
    });
    _socket.on("connect_error", (err) {
      print("Connection error: $err");
    });
    print('${_socket.connected}: ${DateTime.now().toString().substring(10, 16)}');
  }
  Future<bool> getDetails()async{
    _entity = await Services().getCurrentEntity(currentUser.uid);
    _sales = await Services().getMySale(currentUser.uid);
    _newNotif = await Services().getMyNotif(currentUser.uid);
    _suppliers = await Services().getMySuppliers(currentUser.uid);
    _products = await Services().getMyPrdct(currentUser.uid);
    _purchases = await Services().getMyPurchase(currentUser.uid);
    _duties = await Services().getMyDuties(currentUser.uid);
    _payments = await Services().getMyPayments(currentUser.uid);
    _inventory = await Services().getMyInv(currentUser.uid);
    _bill = await Services().getMyBills(currentUser.uid);


    await Data().addOrUpdateNotifList(_newNotif);
    await Data().addOrUpdateEntity(_entity);
    await Data().addOrUpdateSalesList(_sales);
    await Data().addOrUpdateSuppliersList(_suppliers);
    await Data().addOrUpdateProductsList(_products);
    await Data().addOrUpdatePurchaseList(_purchases);
    await Data().addOrUpdateDutyList(_duties);
    await Data().addOrUpdateInvList(_inventory);
    await Data().addOrUpdatePayments(_payments);
    await Data().addOrUpdateBillList(_bill);

    return false;
  }
  void setData(){
    _mess = myMess.map((jsonString) => MessModel.fromJson(json.decode(jsonString))).toList();
    _chat = myChats.map((jsonString) => ChatsModel.fromJson(json.decode(jsonString))).toList();
    _notifications = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();
    messages.addAll(_mess);
    chats.addAll(_chat);
    notifications.addAll(_notifications);
  }
  void signout(){
    _socket.emit("signout", currentUser.uid);
    print("User Sign Out");
  }
  void disconnect() {
    if (_socket != null) {
      _socket.disconnect();
      print("Socket disconnected");
    }
  }
  void setMessage(String mid, String gid,String sourceId, String targetId, String message, String path,  String time, String type){
    MessModel messageModel = MessModel(
      mid: mid,
      gid: gid,
      targetId: targetId,
      sourceId: sourceId,
      message: message,
      time: time,
      path: path,
      type: type,
      deleted: "",
      seen: "",
      delivered: "",
      checked: "false",
    );
    List<String> _cidList = [sourceId,targetId];
    _cidList.sort();
    ChatsModel chatsModel= ChatsModel(cid: "");
    if(type=='individual'){
      chatsModel = ChatsModel(
        cid: _cidList.join(","),
        title: "",
        time: time,
        type: type,
      );
    } else {
      chatsModel = ChatsModel(
        cid: gid,
        title: "",
        time: time,
        type: type,
      );
    }
    messages.add(messageModel);
    if(chats.contains(chatsModel)){
      chats.firstWhere((element) => element.cid == chatsModel.cid).time = chatsModel.time;
    } else {
      chats.add(chatsModel);
    }
    Data().addOrUpdateChats(chats);
    Data().addOrUpdateMessagesList(messages);
  }
  void setNotif(String nid, String sourceId, String targetId, String message, String eid, String pid, String time, String type, String actions,String text){
    NotifModel notif =  NotifModel(
      nid: nid,
      sid: sourceId,
      rid: targetId,
      eid: eid,
      pid: pid,
      text: text,
      message: message,
      actions: actions,
      type: type,
      seen: "",
      time: time,
      deleted: "",
      checked: "true"
    );

    if(notifications.any((test) => test.nid == notif.nid)){

    } else {
      notifications.add(notif);
    }
    // if(notifications.any((element) => element.nid == notif.nid)){
    //   notifications.forEach((element) {
    //     if(element.nid == notif.nid && element.type == "MNTNRQ" && element.actions == "" && element.text!.split(",").first == notif.text!.split(",").first){
    //       element.actions = "DONE";
    //       element.time = DateTime.now().toString();
    //     } else if(element.nid == notif.nid && element.type == "MNTNRQ" && element.actions == "DONE" && element.text!.split(",").first == notif.text!.split(",").first){
    //       element.actions = actions;
    //       element.time = DateTime.now().toString();
    //     }
    //   });
    // } else {
    //   notifications.add(notif);
    // }
    Data().addOrUpdateNotifList(notifications);
  }
  Future<void> initPlatform()async{
    if(Platform.isAndroid || Platform.isIOS){
      await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.Debug.setAlertLevel(OSLogLevel.none);
      OneSignal.initialize("41db0b95-b70f-44a5-a5bf-ad849c74352e");
      OneSignal.Notifications.requestPermission(true);

      await OneSignal.User.getOnesignalId().then((value){
        APIService().getUserData(value!);
      });
    }
  }
}
