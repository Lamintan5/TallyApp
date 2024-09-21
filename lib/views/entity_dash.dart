import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/Widget/logos/prop_logo.dart';
import 'package:TallyApp/Widget/logos/studio5ive.dart';
import 'package:TallyApp/Widget/profile_images/user_profile.dart';
import 'package:TallyApp/Widget/buttons/row_button.dart';
import 'package:TallyApp/Widget/show_my_case.dart';
import 'package:TallyApp/home/tabs/reports.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/duties.dart';
import 'package:TallyApp/models/users.dart';
import 'package:TallyApp/resources/socket.dart';
import 'package:TallyApp/views/entity_options/edit_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../Widget/dialogs/dialog_title.dart';
import '../models/data.dart';
import '../models/entities.dart';
import '../resources/services.dart';
import '../utils/colors.dart';
import 'entity_options/entity_payments.dart';
import 'entity_options/managers.dart';
import 'enty_tabs/dashboard.dart';
import 'enty_tabs/products.dart';
import 'enty_tabs/sales.dart';
import 'enty_tabs/suppliers.dart';

class EntityDash extends StatefulWidget {
  final EntityModel entity;
  final Function getData;
  const EntityDash({super.key, required this.entity, required this.getData});

  @override
  State<EntityDash> createState() => _EntityDashState();
}

class _EntityDashState extends State<EntityDash>  with TickerProviderStateMixin {
  late TabController _tabController;

  bool _loading = false;
  bool _loadingAction = false;

  List<String> _pidList = [];
  List<UserModel> _user = [];
  List<UserModel> _newUser = [];
  List<DutiesModel> _duties = [];
  List<DutiesModel> _newDuties = [];
  List<EntityModel> _entity = [];
  List<EntityModel> _enty = [];
  List<String> admin = [];

  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();

  UserModel user = UserModel(uid: "", image: "");
  EntityModel entity = EntityModel(eid: "");


  String image1 = '';
  String image2 = '';
  String image3 = '';

  double _position1 = 20.0;
  double _position2 = 20.0;
  double _position3 = 20.0;
  double _position4 = 20.0;

  _getDetails()async{
    _getData();
    SocketManager().getDetails();
    _entity = await Services().getOneEntity(widget.entity.eid);
    await Data().addOrUpdateEntity(_entity);
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
    _enty = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _user =  myUsers.isEmpty ? [] : myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    entity = _enty.firstWhere((element)=>element.eid == widget.entity.eid, orElse: ()=>EntityModel(eid: ""));
    _pidList = entity.pid!.split(",");
    _pidList = _pidList.toSet().toList();
    admin = widget.entity.admin.toString().split(",");
    _pidList.removeAt(0);

    _user = _user.where((usr) => _pidList.any((pids) => pids == usr.uid)).toList();
    image1 = _user.isEmpty ? "" : _user.isNotEmpty && _user.length > 0 ? _user[0].image.toString() : "";
    image2 = _user.length < 2 ? "" : _user.isNotEmpty && _user.length > 1 ? _user[1].image.toString() : "";
    image3 = _user.length < 3 ? "" : _user.isNotEmpty && _user.length > 2 ? _user[2].image.toString() : "";

    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _getDetails();
    if(!myShowCases.contains("entity_dash")){
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          ShowCaseWidget.of(context).startShowCase([_one,_two,_three])
      );
    }
    Data().addOrRemoveShowCase("entity_dash","add");

    Future.delayed(Duration(milliseconds:100), () {
      setState(() {
        _position1 = _pidList.length == 2 ? 18 : _pidList.length == 3 || _pidList.length > 3 ? 10 : 20.0;
        _position2 = _pidList.length == 2 ? 18 : _pidList.length == 3 || _pidList.length > 3 ? 20 : 20.0;
        _position3 = _pidList.length == 0 ? 20 : _pidList.length == 1 ? 20 : _pidList.length == 2 || _pidList.length == 3 || _pidList.length > 3 ? 30 : 20.0;
        _position4 = _pidList.length == 0 ? 20 : _pidList.length == 1 ? 30 : _pidList.length == 2 || _pidList.length == 3 || _pidList.length > 3 ? 40 : 20.0;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final normalscreen = Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final double padding = 10;
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScroller) => [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              pinned: true,
              expandedHeight: 200,
              toolbarHeight: 30,
              floating: true,
              forceElevated: innerBoxIsScroller,
              snap: true,
              actions: [
                ShowMyCase(mykey: _two, description: "Click here to get more options.", child: buildButton())
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Hero(tag: widget.entity, child: PropLogo(entity: entity, radius: 30,)),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  entity.title.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(entity.category.toString(), style: TextStyle(color: secondaryColor),),
                                Text('Created on ${DateFormat.yMMMd().format(DateTime.parse(entity.time.toString()))}',
                                  style: TextStyle(color: secondaryColor, fontSize: 11, ),),
                                SizedBox(height: 5,),
                              ],
                            ),
                          ),
                          _loading? SizedBox(width: 25,height: 25,
                              child: CircularProgressIndicator(color: reverse,strokeWidth: 3,)) : SizedBox(),
                          SizedBox(width: 20,),
                          Column(
                            children: [
                              ShowMyCase(
                                mykey: _three,
                                title: "Managers",
                                description: 'Assign managers to help oversee operations. Grant specific permissions for managing sales, purchases, inventory, and more.',
                                child: InkWell(
                                  onTap: (){
                                    Get.to(() => Managers(entity: entity, getManagers: _getDetails), transition: Transition.rightToLeft);
                                  },
                                  borderRadius: BorderRadius.circular(5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Tooltip(
                                        message: 'Click here to see all managaers',
                                        child: Container(
                                          width: 60,
                                          height: 20,
                                          child: Stack(
                                            children: [
                                              AnimatedPositioned(
                                                left: _position1,
                                                duration: Duration(seconds: 1),
                                                curve: Curves.easeInOut,
                                                child:  UserProfile(image: image3, radius: 10,),
                                              ),
                                              AnimatedPositioned(
                                                left: _position2,
                                                duration: Duration(seconds: 1),
                                                curve: Curves.easeInOut,
                                                child: UserProfile(image: image2, radius: 10),
                                              ),
                                              AnimatedPositioned(
                                                left: _position3,
                                                duration: Duration(seconds: 1),
                                                curve: Curves.easeInOut,
                                                child: UserProfile(image: image1, radius: 10),
                                              ),
                                              !admin.contains(currentUser.uid)
                                                  ?  SizedBox()
                                                  :  AnimatedPositioned(
                                                left: _position4,
                                                duration: Duration(seconds: 1),
                                                curve: Curves.easeInOut,
                                                child: CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: reverse, // Change to your desired color
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 15,
                                                      color: normal, // Change to your desired color
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text('Managers', overflow: TextOverflow.ellipsis, style: TextStyle(color: secondaryColor, fontSize: 10),)
                                    ],
                                  ),
                                ),
                              ),
                              entity.checked.contains("false") || entity.checked.contains("EDIT") || entity.checked.contains("DELETE") || entity.checked.contains("REMOVED")
                                  ? Card(
                                    color: Colors.red,
                                   shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(5)
                                   ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, top: 3, bottom: 3, right: 5),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                entity.checked == "false" || entity.checked == "false, EDIT"
                                                    ? _upload()
                                                    :  entity.checked.toString().contains("REMOVED")
                                                    ? dialogRemoveEntity(context)
                                                    :_updateEntity();
                                              },
                                              child: Row(
                                                children: [
                                                  _loadingAction
                                                      ?SizedBox(width: 12, height: 12,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2,))
                                                      :Icon(
                                                    entity.checked == "false"
                                                        ? Icons.cloud_upload
                                                        : entity.checked.contains("REMOVE")
                                                        ? CupertinoIcons.delete_solid
                                                        : entity.checked.contains("DELETE")
                                                        ? CupertinoIcons.delete
                                                        : entity.checked.contains("EDIT")
                                                        ? Icons.edit
                                                        : Icons.more_vert,
                                                    size: 15,
                                                  ),
                                                  SizedBox(width: 5,),
                                                  Text(
                                                    _loadingAction
                                                        ?"Loading..."
                                                        :entity.checked.split(", ").last == "false"
                                                        ? "UPLOAD"
                                                        : entity.checked.split(", ").last == "DELETE"
                                                        ? "DELETE"
                                                        : entity.checked.split(", ").last == "EDIT"
                                                        ? "EDIT"
                                                        : entity.checked.split(", ").last == "REMOVED"
                                                        ? "REMOVE"
                                                        : entity.checked,
                                                    style: TextStyle(color: Colors.white, fontSize: 13),),
                                                  SizedBox(width: 5,),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                                              child: VerticalDivider(
                                                width: 1,color: Colors.white,
                                              ),
                                            ),
                                            PopupMenuButton(
                                                child: Icon(Icons.keyboard_arrow_down),
                                                itemBuilder: (BuildContext context){
                                                  return [
                                                    if (entity.checked == "false" || entity.checked == "false, EDIT"
                                                        || entity.checked.toString().contains("REMOVED"))
                                                      PopupMenuItem(
                                                        value: 'upload',
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(Icons.cloud_upload, color: Colors.red,),
                                                            SizedBox(width: 5,),
                                                            Text(
                                                              'Upload', style: TextStyle(
                                                              color:Colors.red,),
                                                            ),
                                                          ],
                                                        ),
                                                        onTap: (){
                                                          _upload();
                                                        },
                                                      ),
                                                    PopupMenuItem(
                                                      value: 'delete',
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(CupertinoIcons.delete, color:reverse),
                                                          SizedBox(width: 5,),
                                                          Text('Delete',style: TextStyle(
                                                            color:  reverse,
                                                          ),),
                                                        ],
                                                      ),
                                                      onTap: (){
                                                        dialogRemoveEntity(context);
                                                      },
                                                    ),
                                                    PopupMenuItem(
                                                      value: entity.checked.toString().contains("DELETE")
                                                          ? 'Restore'
                                                          : 'Edit',
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(entity.checked.toString().contains("DELETE") ?Icons.restore :Icons.edit,
                                                            color: reverse,
                                                          ),
                                                          SizedBox(width: 5,),
                                                          Text(entity.checked.toString().contains("DELETE") ?'Restore' :'Edit', style: TextStyle(
                                                            color:reverse),
                                                          ),
                                                        ],
                                                      ),
                                                      onTap: (){
                                                        entity.checked.toString().contains("DELETE")
                                                            ? _restore()
                                                            : Get.to(() => EditEntity(entity: entity, getData: _update,), transition: Transition.rightToLeft);
                                                      },
                                                    )
                                                  ];
                                            }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  : SizedBox()
                            ],
                          ),
                          SizedBox(width: 20,),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(),
                    Column(
                      children: [
                        SizedBox(
                          width: 500,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            indicatorWeight: 3,
                            labelStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                            unselectedLabelStyle: const TextStyle(fontSize: 15),
                            labelPadding: const EdgeInsets.only(bottom: 0),
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorPadding: const EdgeInsets.symmetric(horizontal: 10,),
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.transparent,
                            splashBorderRadius: const BorderRadius.all(Radius.circular(30)),
                            tabs: [
                              Text('Overview',),
                              Text('Products',),
                              Text('Sales',),
                              ShowMyCase(
                                  mykey: _one,
                                  title: null,
                                  description: "Get started by adding a new supplier to streamline procurement.",
                                  child: Text('Suppliers',)
                              ),
                            ],
                          ),
                        ),
                        Platform.isAndroid || Platform.isIOS?Container(
                          width: 100,
                          height: 5,
                          margin: EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.all(Radius.circular(50))
                          ),
                        ):SizedBox()
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: Column(
            children: [
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: entity.pid.toString().split(",").contains(currentUser.uid)
                      ? TabBarView(
                        controller: _tabController,
                        children: [
                          Dashboard(entity: entity),
                          Products(entity: entity),
                          Sales(entity: entity,),
                          Suppliers(entity: entity,),
                        ],
                      )
                      : Column(
                        children: [
                          Row(),
                          SizedBox(
                            height: 100,
                          ),
                          Image.asset(
                            "assets/add/removed.png",
                          ),
                          SizedBox(height: 10,),
                          Text("Manager Removed", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),),
                          SizedBox(width: 450,
                              child: Text("You have been removed from ${entity.title} and no longer have access to modify its data. If you believe this is an error or would like to regain access, please contact the entity administrator for assistance.",
                                style: TextStyle(color: Colors.grey[700]),
                                textAlign: TextAlign.center,
                              )
                          ),
                        ],
                      ),
                ),
              ),
              Text(
                Data().message,
                style: TextStyle(color: secondaryColor, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      endDrawer: Drawer(
        child: Scaffold(
          body: SafeArea (
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Options',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: 50,),
                  !admin.contains(currentUser.uid)
                      ? SizedBox()
                      :RowButton(onTap: (){
                        Navigator.pop(context);
                    Get.to(() => EditEntity(entity: entity, getData: _update,), transition: Transition.rightToLeft);
                  }, icon: Icon(CupertinoIcons.pen), title: 'Edit Entity', subtitle: ""),
                  !admin.contains(currentUser.uid)
                      ? SizedBox()
                      :RowButton(onTap: (){
                    Get.to(()=>Managers(entity: entity, getManagers: _getDetails,), transition: Transition.rightToLeftWithFade);
                  }, icon: LineIcon.users(), title: "Managers", subtitle: ""),
                  RowButton(onTap: (){
                    Get.to(()=>EntityPayments(entity: entity), transition: Transition.rightToLeftWithFade);
                  }, icon: Icon(CupertinoIcons.money_dollar), title: 'Payments', subtitle: ''),
                  RowButton(onTap: (){
                    Get.to(()=>Reports(entity: widget.entity), transition: Transition.rightToLeftWithFade);
                  }, icon: Icon(CupertinoIcons.graph_square), title: 'Reports & Analytics', subtitle: ''),
                  admin.first.toString() == currentUser.uid
                      ? RowButton(onTap: (){
                        dialogRemoveEntity(context);
                      }, icon: Icon(CupertinoIcons.delete, size: 20,), title: "Remove Entity", subtitle: "")
                      : RowButton(onTap: (){
                      Navigator.pop(context);
                      dialogExit(context);
                    }, icon: Icon(Icons.logout ), title: "Exit", subtitle: ""),
                  Expanded(child: SizedBox()),
                  Container(
                    child: Column(
                      children: [
                        Studio5ive()
                      ],
                    ),
                  ),
                  SizedBox(height: 20,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  void dialogRemoveEntity(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final style = TextStyle(color: secondaryColor);
    showDialog(context: context, builder: (context){
      return Dialog(
        backgroundColor: dilogbg,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'R E M O V E  E N T I T Y'),
                RichText(
                  textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Please confirm that you want to delete ',
                          style: style,
                        ),
                        TextSpan(
                          text: '${entity.title}. ',
                        ),
                        TextSpan(
                          text: 'All the data related to this entity will be lost if you proceed.',
                          style: style,
                        ),
                      ]
                    )
                ),
                DoubleCallAction(
                  action: ()async{
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    await Data().removeEntity(entity, widget.getData, context).then((value){
                      print("value:$value");

                    });
                  },
                  title: "Remove",titleColor: Colors.red,
                )
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogExit(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final style = TextStyle(color: secondaryColor);
    showDialog(context: context, builder: (context){
      return Dialog(
        backgroundColor: dilogbg,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'E X I T'),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Please confirm that you want to exit ',
                            style: style,
                          ),
                          TextSpan(
                            text: '${entity.title}. ',
                          ),
                          TextSpan(
                            text: 'You will no longer have access to its data',
                            style: style,
                          ),
                        ]
                    )
                ),
                DoubleCallAction(
                  action: ()async{
                    Navigator.pop(context);
                    _remove();
                  },
                  title: "Remove",titleColor: Colors.red,
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  _updateEntity()async{
    setState(() {
      _loadingAction = true;
    });
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();

    final response = await Services.updateEntity(
        entity.eid,
        entity.pid!.split(","),
        entity.title.toString(),
        entity.category.toString(),
        entity.image.toString().contains("/") || entity.image.toString().contains("\\")
            ? File(entity.image.toString()) : null,
        entity.image.toString()
    );
    final String responseString = await response.stream.bytesToString();
    print(responseString);
    if(responseString.contains("success")){
      entity.checked = "true";
      _entity.firstWhere((element) => element.eid == widget.entity.eid).checked = "true";
      uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList('myentity', uniqueEntities);
      myEntity = uniqueEntities;
      widget.getData();
      setState(() {
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Entity updated Successfully"),
            showCloseIcon: true,
          )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Entity updated. Awaiting internet connection."),
            showCloseIcon: true,
          )
      );
    }
    setState(() {
      _loadingAction = false;
    });
  }
  _update(EntityModel newEntity){
    entity.title = newEntity.title;
    entity.category = newEntity.category;
    entity.image = newEntity.image;
    entity.checked = newEntity.checked;
    widget.getData();
    setState(() {

    });
  }
  _restore()async{
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    EntityModel initial = _entity.firstWhere((element) =>element.eid == entity.eid);

    _entity.firstWhere((element) => element.eid == entity.eid).checked = initial.checked.split(",").first;
    entity.checked = initial.checked.split(",").first;

    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    _getData();
    widget.getData();
  }
  _upload()async{
    setState(() {
      _loadingAction = true;
    });
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    File? _image;
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _image = File(entity.image.toString());

    final response =  await Services.addEntity(
        entity.eid,
        entity.pid!.split(","),
        entity.title.toString(),
        entity.category.toString(),
        entity.image.toString() == ""? null : _image);
    final String responseString = await response.stream.bytesToString();
    print("Response : $responseString");
    if(responseString.contains("Success")){
      entity.checked = "true";
      entity.image = entity.image.toString().contains("\\")
          ? entity.image.toString().split("\\").last
          : entity.image.toString().split("/").last;
      _entity.firstWhere((test) => test.eid == entity.eid).checked = "true";
      _entity.firstWhere((test) => test.eid == entity.eid).image = entity.image.toString().contains("\\")
          ? entity.image.toString().split("\\").last
          : entity.image.toString().split("/").last;
      uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList('myentity', uniqueEntities);
      myEntity = uniqueEntities;
      _getData();
      widget.getData();
    }
    setState(() {
      _loadingAction = false;
    });
  }
  _remove()async{
    setState(() {
      _loading = true;
    });
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    List<String> pidList = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    pidList = entity.pid.toString().split(",");
    pidList.remove(currentUser.uid);

    Services.updateEntityPID(widget.entity.eid.toString(), pidList).then((response) async{
      if(response=="success"){
        _entity.removeWhere((element) => element.eid == widget.entity.eid);
        uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myentity', uniqueEntities);
        myEntity = uniqueEntities;
        await Data().removeData(entity.eid, widget.getData, context).then((value){
          Navigator.pop(context);
        });
      }
    });
  }
}
class buildButton extends StatelessWidget {
  const buildButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: (){
          Scaffold.of(context).openEndDrawer();
        },
        icon: Icon(Icons.menu));
  }
}
