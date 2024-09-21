import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/duties.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/inventories.dart';
import 'package:TallyApp/models/notifications.dart';
import 'package:TallyApp/models/payments.dart';
import 'package:TallyApp/models/products.dart';
import 'package:TallyApp/models/purchases.dart';
import 'package:TallyApp/models/sales.dart';
import 'package:TallyApp/models/suppliers.dart';
import 'package:TallyApp/models/users.dart';
import 'package:http/http.dart' as http;

class Services{
  static String HOST = "http://${domain}/Tally/";
  //static  HOST = "http://192.168.137.1/Tally/";
  //static  HOST = "http://192.168.100.10/Tally/";


  static String _USERS = HOST + 'users.php';
  static String _ENTITY = HOST + 'entity.php';
  static String _INVENTORY = HOST + 'inventory.php';
  static String _SUPPLIERS = HOST + 'suppliers.php';
  static String _PRODUCTS = HOST + 'products.php';
  static String _PURCHASE = HOST + 'purchase.php';
  static String _SALE = HOST + 'sales.php';
  static String _NOTIFICATIONS = HOST + 'notifications.php';
  static String _PAYMENTS = HOST + 'payments.php';
  static String _DUTIES = HOST + 'duties.php';

  static  String _ADD  = 'ADD';
  static  String _REGISTER  = 'REGISTER';
  static  String _LOGIN  = 'LOGIN';
  static  String _LOGIN_EMAIL  = 'LOGIN_EMAIL';
  static  String _GET  = 'GET';
  static  String _GET_CURRENT  = 'GET_CURRENT';
  static  String _GET_BY_USER  = 'GET_BY_USER';
  static  String _GET_BY_ADMIN  = 'GET_BY_ADMIN';
  static  String _GET_ALL_BY_ADMIN  = 'GET_ALL_BY_ADMIN';
  static  String _GET_REC_BY_ADMIN  = 'GET_REC_BY_ADMIN';
  static  String _GET_COMPLETE  = 'GET_COMPLETE';
  static  String _GET_PAYABLE  = 'GET_PAYABLE';
  static  String _GET_PAYABLE0_BY_ADMIN  = 'GET_PAYABLE0_BY_ADMIN';
  static  String _GET_RECEIVABLE  = 'GET_RECEIVABLE';
  static  String _GET_ONE  = 'GET_ONE';
  static  String _GET_PURCHASE = 'GET_PURCHASE';
  static  String _GET_UNSEEN  = 'GET_UNSEEN';
  static  String _GET_BY_PRODUCT  = 'GET_BY_PRODUCT';
  static  String _GET_BY_SALEID  = 'GET_BY_SALEID';
  static  String _GET_BY_SID  = 'GET_BY_SID';
  static  String _GET_BY_PURCHASEID  = 'GET_BY_PURCHASEID';
  static  String _GET_BY_PRCID  = 'GET_BY_PRCID';
  static  String _GET_BY_ENTITY  = 'GET_BY_ENTITY';
  static  String _GET_ALL  = 'GET_ALL';
  static  String _GET_MY  = 'GET_MY';
  static  String _GET_PRODUCTID  = 'GET_PRODUCTID';
  static  String _UPDATE  = 'UPDATE';
  static  String _UPDATE_TOKEN  = 'UPDATE_TOKEN';
  static  String _UPDATE_PID  = 'UPDATE_PID';
  static  String _UPDATE_PROFILE  = 'UPDATE_PROFILE';
  static  String _UPDATE_AMOUNT  = 'UPDATE_AMOUNT';
  static  String _UPDATE_SALE_AMOUNT  = 'UPDATE_SALE_AMOUNT';
  static  String _UPDATE_SPRICE  = 'UPDATE_SPRICE';
  static  String _UPDATE_PURCHASE_AMOUNT  = 'UPDATE_PURCHASE_AMOUNT';
  static  String _UPDATE_PURCHASE_PAID  = 'UPDATE_PURCHASE_PAID';
  static  String _UPDATE_ALL_AMOUNT  = 'UPDATE_ALL_AMOUNT';
  static  String _UPDATE_ONE_QUANTITY  = 'UPDATE_ONE_QUANTITY';
  static  String _UPDATE_SEEN  = 'UPDATE_SEEN';
  static  String _UPDATE_DELETE  = 'UPDATE_DELETE';
  static  String _UPDATE_PAID  = 'UPDATE_PAID';
  static  String _UPDATE_PHONE  = 'UPDATE_PHONE';
  static  String _UPDATE_EMAIL  = 'UPDATE_EMAIL';
  static  String _UPDATE_PASS  = 'UPDATE_PASS';
  static  String _UPDATE_QUANTITY = 'UPDATE_QUANTITY';
  static  String _UPDATE_ADMIN = 'UPDATE_ADMIN';
  static  String _REMOVE_ADMIN = 'REMOVE_ADMIN';
  static  String _UPDATE_SUB_QNTY = 'UPDATE_SUB_QNTY';
  static  String _UPDATE_ADD_QNTY = 'UPDATE_ADD_QNTY';
  static  String _UPDATE_DIFF_QNTY = 'UPDATE_DIFF_QNTY';
  static  String _UPDATE_BY_PRODUCTID = 'UPDATE_BY_PRODUCTID';
  static  String _DELETE  = 'DELETE';
  static  String _DELETE_PRCHID  = 'DELETE_PRCHID';
  static  String _DELETE_EID  = 'DELETE_EID';
  static  String _DELETE_SID  = 'DELETE_SID';
  static  String _DELETE_SALEID  = 'DELETE_SALEID';
  static  String _DELETE_PRCID  = 'DELETE_PRCID';
  static  String _REMOVE_USER  = 'REMOVE_USER';

  // Method to create the table Users.
  List<UserModel> userFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<UserModel>.from(data.map((item)=>UserModel.fromJson(item)));
  }
  // Method to create the table Entity.
  List<EntityModel> entityFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<EntityModel>.from(data.map((item)=>EntityModel.fromJson(item)));
  }
  // Method to create the table Purchase.
  List<PurchaseModel> purchaseFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<PurchaseModel>.from(data.map((item)=>PurchaseModel.fromJson(item)));
  }

  // Method to create the table Payments.
  List<PaymentModel> paymentsFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<PaymentModel>.from(data.map((item)=>PaymentModel.fromJson(item)));
  }

  // Method to create the table Inventory.
  List<InventModel> inventFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<InventModel>.from(data.map((item)=>InventModel.fromJson(item)));
  }

  // Method to create the table Products.
  List<ProductModel> productsFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<ProductModel>.from(data.map((item)=>ProductModel.fromJson(item)));
  }

  // Method to create the table Notification.
  List<NotifModel> notifFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<NotifModel>.from(data.map((item)=>NotifModel.fromJson(item)));
  }

  // Method to create the table Suppliers.
  List<SupplierModel> supplierFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<SupplierModel>.from(data.map((item)=>SupplierModel.fromJson(item)));
  }

  // Method to create the table Sales.
  List<SaleModel> saleFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<SaleModel>.from(data.map((item)=>SaleModel.fromJson(item)));
  }

  // Method to create the table Duties.
  List<DutiesModel> dutyFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<DutiesModel>.from(data.map((item)=>DutiesModel.fromJson(item)));
  }


  // // GET USERS
  // Future<List<UserModel>> getUser()async{
  //   final response = await http.get(GET_USERS);
  //   if(response.statusCode==200) {
  //     List<UserModel> user = userFromJson(response.body);
  //     return user;
  //   } else {
  //     return <UserModel>[];
  //   }
  // }

  // GET LOGGED IN USER
  Future<List<UserModel>> getUser(String email)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET;
    map["email"] = email;
    final response = await http.post(Uri.parse(_USERS),body: map);
    if(response.statusCode==200) {
      List<UserModel> user = userFromJson(response.body);
      return user;
    } else {
      return <UserModel>[];
    }
  }

  // GET ALL USERS
  Future<List<UserModel>> getAllUser()async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_ALL;
    final response = await http.post(Uri.parse(_USERS),body: map);
    if(response.statusCode==200) {
      List<UserModel> user = userFromJson(response.body);
      return user;
    } else {
      return <UserModel>[];
    }
  }

  // GET ALL PRODUCT
  Future<List<ProductModel>> getAllPrdct()async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_ALL;
    final response = await http.post(Uri.parse(_PRODUCTS),body: map);
    if(response.statusCode==200) {
      List<ProductModel> product = productsFromJson(response.body);
      return product;
    } else {
      return <ProductModel>[];
    }
  }

  // GET CURRENT NOTIFICATIONS
  Future<List<NotifModel>> getMyNotif(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["uid"] = uid;
    final response = await http.post(Uri.parse(_NOTIFICATIONS),body: map);
    if(response.statusCode==200) {
      List<NotifModel> notif = notifFromJson(response.body);
      return notif;
    } else {
      return <NotifModel>[];
    }
  }

  // GET CURRENT NOTIFICATIONS
  Future<List<DutiesModel>> getCrntDuties(String eid, String pid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT;
    map["eid"] = eid;
    map["pid"] = pid;
    final response = await http.post(Uri.parse(_DUTIES),body: map);
    if(response.statusCode==200) {
      List<DutiesModel> data = dutyFromJson(response.body);
      return data;
    } else {
      return <DutiesModel>[];
    }
  }

  // GET MY DUTIES
  Future<List<DutiesModel>> getMyDuties(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["pid"] = uid;
    final response = await http.post(Uri.parse(_DUTIES),body: map);
    if(response.statusCode==200) {
      List<DutiesModel> data = dutyFromJson(response.body);
      return data;
    } else {
      return <DutiesModel>[];
    }
  }

  // GET CURRENT UNSEEN NOTIFICATIONS
  Future<List<NotifModel>> getUnseenNotif(String rid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_UNSEEN;
    map["rid"] = rid;
    final response = await http.post(Uri.parse(_NOTIFICATIONS),body: map);
    if(response.statusCode==200) {
      List<NotifModel> notif = notifFromJson(response.body);
      return notif;
    } else {
      return <NotifModel>[];
    }
  }

  // GET CURRENT USER
  Future<List<UserModel>> getCrntUsr(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT;
    map["uid"] = uid;
    final response = await http.post(Uri.parse(_USERS),body: map);
    if(response.statusCode==200) {
      List<UserModel> user = userFromJson(response.body);
      return user;
    } else {
      return <UserModel>[];
    }
  }

  // GET CURRENT ENTITY BY USER
  Future<List<EntityModel>> getCurrentEntity(String pid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT;
    map["pid"] = pid;
    final response = await http.post(Uri.parse(_ENTITY),body: map);

    if(response.statusCode==200) {
      List<EntityModel> entity = entityFromJson(response.body);
      return entity;
    } else {
      print("Error");
      return <EntityModel>[];
    }
  }

  // GET CURRENT PAYMENT BY USER
  Future<List<PaymentModel>> getCrrntPayments(String pid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT;
    map["pid"] = pid;
    final response = await http.post(Uri.parse(_PAYMENTS),body: map);
    if(response.statusCode==200) {
      List<PaymentModel> data = paymentsFromJson(response.body);
      return data;
    } else {
      print("Error");
      return <PaymentModel>[];
    }
  }

  // GET CURRENT SALES BY USER
  Future<List<SaleModel>> getCrrntSalesByUser(String pid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_BY_USER;
    map["pid"] = pid;
    final response = await http.post(Uri.parse(_SALE),body: map);
    if(response.statusCode==200) {
      List<SaleModel> data = saleFromJson(response.body);
      return data;
    } else {
      print("Error");
      return <SaleModel>[];
    }
  }
  // GET COMPLETE SALES BY ADMIN
  Future<List<SaleModel>> getSalesByAdmin(String pid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_ALL_BY_ADMIN;
    map["pid"] = pid;
    final response = await http.post(Uri.parse(_SALE),body: map);
    if(response.statusCode==200) {
      List<SaleModel> data = saleFromJson(response.body);
      return data;
    } else {
      print("Error");
      return <SaleModel>[];
    }
  }
  // GET COMPLETE SALES BY ADMIN
  Future<List<SaleModel>> getCmpSalesByAdmin(String pid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_BY_ADMIN;
    map["pid"] = pid;
    final response = await http.post(Uri.parse(_SALE),body: map);
    if(response.statusCode==200) {
      List<SaleModel> data = saleFromJson(response.body);
      return data;
    } else {
      print("Error");
      return <SaleModel>[];
    }
  }
  // GET RECEIVABLE BY ADMIN
  Future<List<SaleModel>> getRcvByAdmin(String pid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_REC_BY_ADMIN;
    map["pid"] = pid;
    final response = await http.post(Uri.parse(_SALE),body: map);
    if(response.statusCode==200) {
      List<SaleModel> data = saleFromJson(response.body);
      return data;
    } else {
      print("Error");
      return <SaleModel>[];
    }
  }

  // GET ONE ENTITY
  Future<List<EntityModel>> getOneEntity(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_ENTITY),body: map);
    if(response.statusCode==200) {
      List<EntityModel> entity = entityFromJson(response.body);
      return entity;
    } else {
      return <EntityModel>[];
    }
  }

  // GET CURRENT SUPPLIERS BY PID
  Future<List<SupplierModel>> getSpplByAdmin(String pid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_BY_ADMIN;
    map["pid"] = pid;
    final response = await http.post(Uri.parse(_SUPPLIERS),body: map);
    if(response.statusCode==200) {
      List<SupplierModel> suppliers = supplierFromJson(response.body);
      return suppliers;
    } else {
      return <SupplierModel>[];
    }
  }

  // GET CURRENT SUPPLIERS
  Future<List<SupplierModel>> getCrrntSuppliers(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_SUPPLIERS),body: map);
    if(response.statusCode==200) {
      List<SupplierModel> suppliers = supplierFromJson(response.body);
      return suppliers;
    } else {
      return <SupplierModel>[];
    }
  }

  // GET ONE SUPPLIER
  Future<List<SupplierModel>> getOneSuppliers(String sid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET;
    map["sid"] = sid;
    final response = await http.post(Uri.parse(_SUPPLIERS),body: map);
    if(response.statusCode==200) {
      List<SupplierModel> suppliers = supplierFromJson(response.body);
      return suppliers;
    } else {
      return <SupplierModel>[];
    }
  }

  // GET ALL SUPPLIER
  Future<List<SupplierModel>> getAllSuppliers()async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_ALL;
    final response = await http.post(Uri.parse(_SUPPLIERS),body: map);
    if(response.statusCode==200) {
      List<SupplierModel> suppliers = supplierFromJson(response.body);
      return suppliers;
    } else {
      return <SupplierModel>[];
    }
  }

  // GET ALL SUPPLIER
  Future<List<SupplierModel>> getMySuppliers(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["pid"] = uid;
    final response = await http.post(Uri.parse(_SUPPLIERS),body: map);
    if(response.statusCode==200) {
      List<SupplierModel> suppliers = supplierFromJson(response.body);
      return suppliers;
    } else {
      return <SupplierModel>[];
    }
  }

  // GET CURRENT INVENTORY
  Future<List<InventModel>> getCrntInv(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_INVENTORY),body: map);
    if(response.statusCode==200) {
      List<InventModel> invent = inventFromJson(response.body);
      return invent;
    } else {
      return <InventModel>[];
    }
  }

  // GET MY INVENTORY
  Future<List<InventModel>> getMyInv(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["pid"] = uid;
    final response = await http.post(Uri.parse(_INVENTORY),body: map);
    if(response.statusCode==200) {
      List<InventModel> invent = inventFromJson(response.body);
      return invent;
    } else {
      return <InventModel>[];
    }
  }

  // GET MY PAYMENTS
  Future<List<PaymentModel>> getMyPayments(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["pid"] = uid;
    final response = await http.post(Uri.parse(_PAYMENTS),body: map);
    if(response.statusCode==200) {
      List<PaymentModel> pay = paymentsFromJson(response.body);
      return pay;
    } else {
      return <PaymentModel>[];
    }
  }

  // GET CURRENT INVENTORY BY PURCHASE
  Future<List<InventModel>> getCrntInvByPurchase(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_PURCHASE;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_INVENTORY),body: map);
    if(response.statusCode==200) {
      List<InventModel> invent = inventFromJson(response.body);
      return invent;
    } else {
      return <InventModel>[];
    }
  }

  // GET CURRENT INVENTORY
  Future<List<InventModel>> getAllInv()async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_ALL;
    final response = await http.post(Uri.parse(_INVENTORY),body: map);
    if(response.statusCode==200) {
      List<InventModel> invent = inventFromJson(response.body);
      return invent;
    } else {
      return <InventModel>[];
    }
  }

  // GET NOTIFICATIONS BY ENTITY
  Future<List<NotifModel>> getNotifByEntity(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_BY_ENTITY;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_NOTIFICATIONS),body: map);
    if(response.statusCode==200) {
      List<NotifModel> notif = notifFromJson(response.body);
      return notif;
    } else {
      return <NotifModel>[];
    }
  }


  // GET INVENTORY BY PRODUCT
  Future<List<InventModel>> getInvByPrd(String productid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_BY_PRODUCT;
    map["productid"] = productid;
    final response = await http.post(Uri.parse(_INVENTORY),body: map);
    if(response.statusCode==200) {
      List<InventModel> invent = inventFromJson(response.body);
      return invent;
    } else {
      return <InventModel>[];
    }
  }

  // GET PURCHASE BY PRCID
  Future<List<PurchaseModel>> getPrchByPRCID(String prcid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_BY_PRCID;
    map["prcid"] = prcid;
    final response = await http.post(Uri.parse(_PURCHASE),body: map);
    if(response.statusCode==200) {
      List<PurchaseModel> purchase = purchaseFromJson(response.body);
      return purchase;
    } else {
      return <PurchaseModel>[];
    }
  }

  // GET PURCHASE BY PURCHASEID
  Future<List<PurchaseModel>> getPrchByPrchId(String purchaseid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_BY_PURCHASEID;
    map["purchaseid"] = purchaseid;
    final response = await http.post(Uri.parse(_PURCHASE),body: map);
    if(response.statusCode==200) {
      List<PurchaseModel> purchase = purchaseFromJson(response.body);
      return purchase;
    } else {
      return <PurchaseModel>[];
    }
  }

  // GET SALE BY SELEID
  Future<List<SaleModel>> getSaleByPrchId(String saleId)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_BY_SALEID;
    map["saleid"] = saleId;
    final response = await http.post(Uri.parse(_SALE),body: map);
    if(response.statusCode==200) {
      List<SaleModel> sale = saleFromJson(response.body);
      return sale;
    } else {
      return <SaleModel>[];
    }
  }

  // GET SALE BY SID
  Future<List<SaleModel>> getSaleBySid(String sid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_BY_SID;
    map["sid"] = sid;
    final response = await http.post(Uri.parse(_SALE),body: map);
    if(response.statusCode==200) {
      List<SaleModel> sale = saleFromJson(response.body);
      return sale;
    } else {
      return <SaleModel>[];
    }
  }

  // GET ONE PURCHASE
  Future<List<PurchaseModel>> getOnePurchase(String prcid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_ONE;
    map["prcid"] = prcid;
    final response = await http.post(Uri.parse(_PURCHASE),body: map);
    if(response.statusCode==200) {
      List<PurchaseModel> purchase = purchaseFromJson(response.body);
      return purchase;
    } else {
      return <PurchaseModel>[];
    }
  }

  // GET MY PURCHASE
  Future<List<PurchaseModel>> getMyPurchase(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["pid"] = uid;
    final response = await http.post(Uri.parse(_PURCHASE),body: map);
    if(response.statusCode==200) {
      List<PurchaseModel> purchase = purchaseFromJson(response.body);
      return purchase;
    } else {
      return <PurchaseModel>[];
    }
  }

  // GET ALL PURCHASE
  Future<List<PurchaseModel>> getAllPurchase()async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_ALL;
    final response = await http.post(Uri.parse(_PURCHASE),body: map);
    if(response.statusCode==200) {
      List<PurchaseModel> purchase = purchaseFromJson(response.body);
      return purchase;
    } else {
      return <PurchaseModel>[];
    }
  }

  // GET CURRENT PURCHASE
  Future<List<PurchaseModel>> getCrrntPrch(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_PURCHASE),body: map);
    if(response.statusCode==200) {
      List<PurchaseModel> purchase = purchaseFromJson(response.body);
      return purchase;
    } else {
      return <PurchaseModel>[];
    }
  }

  // GET CURRENT COMPLETE PURCHASE
  Future<List<PurchaseModel>> getCmptPrch(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_COMPLETE;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_PURCHASE),body: map);
    if(response.statusCode==200) {
      List<PurchaseModel> purchase = purchaseFromJson(response.body);
      return purchase;
    } else {
      return <PurchaseModel>[];
    }
  }

  // GET COMPLETE PURCHASE BY ADMIN
  Future<List<PurchaseModel>> getPrchByAdmin(String pid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_BY_ADMIN;
    map["pid"] = pid;
    final response = await http.post(Uri.parse(_PURCHASE),body: map);
    if(response.statusCode==200) {
      List<PurchaseModel> purchase = purchaseFromJson(response.body);
      return purchase;
    } else {
      return <PurchaseModel>[];
    }
  }

  // GET CURRENT COMPLETE SALE
  Future<List<SaleModel>> getCmptSale(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_COMPLETE;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_SALE),body: map);
    if(response.statusCode==200) {
      List<SaleModel> sale = saleFromJson(response.body);
      return sale;
    } else {
      return <SaleModel>[];
    }
  }

  // GET MY SALES
  Future<List<SaleModel>> getMySale(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["pid"] = uid;
    final response = await http.post(Uri.parse(_SALE),body: map);
    if(response.statusCode==200) {
      List<SaleModel> sale = saleFromJson(response.body);
      return sale;
    } else {
      return <SaleModel>[];
    }
  }

  // GET CURRENT SALE
  Future<List<SaleModel>> getCrrntSale(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_SALE),body: map);
    if(response.statusCode==200) {
      List<SaleModel> sale = saleFromJson(response.body);
      return sale;
    } else {
      return <SaleModel>[];
    }
  }

  // GET CURRENT RECEIVABLE
  Future<List<SaleModel>> getReceivable(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_RECEIVABLE;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_SALE),body: map);
    if(response.statusCode==200) {
      List<SaleModel> sale = saleFromJson(response.body);
      return sale;
    } else {
      return <SaleModel>[];
    }
  }
// GET CURRENT PAYABLE
  Future<List<PurchaseModel>> getPayableByAdmin(String pid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_PAYABLE0_BY_ADMIN;
    map["pid"] = pid;
    final response = await http.post(Uri.parse(_PURCHASE),body: map);
    if(response.statusCode==200) {
      List<PurchaseModel> purchase = purchaseFromJson(response.body);
      return purchase;
    } else {
      return <PurchaseModel>[];
    }
  }

  // GET CURRENT PAYABLE
  Future<List<PurchaseModel>> getPayable(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_PAYABLE;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_PURCHASE),body: map);
    if(response.statusCode==200) {
      List<PurchaseModel> purchase = purchaseFromJson(response.body);
      return purchase;
    } else {
      return <PurchaseModel>[];
    }
  }

  // GET PURCHASE BY PRODUCTID
  Future<List<PurchaseModel>> getPrchbyProductId(String purchaseid, String productid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_PRODUCTID;
    map["purchaseid"] = purchaseid;
    map["productid"] = productid;
    final response = await http.post(Uri.parse(_PURCHASE),body: map);
    if(response.statusCode==200) {
      List<PurchaseModel> purchase = purchaseFromJson(response.body);
      return purchase;
    } else {
      return <PurchaseModel>[];
    }
  }

  // GET SALE BY PRODUCTID
  Future<List<SaleModel>> getSalebyProductId(String saleid, String productid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_PRODUCTID;
    map["saleid"] = saleid;
    map["productid"] = productid;
    final response = await http.post(Uri.parse(_SALE),body: map);
    if(response.statusCode==200) {
      List<SaleModel> sale = saleFromJson(response.body);
      return sale;
    } else {
      return <SaleModel>[];
    }
  }



  // GET CURRENT PRODUCT
  Future<List<ProductModel>> getCrntPrdct(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_PRODUCTS),body: map);
    if(response.statusCode==200) {
      List<ProductModel> product = productsFromJson(response.body);
      return product;
    } else {
      return <ProductModel>[];
    }
  }

  // GET MY PRODUCT
  Future<List<ProductModel>> getMyPrdct(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["pid"] = uid;
    final response = await http.post(Uri.parse(_PRODUCTS),body: map);
    if(response.statusCode==200) {
      List<ProductModel> product = productsFromJson(response.body);
      return product;
    } else {
      return <ProductModel>[];
    }
  }

  // GET PAYMENT BY ENTITY
  Future<List<PaymentModel>> getPayByEntity(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_BY_ENTITY;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_PAYMENTS),body: map);
    if(response.statusCode==200) {
      List<PaymentModel> data = paymentsFromJson(response.body);
      return data;
    } else {
      return <PaymentModel>[];
    }
  }

  // REGISTER USER
  static Future registerUsers(String uid, String username, String first, String last, String email, String phone,
      String password,  File? image, String status, String url, String token, String country) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_USERS));
      request.fields['action'] = _REGISTER;
      request.fields['uid'] = uid;
      request.fields['username'] = username;
      request.fields['first'] = first;
      request.fields['last'] = last;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['password'] = password;
      request.fields['status'] = status;
      request.fields['token'] = token;
      request.fields['country'] = country;
      if (image != null) {
        var pic = await http.MultipartFile.fromPath("image", image.path);
        request.files.add(pic);
      } else {
        request.fields['image'] = url;
      }
      var response = await request.send();
      return response;
    } catch (e) {
      return 'error';
    }
  }

  // ADD NOTIFICATION
  static Future<String> addNotification(NotifModel notif) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["nid"] = notif.nid;
      map["sid"] = notif.sid;
      map["rid"] = notif.rid;
      map["pid"] = notif.pid;
      map["eid"] = notif.eid;
      map["text"] = notif.text;
      map["message"] = notif.message;
      map["actions"] = notif.actions;
      map["type"] = notif.type;
      map["seen"] = notif.seen;
      final response = await http.post(Uri.parse(_NOTIFICATIONS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // ADD DUTIES
  static Future<String> addDuties(String did, String eid, String pid, List duties) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["did"] = did;
      map["pid"] = pid;
      map["eid"] = eid;
      map["duties"] = duties.join(',');
      final response = await http.post(Uri.parse(_DUTIES), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // ADD INVENTORY
  static Future<String> addInventory(InventModel invent) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["iid"] = invent.iid;
      map["pid"] = invent.pid;
      map["eid"] = invent.eid;
      map["productId"] = invent.productid;
      map["quantity"] = invent.quantity;
      map["type"] = invent.type;
      final response = await http.post(Uri.parse(_INVENTORY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // ADD PAYMENT
  static Future<String> addPayment(PaymentModel payment) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["payid"] = payment.payid;
      map["eid"] = payment.eid;
      map["pid"] = payment.pid;
      map["payerid"] = payment.payerid;
      map["admin"] = payment.admin;
      map["saleid"] = payment.saleid;
      map["purchaseid"] = payment.purchaseid;
      map["items"] = payment.items;
      map["amount"] = payment.amount;
      map["paid"] = payment.paid;
      map["type"] = payment.type;
      map["method"] = payment.method;
      map["time"] = payment.time;
      final response = await http.post(Uri.parse(_PAYMENTS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // ADD PURCHASE
  static Future<String> addPurchase(PurchaseModel purchase) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["purchaseid"] = purchase.purchaseid;
      map["productid"] = purchase.productid;
      map["prcid"] = purchase.prcid;
      map["eid"] = purchase.eid;
      map["pid"] = purchase.pid;
      map["purchaser"] = purchase.purchaser;
      map["bprice"] = purchase.bprice;
      map["paid"] = purchase.paid;
      map["amount"] = purchase.amount;
      map["quantity"] = purchase.quantity;
      map["due"] = purchase.due;
      map["date"] = purchase.date;
      map["type"] = purchase.type;
      final response = await http.post(Uri.parse(_PURCHASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // ADD SALE
  static Future<String> addSale(SaleModel sale) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["saleid"] = sale.saleid;
      map["sid"] = sale.sid;
      map["iid"] = sale.iid;
      map["eid"] = sale.eid;
      map["pid"] = sale.pid;
      map["sellerid"] = sale.sellerid;
      map["productid"] = sale.productid;
      map["customer"] = sale.customer;
      map["phone"] = sale.phone;
      map["bprice"] = sale.bprice;
      map["sprice"] = sale.sprice;
      map["amount"] = sale.amount;
      map["paid"] = sale.paid;
      map["method"] = sale.method;
      map["quantity"] = sale.quantity;
      map["due"] = sale.due;
      map["date"] = sale.date;
      final response = await http.post(Uri.parse(_SALE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // ADD_PRODUCT
  static Future<String> addProduct(ProductModel product) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["prid"] = product.prid;
      map["pid"] = product.pid;
      map["eid"] = product.eid;
      map["name"] = product.name;
      map["category"] = product.category;
      map["quantity"] = product.quantity;
      map["volume"] = product.volume;
      map["supplier"] = product.supplier;
      map["buying"] = product.buying;
      map["selling"] = product.selling;
      map["type"] = product.type;
      final response = await http.post(Uri.parse(_PRODUCTS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // ADD SUPPLIER
  static Future<String> addSupplier(SupplierModel supplier) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["sid"] = supplier.sid;
      map["pid"] = supplier.pid;
      map["eid"] = supplier.eid;
      map["name"] = supplier.name;
      map["category"] = supplier.category;
      map["company"] = supplier.company;
      map["phone"] = supplier.phone;
      map["email"] = supplier.email;
      final response = await http.post(Uri.parse(_SUPPLIERS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // LOGIN USERS
  static Future<String> loginUsers(String email, String password) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _LOGIN;
      map["email"] = email;
      map["password"] = password;
      final response = await http.post(Uri.parse(_USERS), body: map);
      return response.body;
    } catch (e) {
      return 'error : ${e}';
    }
  }
  // LOGIN USERS WITH EMAIL
  static Future<String> loginUserWithEmail(String email) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _LOGIN_EMAIL;
      map["email"] = email;
      final response = await http.post(Uri.parse(_USERS), body: map);
      return response.body;
    } catch (e) {
      return 'error : ${e}';
    }
  }

  // ADD_ENTITY
  static Future addEntity(String eid, List pid, String title, String category, File? image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_ENTITY));
      request.fields['action'] = _ADD;
      request.fields['eid'] = eid;
      request.fields['pid'] = pid.join(',');
      request.fields['admin'] = currentUser.uid;
      request.fields['title'] = title;
      request.fields['category'] = category;
      if (image != null) {
        var pic = await http.MultipartFile.fromPath("image", image.path);
        request.files.add(pic);
      } else {
        request.fields['image'] = "";
      }
      var response = await request.send();
      return response;
    } catch (e) {
      return 'error';
    }
  }

  // REMOVE MANAGER FROM PAYMENT
  static Future<String> rmvUsrFrmPymnt(String eid, List pid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _REMOVE_USER;
      map["eid"] = eid;
      map["pid"] =  pid.join(',');
      final response = await http.post(Uri.parse(_PAYMENTS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // REMOVE MANAGER FROM SALES
  static Future<String> rmvUsrFrmSale(String eid, List pid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _REMOVE_USER;
      map["eid"] = eid;
      map["pid"] =  pid.join(',');
      final response = await http.post(Uri.parse(_SALE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE USER PHONE NUMBER
  static Future updatePhone(String phone) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_PHONE;
      map["uid"] = currentUser.uid;
      map["phone"] = phone;
      final response = await http.post(Uri.parse(_USERS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE USER EMAIL ADDRESS
  static Future updateEmail(String email) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_EMAIL;
      map["uid"] = currentUser.uid;
      map["email"] = email;
      final response = await http.post(Uri.parse(_USERS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE USER PASSWORD
  static Future<String> updatePassword(String uid,String password) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_PASS;
      map["uid"] = uid;
      map["password"] = password;
      final response = await http.post(Uri.parse(_USERS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE INVENTORY
  static Future<String> updateInventory(InventModel invent) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE;
      map["iid"] = invent.iid.toString();
      map["quantity"] = invent.quantity.toString();
      map["type"] = invent.type.toString();
      final response = await http.post(Uri.parse(_INVENTORY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE INVENTORY QUANTITY
  static Future<String> updateInvQnty(String productid, String quantity) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_QUANTITY;
      map["productid"] = productid;
      map["quantity"] = quantity;
      final response = await http.post(Uri.parse(_INVENTORY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE INVENTORY QUANTITY
  static Future<String> updateInvSubQnty(String productid, String quantity) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_SUB_QNTY;
      map["productid"] = productid;
      map["quantity"] = quantity;
      final response = await http.post(Uri.parse(_INVENTORY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE INVENTORY QUANTITY
  static Future<String> updateInvAddQnty(String productid, String quantity) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_ADD_QNTY;
      map["productid"] = productid;
      map["quantity"] = quantity;
      final response = await http.post(Uri.parse(_INVENTORY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE INVENTORY DIFF QUANTITY
  static Future<String> updateInvDiffQnty(String productid, String quantity) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_DIFF_QNTY;
      map["productid"] = productid;
      map["quantity"] = quantity;
      final response = await http.post(Uri.parse(_INVENTORY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE INVENTORY BY PRODUCT ID
  static Future<String> updateInvByPrdId(String productId, String quantity) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE;
      map["productId"] = productId;
      map["quantity"] = quantity;
      final response = await http.post(Uri.parse(_INVENTORY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE PRODUCT
  static Future<String> updateProduct(ProductModel product) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE;
      map["prid"] = product.prid.toString();
      map["name"] = product.name.toString();
      map["category"] = product.category.toString();
      map["quantity"] = product.quantity.toString();
      map["volume"] = product.volume.toString();
      map["type"] = product.type.toString();
      map["supplier"] = product.supplier.toString();
      map["buying"] = product.buying.toString();
      map["selling"] = product.selling.toString();
      final response = await http.post(Uri.parse(_PRODUCTS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE SUPPLIER
  static Future<String> updateSupplier(SupplierModel supplier) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE;
      map["sid"] = supplier.sid.toString();
      map["name"] = supplier.name.toString();
      map["category"] = supplier.category.toString();
      map["company"] = supplier.company .toString();
      map["phone"] = supplier.phone.toString();
      map["email"] = supplier.email.toString();
      final response = await http.post(Uri.parse(_SUPPLIERS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE NOTIFICATION
  static Future<String> updateNotification(NotifModel notif) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE;
      map["nid"] = notif.nid.toString();
      map["text"] = notif.text.toString();
      map["type"] = notif.type.toString();
      map["actions"] = notif.actions.toString();
      final response = await http.post(Uri.parse(_NOTIFICATIONS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE SEEN NOTIFICATION
  static Future<String> updateSeenNotif() async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_SEEN;
      map["rid"] = currentUser.uid;
      map["seen"] = "SEEN";
      final response = await http.post(Uri.parse(_NOTIFICATIONS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE NOTIFICATION DELETE
  static Future<String> updateNotifDel(String nid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_DELETE;
      map["nid"] = nid;
      map["uid"] = currentUser.uid;
      final response = await http.post(Uri.parse(_NOTIFICATIONS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE NOTIFICATION SEEN
  static Future<String> updateNotifSeen(String nid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_SEEN;
      map["nid"] = nid;
      map["uid"] = currentUser.uid;
      final response = await http.post(Uri.parse(_NOTIFICATIONS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE PURCHASE AMOUNT
  static Future<String> updatePrchAmount(String purchaseid, String paid, String amount, String due, String type, String date) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_AMOUNT;
      map["purchaseid"] = purchaseid;
      map["paid"] = paid;
      map["amount"] = amount;
      map["due"] = due;
      map["type"] = type;
      map["date"] = date;
      final response = await http.post(Uri.parse(_PURCHASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE SALE
  static Future<String> updateSale(SaleModel sale) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE;
      map["sid"] = sale.sid;
      map["paid"] = sale.paid;
      map["method"] = sale.method;
      map["amount"] = sale.amount;
      map["due"] = sale.due;
      map["customer"] = sale.customer;
      map["phone"] = sale.phone;
      map["date"] = sale.date;
      map["quantity"] = sale.quantity;
      map["bprice"] = sale.bprice;
      map["sprice"] = sale.sprice;
      final response = await http.post(Uri.parse(_SALE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }


  // UPDATE SALE AMOUNT
  static Future<String> updateSalesAmount(String saleId, String paid, String amount, String due, String customer, String phone, String method, String date) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_AMOUNT;
      map["saleid"] = saleId;
      map["paid"] = paid;
      map["method"] = method;
      map["amount"] = amount;
      map["due"] = due;
      map["customer"] = customer;
      map["phone"] = phone;
      map["date"] = date;
      final response = await http.post(Uri.parse(_SALE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE SALE ONE AMOUNT
  static Future<String> updateSaleOneAmount(String saleId, String amount) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_SALE_AMOUNT;
      map["saleid"] = saleId;
      map["amount"] = amount;
      final response = await http.post(Uri.parse(_SALE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE SALE ONE AMOUNT
  static Future<String> updateOneSalePrice(String sid, String sprice) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_SPRICE;
      map["sid"] = sid;
      map["sprice"] = sprice;
      final response = await http.post(Uri.parse(_SALE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE ALL PURCHASE  AMOUNT
  static Future<String> updateAllPrchAmount(String purchaseid, String amount) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_ALL_AMOUNT;
      map["purchaseid"] = purchaseid;
      map["amount"] = amount;
      final response = await http.post(Uri.parse(_PURCHASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

    // UPDATE SALE ONE QUANTITY
  static Future<String> updateOneQnty(String sid, String quantity) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_ONE_QUANTITY;
      map["sid"] = sid;
      map["quantity"] = quantity;
      final response = await http.post(Uri.parse(_SALE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE ONE PURCHASE QUANTITY
  static Future<String> updateOnePrchQnty(String prcid, String quantity) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_ONE_QUANTITY;
      map["prcid"] = prcid;
      map["quantity"] = quantity;
      final response = await http.post(Uri.parse(_PURCHASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE SALE PAID
  static Future<String> updateSalePaid(String saleId, String paid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_PAID;
      map["saleid"] = saleId;
      map["paid"] = paid;
      final response = await http.post(Uri.parse(_SALE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE PURCHASE PAYMENT AMOUNT
  static Future<String> updatePrchPayAmount(String purchaseid, String amount, String type,  String items) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_PURCHASE_AMOUNT;
      map["purchaseid"] = purchaseid;
      map["amount"] = amount;
      map["type"] = type;
      map["items"] = items;
      final response = await http.post(Uri.parse(_PAYMENTS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE PURCHASE PAYMENT AMOUNT
  static Future<String> updatePrchPayPaid(String purchaseid, String paid, String type, String method) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_PURCHASE_PAID;
      map["purchaseid"] = purchaseid;
      map["paid"] = paid;
      map["type"] = type;
      map["method"] = method;
      final response = await http.post(Uri.parse(_PAYMENTS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }


  // UPDATE SALE PAYMENT AMOUNT
  static Future<String> updateSalePayAmount(String saleid, String amount, String type,String items) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_SALE_AMOUNT;
      map["saleid"] = saleid;
      map["amount"] = amount;
      map["type"] = type;
      map["items"] = items;
      final response = await http.post(Uri.parse(_PAYMENTS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE PURCHASE
  static Future<String> updatePurchase(PurchaseModel purchase) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE;
      map["prcid"] = purchase.prcid;
      map["bprice"] = purchase.bprice;
      map["amount"] = purchase.amount;
      map["paid"] = purchase.paid;
      map["quantity"] = purchase.quantity;
      map["type"] = purchase.type;
      map["date"] = purchase.date;
      map["due"] = purchase.due;
      final response = await http.post(Uri.parse(_PURCHASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE PURCHASE PAID
  static Future<String> updatePrchPaid(String purchaseid, String paid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_PAID;
      map["purchaseid"] = purchaseid;
      map["paid"] = paid;
      final response = await http.post(Uri.parse(_PURCHASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE CREATE PURCHASE QUANTITY
  static Future<String> updtCrtPrchsQnty(String purchaseid, String productid, String quantity, String amount) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_QUANTITY;
      map["purchaseid"] = purchaseid;
      map["productid"] = productid;
      map["quantity"] = quantity;
      map["amount"] = amount;
      final response = await http.post(Uri.parse(_PURCHASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE CREATE SALE QUANTITY
  static Future<String> updtCrtSaleQnty(String saleid, String productid, String quantity) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_QUANTITY;
      map["saleid"] = saleid;
      map["productid"] = productid;
      map["quantity"] = quantity;
      final response = await http.post(Uri.parse(_SALE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
// UPDATE ADMIN
  static Future<String> updateAdmin(String eid, String uid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_ADMIN;
      map["eid"] = eid;
      map["uid"] = uid;
      final response = await http.post(Uri.parse(_ENTITY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  //REMOVE ADMIN
  static Future<String> removeAdmin(String eid, String uid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _REMOVE_ADMIN;
      map["eid"] = eid;
      map["uid"] = uid;
      final response = await http.post(Uri.parse(_ENTITY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE ENTITY
  static Future updateEntity(String eid, List pid, String title, String category, File? image, String oldImage) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_ENTITY));
      request.fields['action'] = _UPDATE;
      request.fields['eid'] = eid;
      request.fields['pid'] = pid.join(',');
      request.fields['title'] = title;
      request.fields['category'] = category;
      if (image != null) {
        var pic = await http.MultipartFile.fromPath("image", image.path);
        request.files.add(pic);
      } else {
        request.fields['image'] = oldImage;
      }
      var response = await request.send();
      return response;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE ENTITY PID
  static Future updateEntityPID(String eid, List pid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_PID;
      map["eid"] = eid;
      map["pid"] = pid.join(',');
      final response = await http.post(Uri.parse(_ENTITY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE DUTIES
  static Future<String> updateDuties(String did,List duties) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE;
      map["did"] = did;
      map["duties"] = duties.join(',');
      final response = await http.post(Uri.parse(_DUTIES), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE USER TOKEN
  static Future<String> updateToken(String uid,String token) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_TOKEN;
      map["uid"] = uid;
      map["token"] = token;
      final response = await http.post(Uri.parse(_USERS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // REGISTER USER
  static Future updateProfile(String username, String first, String last, File? image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_USERS));
      request.fields['action'] = _UPDATE_PROFILE;
      request.fields['uid'] = currentUser.uid;
      request.fields['username'] = username;
      request.fields['first'] = first;
      request.fields['last'] = last;
      if (image != null) {
        var pic = await http.MultipartFile.fromPath("image", image.path);
        request.files.add(pic);
      } else {
        request.fields['image'] = "";
      }
      var response = await request.send();
      return response;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE ONE INVENTORY
  static Future<String> deleteInventory(String iid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE;
      map["iid"] = iid;
      final response = await http.post(Uri.parse(_INVENTORY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE INVENTORY BY EID
  static Future<String> deleteInvByEid(String eid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_EID;
      map["eid"] = eid;
      final response = await http.post(Uri.parse(_INVENTORY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

// DELETE ENTITY
  static Future<String> deleteEntity(String eid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE;
      map["eid"] = eid;
      final response = await http.post(Uri.parse(_ENTITY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE ONE PRODUCT
  static Future<String> deleteProduct(String prid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE;
      map["prid"] = prid;
      final response = await http.post(Uri.parse(_PRODUCTS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE PRODUCT BY EID
  static Future<String> deletePrdctByEid(String eid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_EID;
      map["eid"] = eid;
      final response = await http.post(Uri.parse(_PRODUCTS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE ONE SUPPLIER
  static Future<String> deleteSupplier(String sid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE;
      map["sid"] = sid;
      final response = await http.post(Uri.parse(_SUPPLIERS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE SUPPLIER BY EID
  static Future<String> deleteSpplrByEid(String eid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_EID;
      map["eid"] = eid;
      final response = await http.post(Uri.parse(_SUPPLIERS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE PURCHASE
  static Future<String> deletePurchase(String purchaseid,String productid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE;
      map["purchaseid"] = purchaseid;
      map["productid"] = productid;
      final response = await http.post(Uri.parse(_PURCHASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE PURCHASE BY EID
  static Future<String> deletePrchByEid (String eid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_EID;
      map["eid"] = eid;
      final response = await http.post(Uri.parse(_PURCHASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE PURCHASE BY PRCID
  static Future<String> deletePrcByPrcId(String prcid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_PRCID;
      map["prcid"] = prcid;
      final response = await http.post(Uri.parse(_PURCHASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE PURCHASE BY PURCHASEID
  static Future<String> deletePrchByPrchId(String purchaseid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_PRCHID;
      map["purchaseid"] = purchaseid;
      final response = await http.post(Uri.parse(_PURCHASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE SALE
  static Future<String> deleteSale(String saleid,String productid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE;
      map["saleid"] = saleid;
      map["productid"] = productid;
      final response = await http.post(Uri.parse(_SALE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE SALE BY SID
  static Future<String> deleteSaleBySid(String sid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_SID;
      map["sid"] = sid;
      final response = await http.post(Uri.parse(_SALE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE SALE BY SALEID
  static Future<String> deleteSaleBySaleId(String saleid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_SALEID;
      map["saleid"] = saleid;
      final response = await http.post(Uri.parse(_SALE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE SALE BY EID
  static Future<String> deleteSaleByEid(String eid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_EID;
      map["eid"] = eid;
      final response = await http.post(Uri.parse(_SALE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE DUTIES BY EID
  static Future<String> deleteDutityByEid(String eid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_EID;
      map["eid"] = eid;
      final response = await http.post(Uri.parse(_DUTIES), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE NOTIFICATION
  static Future<String> deleteNotif(String nid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE;
      map["nid"] = nid;
      final response = await http.post(Uri.parse(_NOTIFICATIONS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE NOTIFICATION BY EID
  static Future<String> deleteNotifByEid(String eid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_EID;
      map["eid"] = eid;
      final response = await http.post(Uri.parse(_NOTIFICATIONS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE PAYMENTS BY SALEID
  static Future<String> deletePayBySaleId(String saleid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_SALEID;
      map["saleid"] = saleid;
      final response = await http.post(Uri.parse(_PAYMENTS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE PAYMENTS BY PURCHASEID
  static Future<String> deletePayByPurchaseId(String purchaseid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_PRCHID;
      map["purchaseid"] = purchaseid;
      final response = await http.post(Uri.parse(_PAYMENTS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // DELETE PAYMENTS BY EID
  static Future<String> deletePayByEid(String eid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE_EID;
      map["eid"] = eid;
      final response = await http.post(Uri.parse(_PAYMENTS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

}