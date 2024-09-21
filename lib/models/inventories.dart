class InventModel {
  String iid;
  String? eid;
  String? pid;
  String? productid;
  String? quantity;
  String? type;
  String? time;
  String? checked;

  InventModel({required this.iid, this.eid, this.pid, this.productid, this.quantity, this.time, this.type, this.checked});

  factory InventModel.fromJson(Map<String, dynamic> json) {
    return InventModel(
      iid: json['iid'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      productid: json['productid'] as String,
      quantity: json['quantity'] as String,
      type: json['type'] as String,
      checked: json['checked'] as String,
      time: json['time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "iid" : iid,
      "eid" : eid,
      "pid" : pid,
      "productid" : productid,
      "quantity" : quantity,
      "type" : type,
      "checked":checked,
      "time":time,
    };
  }
}