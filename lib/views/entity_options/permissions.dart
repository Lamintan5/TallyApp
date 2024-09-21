import 'package:TallyApp/models/data.dart';
import 'package:flutter/material.dart';

import '../../Widget/items/item_duties.dart';
import '../../models/duties.dart';
import '../../models/duty.dart';
import '../../models/entities.dart';
import '../../utils/colors.dart';

class Permissions extends StatefulWidget {
  final EntityModel entity;
  final DutiesModel duties;
  const Permissions({super.key, required this.entity, required this.duties});

  @override
  State<Permissions> createState() => _PermissionsState();
}

class _PermissionsState extends State<Permissions> {
  List<String> newDuties = [];
  String _dutiesString = "";
  List<String> _dutiesList = [];
  bool _loading = false;
  String did = "";

  _getDuties() {
    _dutiesString = widget.duties.duties.toString();
    _dutiesList = _dutiesString.split(",");
    newDuties = widget.duties.duties.toString().split(",");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final normal = Theme
        .of(context)
        .brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    final reverse = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    bool isEqual = listsAreEqualIgnoringOrder(_dutiesList, newDuties);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Row(),
          Expanded(
              child: Container(
                width: 800,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Permissions', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                          itemCount: Data().dutyList.length,
                          itemBuilder: (context, index){
                            DutyModel duty = Data().dutyList[index];
                            return ItemDuties(
                              duty: duty,
                              dutiesModel: widget.duties,
                              removeDuty: removeDuty,
                              addDuty: addDuty,
                            );
                          }),
                    )
                  ],
                ),
              )
          ),
          isEqual
              ? SizedBox()
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: MaterialButton(
              onPressed: (){
                if(widget.duties.did==""){
                  // _addDuties();
                } else {
                  // _saveDuties();
                }
              },
              child: _loading
                  ? SizedBox(width: 15,height: 15,child: CircularProgressIndicator(strokeWidth: 1,color: Colors.black,))
                  : Text("S A V E", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
              color: secBtn,
              elevation: 8,
              minWidth: 400,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
          ),
          Text(Data().message,
            style: TextStyle(color: secondaryColor, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  void removeDuty(String duty) {
    if (newDuties.isNotEmpty) {
      newDuties.remove(duty);
      setState(() {});
    }
  }

  void addDuty(String duty) {
    newDuties.add(duty);
    setState(() {});
  }

  bool listsAreEqualIgnoringOrder(List<String> list1, List<String> list2) {
    Set<String> set1 = Set.from(list1);
    Set<String> set2 = Set.from(list2);

    return set1.length == set2.length && set1.containsAll(set2);
  }
}
