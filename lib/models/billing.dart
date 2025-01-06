
class BillingModel {
  String bid;
  String? eid;
  String? pid;
  String? bill;
  String? businessno;
  String? phone;
  String? tillno;
  String? accountno;
  String? type;
  String? account;
  String? time;
  String? checked;

  BillingModel({required this.bid, this.eid, this.pid, this.bill, this.businessno, this.phone,
    this.tillno, this.type, this.account,  this.accountno,  this.time, this.checked});

  factory BillingModel.fromJson(Map<String, dynamic> json) {
    return BillingModel(
      bid: json['bid'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      bill: json['bill'] as String,
      businessno: json['businessno'] as String,
      phone: json['phone'] as String,
      tillno: json['tillno'] as String,
      accountno: json['accountno'] as String,
      type: json['type'] as String,
      account: json['account'] as String,
      checked: json['checked'] as String,
      time: json['time'] as String,

    );
  }
  Map<String, dynamic> toJson() {
    return {
      'bid': bid,
      'eid': eid,
      'pid': pid,
      'bill': bill,
      'businessno': businessno,
      'phone':phone,
      'tillno':tillno,
      'accountno': accountno,
      'type': type,
      'account': account,
      'checked': checked,
      'time': time,
    };
  }
}