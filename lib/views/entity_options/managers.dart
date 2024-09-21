import 'dart:convert';

import 'package:TallyApp/models/entities.dart';
import 'package:flutter/material.dart';

import '../../Widget/dialogs/dialog_add_managers.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/items/item_managers.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/users.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';

class Managers extends StatefulWidget {
  final EntityModel entity;
  final Function getManagers;
  const Managers({super.key, required this.entity, required this.getManagers});

  @override
  State<Managers> createState() => _ManagersState();
}

class _ManagersState extends State<Managers> {
  TextEditingController _search = TextEditingController();
  List<String> _pidList = [];
  List<UserModel> _user = [];
  List<UserModel> _newUser = [];
  UserModel user = UserModel(uid: "", image: "");
  String duty = '';
  List<String> admin = [];
  bool _loading = false;

  _getDetails()async{
    _getData();
    if(_pidList.isNotEmpty){
      await Future.forEach(_pidList, (element) async {
        _newUser = await Services().getCrntUsr(element.toString());
        user = _newUser.first;
        if (_user.any((user) => user.uid == element)) {
        } else {
          _user.add(user);
        }
      });
      await Data().addOrUpdateUserList(_user);
    }
    _getData();
  }
  _getData(){
    _pidList = widget.entity.pid.toString().split(",").toSet().toList();
    _user =  myUsers.isEmpty ? [] : myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _user = _user.where((usr) => _pidList.any((pids) => pids == usr.uid)).toList();
    admin = widget.entity.admin.toString().split(",");
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      _user.forEach((item) {
        if (item.firstname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.lastname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.username.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    }
    else {
      filteredList = _user;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: normal,
        foregroundColor: reverse,
      ),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text('Entity Managers', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),),
                        ),
                        !admin.contains(currentUser.uid) ? SizedBox() : IconButton(
                            onPressed: (){
                              dialogGetManagers(context);
                            },
                            tooltip: 'Add a new manager',
                            icon: Icon(Icons.add_circle))
                      ],
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      controller: _search,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "🔎  Search for Managers...",
                        fillColor: color1,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(5)
                          ),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      onChanged:  (value) => setState((){}),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index){
                            UserModel users = filteredList[index];
                            return ItemManagers(
                              user: users,
                              entity: widget.entity,
                              getManagers: _getData, remove: _remove,
                            );
                          }),
                    ),

                  ],
                ),
              ),
            ),
          ),
          Text(Data().message,
            style: TextStyle(color: secondaryColor, fontSize: 11),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
  void dialogGetManagers(BuildContext context) {
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            )
        ),
        backgroundColor: dilogbg,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        constraints: BoxConstraints(
            maxHeight: size.height - 100,
            minHeight: size.height-100,
            maxWidth: 500,minWidth: 400
        ),
        context: context,
        builder: (context) {
          return Column(
            children: [
              DialogTitle(title: 'A D D  M A N A G E R S'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text( 'Tap on any manager to get more options',
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(child: DialogAddManagers(entity: widget.entity))
            ],
          );
        });
  }

  _remove(UserModel user){
    _user.removeWhere((test) => test.uid == user.uid);
    widget.getManagers();
    setState(() {

    });
  }
}
