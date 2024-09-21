import 'dart:convert';

import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:flutter/material.dart';

import '../../../models/suppliers.dart';
import '../../../utils/colors.dart';
import '../call_actions/double_call_action.dart';

class DialogFilterGoods extends StatefulWidget {
  final EntityModel entity;
  final Function filter;
  const DialogFilterGoods({super.key, required this.entity, required this.filter});

  @override
  State<DialogFilterGoods> createState() => _DialogFilterGoodsState();
}

class _DialogFilterGoodsState extends State<DialogFilterGoods> {
  List<String> items = ['Gin', 'Whiskey', 'Vodka', 'Red wines' , 'Brandy','White wines','Cream liquor','Herbal liquor','Foreign beer','Beer','Soft Drinks', 'Ceders', 'Tequila', 'Ram', 'Liqueur', 'Martini', 'Cabernet sauvignon', 'Spirits'];
  List<String> volumesList = ['225ml','250ml', '300ml', '330ml', '350ml','375ml','400ml','500ml', '700ml', '750ml' , '1ltr','1.25ltrs','1.5ltrs', '2L', '3L', '4L','5L'];

  List<SupplierModel> _sppler = [];

  SupplierModel? selectedSupplier;

  String? category;
  String? volume;

  List<EntityModel> _entity = [];
  EntityModel entity = EntityModel(eid: "");

  _getData(){
    _sppler= mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).where((test){
      bool mathEid = widget.entity.eid.isNotEmpty? test.eid == widget.entity.eid : true;
      return mathEid;
    }).toList();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _entity.add(EntityModel(eid: "", title: "All"));
    entity = widget.entity.eid==""? _entity.last : _entity.firstWhere((test)=>test.eid==widget.entity.eid, orElse: ()=>_entity.last);
    setState(() {
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }


  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final dropColor =  Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Please filter the product data by specifying either the category, volume, or suppliers in the form below.",
          style: TextStyle(color: secondaryColor, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        widget.entity.eid != ""? SizedBox() :  Text(" Entity :",style: TextStyle(color: secondaryColor),),
        widget.entity.eid != ""? SizedBox() : Container(
          padding: EdgeInsets.symmetric(horizontal: 12,),
          decoration: BoxDecoration(
              color: color1,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  width: 1,
                  color: color1
              )
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<EntityModel>(
              value: entity,
              dropdownColor: dropColor,
              icon: Icon(Icons.arrow_drop_down, color: reverse),
              isExpanded: true,
              items: _entity.map((EntityModel entityModel) {
                return DropdownMenuItem<EntityModel>(
                  value: entityModel,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(entityModel.title.toString(),style: TextStyle(fontWeight: FontWeight.normal),),
                  ),
                );
              }).toList(),
              onChanged: (EntityModel? newValue) {
                setState(() {
                  entity = newValue!;
                });
              },
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(' Category :  ', style: TextStyle(color: secondaryColor),),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12,),
                    decoration: BoxDecoration(
                        color: color1,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            width: 1,
                            color: color1
                        )
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: category,
                        dropdownColor: dropColor,
                        icon: Icon(Icons.arrow_drop_down, color: reverse),
                        isExpanded: true,
                        items: items.map(buildMenuItem).toList(),
                        onChanged: (value) => setState(() => this.category = value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(' Volume :  ', style: TextStyle(color: secondaryColor),),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12,),
                    decoration: BoxDecoration(
                        color: color1,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            width: 1,
                            color: color1
                        )
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: volume,
                        dropdownColor: dropColor,
                        icon: Icon(Icons.arrow_drop_down, color: reverse),
                        isExpanded: true,
                        items: volumesList.map(buildMenuItem).toList(),
                        onChanged: (value) => setState(() => this.volume = value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(' Suppliers :  ', style: TextStyle(color: secondaryColor),),
        Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12,),
            decoration: BoxDecoration(
                color: color1,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    width: 1,
                    color: color1
                )
            ),
            child:  _sppler.length==0
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Text('No suppliers for this Entity please add new suppliers to your list.', style: TextStyle(color: secondaryColor, fontSize: 12),),
            )
                : DropdownButtonHideUnderline(
              child: DropdownButton<SupplierModel>(
                value: selectedSupplier,
                dropdownColor: dropColor,
                icon: Icon(Icons.arrow_drop_down, color: reverse),
                isExpanded: true,
                items: _sppler.map((SupplierModel supplier) {
                  return DropdownMenuItem<SupplierModel>(
                    value: supplier, // Use the unique SupplierModel as the value
                    child: Text(supplier.name.toString(),style: TextStyle(fontWeight: FontWeight.normal),),
                  );
                }).toList(),
                onChanged: (SupplierModel? newValue) {
                  setState(() {
                    selectedSupplier = newValue;
                  });
                },
              ),
            )
        ),
        DoubleCallAction(
          action: ()async{
            Navigator.pop(context);
            widget.filter(category, volume, selectedSupplier?.sid, entity.eid);
          },
          title: "Filter",
        ),
      ],
    );
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: TextStyle(fontWeight: FontWeight.normal),
    ),
  );
}
