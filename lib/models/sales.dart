class SaleModel {
  String saleid;
  String? amount;
  String? sid;
  String? iid;
  String? eid;
  String? pid;
  String? sellerid;
  String? productid;
  String? quantity;
  String? customer;
  String? phone;
  String? bprice;
  String? sprice;
  String? paid;
  String? method;
  String? due;
  String? date;
  String? time;
  String? checked;

  @override
  int get hashCode => saleid.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SaleModel && runtimeType == other.runtimeType && saleid == other.saleid;

  SaleModel({required this.saleid, this.amount,  this.customer, this.phone, this.sid, this.iid,this.eid, this.pid, this.sellerid, this.productid,this.time, this.sprice, this.quantity,
    this.paid, this.method, this.bprice, this.due, this.date, this.checked});

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      saleid: json['saleid'] as String,
      sid: json['sid'] as String,
      iid: json['iid'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      sellerid: json['sellerid'] as String,
      productid: json['productid'] as String,
      quantity: json['quantity'] as String,
      amount: json['amount'] as String,
      paid: json['paid'] as String,
      method: json['method'] as String,
      customer: json['customer'] as String,
      phone: json['phone'] as String,
      sprice: json['sprice'] as String,
      bprice: json['bprice'] as String,
      due: json['due'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      checked: json['checked'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'saleid': saleid,
      'sid': sid,
      'iid': iid,
      'eid': eid,
      'pid': pid,
      'sellerid': sellerid,
      'productid': productid,
      'quantity': quantity,
      'amount': amount,
      'paid': paid,
      'method': method,
      'customer': customer,
      'phone': phone,
      'sprice': sprice,
      'bprice': bprice,
      'due': due,
      'date': date,
      'time': time,
      'checked': checked,
    };
  }
}