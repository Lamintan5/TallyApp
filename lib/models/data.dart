import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:TallyApp/models/duties.dart';
import 'package:TallyApp/models/duties.dart';
import 'package:TallyApp/models/duties.dart';
import 'package:TallyApp/models/duties.dart';
import 'package:TallyApp/models/duty.dart';
import 'package:TallyApp/models/inventories.dart';
import 'package:TallyApp/models/notifications.dart';
import 'package:TallyApp/models/payments.dart';
import 'package:TallyApp/models/products.dart';
import 'package:TallyApp/models/purchases.dart';
import 'package:TallyApp/models/sales.dart';
import 'package:TallyApp/models/suppliers.dart';
import 'package:TallyApp/models/users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../resources/services.dart';
import '../resources/socket.dart';
import 'billing.dart';
import 'chats.dart';
import 'entities.dart';
import 'messages.dart';

class Data{
  String message = 'Copyright © 2015-2024 Studio5ive Inc. All Rights Reserved. Accessibility, User Agreement, Privacy, Payments, Terms of Use, Cookies, Your Privacy Choices and AdChoice';
  String failed = "mhmm🤔 seems like something went wrong. Please try again";
  String noPhone = "Phone number not available";
  final socketManager = Get.find<SocketManager>();
  List<DutyModel> dutyList = [
    DutyModel(text: 'Inventory', message: 'Allow manager to add, remove and change quantity of inventory data', icon: LineIcon.boxes()),
    DutyModel(text: 'Product', message: 'Allow manager to add, remove and edit product data', icon: LineIcon.box()),
    DutyModel(text: 'Supplier', message: 'Allow manager to add, remove and edit supplier data', icon: LineIcon.users()),
    DutyModel(text: 'Sale', message: 'Allow manager to remove or edit sale data', icon: Icon(CupertinoIcons.money_dollar)),
    DutyModel(text: 'Receivable', message: 'Allow manager to record receivables', icon: LineIcon.handHoldingUsDollar()),
    DutyModel(text: 'Purchase', message: 'Allow manager to add, remove and edit purchases data', icon: LineIcon.luggageCart()),
    DutyModel(text: 'Payable', message: 'Allow manager record payables', icon: Icon(CupertinoIcons.money_dollar_circle)),
  ];
  List<String> dutiesList = ["INVENTORY","PRODUCT","SUPPLIER","SALE","RECEIVABLE","PURCHASE","PAYABLE"];

  Future<void> addOrUpdateEntity(List<EntityModel> newEntities) async {
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    // entities.removeWhere((ent) => ent.checked == "true" && !newEntities.any((newEnt) => newEnt.eid == ent.eid));
    for (var newEntity in newEntities) {
      // Check if a user with the same uid exists in _user
      int existingEntityIndex = _entity.indexWhere((user) => user.eid == newEntity.eid);
      if (existingEntityIndex != -1) {
        // User with the same uid exists, compare other attributes
        EntityModel existingEntity = _entity[existingEntityIndex];
        if (existingEntity.toJson().toString() != newEntity.toJson().toString()) {
          // If any attribute is different, update the existing user with the new data
          _entity[existingEntityIndex] = newEntity;
        }
      } else {
        // User with the same uid doesn't exist, add the new user
        _entity.add(newEntity);
      }
    }
    // Mark Entity as DELETED if they are not in newDataList
    if(newEntities.length != 0 || newEntities.isNotEmpty){
      for (var existingEntity in _entity) {
        bool existsInNewDataList = newEntities.any((newEntity) => newEntity.eid == existingEntity.eid);
        if (!existsInNewDataList && existingEntity.checked.toString().contains("true")) {
          existingEntity.checked = "REMOVED";
        }
      }
    }
    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
  }
  Future<void> addOrUpdateNotMyEntity(List<EntityModel> newEntities) async {
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = notMyEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    // entities.removeWhere((ent) => ent.checked == "true" && !newEntities.any((newEnt) => newEnt.eid == ent.eid));
    for (var newEntity in newEntities) {
      // Check if a user with the same uid exists in _user
      int existingEntityIndex = _entity.indexWhere((user) => user.eid == newEntity.eid);
      if (existingEntityIndex != -1) {
        // User with the same uid exists, compare other attributes
        EntityModel existingEntity = _entity[existingEntityIndex];
        if (existingEntity.toJson().toString() != newEntity.toJson().toString()) {
          // If any attribute is different, update the existing user with the new data
          _entity[existingEntityIndex] = newEntity;
        }
      } else {
        // User with the same uid doesn't exist, add the new user
        _entity.add(newEntity);
      }
    }
    // Mark Entity as DELETED if they are not in newDataList
    if(newEntities.length != 0 || newEntities.isNotEmpty){
      for (var existingEntity in _entity) {
        bool existsInNewDataList = newEntities.any((newEntity) => newEntity.eid == existingEntity.eid);
        if (!existsInNewDataList && existingEntity.checked.toString().contains("true")) {
          existingEntity.checked = "REMOVED";
        }
      }
    }
    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('notMyEntity', uniqueEntities);
    notMyEntity = uniqueEntities;
  }
  Future<void> addOrUpdateUserList(List<UserModel> newDataList)async{
    List<String> uniqueUsers= [];
    List<UserModel> _user = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    for (var newUser in newDataList) {
      // Check if a user with the same uid exists in _user
      int existingUserIndex = _user.indexWhere((user) => user.uid == newUser.uid);
      if (existingUserIndex != -1) {
        // User with the same uid exists, compare other attributes
        UserModel existingUser = _user[existingUserIndex];
        if (existingUser.toJsonAdd().toString() != newUser.toJsonAdd().toString()) {
          // If any attribute is different, update the existing user with the new data
          _user[existingUserIndex] = newUser;

        }
      } else {
        // User with the same uid doesn't exist, add the new user
        _user.add(newUser);
      }
    }

    uniqueUsers = _user.map((model) => jsonEncode(model.toJsonAdd())).toList();
    sharedPreferences.setStringList('myusers', uniqueUsers);
    myUsers = uniqueUsers;
  }
  Future<bool> addOrUpdateSuppliersList(List<SupplierModel> newDataList)async{
    List<String> uniqueSuppliers= [];
    List<SupplierModel> _supplier = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _supplier = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    for (var newSupplier in newDataList) {
      int existingSupplierIndex = _supplier.indexWhere((supp) => supp.sid == newSupplier.sid);
      if (existingSupplierIndex != -1) {
        SupplierModel existingSupplier = _supplier[existingSupplierIndex];
        if (existingSupplier.toJson().toString() != newSupplier.toJson().toString()) {
          _supplier[existingSupplierIndex] = newSupplier;
        }
      } else {
        _supplier.add(newSupplier);
      }
    }
    // Mark suppliers as DELETED if they are not in newDataList
    if(newDataList.length != 0 || newDataList.isNotEmpty){
      for (var existingSupplier in _supplier) {
        bool existsInNewDataList = newDataList.any((newSupplier) => newSupplier.sid == existingSupplier.sid);
        if (!existsInNewDataList && existingSupplier.checked.toString().contains("true")) {
          existingSupplier.checked = "REMOVED";
        }
      }
    }
    uniqueSuppliers = _supplier.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mysuppliers', uniqueSuppliers);
    mySuppliers = uniqueSuppliers;
    return false;
  }
  Future<bool> addOrUpdateSalesList(List<SaleModel> newDataList)async{
    List<String> uniqueSales= [];
    List<SaleModel> _sale = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    for (var newSales in newDataList) {
      // Check if a user with the same uid exists in _user
      int existingSaleIndex = _sale.indexWhere((sale) => sale.saleid == newSales.saleid && sale.productid == newSales.productid);
      if (existingSaleIndex != -1) {
        // User with the same uid exists, compare other attributes
        SaleModel existingSale = _sale[existingSaleIndex];
        if (existingSale.toJson().toString() != newSales.toJson().toString()) {
          // If any attribute is different, update the existing user with the new data
          _sale[existingSaleIndex] = newSales;
        }
      } else {
        // User with the same uid doesn't exist, add the new user
        _sale.add(newSales);
      }
    }
    for (var existingSale in _sale) {
      bool existsInNewDataList = newDataList.any((newSale) => newSale.sid == existingSale.sid);
      if (!existsInNewDataList && existingSale.checked.toString().contains("true")) {
        existingSale.checked = "REMOVED";
      }
    }
    uniqueSales = _sale.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mysales', uniqueSales);
    mySales = uniqueSales;
    return false;
  }
  Future<void> addOrUpdateProductsList(List<ProductModel> newDataList)async{
    List<String> uniqueProducts = [];
    List<ProductModel> _products = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _products = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    for (var newProduct in newDataList) {
      // Check if a user with the same prid exists in _prodyct
      int existingProductIndex = _products.indexWhere((product) => product.prid == newProduct.prid);
      if (existingProductIndex != -1) {
        // User with the same uid exists, compare other attributes
        ProductModel existingProduct = _products[existingProductIndex];
        if (existingProduct.toJson().toString() != newProduct.toJson().toString()) {
          // If any attribute is different, update the existing prodyct with the new data
          _products[existingProductIndex] = newProduct;
        }
      } else {
        // User with the same uid doesn't exist, add the new prodyct
        _products.add(newProduct);
      }
    }
    for (var existingProduct in _products) {
      bool existsInNewDataList = newDataList.any((newProduct) => newProduct.prid == existingProduct.prid);
      if (!existsInNewDataList && existingProduct.checked.toString().contains("true")) {
        existingProduct.checked = "REMOVED";
      }
    }

    uniqueProducts  = _products.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myproducts', uniqueProducts );
    myProducts = uniqueProducts;
  }
  Future<bool> addOrUpdatePurchaseList(List<PurchaseModel> newDataList)async{
    List<String> uniquePurchase = [];
    List<PurchaseModel> _purchase = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchase = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    for (var newPurchase in newDataList) {
      int existingPurchaseIndex = _purchase.indexWhere((purchase) => purchase.prcid == newPurchase.prcid);
      if (existingPurchaseIndex != -1) {
        PurchaseModel existingPurchase = _purchase[existingPurchaseIndex];
        if (existingPurchase.toJson().toString() != newPurchase.toJson().toString()) {
          _purchase[existingPurchaseIndex] = newPurchase;
        }
      } else {
        _purchase.add(newPurchase);
      }
    }
    for (var existingPurchase in _purchase) {
      bool existsInNewDataList = newDataList.any((newPurchase) => newPurchase.prcid == existingPurchase.prcid);
      if (!existsInNewDataList && existingPurchase.checked.toString().contains("true")) {
        if(existingPurchase.checked == "true" ){
          existingPurchase.checked = "REMOVED";
        }
      }
    }
    uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypurchases', uniquePurchase );
    myPurchases = uniquePurchase;
    return false;
  }
  Future<bool> addOrUpdateInvList(List<InventModel> newDataList)async{
    List<String> uniqueInventory = [];
    List<InventModel> _inventory = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    for (var newInv in newDataList) {
      int existingInvIndex = _inventory.indexWhere((inv) => inv.iid == newInv.iid);
      if (existingInvIndex != -1) {
        InventModel existingInv = _inventory[existingInvIndex];
        if (existingInv.toJson().toString() != newInv.toJson().toString()) {
          _inventory[existingInvIndex] = newInv;
        }
      } else {
        _inventory.add(newInv);
      }
    }
    // Mark suppliers as DELETED if they are not in newDataList
    for (var existingInventory in _inventory) {
      bool existsInNewDataList = newDataList.any((newInventory) => newInventory.iid == existingInventory.iid);
      if (!existsInNewDataList && existingInventory.checked.toString().contains("true")) {
        existingInventory.checked = "REMOVED";
      }
    }
    uniqueInventory  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myinventory', uniqueInventory );
    myInventory = uniqueInventory;
    return false;
  }
  Future<void> addOrUpdatePayments(List<PaymentModel> newDataList)async{
    List<String> uniquePayments = [];
    List<PaymentModel> _payments = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _payments = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();
    for (var newPay in newDataList) {
      // Check if a user with the same prid exists in _prodyct
      int existingPayIndex = _payments.indexWhere((pay) => pay.payid == newPay.payid);
      if (existingPayIndex != -1) {
        // User with the same uid exists, compare other attributes
        PaymentModel existingPay = _payments[existingPayIndex];
        if (existingPay.toJson().toString() != newPay.toJson().toString()) {
          // If any attribute is different, update the existing prodyct with the new data
          _payments[existingPayIndex] = newPay;
        }
      } else {
        // User with the same uid doesn't exist, add the new prodyct
        _payments.add(newPay);
      }
    }
    for (var existingPayment in _payments) {
      bool existsInNewDataList = newDataList.any((newPayment) => newPayment.payid == existingPayment.payid);
      if (!existsInNewDataList && existingPayment.checked.toString().contains("true")) {
        existingPayment.checked = "REMOVED";
      }
    }
    uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypayments', uniquePayments );
    myPayments = uniquePayments;
  }
  Future<bool> addOrUpdateDutyList(List<DutiesModel> newDataList)async{
    List<String> uniqueDuties= [];
    List<DutiesModel> _duty = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _duty = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    for (var newDuty in newDataList) {
      int existingDutyIndex = _duty.indexWhere((dty) => dty.did == newDuty.did);
      if (existingDutyIndex != -1) {
        DutiesModel existingDuty = _duty[existingDutyIndex];
        if (existingDuty.toJson().toString() != newDuty.toJson().toString()) {
          _duty[existingDutyIndex] = newDuty;
        }
      } else {
        _duty.add(newDuty);
      }
    }
    if(newDataList.length != 0 || newDataList.isNotEmpty){
      for (var existingDuty in _duty) {
        bool existsInNewDataList = newDataList.any((dty) => dty.did == existingDuty.did);
        if (!existsInNewDataList && existingDuty.checked.toString().contains("true")) {
          existingDuty.checked = "REMOVED";
        }
      }
    }
    uniqueDuties = _duty.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myduties', uniqueDuties);
    myDuties = uniqueDuties;
    return false;
  }
  Future<void> addOrRemoveShowCase(String showcase, String action)async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(action=="add"){
      if(!myShowCases.contains(showcase)){
        myShowCases.add(showcase);
        print("Adding $showcase");
      }
    } else {
      myShowCases.remove(showcase);
      print("Removing $showcase");
    }
    sharedPreferences.setStringList('myshowcase', myShowCases);
  }
  Future<void> addOrUpdateBillList(List<BillingModel> newDataList) async {
    List<BillingModel> _bills = [];
    List<String> uniqueBills = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _bills = myBills.map((jsonString) => BillingModel.fromJson(json.decode(jsonString))).toList();
    // entities.removeWhere((ent) => ent.checked == "true" && !newDataList.any((newEnt) => newEnt.eid == ent.eid));
    for (var newBill in newDataList) {
      // Check if a user with the same uid exists in _user
      int existingBillIndex = _bills.indexWhere((bill) => bill.bid == newBill.bid);
      if (existingBillIndex != -1) {
        // User with the same uid exists, compare other attributes
        BillingModel existingBill = _bills[existingBillIndex];
        if (existingBill.toJson().toString() != newBill.toJson().toString()) {
          // If any attribute is different, update the existing user with the new data
          _bills[existingBillIndex] = newBill;
        }
      } else {
        // User with the same uid doesn't exist, add the new user
        _bills.add(newBill);
      }
    }
    // Mark Entity as DELETED if they are not in newDataList
    for (var existingBill in _bills) {
      bool existsInNewDataList = newDataList.any((newBill) => newBill.bid == existingBill.bid);
      if (!existsInNewDataList && existingBill.checked.toString().contains("true")) {
        existingBill.checked = "REMOVED";
      }
    }

    uniqueBills = _bills.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mybills', uniqueBills);
    myBills = uniqueBills;
  }

  Future<void> addOrUpdateMessagesList(List<MessModel> newDataList)async{
    List<String> uniqueMessages= [];
    List<MessModel> _messages = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _messages = myMess.map((jsonString) => MessModel.fromJson(json.decode(jsonString))).toList();
    for (var newMessages in newDataList) {
      int existingMessIndex = _messages.indexWhere((mess) => mess.mid == newMessages.mid);
      if (existingMessIndex != -1) {
        MessModel existingMess = _messages[existingMessIndex];
        if (existingMess.toJson().toString() != newMessages.toJson().toString()) {
          _messages[existingMessIndex] = newMessages;
        }
      } else {
        _messages.add(newMessages);
      }
    }
    for (var existingMessages in _messages) {
      bool existsInNewDataList = newDataList.any((newMess) => newMess.mid == existingMessages.mid);
      if (!existsInNewDataList && existingMessages.checked.toString().contains("true")) {
        existingMessages.checked = "REMOVED";
      }
    }
    uniqueMessages = _messages.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mymess', uniqueMessages);
    myMess = uniqueMessages;
  }
  Future<void> addOrUpdateChats(List<ChatsModel> newChats) async {
    List<String> uniqueChats = [];
    List<ChatsModel> _chat = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _chat = myChats.map((jsonString) => ChatsModel.fromJson(json.decode(jsonString))).toList();
    for (var newChat in newChats) {
      // Check if a chat with the same cid exists in _chat
      int existingChatIndex = _chat.indexWhere((chat) => chat.cid == newChat.cid);
      if (existingChatIndex != -1) {
        // Chat with the same cid exists, update only specific attributes
        ChatsModel existingChat = _chat[existingChatIndex];
        if(existingChat.title == "" || existingChat.title == null){
          existingChat.title = newChat.title;
        } else {
        }
        if(newChat.time != "new"){
          existingChat.time = newChat.time;
        }
      } else {
        // Chat with the same cid doesn't exist, add the new chat
        _chat.add(newChat);
      }
    }
    uniqueChats = _chat.map((model) => jsonEncode(model.toJsonAdd())).toList();
    sharedPreferences.setStringList('mychats', uniqueChats);
    myChats = uniqueChats;
  }
  Future<void> addOrUpdateNotifList(List<NotifModel> newDataList)async{
    List<String> uniqueNotif= [];
    List<NotifModel> _notifs = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _notifs = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();
    for (var newNotif in newDataList) {
      int existingNotifIndex = _notifs.indexWhere((notif) => notif.nid == newNotif.nid);
      if (existingNotifIndex != -1) {
        NotifModel existingNotif = _notifs[existingNotifIndex];
        if (existingNotif.toJson().toString() != newNotif.toJson().toString()) {
          _notifs[existingNotifIndex] = newNotif;
        }
      } else {
        _notifs.add(newNotif);
      }
    }
    for (var existingNotif in _notifs) {
      bool existsInNewDataList = newDataList.any((newNotif) => newNotif.nid == existingNotif.nid);
      if (!existsInNewDataList && existingNotif.checked.toString().contains("true")) {
        existingNotif.checked = "REMOVED";
      }
    }
    uniqueNotif = _notifs.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mynotif', uniqueNotif);
    myNotif = uniqueNotif;
  }

  Future<void> addNotification(NotifModel notif) async {
    List<NotifModel> _notification = [];
    List<String> uniqueNotif = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _notification = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();

    bool exists = false;
    for (int i = 0; i < _notification.length; i++) {
      if (_notification[i].nid == notif.nid) {
        _notification[i] = notif;
        exists = true;
        break;
      }
    }
    if (!exists) {
      _notification.add(notif);
    }

    uniqueNotif = _notification.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mynotif', uniqueNotif);
    myNotif = uniqueNotif;
  }
  Future<void> addBill(BillingModel bill) async {
    List<BillingModel> _bills = [];
    List<String> uniqueBills = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _bills = myBills.map((jsonString) => BillingModel.fromJson(json.decode(jsonString))).toList();

    bool exists = false;
    for (int i = 0; i < _bills.length; i++) {
      if (_bills[i].bid == bill.bid) {
        _bills[i] = bill;
        exists = true;
        break;
      }
    }
    if (!exists) {
      _bills.add(bill);
    }

    uniqueBills = _bills.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mybills', uniqueBills);
    myBills = uniqueBills;
  }

  Future<void> removePurchaseList(List<PurchaseModel> newDataList, double amount)async{
    List<String> uniquePurchase = [];
    List<String> uniqueInv = [];
    List<PurchaseModel> _purchase = [];
    List<InventModel> _inventory = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchase = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();

    newDataList.forEach((element) {
      if(_purchase.contains(element)){
        _purchase.remove(element);
        var invModel = _inventory.firstWhere((inv) => inv.productid == element.productid);
        _inventory.firstWhere((inv) => inv.productid == element.productid).quantity =  (int.parse(invModel.quantity!) - int.parse(element.quantity!)).toString();
      }
    });
    _purchase.where((prch) => prch.purchaseid == newDataList.first.purchaseid).forEach((element) {
      element.amount = amount.toString();
    });
    uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
    uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypurchases', uniquePurchase );
    sharedPreferences.setStringList('myinventory', uniqueInv);
    myPurchases = uniquePurchase;
    myInventory = uniqueInv;
  }
  Future<void> removeSaleList(List<SaleModel> newDataList, double amount)async{
    List<String> uniqueSale = [];
    List<String> uniqueInv = [];
    List<SaleModel> _sales = [];
    List<InventModel> _inventory = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _sales = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();

    newDataList.forEach((element) {
      if(_sales.contains(element)){
        _sales.remove(element);
        var invModel = _inventory.firstWhere((inv) => inv.productid == element.productid);
        _inventory.firstWhere((inv) => inv.productid == element.productid).quantity =  (int.parse(invModel.quantity!) + int.parse(element.quantity!)).toString();
      }
    });
    _sales.where((sale) => sale.saleid == newDataList.first.saleid).forEach((element) {
      element.amount = amount.toString();
    });
    uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
    uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mysales', uniqueSale);
    sharedPreferences.setStringList('myinventory', uniqueInv);
    mySales = uniqueSale;
    myInventory = uniqueInv;
  }
  Future<bool> removeSupplier(SupplierModel supplier, Function reload, BuildContext context)async{
    List<String> uniqueSupplier = [];
    List<SupplierModel> _suppliers = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _suppliers = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    SupplierModel supplierModel = _suppliers.firstWhere((element) => element.sid == supplier.sid);
    _suppliers.firstWhere((element) => element.sid == supplier.sid).checked = supplierModel.checked.toString().contains("DELETE")
        ?supplierModel.checked
        :"${supplierModel}, DELETE";

    uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
    mySuppliers = uniqueSupplier;
    reload();

    if(supplier.checked.toString().contains("false")){
      _suppliers.removeWhere((element) => element.sid == supplier.sid);
      uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
      mySuppliers = uniqueSupplier;
      reload();
    }
    else if(supplier.checked.toString().contains("true")){
      await Services.deleteSupplier(supplier.sid).then((response)async{
        if(response=="success" || response=="Does not exist") {
          _suppliers.removeWhere((element) => element.sid == supplier.sid);
          uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
          sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
          mySuppliers = uniqueSupplier;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Supplier ${supplier.name} removed from Supplier list"),
                showCloseIcon: true,
              )
          );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Supplier ${supplier.name} removed from supplier list. Awaiting internet connection."),
                showCloseIcon: true,
              )
          );
        }
        reload();
      });
    }
    else if(supplier.checked.toString().contains("REMOVE")) {
      _suppliers.removeWhere((element) => element.sid == supplier.sid);
      uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
      mySuppliers = uniqueSupplier;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Supplier ${supplier.name} removed from Server supplier list."),
            showCloseIcon: true,
          )
      );
      reload();
    }
    else {
      uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
      mySuppliers = uniqueSupplier;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Supplier ${supplier.name} removed from Server supplier list."),
            showCloseIcon: true,
          )
      );
      reload();
    }
    return false;
  }
  Future<bool> removePurchases(String purchaseid, Function reload, BuildContext context)async{
    List<String> uniquePurchase = [];
    List<String> uniqueInv = [];
    List<String> uniquePayment = [];
    List<PurchaseModel> _purchase = [];
    List<InventModel> _inventory = [];
    List<PaymentModel> _payment = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchase = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _payment = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();

    List<PurchaseModel> purchasesToRemove = [];
    List<PurchaseModel> purchasesRemoved = [];

    for (var purchase in _purchase.where((element) => element.purchaseid == purchaseid)) {
      int quantity = int.parse(purchase.quantity.toString());
      int invQuantity = int.parse(_inventory.firstWhere((element) => element.productid == purchase.productid).quantity.toString());
      int newQuantity = invQuantity - quantity;

      if(purchase.checked.toString().contains("false")){
        purchasesRemoved.add(purchase);
      } else if (!purchase.checked.toString().contains("DELETE")){
        PurchaseModel purchaseModel = _purchase.firstWhere((element) => element.prcid == purchase.prcid);
        _purchase.firstWhere((element) => element.prcid == purchase.prcid).checked = purchaseModel.checked.toString().contains("DELETE")
            ? purchaseModel.checked
            : "${purchase.checked}, DELETE";
        _inventory.firstWhere((test) => test.productid == purchase.productid).quantity = newQuantity < 0 ? "0" : newQuantity.toString();
      }

      uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
      uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList('mypurchases', uniquePurchase);
      sharedPreferences.setStringList('myinventory', uniqueInv);
      myPurchases = uniquePurchase;
      myInventory = uniqueInv;
      reload();
    }

    for(var purchase in purchasesRemoved){
      int quantity = int.parse(purchase.quantity.toString());
      int invQuantity = int.parse(_inventory.firstWhere((element) => element.productid == purchase.productid).quantity.toString());
      int newQuantity = invQuantity - quantity;

      _purchase.removeWhere((element) => element.prcid == purchase.prcid);
      _inventory.firstWhere((test) => test.productid == purchase.productid).quantity = newQuantity < 0 ? "0" : newQuantity.toString();

      uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
      uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList('mypurchases', uniquePurchase);
      sharedPreferences.setStringList('myinventory', uniqueInv);
      myPurchases = uniquePurchase;
      myInventory = uniqueInv;
      reload();
    }

    _payment.where((element) => element.purchaseid == purchaseid).forEach((pay){
      pay.checked.toString().contains("DELETE") ? pay.checked
          : "${pay.checked}, DELETE";
    });
    uniquePayment  = _payment.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypayments', uniquePayment );
    myPayments = uniquePayment;

    await Services.deletePrchByPrchId(purchaseid).then((response)async{
      if(response=="success"){
        purchasesToRemove.addAll(_purchase.where((test) => test.purchaseid == purchaseid));
      } else if(response=="Does not exist"){
        _purchase.removeWhere((element) => element.purchaseid == purchaseid);
      }
    });
    await Services.deletePayByPurchaseId(purchaseid).then((response){
      print(response);
      if(response=="success"){
        _payment.removeWhere((element) => element.purchaseid == purchaseid);
        uniquePayment  = _payment.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mypayments', uniquePayment );
        myPayments = uniquePayment;
      }
    });

    for (var purchase in purchasesToRemove) {
      await Services.updateInvSubQnty(purchase.productid.toString(), purchase.quantity.toString());
      _purchase.removeWhere((element) => element.prcid == purchase.prcid);
    }

    uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypurchases', uniquePurchase);
    myPurchases = uniquePurchase;
    reload();
    return false;
  }
  Future<bool> removeProduct(ProductModel product, Function reload, BuildContext context)async{
    List<String> uniqueProduct = [];
    List<ProductModel> _product = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _product = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();

    ProductModel prdtModel = _product.firstWhere((element) => element.prid == product.prid);

    _product.firstWhere((element) => element.prid == product.prid).checked = product.checked.toString().contains("DELETE")
        ? prdtModel.checked.toString()
        : "${prdtModel.checked.toString()}, DELETE";

    uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("myproducts", uniqueProduct);
    myProducts = uniqueProduct;
    reload();

    if(product.checked.toString().contains("true")){
      await Services.deleteProduct(product.prid).then((response){
        if(response=="success" || response=="Does not exist"){
          _product.removeWhere((element) => element.prid == product.prid);
          uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
          sharedPreferences.setStringList("myproducts", uniqueProduct);
          myProducts = uniqueProduct;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Product ${product.name} removed from Products list"),
                showCloseIcon: true,
              )
          );
        }  else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Product ${product.name} removed from Products list. Awaiting internet connection."),
                showCloseIcon: true,
              )
          );
        }
        reload();
      });
    }
    else if(product.checked.toString().contains("REMOVE")){
      _product.removeWhere((element) => element.prid == product.prid);
      uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList("myproducts", uniqueProduct);
      myProducts = uniqueProduct;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Product ${product.name} removed from Products list"),
            showCloseIcon: true,
          )
      );
      reload();
    }
    return false;
  }
  Future<bool> removeInventory(InventModel inventory, Function reload, BuildContext context)async{
    List<String> uniqueInventory = [];
    List<InventModel> _inventroy = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _inventroy = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();

    InventModel inventoryModel = _inventroy.firstWhere((test) => test.iid == inventory.iid);

    _inventroy.firstWhere((test) => test.iid == inventory.iid).checked = inventoryModel.checked.toString().contains("DELETE")
        ? inventoryModel.checked
        : "${inventoryModel.checked}, DELETE";

    uniqueInventory = _inventroy.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("myinventory", uniqueInventory);
    myInventory = uniqueInventory;
    reload();



    if(inventory.checked.toString().contains("true")){
      await Services.deleteInventory(inventory.iid).then((response){
        if(response=="success" || response=="Does not exist"){
          _inventroy.removeWhere((element) => element.iid == inventory.iid);
          uniqueInventory = _inventroy.map((model) => jsonEncode(model.toJson())).toList();
          sharedPreferences.setStringList("myinventory", uniqueInventory);
          myInventory = uniqueInventory;
          reload();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Inventory removed from Inventory list."),
                  showCloseIcon: true,
              )
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Inventory removed from Inventory list. Awaiting internet connection."),
                  showCloseIcon: true,
              )
          );
        }
      });
    }
    else if(inventory.checked.toString().contains("REMOVE")){
      _inventroy.removeWhere((element) => element.iid == inventory.iid);
      uniqueInventory = _inventroy.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList("myinventory", uniqueInventory);
      myInventory = uniqueInventory;
      reload();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Inventory removed from Inventory list."),
            showCloseIcon: true,
          )
      );
    }
    reload();
    return false;
  }
  Future<bool> removeEntity(EntityModel entity, Function reload, BuildContext context)async{
    List<EntityModel> _entity = [];
    List<SupplierModel> _suppliers = [];
    List<ProductModel> _product = [];
    List<PurchaseModel> _purchase = [];
    List<InventModel> _inventory = [];
    List<SaleModel> _sales = [];
    List<String> uniqueDuties= [];
    List<String> uniquePayments = [];

    List<String> uniqueEntities = [];
    List<String> uniqueSupplier = [];
    List<String> uniqueProduct = [];
    List<String> uniquePurchase = [];
    List<String> uniqueInv = [];
    List<String> uniqueSale = [];
    List<DutiesModel> _duty = [];
    List<PaymentModel> _payments = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _product = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _suppliers = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _purchase = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _sales = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _duty = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    _payments = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();

    EntityModel initial = _entity.firstWhere((element) =>element.eid == entity.eid);

    if(entity.checked.toString().contains("true")){
      _entity.firstWhere((element) => element.eid == entity.eid).checked = initial.checked.toString().contains("DELETE")
          ? initial.checked
          : "${initial.checked}, DELETE";
    } else {
      _entity.removeWhere((element) => element.eid == entity.eid);
    }
    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    reload();

    await Services.deleteEntity(entity.eid).then((response)async{
      if(response=="success"||response=="Does not exist"){
        await Services.deletePrdctByEid(entity.eid);
        await Services.deleteSpplrByEid(entity.eid);
        await Services.deletePrchByEid(entity.eid);
        await Services.deleteInvByEid(entity.eid);
        await Services.deleteSaleByEid(entity.eid);
        await Services.deleteDutityByEid(entity.eid);
        await Services.deleteNotifByEid(entity.eid);
        await Services.deletePayByEid(entity.eid);

        _entity.removeWhere((element) => element.eid == entity.eid);
        _product.removeWhere((element) => element.eid == entity.eid);
        _suppliers.removeWhere((element) => element.eid == entity.eid);
        _purchase.removeWhere((element) => element.eid == entity.eid);
        _inventory.removeWhere((element) => element.eid == entity.eid);
        _sales.removeWhere((element) => element.eid == entity.eid);
        _duty.removeWhere((element) => element.eid == entity.eid);
        _payments.removeWhere((element) => element.eid == entity.eid);

        uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
        uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
        uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
        uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
        uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
        uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
        uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
        uniqueDuties = _duty.map((model) => jsonEncode(model.toJson())).toList();

        sharedPreferences.setStringList('myentity', uniqueEntities);
        sharedPreferences.setStringList("myproducts", uniqueProduct);
        sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
        sharedPreferences.setStringList('mypurchases', uniquePurchase);
        sharedPreferences.setStringList('myinventory', uniqueInv);
        sharedPreferences.setStringList('mysales', uniqueSale);
        sharedPreferences.setStringList('myduties', uniqueDuties);
        sharedPreferences.setStringList('mypayments', uniquePayments);

        myEntity = uniqueEntities;
        myProducts = uniqueProduct;
        mySuppliers = uniqueSupplier;
        myPurchases = uniquePurchase;
        myInventory = uniqueInv;
        mySales = uniqueSale;
        myDuties = uniqueDuties;
        myPayments = uniquePayments;
        reload();
        Get.snackbar(
            "Success",
            "Entity was removed from Entity list successfully",
            icon: Icon(CupertinoIcons.check_mark, color: Colors.green,),
            shouldIconPulse: true,
            maxWidth: 500,
        );

      } else {
        Get.snackbar(
          "Success",
          "Entity was removed from Entity list. Awaiting internet connection.",
          icon: Icon(CupertinoIcons.check_mark, color: Colors.green,),
          shouldIconPulse: true,
          maxWidth: 500,
        );
      }
    });
    return false;
  }
  Future<bool> removeSales(String saleid, Function reload, BuildContext context)async{
    List<String> uniqueSale = [];
    List<String> uniqueInv = [];
    List<String> uniquePayment = [];
    List<SaleModel> _sales = [];
    List<InventModel> _inventory = [];
    List<PaymentModel> _payment = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _sales = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _payment = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();

    List<SaleModel> salesToRemove = [];
    List<SaleModel> salesRemoved = [];

    for (var sale in _sales.where((element) => element.saleid == saleid)) {
      int quantity = int.parse(sale.quantity.toString());
      int invQuantity = int.parse(_inventory.firstWhere((element) => element.productid == sale.productid).quantity.toString());
      int newQuantity = invQuantity + quantity;

      if(sale.checked.toString().contains("false")){
        salesRemoved.add(sale);
      } else if (!sale.checked.toString().contains("DELETE")){
        SaleModel saleModel = _sales.firstWhere((element) => element.sid == sale.sid);
        _sales.firstWhere((element) => element.sid == sale.sid).checked = saleModel.checked.toString().contains("DELETE")
            ? saleModel.checked
            : "${sale.checked}, DELETE";
        _inventory.firstWhere((test) => test.productid == sale.productid).quantity = newQuantity.toString();
      }
      uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
      uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList('mysales', uniqueSale);
      sharedPreferences.setStringList('myinventory', uniqueInv);
      mySales = uniqueSale;
      myInventory = uniqueInv;
      reload();
    }

    for (var sale in salesRemoved){
      int quantity = int.parse(sale.quantity.toString());
      int invQuantity = int.parse(_inventory.firstWhere((element) => element.productid == sale.productid).quantity.toString());
      int newQuantity = invQuantity + quantity;

      _sales.removeWhere((element) => element.sid == sale.sid);
      _inventory.firstWhere((test) => test.productid == sale.productid).quantity = newQuantity < 0 ? "0" : newQuantity.toString();

      uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
      uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList('mysales', uniqueSale);
      sharedPreferences.setStringList('myinventory', uniqueInv);
      mySales = uniqueSale;
      myInventory = uniqueInv;
      reload();
    }

    _payment.where((element) => element.saleid == saleid).forEach((pay){
      pay.checked.toString().contains("DELETE") ? pay.checked
          : "${pay.checked}, DELETE";
    });
    uniquePayment  = _payment.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypayments', uniquePayment );
    myPayments = uniquePayment;

    await Services.deleteSaleBySaleId(saleid).then((response)async{
      if(response=="success"){
        salesToRemove.addAll(_sales.where((test) => test.saleid == saleid));
      } else if(response=="Does not exist"){
        _sales.removeWhere((element) => element.saleid == saleid);
      }
    });

    await Services.deletePayBySaleId(saleid).then((response){
      print(response);
      if(response=="success"){
        _payment.removeWhere((element) => element.saleid == saleid);
        uniquePayment  = _payment.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mypayments', uniquePayment );
        myPayments = uniquePayment;
      }
    });

    for (var sale in salesToRemove) {
      await Services.updateInvAddQnty(sale.productid.toString(), sale.quantity.toString());
      _sales.removeWhere((element) => element.saleid == saleid);
    }

    uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mysales', uniqueSale);
    mySales = uniqueSale;
    reload();
    return false;
  }
  Future<bool> removeData(String eid, Function reload, BuildContext context)async{
    List<EntityModel> _entity = [];
    List<SupplierModel> _suppliers = [];
    List<ProductModel> _product = [];
    List<PurchaseModel> _purchase = [];
    List<InventModel> _inventory = [];
    List<SaleModel> _sales = [];
    List<String> uniqueDuties= [];
    List<String> uniquePayments = [];

    List<String> uniqueEntities = [];
    List<String> uniqueSupplier = [];
    List<String> uniqueProduct = [];
    List<String> uniquePurchase = [];
    List<String> uniqueInv = [];
    List<String> uniqueSale = [];
    List<DutiesModel> _duty = [];
    List<PaymentModel> _payments = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _product = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();
    _suppliers = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _purchase = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _sales = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _duty = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    _payments = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();

    _entity.removeWhere((element) => element.eid == eid);
    _product.removeWhere((element) => element.eid == eid);
    _suppliers.removeWhere((element) => element.eid == eid);
    _purchase.removeWhere((element) => element.eid == eid);
    _inventory.removeWhere((element) => element.eid == eid);
    _sales.removeWhere((element) => element.eid == eid);
    _duty.removeWhere((element) => element.eid == eid);
    _payments.removeWhere((element) => element.eid == eid);

    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
    uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
    uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
    uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
    uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
    uniqueDuties = _duty.map((model) => jsonEncode(model.toJson())).toList();

    sharedPreferences.setStringList('myentity', uniqueEntities);
    sharedPreferences.setStringList("myproducts", uniqueProduct);
    sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
    sharedPreferences.setStringList('mypurchases', uniquePurchase);
    sharedPreferences.setStringList('myinventory', uniqueInv);
    sharedPreferences.setStringList('mysales', uniqueSale);
    sharedPreferences.setStringList('myduties', uniqueDuties);
    sharedPreferences.setStringList('mypayments', uniquePayments);

    myEntity = uniqueEntities;
    myProducts = uniqueProduct;
    mySuppliers = uniqueSupplier;
    myPurchases = uniquePurchase;
    myInventory = uniqueInv;
    mySales = uniqueSale;
    myDuties = uniqueDuties;
    myPayments = uniquePayments;
    reload();
    return false;
  }
  Future<bool> removePayment(PaymentModel payment, Function reload, BuildContext context)async{
    List<String> uniquePayment = [];
    List<PaymentModel> _payments = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _payments = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();

    PaymentModel payModel = _payments.firstWhere((element) => element.payid == payment.payid);

    _payments.firstWhere((element) => element.payid == payment.payid).checked = payment.checked.toString().contains("DELETE")
        ? payModel.checked.toString()
        : "${payModel.checked.toString()}, DELETE";

    uniquePayment = _payments.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("mypayments", uniquePayment);
    myPayments = uniquePayment;
    reload();

    if(payment.checked.toString().contains("true")){
      await Services.deletePayment(payment.payid).then((response){
        if(response=="success" || response=="Does not exist"){
          _payments.removeWhere((element) => element.payid == payment.payid);
          uniquePayment = _payments.map((model) => jsonEncode(model.toJson())).toList();
          sharedPreferences.setStringList("mypayments", uniquePayment);
          myPayments = uniquePayment;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Payment removed from Payments list"),
                showCloseIcon: true,
              )
          );
        }  else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Payment removed from Payments list. Awaiting internet connection."),
                showCloseIcon: true,
              )
          );
        }
        reload();
      });
    }
    else if(payment.checked.toString().contains("REMOVE")){
      _payments.removeWhere((element) => element.payid == payment.payid);
      uniquePayment = _payments.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList("mypayments", uniquePayment);
      myPayments = uniquePayment;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment removed from Payments list"),
            showCloseIcon: true,
          )
      );
      reload();
    }
    return false;
  }

  Future<bool> deleteNotif(BuildContext context, NotifModel notif, Function remove) async {
    List<NotifModel> _notification = [];
    List<String> uniqueNotif = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _notification = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();

    List<String> del = notif.deleted.toString().isEmpty ? [] : notif.deleted.toString().split(",");
    if (notif.deleted.toString().isEmpty) {
      del.add(currentUser.uid);
    }

    NotifModel targetNotif = _notification.firstWhere((test) => test.nid == notif.nid);
    targetNotif.deleted = notif.deleted.toString().contains(currentUser.uid) ? notif.deleted : del.join(",");
    targetNotif.checked = notif.checked.toString().contains("DELETE") ? notif.checked : "${notif.checked},DELETE";

    socketManager.notifications.removeWhere((test) => test.nid == notif.nid);
    uniqueNotif = _notification.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mynotif', uniqueNotif);
    myNotif = uniqueNotif;

    remove(notif);


    await Services.updateNotifDel(notif.nid).then((response) {

      if (response == "success" || response == "Does not exist") {
        _notification.removeWhere((test) => test.nid == notif.nid);
        uniqueNotif = _notification.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mynotif', uniqueNotif);
        myNotif = uniqueNotif;


        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Notification removed"),
              width: 500,
              showCloseIcon: true,
            ),
          );
        }
      }
    });

    return false;
  }

  Future<void> editPurchaseList(String prcid, String productid, String purchaseid, String quantity, String initialQantity, String check)async{
    List<String> uniquePurchase = [];
    List<String> uniqueInv = [];
    List<PurchaseModel> _purchase = [];
    List<InventModel> _inventory = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchase = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    var invqnty = _inventory.firstWhere((inv) => inv.productid == productid).quantity;
    var quantityDiff = int.parse(quantity) - int.parse(initialQantity);
    var finalQnty = int.parse(invqnty.toString()) + quantityDiff;

    _purchase.firstWhere((prch) => prch.prcid == prcid).quantity = quantity;
    _purchase.firstWhere((prch) => prch.prcid == prcid).checked = check;
    _inventory.firstWhere((prch) => prch.productid == productid).quantity = finalQnty.toString();
    var amount = _purchase.where((element) => element.purchaseid == purchaseid)
        .fold(0.0, (previousValue, element) => previousValue + (double.parse(element.bprice!) * int.parse(element.quantity!)));
    _purchase.where((element) => element.purchaseid == purchaseid).forEach((prch) {
      prch.amount = amount.toString();
    });
    uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
    uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypurchases', uniquePurchase );
    sharedPreferences.setStringList('myinventory', uniqueInv);
    myPurchases = uniquePurchase;
    myInventory = uniqueInv;
  }
  Future<void> editSaleList(String sid, String productid, String saleid, String quantity, String initialQantity, String check)async{
    List<String> uniqueSale = [];
    List<String> uniqueInv = [];
    List<SaleModel> _sale = [];
    List<InventModel> _inventory = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    var invqnty = _inventory.firstWhere((inv) => inv.productid == productid).quantity;
    var quantityDiff = int.parse(quantity) - int.parse(initialQantity);
    var finalQnty = int.parse(invqnty.toString()) - quantityDiff;

    _sale.firstWhere((sale) => sale.sid == sid).quantity = quantity;
    _sale.firstWhere((sale) => sale.sid == sid).checked = check;
    _inventory.firstWhere((inv) => inv.productid == productid).quantity = finalQnty.toString();
    var amount = _sale.where((element) => element.saleid == saleid)
        .fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice!) * int.parse(element.quantity!)));
    _sale.where((element) => element.saleid == saleid).forEach((sale) {
      sale.amount = amount.toString();
    });
    uniqueSale  = _sale.map((model) => jsonEncode(model.toJson())).toList();
    uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mysales', uniqueSale );
    sharedPreferences.setStringList('myinventory', uniqueInv);
    mySales = uniqueSale;
    myInventory = uniqueInv;
  }
  Future<bool> editSupplier(SupplierModel supplier, BuildContext context, Function update)async{
    List<String> uniqueSupplier = [];
    List<SupplierModel> _suppliers = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _suppliers = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    SupplierModel supplierModel = _suppliers.firstWhere((element) => element.sid == supplier.sid);

    _suppliers.firstWhere((element) => element.sid == supplier.sid).name = supplier.name;
    _suppliers.firstWhere((element) => element.sid == supplier.sid).category = supplier.category;
    _suppliers.firstWhere((element) => element.sid == supplier.sid).company = supplier.company;
    _suppliers.firstWhere((element) => element.sid == supplier.sid).email = supplier.email;
    _suppliers.firstWhere((element) => element.sid == supplier.sid).phone = supplier.phone;
    _suppliers.firstWhere((element) => element.sid == supplier.sid).checked = supplierModel.checked.toString().contains("EDIT")
        ?supplierModel.checked
        :"${supplierModel}, EDIT";

    uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
    mySuppliers = uniqueSupplier;
    update();

    await Services.updateSupplier(supplier).then((response)async{
      if(response=="success") {
        _suppliers.firstWhere((element) => element.sid == supplier.sid).checked = "true";
        uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
        mySuppliers = uniqueSupplier;
        update();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Supplier ${supplier.name} was updated Successfully"),
                showCloseIcon: true,
            )
        );
      }  else if(response=="Does not exist"){
        await Services.addSupplier(supplier).then((value){
          if(value=="Success"){
            _suppliers.firstWhere((element) => element.sid == supplier.sid).checked = "true";
            uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
            mySuppliers = uniqueSupplier;
            update();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Supplier ${supplier.name} was uploaded with changes"),
                  showCloseIcon: true,
                )
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("mhmm 🤔 seems like something went wrong. Please try again later"),
                  showCloseIcon: true,
                )
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Supplier ${supplier.name} has been successfully updated. Awaiting internet connection."),
              showCloseIcon: true,
            )
        );
      }
    });
    return false;
  }
  Future<bool> editProduct(ProductModel product, BuildContext context, Function update)async{
    List<String> uniqueProduct = [];
    List<ProductModel> _product = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _product = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();

    ProductModel prdtModel = _product.firstWhere((element) => element.prid == product.prid);

    _product.firstWhere((element) => element.prid == product.prid).name = product.name;
    _product.firstWhere((element) => element.prid == product.prid).category = product.category;
    _product.firstWhere((element) => element.prid == product.prid).volume = product.volume;
    _product.firstWhere((element) => element.prid == product.prid).supplier = product.supplier;
    _product.firstWhere((element) => element.prid == product.prid).buying = product.buying;
    _product.firstWhere((element) => element.prid == product.prid).selling = product.selling;
    _product.firstWhere((element) => element.prid == product.prid).checked = prdtModel.checked.toString().contains("EDIT")
        ? prdtModel.checked
        : "${prdtModel.checked}, EDIT";

    uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("myproducts", uniqueProduct);
    myProducts = uniqueProduct;
    update();

    await Services.updateProduct(product).then((response)async{
      if(response=="success") {
        _product.firstWhere((element) => element.prid == product.prid).checked = "true";
        uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList("myproducts", uniqueProduct);
        myProducts = uniqueProduct;
        update();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Product ${product.name} was updated Successfully"),
              showCloseIcon: true,
            )
        );
      }
      else if(response=="Does not exist"){
        await Services.addProduct(product).then((value){
          if(value=="Success"){
            _product.firstWhere((element) => element.prid == product.prid).checked = "true";
            uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList("myproducts", uniqueProduct);
            myProducts = uniqueProduct;
            update();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Product ${product.name} was uploaded with changes"),
                  showCloseIcon: true,
                )
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("mhmm 🤔 seems like something went wrong. Please try again later"),
                  showCloseIcon: true,
                )
            );
          }
        });

      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Product ${product.name} was updated Successfully. Awaiting internet connection"),
              showCloseIcon: true,
            )
        );
      }
    });
    return false;
  }
  Future<bool> editInventory(InventModel inventory, BuildContext context, Function update, String quantity)async{
    List<String> uniqueInventory = [];
    List<InventModel> _inventroy = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _inventroy = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();

    InventModel inventModel = _inventroy.firstWhere((test) => inventory.iid == test.iid);

    _inventroy.firstWhere((element) => element.iid == inventory.iid).quantity = quantity;
    _inventroy.firstWhere((element) => element.iid == inventory.iid).checked = inventModel.checked.toString().contains("EDIT")
        ?inventModel.checked
        : "${inventModel.checked}, EDIT";

    uniqueInventory = _inventroy.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("myinventory", uniqueInventory);
    myInventory = uniqueInventory;
    update();

    await Services.updateInvQnty(inventory.productid.toString(), quantity).then((response)async{
      print(response);
      if(response=="success"){
        _inventroy.firstWhere((element) => element.iid == inventory.iid).checked = "true";
        uniqueInventory = _inventroy.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList("myinventory", uniqueInventory);
        myInventory = uniqueInventory;
        update();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Quantity updated successfully."),
                showCloseIcon: true,
            )
        );
      }
      else if(response=="Does not exist"){
        inventory.quantity = quantity;
        await Services.addInventory(inventory).then((value){
          print(value);
          if(value=="Success"){
            _inventroy.firstWhere((element) => element.iid == inventory.iid).checked = "true";
            uniqueInventory = _inventroy.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList("myinventory", uniqueInventory);
            myInventory = uniqueInventory;
            update();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Inventory was uploaded with changes"),
                  showCloseIcon: true,
                )
            );
          }
          else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Quantity updated successfully. Awaiting internet connection."),
                  showCloseIcon: true,
                )
            );
          }
        });
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Quantity updated successfully. Awaiting internet connection."),
                showCloseIcon: true,
            )
        );
      }
    });
    return false;
  }
  Future<bool> editPurchases(BuildContext context, Function update, String purchaseid, String paid, String amount,String method, String date, String due)async{
    List<String> uniquePurchase = [];
    List<String> uniquePayment = [];
    List<PurchaseModel> _purchase = [];
    List<PaymentModel> _payment = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchase = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _payment = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();
    PaymentModel paymentModel = PaymentModel(payid: "");
    PurchaseModel purchaseModel = _purchase.firstWhere((element) => element.purchaseid == purchaseid);

    _purchase.where((element) => element.purchaseid == purchaseid).forEach((purchase){
      purchase.paid = paid;
      purchase.type = method;
      purchase.date = date;
      purchase.due = due;
      purchase.checked = "${purchase.checked.toString().split(",").first}, EDIT";
    });

    paymentModel = _payment.firstWhere((element) => element.purchaseid == purchaseModel.purchaseid);
    _payment.firstWhere((element) => element.purchaseid == purchaseModel.purchaseid).paid = paid;
    _payment.firstWhere((element) => element.purchaseid == purchaseModel.purchaseid).method = method;
    _payment.firstWhere((element) => element.purchaseid == purchaseModel.purchaseid).type = double.parse(purchaseModel.amount.toString()) == double.parse(paid.toString())
        ?"PURCHASE":"PAYABLE";
    _payment.firstWhere((element) => element.purchaseid == purchaseModel.purchaseid).checked = paymentModel.checked.toString().contains("EDIT")
        ? paymentModel.checked
        : "${paymentModel}, EDIT";

    uniquePayment  = _payment.map((model) => jsonEncode(model.toJson())).toList();
    uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypayments', uniquePayment );
    sharedPreferences.setStringList('mypurchases', uniquePurchase );
    myPurchases = uniquePurchase;
    myPayments = uniquePayment;
    update();

    await Services.updatePrchAmount(purchaseid, paid, amount, due, method, date).then((response){
      if(response=="success"){
        _purchase.where((element) => element.purchaseid == purchaseid).forEach((purchase)async{
          purchase.checked = "true";
        });
        uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mypurchases', uniquePurchase );
        myPurchases = uniquePurchase;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Purchase was updated Successfully"),
              showCloseIcon: true,
            )
        );
      } else if(response == "Does not exist"){
        _purchase.where((element) => element.purchaseid == purchaseid).forEach((purchase)async{
          purchase.checked = "REMOVED";
        });
        uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mypurchases', uniquePurchase );
        myPurchases = uniquePurchase;
      }  else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Purchase was updated. Awaiting internet connection"),
              showCloseIcon: true,
            )
        );
      }
      update();
    });
    await Services.updatePrchPayPaid(
        purchaseModel.purchaseid,
        paid.toString(),
        double.parse(purchaseModel.amount.toString()) == double.parse(paid.toString())
            ?"PURCHASE":"PAYABLE",method).then((response){
      if(response=="success"){
        _payment.firstWhere((element) => element.purchaseid == purchaseModel.purchaseid).checked = "true";
      }
    });
    return false;
  }
  Future<bool> editEntity(BuildContext context, Function update, EntityModel updatedEntity, File? image, String oldImage)async{
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();

    _entity.firstWhere((element) => element.eid == updatedEntity.eid).title = updatedEntity.title;
    _entity.firstWhere((element) => element.eid == updatedEntity.eid).category = updatedEntity.category;
    _entity.firstWhere((element) => element.eid == updatedEntity.eid).image = updatedEntity.image;
    _entity.firstWhere((element) => element.eid == updatedEntity.eid).checked = updatedEntity.checked;

    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    update(updatedEntity);

    print(updatedEntity.image.toString());

    final response = await Services.updateEntity(
        updatedEntity.eid,
        updatedEntity.pid!.split(","),
        updatedEntity.title.toString(),
        updatedEntity.category.toString(),
        image,
        oldImage
    );
    final String responseString = await response.stream.bytesToString();
    if(responseString.contains("success")){
      updatedEntity.checked = "true";
      _entity.firstWhere((element) => element.eid == updatedEntity.eid).checked = "true";
      uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList('myentity', uniqueEntities);
      myEntity = uniqueEntities;
      update(updatedEntity);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Entity updated Successfully"),
            showCloseIcon: true,
          )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Entity updated. Awaiting internet connection."),
            showCloseIcon: true,
          )
      );
    }
    return false;
  }
  Future<bool> editSales(BuildContext context, Function update, String saleid, String paid,String amount, String method, String name, String phone, String date, String due)async{
    List<String> uniqueSale = [];
    List<SaleModel> _sales = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _sales = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();

    _sales.where((element) => element.saleid == saleid).forEach((sale){
      sale.paid = paid;
      sale.method = method;
      sale.customer = name;
      sale.phone = phone;
      sale.date = date;
      sale.due = due;
      sale.checked = "${sale.checked.toString().split(",").first}, EDIT";
    });

    uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mysales', uniqueSale);
    mySales = uniqueSale;
    update();

    await Services.updateSalesAmount(saleid, paid, amount, due, name, phone, method, date).then((response){
      if(response=="success"){
        _sales.where((element) => element.saleid == saleid).forEach((sale)async{
          sale.checked = "true";
        });
        uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mysales', uniqueSale);
        mySales = uniqueSale;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Sales were updated Successfully"),
              showCloseIcon: true,
            )
        );
      } else if(response == "Does not exist"){
        _sales.where((element) => element.saleid == saleid).forEach((sale)async{
          sale.checked = "REMOVED";
        });
        uniqueSale  = _sales.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mysales', uniqueSale);
        mySales = uniqueSale;
      }  else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Sales were updated. Awaiting internet connection"),
              showCloseIcon: true,
            )
        );
      }
      update();
    });
    return false;
  }
  Future<bool> editBill(BillingModel updatedBill)async{
    List<BillingModel> _bills = [];
    List<String> uniqueBill = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _bills = myBills.map((jsonString) => BillingModel.fromJson(json.decode(jsonString))).toList();

    BillingModel newBill = updatedBill;
    newBill.accountno = updatedBill.type == 'Different'? '' : updatedBill.accountno;

    _bills.firstWhere((test) => test.bid == newBill.bid).businessno = newBill.businessno;
    _bills.firstWhere((test) => test.bid == newBill.bid).accountno = newBill.accountno;
    _bills.firstWhere((test) => test.bid == newBill.bid).phone = newBill.phone;
    _bills.firstWhere((test) => test.bid == newBill.bid).tillno = newBill.tillno;

    uniqueBill = _bills.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mybills', uniqueBill);
    myBills = uniqueBill;

    // await Services.updateBill(updatedBill.bid, newBill.businessno, newBill.account, newBill.type).then((value){
    //   if(value=="success"){
    //
    //     reload();
    //   } else if(value=="failed"){
    //     ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text("Account was not updated please try again"),
    //           showCloseIcon: true,
    //         )
    //     );
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text("Account was not updated please try again"),
    //           showCloseIcon: true,
    //         )
    //     );
    //   }
    // });


    return false;
  }

  Future<bool> updatePurchaseList(BuildContext context, List<PurchaseModel> purchases, Function reload)async{
    List<String> uniquePurchase = [];
    List<String> uniqueInv = [];
    List<String> uniquePayment = [];
    List<PurchaseModel> _purchase = [];
    List<InventModel> _inventory = [];
    List<PaymentModel> _payment = [];

    int quantity = 0;
    int invQuantity = 0;
    int newQuantity = 0;
    int initialQ = 0;
    int items = 0;

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchase = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _payment = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();
    PurchaseModel purchaseModel = purchases.first;
    PaymentModel paymentModel = PaymentModel(payid: "");

    for(var purchase in purchases){
      if(purchase.checked.toString().contains("DELETE")) {
        quantity = int.parse(purchase.quantity.toString());
        invQuantity = int.parse(_inventory.firstWhere((element) => element.productid == purchase.productid).quantity.toString());
        newQuantity = invQuantity - quantity;
        items = purchases.length - 1;

        _inventory.firstWhere((test) => test.productid == purchase.productid).quantity = newQuantity < 0? "0" : newQuantity.toString();
        _purchase.firstWhere((element) => element.prcid == purchase.prcid).checked = purchase.checked;

        if(purchase.checked.toString().contains("true")){
          await Services.deletePrcByPrcId(purchase.prcid.toString()).then((response)async{
            if(response == "success"){
              await Services.updatePrchAmount(purchase.purchaseid, purchase.paid.toString(), purchase.amount.toString(), purchase.due.toString(), purchase.type.toString(), purchase.date.toString());
              await Services.updateInvSubQnty(purchase.productid.toString(), purchase.quantity.toString());
              _purchase.removeWhere((element) => element.prcid == purchase.prcid);
            }
          });
        } else if(purchase.checked.toString().contains("false")) {
          _purchase.removeWhere((element) => element.prcid == purchase.prcid);
        }
      }
      else if(purchase.checked.toString().contains("false")){

        _purchase.firstWhere((element) => element.prcid == purchase.prcid).checked = purchase.checked;

        await Services.addPurchase(purchase).then((response)async{
          if(response=="Success"){
            await Services.updateInvAddQnty(purchase.productid.toString(), purchase.quantity.toString());
            _purchase.firstWhere((element) => element.prcid == purchase.prcid).checked = "true";
          }
        });
      }
      else if(purchase.checked.toString().contains("REMOVE")) {
        quantity = int.parse(purchase.quantity.toString());
        invQuantity = int.parse(_inventory.firstWhere((element) => element.productid == purchase.productid).quantity.toString());
        newQuantity = invQuantity - quantity;
        _inventory.firstWhere((test) => test.productid == purchase.productid).quantity = newQuantity < 0? "0" : newQuantity.toString();
        _purchase.removeWhere((element) => element.prcid == purchase.prcid);

      }
      else if(purchase.checked.toString().contains("EDIT")){
        PurchaseModel purchaseModel = _purchase.firstWhere((element) => element.prcid == purchase.prcid);
        InventModel inventModel = _inventory.firstWhere((element) => element.productid == purchase.productid);

        quantity = int.parse(purchase.quantity.toString());
        initialQ = int.parse(purchaseModel.quantity.toString());
        invQuantity = int.parse(inventModel.quantity.toString());
        newQuantity = invQuantity + (quantity - initialQ);


        _inventory.firstWhere((test) => test.productid == purchase.productid).quantity = newQuantity < 0? "0" : newQuantity.toString();
        _purchase.firstWhere((element) => element.prcid == purchase.prcid).quantity = purchase.quantity.toString();
        _purchase.firstWhere((element) => element.prcid == purchase.prcid).checked = purchase.checked;

        _purchase.where((element) => element.purchaseid == purchase.purchaseid).forEach((action){
          action.amount = purchase.amount;
        });

        uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
        uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mypurchases', uniquePurchase);
        sharedPreferences.setStringList('myinventory', uniqueInv);
        myPurchases = uniquePurchase;
        myInventory = uniqueInv;
        reload();

        if(purchase.checked.toString().contains("true")){
          List<InventModel> inv = await Services().getInvByPrd(purchase.productid.toString());
          InventModel invMdl = inv.isNotEmpty || inv.length != 0? inv.first : InventModel(iid: "", quantity: "0");
          int invQ = int.parse(invMdl.quantity.toString());
          int newInvQ = invQ + (quantity - initialQ);

          await Services.updateOnePrchQnty(purchase.prcid.toString(), purchase.quantity.toString()).then((value){
            if(value=="success"){
              _purchase.firstWhere((element) => element.prcid == purchase.prcid).checked = "true";
            }
          });
          await Services.updatePrchAmount(purchase.purchaseid, purchase.paid.toString(), purchase.amount.toString(), purchase.due.toString(), purchase.type.toString(), purchase.date.toString()).then((value){});
          await Services.updateInvQnty(purchase.productid.toString(), newInvQ.toString()).then((value){
            print(value);
          });
        }
        else if(purchase.checked.toString().contains("false")){
          List<InventModel> inv = await Services().getInvByPrd(purchase.prcid.toString());
          InventModel invMdl = inv.isNotEmpty || inv.length != 0? inv.first : InventModel(iid: "", quantity: "0");
          int invQ = int.parse(invMdl.quantity.toString());
          int newInvQ = invQ + (quantity - initialQ);

          await Services.addPurchase(purchase).then((response)async{
            if(response=="Success"){
              await Services.updateInvQnty(purchase.productid.toString(), newInvQ.toString());
              _purchase.firstWhere((element) => element.prcid == purchase.prcid).checked = "true";
            }
          });
        }
      }
    }

    paymentModel = _payment.firstWhere((element) => element.purchaseid == purchaseModel.purchaseid);
    _payment.firstWhere((element) => element.purchaseid == purchaseModel.purchaseid).amount = purchaseModel.amount;
    _payment.firstWhere((element) => element.purchaseid == purchaseModel.purchaseid).items = items.toString();
    _payment.firstWhere((element) => element.purchaseid == purchaseModel.purchaseid).type = double.parse(purchaseModel.amount.toString()) == double.parse(purchaseModel.paid.toString())
        ?"PURCHASE":"PAYABLE";
    _payment.firstWhere((element) => element.purchaseid == purchaseModel.purchaseid).checked = paymentModel.checked.toString().contains("EDIT")
        ? paymentModel.checked
        : "${paymentModel}, EDIT";
    uniquePayment  = _payment.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypayments', uniquePayment );
    myPayments = uniquePayment;

    await Services.updatePrchPayAmount(
        purchaseModel.purchaseid,
        purchaseModel.amount.toString(),
        double.parse(purchaseModel.amount.toString()) == double.parse(purchaseModel.paid.toString())
            ?"PURCHASE":"PAYABLE",
        items.toString()).then((response){
      if(response=="success"){
        _payment.firstWhere((element) => element.purchaseid == purchaseModel.purchaseid).checked = "true";
      }
    });

    uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
    uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    uniquePayment  = _payment.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypurchases', uniquePurchase);
    sharedPreferences.setStringList('myinventory', uniqueInv);
    sharedPreferences.setStringList('mypayments', uniquePayment );
    myPurchases = uniquePurchase;
    myInventory = uniqueInv;
    myPayments = uniquePayment;
    reload();
    return false;
  }
  Future<bool> updateSaleList(BuildContext context, List<SaleModel> sales, Function reload)async{
    List<String> uniqueSale= [];
    List<String> uniqueInv = [];
    List<String> uniquePayment = [];
    List<SaleModel> _sale = [];
    List<InventModel> _inventory = [];
    List<PaymentModel> _payment = [];

    int quantity = 0;
    int invQuantity = 0;
    int newQuantity = 0;
    int initialQ = 0;
    int items = 0;

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();
    _payment = myPayments.map((jsonString) => PaymentModel.fromJson(json.decode(jsonString))).toList();
    SaleModel saleModel = sales.first;
    PaymentModel paymentModel = PaymentModel(payid: "");


    for(var sale in sales){
      if(sale.checked.toString().contains("DELETE")) {
        quantity = int.parse(sale.quantity.toString());
        invQuantity = int.parse(_inventory.firstWhere((element) => element.productid == sale.productid).quantity.toString());
        newQuantity = invQuantity + quantity;
        items = sales.length - 1;

        _inventory.firstWhere((test) => test.productid == sale.productid).quantity = newQuantity < 0? "0" : newQuantity.toString();
        _sale.firstWhere((element) => element.sid == sale.sid).checked = sale.checked;

        if(sale.checked.toString().contains("true")){
          await Services.deleteSaleBySid(sale.sid.toString()).then((response)async{
            if(response == "success"){
              await Services.updateSalesAmount(sale.saleid, sale.paid.toString(), sale.amount.toString(), sale.due.toString(), sale.customer.toString(), sale.phone.toString(), sale.method.toString(), sale.date.toString());
              await Services.updateInvAddQnty(sale.productid.toString(), sale.quantity.toString());
              _sale.removeWhere((element) => element.sid == sale.sid);
            }
          });
        } else if(sale.checked.toString().contains("false")) {
          _sale.removeWhere((element) => element.sid == sale.saleid);
        }
      }
      else if(sale.checked.toString().contains("false")){

        _sale.firstWhere((element) => element.sid == sale.sid).checked = sale.checked;

        await Services.addSale(sale).then((response)async{
          if(response=="Success"){
            await Services.updateInvSubQnty(sale.productid.toString(), sale.quantity.toString());
            _sale.firstWhere((element) => element.sid == sale.sid).checked = "true";
          }
        });
      }
      else if(sale.checked.toString().contains("REMOVE")) {
        quantity = int.parse(sale.quantity.toString());
        invQuantity = int.parse(_inventory.firstWhere((element) => element.productid == sale.productid).quantity.toString());
        newQuantity = invQuantity + quantity;
        _inventory.firstWhere((test) => test.productid == sale.productid).quantity = newQuantity < 0? "0" : newQuantity.toString();
        _sale.removeWhere((element) => element.sid == sale.sid);

      }
      else if(sale.checked.toString().contains("EDIT")){
        SaleModel saleModel = _sale.firstWhere((element) => element.sid == sale.sid);
        InventModel inventModel = _inventory.firstWhere((element) => element.productid == sale.productid);

        quantity = int.parse(sale.quantity.toString());
        initialQ = int.parse(saleModel.quantity.toString());
        invQuantity = int.parse(inventModel.quantity.toString());
        newQuantity = invQuantity + (initialQ - quantity);


        _inventory.firstWhere((test) => test.productid == sale.productid).quantity = newQuantity < 0? "0" : newQuantity.toString();
        _sale.firstWhere((element) => element.sid == sale.sid).quantity = sale.quantity.toString();
        _sale.firstWhere((element) => element.sid == sale.sid).checked = sale.checked;

        _sale.where((element) => element.saleid == sale.saleid).forEach((action){
          action.amount = sale.amount;
        });

        uniqueSale  = _sale.map((model) => jsonEncode(model.toJson())).toList();
        uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mysales', uniqueSale);
        sharedPreferences.setStringList('myinventory', uniqueInv);
        mySales = uniqueSale;
        myInventory = uniqueInv;
        reload();

        if(sale.checked.toString().contains("true")){
          List<InventModel> inv = await Services().getInvByPrd(sale.productid.toString());
          InventModel invMdl = inv.isNotEmpty || inv.length != 0? inv.first : InventModel(iid: "", quantity: "0");
          int invQ = int.parse(invMdl.quantity.toString());
          int newInvQ = invQ + (initialQ - quantity);

          await Services.updateSale(sale).then((value){
            if(value=="success"){
              _sale.firstWhere((element) => element.sid == sale.sid).checked = "true";
            }
          });
          await Services.updateSalesAmount(sale.saleid,
              sale.paid.toString(), sale.amount.toString(),
              sale.due.toString(), sale.customer.toString(),
              sale.phone.toString(), sale.method.toString(),
              sale.date.toString());
          await Services.updateInvQnty(sale.productid.toString(), newInvQ.toString());
        }
        else if(sale.checked.toString().contains("false")){
          List<InventModel> inv = await Services().getInvByPrd(sale.sid.toString());
          InventModel invMdl = inv.isNotEmpty || inv.length != 0? inv.first : InventModel(iid: "", quantity: "0");
          int invQ = int.parse(invMdl.quantity.toString());
          int newInvQ = invQ + (quantity - initialQ);

          await Services.addSale(sale).then((response)async{
            if(response=="Success"){
              await Services.updateInvQnty(sale.productid.toString(), newInvQ.toString());
              _sale.firstWhere((element) => element.sid == sale.sid).checked = "true";
            }
          });
        }
      }
    }
    paymentModel = _payment.firstWhere((element) => element.saleid == saleModel.saleid);
    _payment.firstWhere((element) => element.saleid == saleModel.saleid).amount = saleModel.amount;
    _payment.firstWhere((element) => element.saleid == saleModel.saleid).items = items.toString();
    _payment.firstWhere((element) => element.saleid == saleModel.saleid).type = double.parse(saleModel.amount.toString()) == double.parse(saleModel.paid.toString())
        ?"SALE":"RECEIVABLE";
    _payment.firstWhere((element) => element.saleid == saleModel.saleid).checked = paymentModel.checked.toString().contains("EDIT")
        ? paymentModel.checked
        : "${paymentModel}, EDIT";
    uniquePayment  = _payment.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypayments', uniquePayment );
    myPayments = uniquePayment;

    await Services.updateSalePayAmount(
        saleModel.saleid,
        saleModel.amount.toString(),
        double.parse(saleModel.amount.toString()) == double.parse(saleModel.paid.toString())
            ?"SALE":"RECEIVABLE",
        items.toString()).then((response){
      if(response=="success"){
        _payment.firstWhere((element) => element.saleid == saleModel.saleid).checked = "true";
      }
    });


    uniqueSale  = _sale.map((model) => jsonEncode(model.toJson())).toList();
    uniqueInv  = _inventory.map((model) => jsonEncode(model.toJson())).toList();
    uniquePayment  = _payment.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mysales', uniqueSale);
    sharedPreferences.setStringList('myinventory', uniqueInv);
    sharedPreferences.setStringList('mypayments', uniquePayment );
    mySales = uniqueSale;
    myInventory = uniqueInv;
    myPayments = uniquePayment;
    reload();
    return false;
  }

  Future<void> updateSeen(NotifModel notif)async{
    List<NotifModel> _notification = [];
    List<String> uniqueNotif = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _notification = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();

    if(!notif.seen.toString().contains(currentUser.uid)){
      List<String> seens = [];
      List<String> _checks = [];
      seens = notif.seen.toString().split(",");
      _checks = notif.checked.toString().split(",");
      seens.remove("");
      if(!seens.contains(currentUser.uid)){
        seens.add(currentUser.uid);
      }
      if(!_checks.contains("SEEN")){
        _checks.add("SEEN");
      }
      _notification.firstWhere((test) => test.nid == notif.nid).seen = seens.join(",");
      _notification.firstWhere((test) => test.nid == notif.nid).checked = _checks.join(",");
      if(socketManager.notifications.any((test) => test.nid == notif.nid)){
        socketManager.notifications.firstWhere((test) => test.nid == notif.nid).seen = seens.join(",");
        socketManager.notifications.firstWhere((test) => test.nid == notif.nid).checked = _checks.join(",");
      }
    }

    uniqueNotif = _notification.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mynotif', uniqueNotif);
    myNotif = uniqueNotif;

    await Services.updateNotifSeen(notif.nid).then((response){
      if(response=="success"){
        List<String> _checks = [];
        _checks = notif.checked.toString().split(",");
        if(_checks.contains("SEEN")){
          _checks.remove("SEEN");
        }

        _notification.firstWhere((test) => test.nid == notif.nid).checked = _checks.join(",");
        if(socketManager.notifications.any((test) => test.nid == notif.nid)){
          socketManager.notifications.firstWhere((test) => test.nid == notif.nid).checked = _checks.join(",");
        }
        uniqueNotif = _notification.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mynotif', uniqueNotif);
        myNotif = uniqueNotif;
      }
    });
  }

  Future<void> checkAndUploadEntity(EntityModel entityModel, Function updateEntity) async {
    if (entityModel.checked == "false") {
      try {
        final response = await Services.addEntity(
          entityModel.eid,
          entityModel.pid!.split(","),
          entityModel.title.toString(),
          entityModel.category.toString(),
          entityModel.location.toString(),
          File(entityModel.image.toString()),
        );
        final String responseString = await response.stream.bytesToString();
        if (responseString.contains("Success")) {
          entityModel.checked = 'true';
          updateEntity();
        } else {
          print("Error: $responseString");

        }
      } catch (e) {
        print("Error: $e");

      }
    }
  }
  Future<void> checkAndUploadSupplier(SupplierModel supplier, Function updateSupplier) async {
      try {
      if (supplier.checked == "false") {
        final response = await Services.addSupplier(supplier);
        if (response == "Success") {
          supplier.checked = 'true';
          updateSupplier(supplier);
        } else {
          print("Error: $response");
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  Future<void> checkAndUploadProduct(ProductModel product, Function updateProduct) async {
    if (product.checked == "false") {
      try {
        final response = await Services.addProduct(product);
        if (response == "Success") {
          product.checked = 'true';
          updateProduct(product);
        } else {
          print("Error: $response");
        }
      } catch (e) {
        print("Error: $e");
      }
    }
  }
  Future<void> checkAndUploadInvento(InventModel invent, Function updateInvento) async {
    if (invent.checked == "false") {
      try {
        final response = await Services.addInventory(invent);
        if (response == "Success") {
          invent.checked = 'true';
          updateInvento(invent);
        } else {
          print("Error: $response");
        }
      } catch (e) {
        print("Error: $e");

      }
    }
  }
  Future<bool> checkAndUploadPurchases(List<PurchaseModel> purchases, Function reload)async{
    List<String> uniquePurchase = [];
    List<PurchaseModel> _purchase = [];

    int quantity = 0;
    int invQuantity = 0;
    int newQuantity = 0;
    int initialQ = 0;

    List<PurchaseModel> purchasesToRemove = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _purchase = myPurchases.map((jsonString) => PurchaseModel.fromJson(json.decode(jsonString))).toList();

    for(var purchase in purchases){
      if(purchase.checked.toString().contains("DELETE")) {
        if(purchase.checked.toString().contains("false")){
          _purchase.removeWhere((test)=>test.prcid==purchase.prcid);
        } else {
          purchasesToRemove.add(purchase);
        }
      }
      else if(purchase.checked.toString().contains("false")){
        await Services.addPurchase(purchase).then((response)async{
          if(response=="Success"){
            await Services.updateInvAddQnty(purchase.productid.toString(), purchase.quantity.toString());
            _purchase.firstWhere((element) => element.prcid == purchase.prcid).checked = "true";
          }
        });
      }
      else if(purchase.checked.toString().contains("EDIT")){
        List<PurchaseModel> newPrch =  await Services().getPrchByPRCID(purchase.prcid.toString());
        quantity = int.parse(purchase.quantity.toString());
        initialQ = int.parse(newPrch.first.quantity.toString());

        await Services.updatePurchase(purchase).then((response)async{
          if(response=="success"){
            await Services.updatePrchAmount(purchase.purchaseid, purchase.paid.toString(), purchase.amount.toString(), purchase.due.toString(), purchase.type.toString(), purchase.date.toString()).then((value){});
            await Services.updateInvDiffQnty(purchase.productid.toString(), (quantity - initialQ).toString()).then((inv){
            });
            _purchase.firstWhere((element) => element.prcid == purchase.prcid).checked = "true";
          } else if(response=="Does not exist"){
            await Services.addPurchase(purchase).then((value)async{
              if(value=="Success"){
                await Services.updateInvDiffQnty(purchase.productid.toString(), (quantity - initialQ).toString());
                _purchase.firstWhere((element) => element.prcid == purchase.prcid).checked = "true";
              }
            });
          }
        });
      }
    }

    for (var purchase in purchasesToRemove) {
      await Services.updateInvSubQnty(purchase.productid.toString(), purchase.quantity.toString());
      await Services.deletePrchByPrchId(purchase.purchaseid.toString()).then((value){
        if(value=="Does not exist" || value=="success"){
          _purchase.removeWhere((element) => element.prcid == purchase.prcid);
        };
      });
    }

    uniquePurchase  = _purchase.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypurchases', uniquePurchase);
    myPurchases = uniquePurchase;
    reload();
    return false;
  }
  Future<bool> checkAndUploadSales(List<SaleModel> sales, Function reload)async{
    List<String> uniqueSale = [];
    List<SaleModel> _sale = [];

    int quantity = 0;
    int invQuantity = 0;
    int newQuantity = 0;
    int initialQ = 0;

    List<SaleModel> saleToRemove = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();

    for(var sale in sales){
      if(sale.checked.toString().contains("DELETE")) {
        if(sale.checked.toString().contains("false")){
          _sale.removeWhere((test)=>test.sid==sale.sid);
        } else {
          saleToRemove.add(sale);
        }
      }
      else if(sale.checked.toString().contains("false")){
        await Services.addSale(sale).then((response)async{
          if(response=="Success"){
            await Services.updateInvSubQnty(sale.productid.toString(), sale.quantity.toString());
            _sale.firstWhere((element) => element.sid == sale.sid).checked = "true";
          }
        });
      }
      else if(sale.checked.toString().contains("EDIT")){
        List<SaleModel> newSale =  await Services().getSaleBySid(sale.sid.toString());
        quantity = int.parse(sale.quantity.toString());
        initialQ = int.parse(newSale.first.quantity.toString());

        await Services.updateSale(sale).then((response)async{
          print(response);
          if(response=="success"){
            await Services.updateSalesAmount(sale.saleid, sale.paid.toString(), sale.amount.toString(), sale.due.toString(), sale.customer.toString(), sale.phone.toString(), sale.method.toString(), sale.date.toString());
            await Services.updateInvDiffQnty(sale.productid.toString(), (initialQ - quantity).toString());
            _sale.firstWhere((element) => element.sid == sale.sid).checked = "true";
          } else if(response=="Does not exist"){
            await Services.addSale(sale).then((value)async{
              if(value=="Success"){
                await Services.updateInvDiffQnty(sale.productid.toString(), (initialQ - quantity).toString());
                _sale.firstWhere((element) => element.sid == sale.sid).checked = "true";
              }
            });
          }
        });
      }
    }

    for (var sale in saleToRemove) {
      await Services.updateInvAddQnty(sale.productid.toString(), sale.quantity.toString());
      await Services.deleteSaleBySaleId(sale.saleid.toString()).then((value){
        if(value=="Does not exist" || value=="success"){
          _sale.removeWhere((element) => element.sid == sale.sid);
        };
      });
    }

    uniqueSale  = _sale.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mysales', uniqueSale);
    mySales = uniqueSale;
    reload();
    return false;
  }
  Future<void> checkAndUploadPay(List<PaymentModel> payments, Function reload)async{
    
  }
  Future<bool> checkNotifications(List<NotifModel> notifications, Function reload) async {
    List<NotifModel> _notification = [];
    List<String> uniqueNotif = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _notification = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();

    for (var notif in notifications){
      if(notif.checked.toString().contains("DELETE")){
        await Services.updateNotifDel(notif.nid).then((value){
          if(value=="success"|| value=="Does not exist"){
            _notification.removeWhere((test) => test.nid == notif.nid);
            socketManager.notifications.removeWhere((test) => test.nid == notif.nid);
          }
        });
      } else if(notif.checked.toString().contains("SEEN")){
        await Services.updateNotifDel(notif.nid).then((value){
          if(value=="success" || value=="Does not exist"){
            List<String> checked = [];
            checked=notif.checked.toString().split(",");
            checked.remove("SEEN");
            _notification.firstWhere((test) => test.nid == notif.nid).checked = checked.join(",");
            if(socketManager.notifications.any((test) => test.nid == notif.nid)){
              socketManager.notifications.firstWhere((test) => test.nid == notif.nid).checked = checked.join(",");
            }
          }
        });
      }
    }

    uniqueNotif = _notification.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mynotif', uniqueNotif);
    myNotif = uniqueNotif;
    return false;
  }

  Future<void> checkSuppliers(List<SupplierModel> suppliers, Function refresh)async{
    List<String> uniqueSupplier = [];
    List<SupplierModel> _suppliers = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _suppliers = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();

    for (var supplier in suppliers) {
      if(supplier.checked!.contains("DELETE")){
        await Services.deleteSupplier(supplier.sid).then((response){
          if(response=="success"){
            _suppliers.removeWhere((element) => element.sid == supplier.sid);
            uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
            mySuppliers = uniqueSupplier;
          }
        });
      } else if(supplier.checked == "false"){
        await Services.addSupplier(supplier).then((response){
          if(response=="Success"){
            _suppliers.firstWhere((element) => element.sid == supplier.sid).checked = "true";
            uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
            mySuppliers = uniqueSupplier;
          }
        });
      }  else if(supplier.checked!.contains("EDIT")){
        await Services.updateSupplier(supplier).then((response)async{
          if(response=="success"){
            _suppliers.firstWhere((element) => element.sid == supplier.sid).checked = "true";
            uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
            mySuppliers = uniqueSupplier;
          } else if(response=="Does not exist"){
            await Services.addSupplier(supplier).then((value){
              if(value=="Success"){
                _suppliers.firstWhere((element) => element.sid == supplier.sid).checked = "true";
                uniqueSupplier = _suppliers.map((model) => jsonEncode(model.toJson())).toList();
                sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
                mySuppliers = uniqueSupplier;
              }
            });
          }
        });
      }
    }
    refresh();
  }
  Future<bool> checkInventory(List<InventModel> inventories, Function refresh)async{
    List<String> uniqueInventory = [];
    List<InventModel> _inventory = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _inventory = myInventory.map((jsonString) => InventModel.fromJson(json.decode(jsonString))).toList();

    for (var inventory in inventories) {
      if(inventory.checked!.contains("DELETE")){
        await Services.deleteInventory(inventory.iid).then((response){
          if(response=="success"){
            _inventory.removeWhere((element) => element.iid == inventory.iid);
            uniqueInventory = _inventory.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList("myinventory", uniqueInventory);
            myInventory = uniqueInventory;
          }
        });
      } else if(inventory.checked.toString().contains('false')){
        await Services.addInventory(inventory).then((response){
          if(response=="Success"){
            _inventory.firstWhere((element) => element.iid == inventory.iid).checked = "true";
            uniqueInventory = _inventory.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList("myinventory", uniqueInventory);
            myInventory = uniqueInventory;
          }
        });
      } else if(inventory.checked!.contains("EDIT")){
        await Services.updateInvQnty(inventory.productid.toString(), inventory.quantity.toString()).then((response)async{
          if(response=="success"){
            _inventory.firstWhere((element) => element.iid == inventory.iid).checked = "true";
            uniqueInventory = _inventory.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList("myinventory", uniqueInventory);
            myInventory = uniqueInventory;
          } else if(response=="Does not exist"){
            await Services.addInventory(inventory).then((value){
              if(value=="Success"){
                _inventory.firstWhere((element) => element.iid == inventory.iid).checked = "true";
                uniqueInventory = _inventory.map((model) => jsonEncode(model.toJson())).toList();
                sharedPreferences.setStringList("myinventory", uniqueInventory);
                myInventory = uniqueInventory;
              }
            });
          }
        });
      }
    }
    refresh();
    return false;
  }
  Future<bool> checkProducts(List<ProductModel> products, Function refresh)async{
    List<String> uniqueProduct = [];
    List<ProductModel> _product = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _product = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).toList();

    for (var product in products) {
      if(product.checked.toString().contains("DELETE")){
        await Services.deleteProduct(product.prid).then((response){
          if(response=="success"){
            _product.removeWhere((element) => element.prid == product.prid);
            uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList("myproducts", uniqueProduct);
            myProducts = uniqueProduct;
          }
        });
      } else if(product.checked.toString().contains("false")){
        await Services.addProduct(product).then((response){
          if(response=="Success"){
            _product.firstWhere((element) => element.prid == product.prid).checked = "true";
            uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList("myproducts", uniqueProduct);
            myProducts = uniqueProduct;
          }
        });
      } else if(product.checked.toString().contains("EDIT")){
        await Services.updateProduct(product).then((response)async{
          if(response=="success"){
            _product.firstWhere((element) => element.prid == product.prid).checked = "true";
            uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList("myproducts", uniqueProduct);
            myProducts = uniqueProduct;
          } else if(response=="Does not exist"){
            await Services.addProduct(product).then((value){
              if(value=="Success"){
                _product.firstWhere((element) => element.prid == product.prid).checked = "true";
                uniqueProduct = _product.map((model) => jsonEncode(model.toJson())).toList();
                sharedPreferences.setStringList("myproducts", uniqueProduct);
                myProducts = uniqueProduct;
              }
            });
          }
        });
      } else if(product.checked.toString().contains("REMOVED")){
        print("object");
      }
    }
    refresh();
    return false;
  }
  Future<bool> checkEntity(Function refresh)async{
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();

    List<String> removedEntity = [];

    for(var entity in _entity){
      if(entity.checked.contains("DELETE")){
        removedEntity.add(entity.eid);
      }
      else if(entity.checked.contains("false")){
        final response =  await Services.addEntity(
            entity.eid,
            entity.pid.toString().split(","),
            entity.title.toString(),
            entity.category.toString(),
            entity.location.toString(),
            entity.image == ""? null
                : File(entity.image.toString())
        );
        final String responseString = await response.stream.bytesToString();
        if(responseString.contains("Success")){
          _entity.firstWhere((element) => element.eid == entity.eid).checked = "true";
        }
      }
      else if(entity.checked.contains("EDIT")){
        final response =  await Services.updateEntity(
            entity.eid,
            entity.pid.toString().split(","),
            entity.title.toString(),
            entity.category.toString(),
            entity.image.toString().contains("/") || entity.image.toString().contains("\\")? File(entity.image.toString())
                : null,
            entity.image.toString()
        );
        final String responseString = await response.stream.bytesToString();
        if(responseString.contains("success")){
          _entity.firstWhere((element) => element.eid == entity.eid).checked = "true";
        }
      }
    }

    for(var eid in removedEntity){
      await Services.deleteEntity(eid).then((response)async{
        if(response=="success"||response=="Does not exist"){
          _entity.removeWhere((element) => element.eid == eid);
        }
      });
    }

    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    refresh();
    return false;
  }

  Future<bool> makeAdmin(BuildContext context, EntityModel entity, UserModel user, Function reload)async{
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    List<String> _admins = [];
    List<String> _checks = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();

    EntityModel entityModel = _entity.firstWhere((test) => test.eid == entity.eid);


    _admins = entityModel.admin.toString().split(",");
    _checks = entityModel.checked.toString().split(",");
    _admins.remove("");
    if(!_admins.contains(user.uid)){
      _admins.add(user.uid);
    }
    if(!_checks.contains("EDIT")){
      _checks.add("EDIT");
    }

    _entity.firstWhere((test) => test.eid == entity.eid).admin = _admins.join(",");
    _entity.firstWhere((test) => test.eid == entity.eid).checked = _checks.join(",");
    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    reload(user,"Add");

    await Services.updateAdmin(entity.eid, user.uid).then((response){
      if(response=="success"){
        _checks.remove("EDIT");
        _entity.firstWhere((test) => test.eid == entity.eid).checked = _checks.join(",");
        uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myentity', uniqueEntities);
        myEntity = uniqueEntities;
        reload(user,"Add");
      }
    });
    return false;
  }
  Future<bool> removeAdmin(BuildContext context, EntityModel entity, UserModel user, Function reload)async{
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    List<String> _admins = [];
    List<String> _checks = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();

    EntityModel entityModel = _entity.firstWhere((test) => test.eid == entity.eid);


    _admins = entityModel.admin.toString().split(",");
    _checks = entityModel.checked.toString().split(",");
    _admins.remove("");
    if(!_admins.contains(user.uid)){
      _admins.remove(user.uid);
    }
    if(!_checks.contains("EDIT")){
      _checks.add("EDIT");
    }

    _entity.firstWhere((test) => test.eid == entity.eid).admin = _admins.join(",");
    _entity.firstWhere((test) => test.eid == entity.eid).checked = _checks.join(",");
    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    reload(user,"Remove");

    await Services.removeAdmin(entity.eid, user.uid).then((response){
      print("Response :$response");
      if(response=="success"){
        _checks.remove("EDIT");
        _entity.firstWhere((test) => test.eid == entity.eid).checked = _checks.join(",");
        uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myentity', uniqueEntities);
        myEntity = uniqueEntities;
        reload(user,"Remove");
      }
    });
    return false;
  }
}