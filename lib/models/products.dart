class ProductModel {
  String prid;
  String? eid;
  String? pid;
  String? name;
  String? category;
  String? quantity;
  String? volume;
  String? type;
  String? supplier;
  String? buying;
  String? selling;
  String? time;
  String? checked;
  bool isChecked;

  ProductModel({required this.prid, this.eid, this.pid, this.name, this.category, this.quantity, this.volume, this.type, this.supplier,this.buying,this.selling, this.time,
    this.checked, this.isChecked = false});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      prid: json['prid'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as String,
      volume: json['volume'] as String,
      type: json['type'] as String,
      supplier: json['supplier'] as String,
      buying: json['buying'] as String,
      selling: json['selling'] as String,
      checked: json['checked'] as String,
      time: json['time'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'prid': prid,
      'eid': eid,
      'pid': pid,
      'name': name,
      'category': category,
      'quantity': quantity,
      'volume': volume,
      'type': type,
      'supplier': supplier,
      'buying': buying,
      'selling': selling,
      'checked': checked,
      'time': time,
    };
  }
}