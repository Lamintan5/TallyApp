import 'dart:convert';

import 'package:TallyApp/Auth/login.dart';
import 'package:TallyApp/Widget/text/text_format.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/data.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/dialogs/dialog_ipaddress.dart';
import '../../Widget/dialogs/dialog_title.dart';
import '../../Widget/logos/studio5ive.dart';
import '../../models/users.dart';
import '../../resources/services.dart';
import '../../resources/socket.dart';
import '../../utils/colors.dart';
import 'change_email.dart';
import 'change_pass.dart';
import 'change_phone.dart';
import 'edit_profile.dart';

class Options extends StatefulWidget {
  final Function reload;
  const Options({super.key, required this.reload});

  @override
  State<Options> createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  final socketManager = Get.find<SocketManager>();
  bool upload = false;
  bool power = false;
  bool _loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(myShowCases.contains("Upload")){
      setState(() {
        upload = true;
      });
    } else {
      setState(() {
        upload = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final double height = 5;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: reverse,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: 550,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30,),
                      Text("Settings", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          LineIcon.user(size: 20,),
                          SizedBox(width: 5,),
                          Text("Account", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Divider(
                        color: reverse,
                        height: 2,
                      ),
                      SizedBox(height: 2,),
                      Text('Update your information to keep your account ', style: TextStyle(color: secondaryColor),),
                      SizedBox(height: 20,),
                      Card(
                        color: background,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              OptionButtons(txt: "Edit Profile", icon: LineIcon.edit(), onTap: () { Get.to(()=>EditProfile(reload: (){
                                widget.reload();
                                setState(() {});},
                              ),transition: Transition.rightToLeft); },),
                              SizedBox(height: height),
                              Divider(color: color1, thickness: 1, height: 1,),
                              SizedBox(height: height),
                              OptionButtons(txt: "Change Password",icon: Icon(Icons.password), onTap: () {  Get.to(()=>ChangePass(),transition: Transition.rightToLeft); },),
                              SizedBox(height: height),
                              Divider(color: color1, thickness: 1, height: 1,),
                              SizedBox(height: height),
                              OptionButtons(
                                txt: "Change Email",
                                mssg : currentUser.email ==null || currentUser.email == ""
                                    ? ""
                                    :  currentUser.email!.replaceRange(4, currentUser.email!.length-6, "*********") ,
                                icon: Icon(Icons.mail), onTap: () { Get.to(()=>ChangeEmail(),transition: Transition.rightToLeft); },),
                              SizedBox(height: height),
                              Divider(color: color1, thickness: 1, height: 1,),
                              SizedBox(height: height),
                              OptionButtons(
                                txt: "Change Phone Number",
                                mssg: currentUser.phone ==null || currentUser.phone == ""
                                    ? ""
                                    : currentUser.phone!.replaceRange(3, currentUser.phone!.length-2, "********"),
                                icon: Icon(Icons.phone_android), onTap: () { Get.to(()=>ChangePhone(reload: (){setState(() {});},),transition: Transition.rightToLeft); },),
                              SizedBox(height: height),
                              // Divider(color: color1, thickness: 1, height: 1,),
                              // SizedBox(height: height),
                              // OptionButtons(txt: "Language", icon: LineIcon.language(), onTap: () {  },),
                              // SizedBox(height: height),
                              // Divider(color: color1, thickness: 1, height: 1,),
                              // SizedBox(height: height),
                              // OptionButtons(txt: "Location", icon: Icon(Icons.pin_drop), onTap: () {  },),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40,),

                      // Row(
                      //   children: [
                      //     LineIcon.lock(size: 20,),
                      //     SizedBox(width: 5,),
                      //     Text("Privacy", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),),
                      //   ],
                      // ),
                      // SizedBox(height: 8,),
                      // Divider(
                      //   color: reverse,
                      //   height: 2,
                      // ),
                      // SizedBox(height: 2,),
                      // Text('Customize your privacy to make experience better', style: TextStyle(color: secondaryColor),),
                      // SizedBox(height: 20,),
                      // Card(
                      //   color: background,
                      //   elevation: 5,
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: Column(
                      //       children: [
                      //         OptionButtons(txt: "Security", icon: LineIcon.lock(), onTap: () {  },),
                      //         SizedBox(height: height),
                      //         Divider(color: color1, thickness: 1, height: 1,),
                      //         SizedBox(height: height),
                      //         OptionButtons(txt: "Login Details", icon: Icon(Icons.login), onTap: () {  },),
                      //         SizedBox(height: height),
                      //         Divider(color: color1, thickness: 1, height: 1,),
                      //         SizedBox(height: height),
                      //         OptionButtons(txt: "Privacy", icon: Icon(Icons.remove_red_eye), onTap: () {  },),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 20,),

                      Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 5,),
                          Text("More Options", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Divider(
                        color: reverse,
                        height: 2,
                      ),
                      SizedBox(height: 2,),
                      Text('Update your information to keep your account ', style: TextStyle(color: secondaryColor),),
                      SizedBox(height: 20,),
                      Card(
                        color: background,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              OptionButtons(
                                txt: "Currency",
                                icon: LineIcon.globe(),
                                mssg: TFormat().getCurrency(), onTap: () {  },
                              ),
                              SizedBox(height: height),
                              Divider(color: color1, thickness: 1, height: 1,),
                              SizedBox(height: height),
                              // OptionButtons(
                              //   txt: "Domain",
                              //   mssg: domain,
                              //   icon: Icon(Icons.cable), onTap: () { dialogIpAddress(context); },),
                              // SizedBox(height: height),
                              // Divider(color: color1, thickness: 1, height: 1,),
                              SizedBox(height: height),
                              OptionButtons(
                                txt: "Auto Upload",
                                icon: Icon(Icons.cloud_upload),
                                action : Switch(
                                    value: upload,
                                    onChanged: (value){
                                      setState(() {
                                        upload = value;
                                        Data().addOrRemoveShowCase("Upload",upload?"add":"remove");
                                      });
                                    }
                                ), onTap: () {},
                              ),
                              SizedBox(height: height),
                              // Divider(color: color1, thickness: 1, height: 1,),
                              // SizedBox(height: height),
                              // OptionButtons(
                              //   txt: "Energy Efficiency",
                              //   icon: Icon(Icons.energy_savings_leaf_outlined),
                              //   action : Switch(
                              //       value: power,
                              //       onChanged: (value){
                              //         setState(() {
                              //           power = value;
                              //           Data().addOrRemoveShowCase("Power",power?"add":"remove");
                              //
                              //         });
                              //       }
                              //   ), onTap: () {  },
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Center(
                        child: InkWell(
                          onTap: (){
                            dialogLogOut(context);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Center(child: _loading
                                  ?  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: reverse,strokeWidth: 2,))
                                  :  Text("SIGN OUT",)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Studio5ive(),
          ],
        ),
      ),
    );
  }
  Future logoutUser(BuildContext context)async{
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    setState(() {
      _loading = true;
    });
    List<UserModel> _user = [];
    _user = await Services().getCrntUsr(currentUser.uid);
    var tokens = _user.isEmpty? [""] : _user.first.token.toString().split(",");
    tokens.remove(currentUser.token);
    await Services.updateToken(currentUser.uid, tokens.join(",")).then((value)async{
      if(value=="success" || value == "Does Not Exist" || value == "Empty"){
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.remove('uid');
        preferences.remove('username');
        preferences.remove('first');
        preferences.remove('last');
        preferences.remove('image');
        preferences.remove('email');
        preferences.remove('phone');
        preferences.remove('type');
        preferences.remove('url');
        preferences.remove('status');
        preferences.remove('token');
        preferences.remove('password');
        preferences.remove('country');
        // preferences.remove('unit_profile_showcase');
        preferences.remove('myentity');
        preferences.remove('myusers');
        preferences.remove('mysuppliers');
        preferences.remove('mysales');
        preferences.remove('myduties');
        preferences.remove('myproducts');
        preferences.remove('mypurchases');
        preferences.remove('myinventory');
        preferences.remove('mypayments');
        preferences.remove('mychats');
        preferences.remove('mymess');
        preferences.remove('mynotif');
        preferences.remove('notmyentity');
        preferences.remove('mybills');
        // preferences.remove('myshowcase');
        currentUser = UserModel(
            uid: "",
            email: "",
            phone: "",
            username: "",
            firstname: "",
            lastname: "",
            type: "",
            url: "",
            token: "",
            password:"",status: "",
            country: ""
        );
        myEntity = [];
        myUsers = [];
        mySuppliers = [];
        mySales = [];
        myDuties = [];
        myProducts = [];
        myPurchases = [];
        myInventory = [];
        myPayments = [];
        myChats = [];
        myNotif = [];
        myMess = [];
        myBills = [];
        // myShowCases = [];
        notMyEntity = [];
        socketManager.chats.clear();
        socketManager.messages.clear();
        socketManager.notifications.clear();
        socketManager.signout();
        socketManager.disconnect();
        Data().addOrRemoveShowCase("Upload", "remove");

        Map<String, List> lists = {
          "myEntity": myEntity,
          "myUsers": myUsers,
          "mySuppliers": mySuppliers,
          "mySales": mySales,
          "myDuties": myDuties,
          "myProducts": myProducts,
          "myPurchases": myPurchases,
          "myInventory": myInventory,
          "myPayments": myPayments,
          "myChats": myChats,
          "myNotif": myNotif,
          "myMess": myMess,
          "myBills": myBills,
        };

        // Print the number of elements in each list
        lists.forEach((name, list) {
          print('$name has ${list.length} item(s).');
        });

        Get.offAll(()=>Login(), transition: Transition.leftToRight);
        Get.snackbar(
            "Success",
            "User logged out successfully",
            icon: Icon(CupertinoIcons.checkmark_alt, color: Colors.green,),
            shouldIconPulse: true,
            maxWidth: 500
        );
        setState(() {
          _loading = false;
        });
      } else if(value=="error"){
        Get.snackbar(
            "Error",
            "User was logged not logged out. Please try again.",
            icon: Icon(Icons.close, color: Colors.red,),
            shouldIconPulse: true,
            maxWidth: 500
        );
        setState(() {
          _loading = false;
        });
      } else {
        Get.snackbar(
            "Error",
            "mhmm🤔 seems like something went wrong. Please try again later.",
            icon: Icon(Icons.warning_amber_rounded, color: Colors.red,),
            shouldIconPulse: true,
            maxWidth: 500
        );
        setState(() {
          _loading = false;
        });
      }
    });

  }
  void dialogLogOut(BuildContext context, ){
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          backgroundColor: dilogbg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'A C C O U N T',),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Are you sure you wish to log out from this account',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryColor, ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: (){
                            Navigator.pop(context);
                            logoutUser(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: secBtn,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(child:  Text('Sign Out', style: TextStyle(color: Colors.black),),),
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 100,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                width: 1, color: color1,
                              )
                          ),
                          child: Center(child: Text("CANCEL")),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
  void dialogIpAddress(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;

    showDialog(
        builder: (context) => Dialog(
          backgroundColor: dilogbg,
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: SizedBox(width: 450,
            child: DialogIpaddress(),
          ),
        ), context: context
    );
  }
}
class OptionButtons extends StatelessWidget {
  final String txt;
  final String mssg;
  final Widget icon;
  final Widget action;
  final void Function() onTap;
  const OptionButtons({super.key, required this.onTap, required this.txt, required this.icon, this.mssg = '', this.action = const Icon(Icons.arrow_forward_ios,size: 15,),
    });

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Row(
          children: [
            icon,
            SizedBox(width: 10,),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txt,style: TextStyle(fontSize: 15),),
                mssg==''?SizedBox():Text(mssg.toString(), style: TextStyle(color: secondaryColor, fontSize: 11),),
              ],
            ),
            Expanded(child: SizedBox()),
            action
          ],
        ),
      ),
    );
  }
}
