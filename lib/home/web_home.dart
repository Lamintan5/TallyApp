import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/basic_stats.dart';
import 'package:TallyApp/Widget/logos/row_logo.dart';
import 'package:TallyApp/home/action_bar/chats/web_chat.dart';
import 'package:TallyApp/home/options/options_screen.dart';
import 'package:TallyApp/home/tabs/payments.dart';
import 'package:TallyApp/home/tabs/products.dart';
import 'package:TallyApp/home/tabs/reports.dart';
import 'package:TallyApp/home/tabs/sell_buy.dart';
import 'package:TallyApp/models/sales.dart';
import 'package:TallyApp/models/users.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:badges/badges.dart' as badges;
import 'package:showcaseview/showcaseview.dart';

import '../Widget/frosted_glass.dart';
import '../Widget/items/item_entity.dart';
import '../Widget/logos/prop_logo.dart';
import '../Widget/profile_images/current_profile.dart';
import '../Widget/show_my_case.dart';
import '../create/create.dart';
import '../main.dart';
import '../models/data.dart';
import '../models/entities.dart';
import '../models/messages.dart';
import '../models/notifications.dart';
import '../resources/services.dart';
import '../resources/socket.dart';
import '../utils/colors.dart';
import '../views/entity_dash.dart';
import 'action_bar/notifications/notifications.dart';
import 'options/edit_profile.dart';

class WebHome extends StatefulWidget {
  const WebHome({super.key});

  @override
  State<WebHome> createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  TextEditingController _search = TextEditingController();

  List<EntityModel> _entity = [];
  List<SaleModel> _sale = [];
  List<SaleModel> _newSale = [];
  List<EntityModel> _newEntity = [];
  List<NotifModel> _notif = [];

  final socketManager = Get.find<SocketManager>();

  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();

  int noEntity = 0;
  int nav = 0;
  int countMess = 0;
  int countNotif = 0;

  bool _expand = false;
  bool isFilled = false;

  late double screenWidth;

  _getEntities()async{
    _getData();
    SocketManager().getDetails();
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
    SocketManager().connect();
    _getEntities();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        screenWidth = MediaQuery.of(context).size.width;
        _expand = screenWidth >= 1500?true:false;
      });
    });

    if(!myShowCases.contains('web_home_entity')){
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          ShowCaseWidget.of(context).startShowCase([_one,_two])
      );
    }
    Data().addOrRemoveShowCase("web_home_entity","add");
  }

  @override
  Widget build(BuildContext context) {
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
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    final style = TextStyle(color: revers, fontSize: 13);
    final secondary = TextStyle(color: secondaryColor, fontSize: 13);
    final image =  Theme.of(context).brightness == Brightness.dark
        ? "assets/logo/5logo_72.png"
        : "assets/logo/5logo_72_black.png";
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              constraints: BoxConstraints(
                maxWidth: _expand
                    ?250
                    :50
              ),
              child: Column(
                children: [
                  Expanded(
                      child:
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _expand?RowLogo(text: "", height: 30,)
                              :  Container(
                            child: Image.asset(
                              'assets/logos/android/res/mipmap-mdpi/ic_launcher.png',
                              height: 30,
                            ),
                          ),
                          SizedBox(height: 40,),
                          Container(
                            margin: EdgeInsets.only( bottom: 20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(5),
                              onTap: (){
                                setState(() {
                                  _expand =! _expand;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.menu),
                              ),
                            ),
                          ),
                          navButton(Icon(CupertinoIcons.chart_bar_alt_fill), "Home", (){setState(() {nav=0;});}, 0),
                          SizedBox(height: 5,),
                          ShowMyCase(
                              mykey: _two,
                              title: "Sell/Buy",
                              description: "Effortlessly record sales or purchases with a single click.",
                              child: navButton(Icon(CupertinoIcons.tag), "Sell/Buy", (){setState(() {nav=1;});},1)
                          ),
                          SizedBox(height: 5,),
                          navButton(LineIcon.box(), "Products", (){setState(() {nav=2;});},2),
                          SizedBox(height: 5,),
                          navButton(LineIcon.wallet(), "Payments", (){setState(() {nav=3;});},3),
                          SizedBox(height: 5,),
                          Tooltip(
                            message: _expand? "" : "Messages",
                            child: InkWell(
                              onTap: (){
                                Get.to(()=>WebChat(selected: UserModel(uid: "")), transition: Transition.rightToLeft);
                              },
                              hoverColor: color1,
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(width: 5,),
                                    _expand
                                        ? Icon(CupertinoIcons.ellipses_bubble)
                                        : Obx((){
                                      List<MessModel> _count = socketManager.messages.where((msg) => msg.sourceId != currentUser.uid && msg.seen =="").toList();
                                      countMess = _count.length;
                                          return badges.Badge(
                                            badgeStyle: badges.BadgeStyle(
                                                shape: countMess > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                                                borderRadius: BorderRadius.circular(30),
                                                padding: EdgeInsets.all(5)
                                            ),
                                            badgeContent: Text(NumberFormat.compact().format(countMess), style: TextStyle(fontSize: 10, color: Colors.black),),
                                            showBadge: countMess==0?false:true,
                                            position: badges.BadgePosition.topEnd(end: -5, top: -4),
                                            child: Icon(CupertinoIcons.ellipses_bubble),
                                          );
                                    }),
                                    _expand?SizedBox(width: 20,):SizedBox(),
                                    _expand?Expanded(
                                        child:
                                        Text(
                                          "Messages",
                                          style: TextStyle(color: revers,),
                                          maxLines: 1,
                                          overflow: TextOverflow.fade,
                                        )
                                    )
                                        :SizedBox(),
                                    _expand
                                        ? Obx((){
                                      List<MessModel> _count = socketManager.messages.where((msg) => msg.sourceId != currentUser.uid && msg.seen =="").toList();
                                      countMess = _count.length;
                                      return badges.Badge(
                                        badgeStyle: badges.BadgeStyle(
                                            shape: countMess > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                                            borderRadius: BorderRadius.circular(30),
                                            padding: EdgeInsets.all(5)
                                        ),
                                        badgeContent: Text(NumberFormat.compact().format(countMess), style: TextStyle(fontSize: 10),),
                                        showBadge: countMess==0?false:true,
                                        position: badges.BadgePosition.topEnd(end: -5, top: -4),
                                      );
                                    })
                                        : SizedBox()

                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          Tooltip(
                            message: _expand? "" : "Notifications",
                            child: InkWell(
                              onTap: (){
                                Get.to(()=> Notifications(getEntity: _getData, updateCount: _updateCount,), transition: Transition.rightToLeft);
                              },
                              hoverColor: color1,
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                                decoration: BoxDecoration(
                            
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(width: 5,),
                                    _expand
                                        ? LineIcon.bell()
                                        : Obx((){
                                      List<NotifModel> _countNotif = socketManager.notifications.where((not) => not.sid != currentUser.uid && !not.seen.toString().contains(currentUser.uid) ).toList();
                                      countNotif = _countNotif.length;
                                      return badges.Badge(
                                            badgeStyle: badges.BadgeStyle(
                                                shape: countNotif > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                                                borderRadius: BorderRadius.circular(30),
                                                padding: EdgeInsets.all(5)
                                            ),
                                            badgeContent: Text(NumberFormat.compact().format(countNotif), style: TextStyle(fontSize: 10, color: Colors.black),),
                                            showBadge: countNotif==0?false:true,
                                            position: badges.BadgePosition.topEnd(end: -5, top: -4),
                                            child: LineIcon.bell(),
                                          );
                                    }),
                                    _expand?SizedBox(width: 20,):SizedBox(),
                                    _expand?Expanded(
                                        child:
                                        Text(
                                          "Notifications",
                                          style: TextStyle(color: revers,),
                                          maxLines: 1,
                                          overflow: TextOverflow.fade,
                                        )
                                    )
                                        :SizedBox(),
                                    _expand
                                        ? Obx((){
                                      List<NotifModel> _countNotif = socketManager.notifications.where((not) => not.sid != currentUser.uid && not.seen == "" ).toList();
                                      countNotif = _countNotif.length;
                                      return badges.Badge(
                                        badgeStyle: badges.BadgeStyle(
                                            shape: countNotif > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                                            borderRadius: BorderRadius.circular(30),
                                            padding: EdgeInsets.all(5)
                                        ),
                                        badgeContent: Text(NumberFormat.compact().format(countNotif), style: TextStyle(fontSize: 10),),
                                        showBadge: countNotif==0?false:true,
                                        position: badges.BadgePosition.topEnd(end: -5, top: -4),
                                      );
                                    })
                                        : SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          navButton(Icon(Icons.settings), "Settings", (){Get.to(() => Options(reload: (){setState(() {});},), transition: Transition.rightToLeft);},6),
                          SizedBox(height: 5,),
                          navButton(Icon(Icons.add_box_outlined), "Create", (){Get.to(() => Create(getData: _getData), transition: Transition.rightToLeft);},7),
                        ],
                      ),
                    )
                  ),
                  Image.asset(
                      height: 30,
                      image
                  ),
                  SizedBox(width: 5,),
                  _expand
                      ?Text(
                    "S T U D I O 5 I V E",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w100),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  )
                      :SizedBox(),
                  SizedBox(height: 20,)
                ],
              ),
            ),
            Expanded(
                child: nav==0
                    ?Reports(entity: EntityModel(eid: ""),)
                    :nav==1
                    ?SellOrBuy()
                    :nav==2
                    ?Products()
                    :nav==3
                    ?Payments()
                    :SizedBox(),
            ),
            SizedBox(width: 10,),
            Container(
              constraints: BoxConstraints(
                  minWidth: 250,
                  maxWidth:350
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: color1,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CurrentImage(radius: 20,),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('@${currentUser.username}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                                  Text('${currentUser.firstname} ${currentUser.lastname}', style: TextStyle()),
                                ],
                              ),
                            ),
                            IconButton(
                                tooltip: "Edit Profile",
                                onPressed: (){
                                  Get.to(()=>EditProfile(reload: (){setState(() {});},), transition: Transition.rightToLeft);
                                },
                                icon: Icon(Icons.arrow_forward_ios, size: 20, color: secondaryColor,)
                            )
                          ],
                        ),
                        SizedBox(height: 5,),
                        RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                style: TextStyle(fontSize: 13, color: secondaryColor),
                                children: [
                                  WidgetSpan(child: Icon(Icons.mail_outline,size: 15,color: secondaryColor)),
                                  WidgetSpan(child: SizedBox(width: 5)),
                                  TextSpan(text: currentUser.email),
                                  WidgetSpan(child: SizedBox(width: 10)),
                                  WidgetSpan(child: LineIcon.phone(size: 15,color: secondaryColor)),
                                  WidgetSpan(child: SizedBox(width: 5)),
                                  TextSpan(text: currentUser.phone),
                                ]
                            )
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  BasicStats(),
                  SizedBox(height: 20,),
                  Text(
                    'Entities',
                    style: TextStyle(
                        fontSize: 25, fontWeight: FontWeight.w900
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextFormField(
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
                  SizedBox(height: 20,),
                  Expanded(
                      child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredList.length+1,
                          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            mainAxisExtent: 250,
                          ),
                          itemBuilder: (context, index){
                            if(index==filteredList.length){
                              return ShowMyCase(
                                mykey: _one,
                                title: 'Create Entity',
                                description: 'Click to establish a new business entity. Customize key details and manage operational data with ease.',
                                child: InkWell(
                                  onTap: (){
                                    Get.to(()=> Create(getData: _getData,), transition: Transition.rightToLeft);
                                  },
                                  splashColor: CupertinoColors.activeBlue,
                                  borderRadius: BorderRadius.circular(10),
                                  hoverColor: color1,
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
                                ),
                              );
                            } else {
                              EntityModel entity = filteredList[index];
                              String image = entity.image!;
                              List<String> _managers = entity.pid!.split(",");
                              double totalSprice = _sale.where((sale) => sale.eid == entity.eid && double.parse(sale.amount.toString()) == double.parse(sale.paid.toString())
                                  && double.parse(sale.paid.toString()) != 0.0).fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
                              return InkWell(
                                splashColor: CupertinoColors.activeBlue,
                                borderRadius: BorderRadius.circular(10),
                                onTap: (){
                                  Navigator.push(context, (MaterialPageRoute(builder: (context) => ShowCaseWidget(builder: (context) => EntityDash(entity: entity, getData: _getData)))));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Stack(
                                    children: [
                                      SizedBox(width: double.infinity, height: double.infinity,
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
                                                entity.title!.toUpperCase(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600
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
                      )
                  )
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
  Widget navButton(Widget icon, String title, void Function() ontap, int index){
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    return Tooltip(
      message: _expand? "" : title,
      child: InkWell(
        onTap: ontap,
        hoverColor: color1,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
          decoration: BoxDecoration(
            color: nav==index?color1:null,
            borderRadius: BorderRadius.circular(5)
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              nav==index
                  ?Container(
                width: 3,height: 15,
                margin: EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color:secBtn,
                  borderRadius: BorderRadius.circular(10)
                ),
              )
                  :SizedBox(width: 5,),
              icon,
              _expand?SizedBox(width: 20,):SizedBox(),
              _expand?Expanded(
                  child:
                Text(
                  title,
                  style: TextStyle(color: revers,),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                )
              )
                  :SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
  void _updateCount(){
    countMess = 0;
    setState(() {
    });
  }

  void _addEntity(EntityModel entityModel){
    _entity.add(entityModel);
    noEntity++;
    setState(() {
    });
  }

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
