import 'dart:convert';

import 'package:TallyApp/Widget/text/text_format.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/suppliers.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:uuid/uuid.dart';

import '../../models/products.dart';
import '../../utils/colors.dart';

class ItemProducts extends StatefulWidget {
  final ProductModel product;
  final String eid;
  const ItemProducts({super.key, required this.product, required this.eid,});

  @override
  State<ItemProducts> createState() => _ItemProductsState();
}

class _ItemProductsState extends State<ItemProducts> {
  List<SupplierModel> _spplr = [];
  String iid = "";
  String name = "";
  String category = "";
  String volume = "";
  String supplier = "";

  bool _adding = false;
  bool _loading = false;
  bool _checked = false;

  _getSuppliers()async{
    _spplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _spplr = _spplr.where((sup) => sup.sid == widget.product.supplier).toList();
    name = TFormat().decryptField(widget.product.name.toString(), widget.product.eid.toString());
    category = TFormat().decryptField(widget.product.category.toString(), widget.product.eid.toString());
    volume = TFormat().decryptField(widget.product.volume.toString(), widget.product.eid.toString());
    supplier = _spplr.isEmpty ? 'Supplier not available' :  TFormat().decryptField(_spplr.first.name.toString(), widget.product.eid.toString());
    setState(() {

    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    const uuid = Uuid();
    iid = uuid.v1();
    _getSuppliers();
  }
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white12,
              child: Center(child: LineIcon.box(color: Colors.white,)),
            ),
            SizedBox(width: 10,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(name.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
                      SizedBox(width: 10,),
                      Text('${category}', style: TextStyle(color: Colors.white54, fontSize: 11),),
                    ],
                  ),
                  Wrap(
                    spacing: 5,
                    children: [
                      Text("Volume : ${volume}",style: TextStyle(fontSize: 11, color: Colors.white)),
                      _loading
                          ? Text('Loading Suppliers...', style: TextStyle(fontSize: 11, color: secondaryColor, fontStyle: FontStyle.italic),)
                          : Text('Supplier : ${supplier}', style: TextStyle(fontSize: 11, color: Colors.white),)
                    ],
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
