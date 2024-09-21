import 'dart:convert';

import 'package:TallyApp/Widget/logos/prop_logo.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../models/entities.dart';
import '../call_actions/double_call_action.dart';

class DialogFilterByEntity extends StatefulWidget {
  final EntityModel entity;
  final Function filter;
  const DialogFilterByEntity({super.key, required this.entity, required this.filter});

  @override
  State<DialogFilterByEntity> createState() => _DialogFilterByEntityState();
}

class _DialogFilterByEntityState extends State<DialogFilterByEntity> {
  List<EntityModel> _entity = [];
  EntityModel entity = EntityModel(eid: "");

  _getData(){
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _entity.add(EntityModel(eid: "", title: "All"));
    entity = widget.entity.eid==""? _entity.last : _entity.firstWhere((test)=>test.eid==widget.entity.eid, orElse: ()=>_entity.last);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final dropColor =  Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("  Select entity",style: TextStyle(fontWeight: FontWeight.w600),),
        DropdownButtonHideUnderline(
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
        DoubleCallAction(
          action: ()async{
            Navigator.pop(context);
            widget.filter(entity);
          },
          title: "Filter",
        ),
      ],
    );
  }
}
