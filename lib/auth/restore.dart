import 'dart:io';

import 'package:TallyApp/Widget/profile_images/current_profile.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:showcaseview/showcaseview.dart';

import '../Home/homescreen.dart';
import '../home/web_home.dart';
import '../resources/socket.dart';

class Restore extends StatefulWidget {
  const Restore({super.key});

  @override
  State<Restore> createState() => _RestoreState();
}

class _RestoreState extends State<Restore> {
  bool _loading = false;

  _getData()async{
    setState(() {
      _loading = true;
    });
    await SocketManager().getDetails().then((value){
      setState(() {
        _loading = value;
      });
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
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: Container(
              width: 500,
              margin: EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome back, ${currentUser.username}",style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),
                  RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(
                              text: "TallyApp securely fetches and syncs your business data, providing real-time access to "
                                  "key insights such as daily sales, expenses, and inventory.",
                              style: TextStyle(color: secondaryColor, fontSize: 13),
                            ),
                            WidgetSpan(
                                child: InkWell(
                                  onTap: (){},
                                  child: Text("Privacy Statement", style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w700, fontSize: 13),),

                                )
                            )
                          ]
                      )
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20 ,),
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      CurrentImage(radius: 23,),
                                      SizedBox(width: 10,),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(currentUser.username.toString(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
                                            Text("Fetching Tally data for ${currentUser.username}", style: TextStyle(color: secondaryColor, fontSize: 12, fontStyle: FontStyle.italic),)
                                          ],
                                        ),
                                      ),
                                      _loading
                                          ?SizedBox(width: 20,height: 20, child: CircularProgressIndicator(color: secondaryColor,strokeWidth: 2,))
                                          : SizedBox()
                                    ],
                                  ),
                                  SizedBox(height: 20,),
                                  Divider(
                                    color: reverse,
                                    thickness: 0.1,
                                    height: 1,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.folder, color: secondaryColor,size: 20,),
                                        SizedBox(width: 15,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Entity", style: TextStyle(color: secondaryColor),),
                                            _loading? SizedBox() : Text("${myEntity.length} Results", style: TextStyle(fontSize: 11, color: secondaryColor),)
                                          ],
                                        ),
                                        Expanded(child: SizedBox()),
                                        _loading?_loading?SizedBox():Icon(Icons.check, color: Colors.green,):Icon(Icons.check, color: Colors.green,)
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: reverse,
                                    thickness: 0.1,
                                    height: 1,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: [
                                        LineIcon.box(color: secondaryColor),
                                        SizedBox(width: 15,),

                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Products", style: TextStyle(color: secondaryColor),),
                                            _loading? SizedBox() : Text("${myProducts.length} Results", style: TextStyle(fontSize: 11, color: secondaryColor),)
                                          ],
                                        ),
                                        Expanded(child: SizedBox()),
                                        _loading?SizedBox():Icon(Icons.check, color: Colors.green,)
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: reverse,
                                    thickness: 0.1,
                                    height: 1,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.money_dollar_circle, color: secondaryColor),
                                        SizedBox(width: 15,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Purchases", style: TextStyle(color: secondaryColor),),
                                            _loading? SizedBox() : Text("${myPurchases.length} Results", style: TextStyle(fontSize: 12, color: secondaryColor),)
                                          ],
                                        ),
                                        Expanded(child: SizedBox()),
                                        _loading?SizedBox():Icon(Icons.check, color: Colors.green,)
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: reverse,
                                    thickness: 0.1,
                                    height: 1,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.cube_box, color: secondaryColor),
                                        SizedBox(width: 15,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Inventory", style: TextStyle(color: secondaryColor),),
                                            _loading? SizedBox() : Text("${myInventory.length} Results", style: TextStyle(fontSize: 12, color: secondaryColor),)
                                          ],
                                        ),
                                        Expanded(child: SizedBox()),
                                        _loading?SizedBox():Icon(Icons.check, color: Colors.green,)
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: reverse,
                                    thickness: 0.1,
                                    height: 1,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.money_dollar, color: secondaryColor,),
                                        SizedBox(width: 15,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Sales", style: TextStyle(color: secondaryColor),),
                                            _loading? SizedBox() : Text("${mySales.length} Results", style: TextStyle(fontSize: 12, color: secondaryColor),)
                                          ],
                                        ),
                                        Expanded(child: SizedBox()),
                                        _loading?SizedBox():Icon(Icons.check, color: Colors.green,)
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: reverse,
                                    thickness: 0.1,
                                    height: 1,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.person_2, color: secondaryColor,size: 20,),
                                        SizedBox(width: 15,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Suppliers", style: TextStyle(color: secondaryColor),),
                                            _loading? SizedBox() : Text("${mySuppliers.length} Results", style: TextStyle(fontSize: 12, color: secondaryColor),)
                                          ],
                                        ),
                                        Expanded(child: SizedBox()),
                                        _loading?SizedBox():Icon(Icons.check, color: Colors.green,)
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: reverse,
                                    thickness: 0.1,
                                    height: 1,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: [
                                        LineIcon.wallet(color: secondaryColor),
                                        SizedBox(width: 15,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Payments", style: TextStyle(color: secondaryColor),),
                                            _loading? SizedBox() : Text("${myPayments.length} Results", style: TextStyle(fontSize: 12, color: secondaryColor),)
                                          ],
                                        ),
                                        Expanded(child: SizedBox()),
                                        _loading?SizedBox():Icon(Icons.check, color: Colors.green,)
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: reverse,
                                    thickness: 0.1,
                                    height: 1,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: [
                                        LineIcon.bell(color: secondaryColor),
                                        SizedBox(width: 15,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Notifications", style: TextStyle(color: secondaryColor),),
                                            _loading? SizedBox() : Text("${myNotif.length} Results", style: TextStyle(fontSize: 12, color: secondaryColor),)
                                          ],
                                        ),
                                        Expanded(child: SizedBox()),
                                        _loading?SizedBox():Icon(Icons.check, color: Colors.green,)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10 ,),
                  Center(
                    child: InkWell(
                      onTap: (){
                        if(!_loading){
                          Get.offAll(()=>Platform.isAndroid || Platform.isIOS
                              ? ShowCaseWidget(builder: (context) => HomeScreen())
                              : ShowCaseWidget(
                              builder : (context) => ShowCaseWidget(builder : (context) => WebHome())
                          ),
                              transition: Transition.fadeIn
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        width: 400,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: secBtn,
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: Center(child: _loading? SizedBox(width: 15,height: 15, child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,)) : Text("Continue", style: TextStyle(color: Colors.black),)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,)
                ],
              ),
            ),
          )
      ),
    );
  }
}
