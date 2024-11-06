import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/profile_images/current_profile.dart';
import 'package:TallyApp/Widget/text/text_format.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/data.dart';
import 'package:badges/badges.dart' as badges;
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../Widget/basic_stats.dart';
import '../../Widget/frosted_glass.dart';
import '../../Widget/logos/prop_logo.dart';
import '../../create/create.dart';
import '../../Widget/logos/row_logo.dart';
import '../../models/entities.dart';
import '../../models/messages.dart';
import '../../models/notifications.dart';
import '../../models/sales.dart';
import '../../models/suppliers.dart';
import '../../resources/services.dart';
import '../../resources/socket.dart';
import '../../utils/colors.dart';
import '../../views/entity_dash.dart';
import '../action_bar/chats/chat_screen.dart';
import '../action_bar/notifications/notifications.dart';
import '../options/edit_profile.dart';
import '../options/options_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  TextEditingController _search = TextEditingController();
  List<EntityModel> _entity = [];
  List<SupplierModel> _suppliers = [];
  List<SupplierModel> _filtSpplr = [];
  List<SaleModel> _sale = [];
  List<NotifModel> _notif = [];
  List<String> _manager = [];
  List<String> pidListAsList = [];
  String pidList = "";
  List<String> uniqueManagersList = [];

  bool _loadUser = false;
  bool _loadEntity = false;
  bool isFilled = false;

  int noEntity = 0;
  int noSpplr = 0;
  int countNotif = 0;
  int countMess = 0;

  final socketManager = Get.find<SocketManager>();

  final _key = encrypt.Key.fromUtf8('f2caaf40-68db-11ee-b339-f1847070');
  final _iv = encrypt.IV.fromLength(16);

  _getEntities()async{
    _getData();
    await Data().checkEntity((){});
    await SocketManager().getDetails();
    _getData();
  }
  _getData(){
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _sale = mySales.map((jsonString) => SaleModel.fromJson(json.decode(jsonString))).toList();
    noEntity = _entity.length;
    setState(() {
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getEntities();

    // if(_entity.isEmpty && !myShowCases.contains('mobile_home_entity')){
    //   WidgetsBinding.instance.addPostFrameCallback((_) =>
    //       ShowCaseWidget.of(context).startShowCase([_one])
    //   );
    // }
    // Data().addOrRemoveShowCase("mobile_home_entity","add");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    TabController _tabController = TabController(length: 2, vsync: this);
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final normalBg = Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final style = TextStyle(color: reverse, fontSize: 13);
    final secondary = TextStyle(color: secondaryColor, fontSize: 13);
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      _entity.forEach((item) {
        if (item.title.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _entity;
    }
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              pinned: true,
              expandedHeight: 320,
              automaticallyImplyLeading: false,
              foregroundColor: reverse,
              toolbarHeight: 30,
              actions: [
                SizedBox(width: 10,),
                RowLogo(text: '',),
                Expanded(child: SizedBox()),
                SizedBox(width: 10,),

                IconButton(
                    onPressed: (){
                      Get.to(()=>Notifications(getEntity: _getEntities, updateCount: _updateCount,), transition: Transition.rightToLeft);
                    },
                    icon: Obx(() {
                      List<NotifModel> _countNotif = socketManager.notifications.where((not) => not.sid != currentUser.uid && !not.seen.toString().contains(currentUser.uid)).toList();
                      //&& not.rid!.contains(currentUser.uid)
                      countNotif = _countNotif.length;
                      return badges.Badge(
                        badgeStyle: badges.BadgeStyle(
                            shape: countNotif > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                            borderRadius: BorderRadius.circular(30),
                            padding: EdgeInsets.all(5)
                        ),
                        badgeContent: Text(NumberFormat.compact().format(countNotif), style: TextStyle(fontSize: 10, color: Colors.black),),
                        showBadge:countNotif ==0?false:true,
                        position: badges.BadgePosition.topEnd(end: -5, top: -4),
                        child: LineIcon.bell(color: secBtn,),
                      );
                    })
                ),
                SizedBox(width: 10,),
                IconButton(
                    onPressed: (){
                      Get.to(() => ChatScreen(updateCount: _updateChat,), transition: Transition.rightToLeft);
                    },
                    icon: Obx((){
                      List<MessModel> _count = socketManager.messages.where((msg) => msg.sourceId != currentUser.uid && msg.seen =="").toList();
                      countMess = _count.length;
                      return badges.Badge(
                        badgeStyle: badges.BadgeStyle(
                            shape:countMess > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                            borderRadius: BorderRadius.circular(30),
                            padding: EdgeInsets.all(5)
                        ),
                        badgeContent: Text(NumberFormat.compact().format(countMess), style: TextStyle(fontSize: 10, color: Colors.black),),
                        showBadge:countMess==0?false:true,
                        position: badges.BadgePosition.topEnd(end: -5, top: -4),
                        child: LineIcon.comment(color: secBtn,),
                      );
                    })
                ),

                SizedBox(width: 10,),
                IconButton(
                    onPressed: (){
                      Get.to(()=>Options(reload: (){setState(() {});},), transition: Transition.rightToLeftWithFade);
                    },
                    icon: Icon(Icons.settings),color: secBtn)
              ],
              scrolledUnderElevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  margin: EdgeInsets.only(top: 60),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,height: 100,
                            child: Stack(
                              children: [
                                Center(child: CurrentImage(radius: 45,)),
                                Positioned(
                                  right: -5,
                                  bottom: -5,
                                  child: MaterialButton(
                                    onPressed: (){Get.to(()=>EditProfile(reload: (){setState(() {});},), transition: Transition.rightToLeft);},
                                    color: normal,
                                    minWidth: 5,
                                    shape: CircleBorder(),
                                    splashColor: CupertinoColors.systemBlue,
                                    child: Icon(Icons.edit, size: 16,color: secBtn,),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 15,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_loadUser? '@username' : '@${currentUser.username}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                              Text(_loadUser? 'FullName' : '${currentUser.firstname} ${currentUser.lastname}', style: TextStyle()),
                              Row(
                                children: [
                                  Icon(Icons.mail_outline,size: 15,color: secondaryColor),
                                  Text(_loadUser? '  Email Address' : '  ${currentUser.email}',
                                    style: TextStyle(fontSize: 13, color: secondaryColor),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  LineIcon.phone(size: 15,color: secondaryColor),
                                  Text(_loadUser? '  Phone Number' : ' ${currentUser.phone}', style: TextStyle(fontSize: 13, color: secondaryColor),),
                                  SizedBox(width: 10,),
                                ],
                              ),
                              SizedBox(height: 5,),
                              InkWell(
                                onTap: (){
                                  Get.to(()=>EditProfile(reload: (){setState(() {});},), transition: Transition.rightToLeft);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 60),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: secBtn
                                  ),
                                  child: Center(child: Text('Edit Profile', style: TextStyle(color: Colors.black),)),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 30),
                      BasicStats(),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(20),
                child: Container(
                  height: 30,
                  margin: EdgeInsets.only(left: 10, bottom: 20, ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: size.height - 80,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('  Entities',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w900
                            ),
                          ),
                        ),
                        _entity.length == 0
                            ? SizedBox() : IconButton(
                            onPressed: (){
                              Get.to(()=> Create(getData: _getData,), transition: Transition.rightToLeft);
                            },
                            icon: Icon(Icons.add_circle))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
                      child: TextFormField(
                        controller: _search,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: "Search",
                          fillColor: color1,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(5)
                            ),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
                          prefixIcon: Icon(CupertinoIcons.search, size: 20,color: secondaryColor),
                          prefixIconConstraints: BoxConstraints(
                              minWidth: 40,
                              minHeight: 30
                          ),
                          suffixIcon: isFilled?InkWell(
                              onTap: (){
                                _search.clear();
                                setState(() {
                                  isFilled = false;
                                });
                              },
                              borderRadius: BorderRadius.circular(100),
                              child: Icon(Icons.cancel, size: 20,color: secondaryColor)
                          ) :SizedBox(),
                          suffixIconConstraints: BoxConstraints(
                              minWidth: 40,
                              minHeight: 30
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
                          filled: true,
                          isDense: true,
                        ),
                        onChanged:  (value) => setState((){
                          if(value.isNotEmpty){
                            isFilled = true;
                          } else {
                            isFilled = false;
                          }
                        }),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Expanded(
                        child: Center(child: SizedBox(width: 450,
                          child: GridView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              physics: const BouncingScrollPhysics(),
                              itemCount: filteredList.length + 1,
                              gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                mainAxisExtent: 250,
                              ),
                              itemBuilder: (context, index){
                                if(index==filteredList.length){
                                  return InkWell(
                                    onTap: (){
                                      Get.to(()=> Create(getData: _getData,), transition: Transition.rightToLeft);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: DottedBorder(
                                        borderType: BorderType.RRect,
                                        color: reverse,
                                        radius: Radius.circular(12),
                                        dashPattern: [5,5],
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Center(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add, color: Colors.tealAccent,size: 50,),
                                                Text(
                                                  "Click here to create new entity",
                                                  style: TextStyle(color: secondaryColor),
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                    ),
                                  );
                                } else {
                                  EntityModel entity = filteredList[index];
                                  String image = entity.image!;
                                  List<String> _managers = entity.pid!.split(",");
                                  double totalSprice = _sale.where((sale) => sale.eid == entity.eid).fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
                                  return InkWell(
                                    onTap: (){
                                      Navigator.push(context, (MaterialPageRoute(builder: (context) => ShowCaseWidget(builder: (context) => EntityDash(entity: entity, getData: _getData)))));
                                      //Get.to(()=> ShowCaseWidget(builder: (context) => EntityDash(entity: entity, getData: _getData)), transition: Transition.rightToLeft);
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    splashColor: CupertinoColors.activeBlue,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        children: [
                                          SizedBox(
                                            width: double.infinity, height: double.infinity,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: entity.image == "" && entity.checked == "true"
                                                  ? SizedBox()
                                                  : entity.checked == "false"
                                                  ? Opacity(opacity: 0.05,
                                                child: Image.file(
                                                  File(entity.image!),
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                                  : Opacity(
                                                opacity: 0.05,
                                                child: CachedNetworkImage(
                                                  cacheManager: customCacheManager,
                                                  imageUrl: Services.HOST + '/logos/${image}',
                                                  key: UniqueKey(),
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                        height: 40,
                                                        width: 40,
                                                      ),
                                                  errorWidget: (context, url, error) => Container(
                                                    height: 40,
                                                    width: 40,
                                                    child: Center(child: Icon(Icons.error_outline_rounded, size: 25,),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                              child: FrostedGlass(width: double.infinity, height: double.infinity)
                                          ),
                                          Align(
                                              alignment: Alignment.topCenter,
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 20.0),
                                                child: Hero(
                                                    tag: entity,
                                                    child: PropLogo(entity: entity, radius: 40,from: 'GRID',)),
                                              )),
                                          Positioned(
                                              top: 5,right: 10,
                                              child:  entity.checked.contains("REMOVED")
                                                  ? Icon(CupertinoIcons.delete_solid, color: Colors.red,)
                                                  : entity.checked.contains("DELETE")
                                                  ? Icon(CupertinoIcons.delete, color: Colors.red,)
                                                  : entity.checked.contains("EDIT")
                                                  ? Icon(Icons.edit, color: Colors.red,)
                                                  : entity.checked == "false"
                                                  ? Icon(Icons.cloud_upload, color: Colors.red,)
                                                  : SizedBox()
                                          ),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              margin: EdgeInsets.all(1),
                                              width: double.infinity,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                  color: normalBg,
                                                  borderRadius: BorderRadius.only(
                                                      bottomLeft: Radius.circular(10),
                                                      bottomRight: Radius.circular(10)
                                                  )
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    entity.title.toString().toUpperCase(),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600
                                                    ),
                                                  ),
                                                  entity.location.toString()==""?SizedBox()
                                                      : Container(
                                                    margin: EdgeInsets.only(bottom: 2),
                                                    child: RichText(
                                                        textAlign: TextAlign.center,
                                                        text: TextSpan(
                                                            children: [
                                                              WidgetSpan(
                                                                child: Icon(CupertinoIcons.location, size: 12,color: secondaryColor,),
                                                              ),
                                                              TextSpan(
                                                                  text:  " ${entity.location}",
                                                                  style: secondary
                                                              ),
                                                            ]
                                                        )
                                                    ),
                                                  ),
                                                  RichText(
                                                      text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text: 'Ksh.${formatNumberWithCommas(totalSprice)} ',
                                                                style: style
                                                            ),
                                                            TextSpan(
                                                                text: "total revenue",
                                                                style: secondary
                                                            )
                                                          ]
                                                      )
                                                  ),
                                                  RichText(
                                                      text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text: _managers.length.toString(),
                                                                style: style
                                                            ),
                                                            TextSpan(
                                                                text: _managers.length == 1? " manager" : " managers",
                                                                style: TextStyle(fontSize: 13, color: secondaryColor)
                                                            ),

                                                          ]
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }
                          ),
                        )
                        )
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  void _updateChat(){
    countNotif = 0;
  }
  void _addEntity(EntityModel entityModel){
    _entity.add(entityModel);
    noEntity++;
    setState(() {
    });
  }
  void _updateCount(){
    countMess = 0;
    setState(() {
    });
  }
  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
