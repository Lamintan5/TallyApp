import 'dart:io';

import 'package:TallyApp/auth/fetching.dart';
import 'package:TallyApp/home/web_home.dart';
import 'package:TallyApp/resources/socket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TallyApp/auth/welcome.dart';
import 'package:showcaseview/showcaseview.dart';

import 'home/homescreen.dart';
import 'models/users.dart';
import 'utils/colors.dart';

import 'package:cached_network_image/cached_network_image.dart';

late List<CameraDescription> cameras;
DateTime today = DateTime.now();
DateTime justToday = DateTime(today.year, today.month, today.day);
UserModel currentUser = UserModel(uid: "");
String domain = "192.168.1.104";
List<String> myEntity = [];
List<String> notMyEntity = [];
List<String> myUsers = [];
List<String> mySuppliers = [];
List<String> mySales = [];
List<String> myDuties = [];
List<String> myProducts = [];
List<String> myPurchases= [];
List<String> myPayments = [];
List<String> myInventory = [];
List<String> myNotif = [];
List<String> myChats = [];
List<String> myMess = [];
List<String> myShowCases = [];

final customCacheManager = CacheManager(
    Config(
      'customCacheManager',
      maxNrOfCacheObjects: 100,
    )
);

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isMacOS || Platform.isWindows || Platform.isLinux ){

  } else {
    cameras = await availableCameras();
  }
  Get.put(SocketManager());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loading = false;


  Future getValidations() async{
    setState((){
      _loading = true;
    });
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var obtainId = sharedPreferences.getString('uid');
    var obtainUsername = sharedPreferences.getString('username');
    var obtainFirst = sharedPreferences.getString('first');
    var obtainLast= sharedPreferences.getString('last');
    var obtainImage = sharedPreferences.getString('image');
    var obtainPhone = sharedPreferences.getString('phone');
    var obtainEmail = sharedPreferences.getString('email');
    var obtainType = sharedPreferences.getString('type');
    var obtainUrl = sharedPreferences.getString('url');
    var obtainStatus = sharedPreferences.getString('status');
    var obtainToken = sharedPreferences.getString('token');
    var obtainPass = sharedPreferences.getString('password');
    var obtainCountry = sharedPreferences.getString('country');

    var obtainDomain = sharedPreferences.getString('domain');

    var obtainMyEntity = sharedPreferences.getStringList('myentity');
    var obtainMyUsers= sharedPreferences.getStringList('myusers');
    var obtainMySuppliers= sharedPreferences.getStringList('mysuppliers');
    var obtainMySales= sharedPreferences.getStringList('mysales');
    var obtainMyDuties= sharedPreferences.getStringList('myduties');
    var obtainMyPrd= sharedPreferences.getStringList('myproducts');
    var obtainMyPurchases= sharedPreferences.getStringList('mypurchases');
    var obtainMyInventory= sharedPreferences.getStringList('myinventory');
    var obtainMyPayments = sharedPreferences.getStringList('mypayments');
    var obtainMyNotif= sharedPreferences.getStringList('mynotif');
    var obtainMyChats= sharedPreferences.getStringList('mychats');
    var obtainMyMess= sharedPreferences.getStringList('mymess');
    var obtainNotMyEntity= sharedPreferences.getStringList('notmyentity');
    var obtainMyShowcase= sharedPreferences.getStringList('myshowcase');

    setState(() {
      currentUser = UserModel(
          uid: obtainId == null || obtainId == ""? "": obtainId,
          firstname: obtainFirst,
          lastname: obtainLast,
          username: obtainUsername,
          email: obtainEmail,
          phone: obtainPhone,
          image: obtainImage,
          type: obtainType,
          url: obtainUrl,
          password: obtainPass,
          status: obtainStatus,
          token: obtainToken,
          country: obtainCountry,
      );
      _loading = false;
      domain = obtainDomain == null || obtainDomain == "" ? "192.168.0.103" : obtainDomain;
      myEntity = obtainMyEntity == null ? [] : obtainMyEntity;
      myUsers = obtainMyUsers == null ? [] : obtainMyUsers;
      mySuppliers = obtainMySuppliers == null ? [] : obtainMySuppliers;
      mySales = obtainMySales == null ? [] : obtainMySales;
      myDuties = obtainMyDuties == null ? [] : obtainMyDuties;
      myProducts = obtainMyPrd == null ? [] : obtainMyPrd;
      myPurchases = obtainMyPurchases == null ? [] : obtainMyPurchases;
      myInventory = obtainMyInventory == null ? [] : obtainMyInventory;
      myPayments = obtainMyPayments == null ? [] : obtainMyPayments;
      myNotif = obtainMyNotif == null ? [] : obtainMyNotif;
      myChats = obtainMyChats == null ? [] : obtainMyChats;
      myMess = obtainMyMess == null ? [] : obtainMyMess;
      notMyEntity = obtainNotMyEntity == null ? [] : obtainNotMyEntity;
      myShowCases = obtainMyShowcase == null ? [] : obtainMyShowcase;
    });
  }

  Future<void> initPlatform()async{
    await OneSignal.shared.setAppId("41db0b95-b70f-44a5-a5bf-ad849c74352e");
    await OneSignal.shared.getDeviceState().then((value){
      print("Token : ${value!.userId}");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getValidations();
    if(Platform.isAndroid || Platform.isIOS){
      initPlatform();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GetMaterialApp(
      title: 'TallyApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true,).copyWith(
          tabBarTheme: TabBarTheme(dividerColor: Colors.transparent),
          popupMenuTheme: PopupMenuThemeData(color: Colors.white, textStyle: TextStyle(color: Colors.black)),
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.highContrastLight(primary: screenBackgroundColor),
          dialogTheme: DialogTheme(surfaceTintColor: Colors.transparent),
          dialogBackgroundColor: Colors.white,
          bottomSheetTheme: BottomSheetThemeData(surfaceTintColor: Colors.transparent,),
          cardTheme: CardTheme(surfaceTintColor: Colors.transparent),
          appBarTheme: AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
          snackBarTheme: SnackBarThemeData(
              width: size.width > 450 ? 500: null,
              actionTextColor: Colors.cyanAccent,
              backgroundColor: Colors.white,
              elevation: 10,
              behavior: SnackBarBehavior.floating,
              contentTextStyle: TextStyle(color: Colors.black),
              closeIconColor: CupertinoColors.systemBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.cyan.withOpacity(0.9); // Color when the scrollbar is hovered
              }
              if (states.contains(MaterialState.focused)) {
                return Colors.cyan; // Color when the scrollbar is focused
              }
              return Colors.cyan.withOpacity(0.5); // Default color
            },
          ),
              thickness: MaterialStateProperty.resolveWith<double?>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return 7.0; // Thickness when the scrollbar is hovered
                }
                if (states.contains(MaterialState.dragged)) {
                  return 7.0; // Thickness when the scrollbar is being dragged
                }
                return 5; // Default thickness
              },
            ),
          ),
      ),
      darkTheme: ThemeData.light(useMaterial3: true,).copyWith(
        dialogBackgroundColor: Colors.grey[900],
          popupMenuTheme: PopupMenuThemeData(color: Colors.grey[900]),
          scaffoldBackgroundColor: screenBackgroundColor,
          iconTheme: IconThemeData(color: Colors.white),
          colorScheme: ColorScheme.highContrastDark(primary: Colors.cyanAccent),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white,),
            bodyMedium: TextStyle(color: Colors.white,),
          ),
          hintColor: secondaryColor,
          tabBarTheme: TabBarTheme(dividerColor: Colors.transparent),
          dialogTheme: DialogTheme(surfaceTintColor: Colors.transparent,),
          bottomSheetTheme: BottomSheetThemeData(surfaceTintColor: Colors.transparent,),
          cardTheme: CardTheme(surfaceTintColor: Colors.transparent),
          appBarTheme: AppBarTheme(backgroundColor: screenBackgroundColor, foregroundColor: Colors.white),
          snackBarTheme: SnackBarThemeData(
              width: size.width > 450 ? 500: null,
              actionTextColor: Colors.cyanAccent,
              backgroundColor: Colors.grey[900],
              elevation: 10,
              behavior: SnackBarBehavior.floating,
              contentTextStyle: TextStyle(color: Colors.white),
              closeIconColor: CupertinoColors.systemBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
          ),
          scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.cyan.withOpacity(0.9);
              }
              if (states.contains(MaterialState.focused)) {
                return Colors.cyan;
              }
              return Colors.cyan.withOpacity(0.5);
            },
          ),
          thickness: MaterialStateProperty.resolveWith<double?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return 7.0;
              }
              if (states.contains(MaterialState.dragged)) {
                return 7.0;
              }
              return 5;
            },
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home:
      _loading
          ?FetchingData()
          :currentUser.uid.isEmpty || currentUser.uid=="" || currentUser.uid.isNull
          ? Welcome()
          : Platform.isAndroid || Platform.isIOS
          ? ShowCaseWidget(builder: (context) => HomeScreen())
          : ShowCaseWidget(builder : (context) => WebHome()),
    );
  }

}

