import 'package:TallyApp/Widget/logos/row_logo.dart';
import 'package:TallyApp/Widget/text_filed_input.dart';
import 'package:TallyApp/auth/signup.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../Widget/emailTextFormWidget.dart';

class Reset extends StatefulWidget {
  const Reset({super.key, });

  @override
  State<Reset> createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  final controller = CarouselSliderController();
  late TextEditingController _email;
  late TextEditingController _pass;
  late TextEditingController _repass;
  int activeIndex = 0;
  String _otpCode = "";
  bool isMatch = true;
  final int _otpCodeLength = 6;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _email = TextEditingController();
    _pass = TextEditingController();
    _repass = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _email.dispose();
    _pass.dispose();
    _repass.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = [
      emailCard(),
      otpCard(),
      passCard(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const RowLogo(text: "", height: 30,),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
              onPressed: (){
                Get.off(()=>const SignUp(), transition: Transition.rightToLeft);
              },
              child: const Text("Create an account",
              style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              )
          )
        ],
      ),
      body: Center(
        child: Container(
          width: 450,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              const SizedBox(),
              Expanded(
                child: CarouselSlider.builder(
                  carouselController: controller,
                  itemCount: cards.length,
                  options: CarouselOptions(
                      // scrollPhysics: NeverScrollableScrollPhysics(),
                      initialPage: 0,
                      enlargeFactor: 0.5,
                      autoPlay: false,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      autoPlayAnimationDuration: const Duration(seconds: 2),
                      onPageChanged: (index, reason) {
                        setState(() {
                          activeIndex = index;
                        });
                      }),
                  itemBuilder: (context, index, realIndex) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: cards[index],
                    );
                  },
                ),
              ),
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  }, child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.arrow_left, size: 15,),
                    SizedBox(width: 5,),
                    Text("Back to log in"),
                  ],
                )
              ),
              const SizedBox(height: 20,),
              buildIndicator(cards.length),
              const SizedBox(height: 30,)
            ],
          ),
        ),
      ),
    );
  }
  Widget emailCard(){
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final secColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context, color: color1)
    );
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 1.5,
                  color: color2
                ),
              ),
              child: const Icon(CupertinoIcons.mail, size: 20,),
            ),
          const SizedBox(height: 10,),
          const Text("Forgot password?", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
          const Text(
            "Please enter the email address linked to your account, and we will send you a one-time password (OTP) to proceed.",
            style: TextStyle(color: secondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10,),
          const Row(
            children: [
              Text("Email", style: TextStyle(fontWeight: FontWeight.w700),),
            ],
          ),
          const SizedBox(height: 5,),
          TextFormField(
              controller: _email,
            enableSuggestions: true,
            decoration: InputDecoration(
              hintText: "Enter you email",
              hintStyle: const TextStyle(color: secondaryColor),
              border: inputBorder,
              focusedBorder: inputBorder,
              enabledBorder: inputBorder,
              filled: true,
              fillColor: color1,
              contentPadding: const EdgeInsets.all(10),
            ),
            keyboardType: TextInputType.emailAddress,
            autofillHints: [AutofillHints.email],
            validator: (email) => email !=null && !EmailValidator.validate(email)
                ? 'Enter a valid email'
                : null,
          ),
          const SizedBox(height: 20,),
          InkWell(
            onTap: (){},
            borderRadius: BorderRadius.circular(5),
            child: Container(
              width: 450,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: secColor,
                  borderRadius: BorderRadius.circular(5)
              ),
              child: const Center(child: Text("Continue", style: TextStyle(color: Colors.black),)),
            ),
          ),
          const SizedBox(height: 30,),

        ],
      ),
    );
  }
  Widget otpCard(){
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                width: 1.5,
                color: color2
            ),
          ),
          child: const Icon(Icons.fingerprint, size: 20,),
        ),
        const SizedBox(height: 20,),
        const Text("OTP", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
        RichText(
          textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "We have sent a ",
                  style: TextStyle(color: secondaryColor)
                ),
                TextSpan(
                  text: "one-time password ",
                  style: TextStyle(color: reverse, fontWeight: FontWeight.w600)
                ),
                const TextSpan(
                    text: "to ",
                    style: TextStyle(color: secondaryColor)
                ),
                TextSpan(
                    text: _email.text,
                    style: TextStyle(color: reverse, fontWeight: FontWeight.w600)
                ),
              ]
            )
        ),
        const SizedBox(height: 20,),
        PinFieldAutoFill(
          autoFocus: true,
          decoration: BoxLooseDecoration(
            textStyle: TextStyle(color:isMatch ? reverse : Colors.red ),
            gapSpace: 5,
            strokeWidth: 1.5,
            radius: const Radius.circular(5),
            strokeColorBuilder:
            FixedColorBuilder(isMatch ? color5 : Colors.red),
          ),
          currentCode: _otpCode,
          codeLength: _otpCodeLength,
          onCodeChanged: (code) {
            if (code!.length == _otpCodeLength) {
              _otpCode = code;
            }
          },
          onCodeSubmitted: (value) {
            print("Submitted");
          },
        ),
        const SizedBox(height: 20,),
        InkWell(
          onTap: (){},
          borderRadius: BorderRadius.circular(5),
          child: Container(
            width: 450,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                color: secColor,
                borderRadius: BorderRadius.circular(5)
            ),
            child: const Center(child: Text("Continue", style: TextStyle(color: Colors.black),)),
          ),
        ),
        const SizedBox(height: 10,),
        RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "Didn't receive the email? ",
                    style: TextStyle(color: secondaryColor, fontSize: 12)
                ),
                WidgetSpan(
                    child: InkWell(
                      onTap: (){},
                      child: Text(
                          "Click to resend",
                          style: TextStyle(color: secColor, fontWeight: FontWeight.w600,decoration: TextDecoration.underline, fontSize: 12)
                      ),
                    )
                ),
              ]
            )
        )

      ],
    );
  }
  Widget passCard(){
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context, color: color1)
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                width: 1.5,
                color: color2
            ),
          ),
          child: const Icon(Icons.password, size: 20,),
        ),
        const SizedBox(height: 20,),
        const Text("Set new password", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
        const Text(
            "Password must be at least 6 characters",
          style: TextStyle(color: secondaryColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20,),
        const Row(
          children: [
            Text("Password", ),
          ],
        ),
        const SizedBox(height: 5,),
        TextFormField(
          controller: _pass,
          enableSuggestions: true,
          decoration: InputDecoration(
            hintText: "Enter new password",
            hintStyle: const TextStyle(color: secondaryColor),
            border: inputBorder,
            focusedBorder: inputBorder,
            enabledBorder: inputBorder,
            filled: true,
            fillColor: color1,
            contentPadding: const EdgeInsets.all(10),
          ),
          keyboardType: TextInputType.emailAddress,
          autofillHints: [AutofillHints.email],
          validator: (value){
            if (value == null || value.isEmpty) {
              return 'Please enter a password.';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters long.';
            }
            if (!value.contains(RegExp(r'[A-Z]'))) {
              return 'Password must contain at least one uppercase letter.';
            }
            if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 1) {
              return 'Password must contain at least one digit.';
            }
            if (!value.contains(RegExp(r'[!@#\$%^&*()_+{}\[\]:;<>,.?~\\-]'))) {
              return 'Password must contain at least one special character.';
            }
            return null;
          },
        ),
        const SizedBox(height: 10,),
        const Row(
          children: [
            Text("Confirm password",),
          ],
        ),
        const SizedBox(height: 5,),
        TextFormField(
          controller: _repass,
          enableSuggestions: true,
          decoration: InputDecoration(
            hintText: "Re-write password",
            hintStyle: const TextStyle(color: secondaryColor),
            border: inputBorder,
            focusedBorder: inputBorder,
            enabledBorder: inputBorder,
            filled: true,
            fillColor: color1,
            contentPadding: const EdgeInsets.all(10),
          ),
          keyboardType: TextInputType.emailAddress,
          autofillHints: [AutofillHints.email],
            validator: (value){
              if(value != _pass.text.trim()){
                return 'Passwords don\'t match. Please check your new password';
              }
              return null;
            }
        ),
        const SizedBox(height: 20,),
        InkWell(
          onTap: (){},
          borderRadius: BorderRadius.circular(5),
          child: Container(
            width: 450,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                color: secColor,
                borderRadius: BorderRadius.circular(5)
            ),
            child: const Center(child: Text("Reset Password", style: TextStyle(color: Colors.black),)),
          ),
        ),
        const SizedBox(height: 10,)

      ],
    );
  }

  Widget buildIndicator(int length) {
    final secColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    return AnimatedSmoothIndicator(
      activeIndex: activeIndex,
      count: length,
      effect: WormEffect(
        activeDotColor: secColor,
        dotColor: color2,
        dotHeight: 5,
        dotWidth: 80 ,
      ),
    );
  }
}
