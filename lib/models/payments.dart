class PaymentModel {
  String payid;
  String? eid;
  String? pid;
  String? payerid;
  String? admin;
  String? saleid;
  String? purchaseid;
  String? items;
  String? type;
  String? method;
  String? amount;
  String? paid;
  String? checked;
  String? time;

  PaymentModel({required this.payid, this.eid, this.pid, this.payerid, this.admin,  this.method, this.saleid, this.purchaseid, this.items, this.type, this.amount,
    this.paid, this.checked,this.time});

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      payid: json['payid'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      payerid: json['payerid'] as String,
      admin: json['admin'] as String,
      saleid: json['saleid'] as String,
      purchaseid: json['purchaseid'] as String,
      items: json['items'] as String,
      amount: json['amount'] as String,
      paid: json['paid'] as String,
      type: json['type'] as String,
      method: json['method'] as String,
      checked: json['checked'] as String,
      time: json['time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "payid" : payid,
      "eid" : eid,
      "pid" : pid,
      "payerid" : payerid,
      "admin" : admin,
      "saleid" : saleid,
      "purchaseid":purchaseid,
      "items":items,
      "amount":amount,
      "paid":paid,
      "type":type,
      "method":method,
      "checked":checked,
      "time":time,
    };
  }
}
