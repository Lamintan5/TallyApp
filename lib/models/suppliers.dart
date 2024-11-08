class SupplierModel {
  String sid;
  String? eid;
  String? pid;
  String? name;
  String? category;
  String? company;
  String? phone;
  String? email;
  String? time;
  String? checked;

  SupplierModel({required this.sid, this.eid, this.pid, this.name, this.category, this.company, this.phone, this.email, this.time, this.checked});

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      sid: json['sid'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      company: json['company'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      time: json['time'] as String,
      checked: json['checked'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'sid': sid,
      'eid': eid,
      'pid': pid,
      'name': name,
      'category': category,
      'company': company,
      'phone': phone,
      'email': email,
      'time': time,
      'checked': checked,
    };
  }
  Map<String, dynamic> toUpdate() {
    return {
      'name': name,
      'category': category,
      'company': company,
      'phone': phone,
      'email': email,
      'checked': checked,
    };
  }
}