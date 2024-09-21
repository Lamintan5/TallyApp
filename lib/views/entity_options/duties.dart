import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../Widget/items/item_duties.dart';
import '../../models/data.dart';
import '../../models/duties.dart';
import '../../models/duty.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';

class Duties extends StatefulWidget {
  final DutiesModel duties;
  final Function getDuties;
  final String eid;
  final String pid;
  const Duties({super.key, required this.duties, required this.getDuties, required this.eid, required this.pid});

  @override
  State<Duties> createState() => _DutiesState();
}

class _DutiesState extends State<Duties> {
  List<String> newDuties = [];
  String _dutiesString = "";
  List<String> _dutiesList = [];
  bool _loading = false;
  String did = "";

  _getDuties(){
    _dutiesString = widget.duties.duties.toString();
    _dutiesList = _dutiesString.split(",");
    newDuties = widget.duties.duties.toString().split(",");
    setState(() {
    });
  }
  _saveDuties(){
    final dialogBg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    setState(() {
      _loading = true;
    });
    Services.updateDuties(widget.duties.did, newDuties).then((response){
      if(response=='success'){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: dialogBg,
              content: Text("Duties Updated Successfully", style: TextStyle(color: reverse),),
            )
        );
        widget.getDuties();
        setState(() {
          _loading = true;
        });
      } else if(response=='failed'){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: dialogBg,
                content: Text("Duties was not updated", style: TextStyle(color: reverse),),
                action: SnackBarAction(label: "Try Again", onPressed: _saveDuties)
            )
        );
        setState(() {
          _loading = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: dialogBg,
                content: Text("mmhm🤔 seems like something went wrong", style: TextStyle(color: reverse),),
                action: SnackBarAction(label: "Try Again", onPressed: _saveDuties)
            )
        );
        setState(() {
          _loading = true;
        });
      }
    });
  }
  _addDuties(){
    final dialogBg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    setState(() {
      Uuid uuid = Uuid();
      did = uuid.v1();
      _loading = true;
      newDuties.remove("null");
    });
    Services.addDuties(did, widget.eid, widget.pid, newDuties).then((response){
      if(response=='Success'){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: dialogBg,
              content: Text("Duties Updated Successfully", style: TextStyle(color: reverse),),
            )
        );
        widget.getDuties();
        setState(() {
          _loading = true;
        });
      } else if(response=='Failed'){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: dialogBg,
                content: Text("Duties was not updated", style: TextStyle(color: reverse),),
                action: SnackBarAction(label: "Try Again", onPressed: _saveDuties)
            )
        );
        setState(() {
          _loading = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: dialogBg,
                content: Text("mmhm🤔 seems like something went wrong", style: TextStyle(color: reverse),),
                action: SnackBarAction(label: "Try Again", onPressed: _saveDuties)
            )
        );
        setState(() {
          _loading = true;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDuties();
  }


  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    bool isEqual = listsAreEqualIgnoringOrder(_dutiesList, newDuties);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Row(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                width: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Permissions', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),),
                      ],
                    ),
                    Text(
                      'Grant managers permission to manage sales, purchases, products, suppliers, and inventory data. This allows them to handle key business operations with your oversight. Make sure to review permissions carefully before granting access.',
                      style: TextStyle(color: secondaryColor, fontSize: 12),),
                    SizedBox(height: 20,),
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
                            })
                    ),
                  ],
                ),
              ),
            ),
          ),
          isEqual
              ? SizedBox()
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: MaterialButton(
              onPressed: (){
                if(widget.duties.did==""){
                  _addDuties();
                } else {
                  _saveDuties();
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
          Text(
            Data().message,
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
