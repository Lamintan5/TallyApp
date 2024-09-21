class PurchaseModel {
  String purchaseid;
  String? amount;
  String? prcid;
  String? eid;
  String? pid;
  String? purchaser;
  String? productid;
  String? quantity;
  String? bprice;
  String? paid;
  String? time;
  String? type;
  String? date;
  String? due;
  String? checked;

  @override
  int get hashCode => purchaseid.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PurchaseModel && runtimeType == other.runtimeType && purchaseid == other.purchaseid;


  PurchaseModel({required this.purchaseid, this.prcid, this.eid, this.pid, this.purchaser, this.productid,this.time, this.date, this.due, this.amount, this.type,this.quantity, this.paid, this.bprice, this.checked});

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      purchaseid: json['purchaseid'] as String,
      prcid: json['prcid'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      purchaser: json['purchaser'] as String,
      productid: json['productid'] as String,
      quantity: json['quantity'] as String,
      paid: json['paid'] as String,
      amount: json['amount'] as String,
      bprice: json['bprice'] as String,
      due: json['due'] as String,
      date: json['date'] as String,
      type: json['type'] as String,
      checked: json['checked'] as String,
      time: json['time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "purchaseid" : purchaseid,
      "prcid" : prcid,
      "eid" : eid,
      "pid" : pid,
      "purchaser" : purchaser,
      "productid" : productid,
      "quantity" : quantity,
      "paid":paid,
      "amount":amount,
      "bprice":bprice,
      "due":due,
      "date":date,
      "type":type,
      "checked":checked,
      "time":time,
    };
  }
}