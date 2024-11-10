import 'package:TallyApp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:TallyApp/auth/signup.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../models/welcome.dart';
import '../utils/colors.dart';
import 'login.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final controller = CarouselSliderController();
  int activeIndex = 0;

  List<WelcomeModel> welcome = [
    WelcomeModel(image: "assets/1.jpg", message: "Simplify your daily business tracking with intuitive and easy-to-use tools.", title: 'Effortless Daily Tracking'),
    WelcomeModel(image: "assets/2.jpg", message: "Maintain detailed records of sales, expenses, and profits in one place.", title: 'Comprehensive Record Keeping'),
    WelcomeModel(image: "assets/3.jpg", message: "Get real-time insights into your business performance with dynamic dashboards.", title: 'Instant Financial Insights'),
    WelcomeModel(image: "assets/4.jpg", message: "Ensure your data is safe with robust security and backup features.", title: 'Secure Data Management'),
    WelcomeModel(image: "assets/5.jpg", message: "Generate customized reports and analytics to make informed business decisions.", title: 'Custom Reports & Analytics'),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarColor: Colors.transparent
        )
    );
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Carousel(),
          Center(
            child: SafeArea(
              child: SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20,),
                    Text('WELCOME TO TALLYAPP', style: TextStyle(fontSize: 20,color: Colors.white),),
                    Expanded(child: SizedBox()),
                    Text(
                      welcome[activeIndex].title.toString(),
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        welcome[activeIndex].message.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Get.to(() => Login(), transition: Transition.rightToLeft);
                      },
                      child: Container(
                        width: 350,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                                color: screenBackgroundColor,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    InkWell(
                      onTap: () {
                        Get.to(() => SignUp(), transition: Transition.rightToLeft);
                      },
                      child: Container(
                        width: 350,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.cyan, width: 1)),
                        child: Center(
                          child: Text(
                            'SIGNUP',
                            style: TextStyle(
                                color: Colors.cyan, fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                            height: 20,
                            "assets/logo/5logo_72.png"
                        ),
                        SizedBox(width: 5,),
                        Text("S T U D I O 5 I V E", style: TextStyle(color:Colors.white, fontSize: 15, fontWeight: FontWeight.w100),)
                      ],
                    ),
                    SizedBox(height: 20,),
                    buildIndicator(),
                    SizedBox(height: 10,)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildIndicator() {
    return AnimatedSmoothIndicator(
      activeIndex: activeIndex,
      count: welcome.length,
      effect: WormEffect(
        activeDotColor: Colors.cyan,
        dotColor: Colors.white38,
        dotHeight: 8,
        dotWidth: 8,
      ),
    );
  }

  Widget Carousel() {
    final size = MediaQuery.of(context).size;
    return Container(
      child: CarouselSlider.builder(
        carouselController: controller,
        itemCount: welcome.length,
        options: CarouselOptions(
            initialPage: 0,
            height: size.height,
            enlargeFactor: 0.5,
            autoPlay: true,
            viewportFraction: 1,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
            autoPlayAnimationDuration: Duration(seconds: 2),
            onPageChanged: (index, reason) {
              setState(() {
                activeIndex = index;
              });
            }),
        itemBuilder: (context, index, realIndex) {
          WelcomeModel wel = welcome[index];
          return ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [Colors.transparent, Colors.black],
                begin: Alignment.center,
                end: Alignment.bottomCenter,
              ).createShader(bounds);
            },
            blendMode: BlendMode.hardLight,
            child: Image.asset(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              wel.image.toString(),
            ),
          );
        },
      ),
    );
  }

  Widget buildCard(WelcomeModel wel) {
    final size = MediaQuery.of(context).size;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white38
        : Colors.black38;
    return Image.asset(
      fit: BoxFit.cover,
      wel.image.toString(),
    );
  }
}
