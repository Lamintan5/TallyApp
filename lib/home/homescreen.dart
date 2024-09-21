import 'dart:io';

import 'package:TallyApp/Widget/show_my_case.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../resources/socket.dart';
import '../utils/colors.dart';
import '../utils/global_variables.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController pageController;
  String? currentUser;
  final GlobalKey _one = GlobalKey();

  Future getValidations() async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var obtainEmail = sharedPreferences.getString('uid');
    setState(() {
      currentUser = obtainEmail;
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _selectedIndex = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    getValidations();
    pageController = PageController(initialPage: 0);
    if(!myShowCases.contains("home_nav_items")){
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          ShowCaseWidget.of(context).startShowCase([_one])
      );
    }
    Data().addOrRemoveShowCase("home_nav_items", "add");
    SocketManager().getDetails();
    SocketManager().connect();
  }
  @override
  Widget build(BuildContext context) {
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    return Scaffold(
      body: SizedBox(
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
          onPageChanged: onPageChanged,
          children: homeScreenItems,
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: normal,
        onTap: navigationTapped,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: LineIcon.home(
              size: 27,
              color: (_selectedIndex == 0) ? secBtn : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: ShowMyCase(
                mykey: _one,
                title: "Sell/Buy",
                description: "Effortlessly record sales or purchases with a single click.",
                child: Icon(CupertinoIcons.tag, color: (_selectedIndex == 1) ? secBtn : secondaryColor,)
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: LineIcon.wallet(
              color: (_selectedIndex == 2) ? secBtn : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: LineIcon.poll(
              color: (_selectedIndex == 3) ? secBtn : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
        ],
      ),
    );
  }
}

