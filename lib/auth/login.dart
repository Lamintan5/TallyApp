import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/emailTextFormWidget.dart';
import 'package:TallyApp/auth/reset.dart';
import 'package:TallyApp/auth/restore.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/users.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:showcaseview/showcaseview.dart';

import '../Home/homescreen.dart';
import '../Widget/dialogs/dialog_ipaddress.dart';
import '../Widget/logos/row_logo.dart';
import '../Widget/text_filed_input.dart';
import '../api/google_signin_api.dart';
import '../home/web_home.dart';
import '../resources/socket.dart';
import '../utils/colors.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<UserModel> _user = [];
  List<UserModel> fltUsrs = [];

  UserModel user = UserModel(uid: "");
  bool obsecure = true;
  bool select = false;
  bool checked = true;
  String id = '';
  bool _isLoading = false;
  String email = '';
  String token = '';
  List<String> tokens = [];

  _getUser()async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
    });
    _user = await Services().getUser(email==""?_emailController.text.trim().toString():email);
    user = _user.first;
    token = Platform.isAndroid || Platform.isIOS ? deviceModel.id! : "";
    tokens = user.token.toString().split(",");
    tokens.add(token);
    tokens.remove("");
    await Services.updateToken(user.uid, tokens.join(",")).then((value){
      print("Token : $token, ${value}");
    });
    sharedPreferences.setString('uid', user.uid.toString());
    sharedPreferences.setString('username', user.username.toString());
    sharedPreferences.setString('first', user.firstname.toString());
    sharedPreferences.setString('last', user.lastname.toString());
    sharedPreferences.setString('image', user.image.toString());
    sharedPreferences.setString('email', user.email.toString());
    sharedPreferences.setString('phone', user.phone.toString());
    sharedPreferences.setString('type', user.type.toString());
    sharedPreferences.setString('token', token.toString());
    sharedPreferences.setString('country', user.country.toString());
    sharedPreferences.setString('password', user.password.toString());

    currentUser.uid = user.uid.toString();
    currentUser.username = user.username.toString();
    currentUser.firstname = user.firstname.toString();
    currentUser.lastname = user.lastname.toString();
    currentUser.image = user.image.toString();
    currentUser.email = user.email.toString();
    currentUser.phone = user.phone.toString();
    currentUser.type = user.type.toString();
    currentUser.token = token.toString();
    currentUser.password = user.password.toString();
    currentUser.country = user.country.toString();
    Get.offAll(()=>Restore(), transition: Transition.fadeIn);
    setState(() {
      _isLoading = false;
    });
  }
  _loginUser()async{
    setState(() {
      _isLoading = true;
    });
    var response;
    if (email == "") {
      response = await Services.loginUsers(_emailController.text.trim().toString(), _passwordController.text.trim().toString());
    } else {
      response = await Services.loginUserWithEmail(email);
    }
    print("Response $response");
    if(response.contains('Success')){
      _getUser();
    }
    else if(response.contains('Error')){
      Get.snackbar(
          'Authentication',
          'Invalid credentials. Please check you email or password',
          shouldIconPulse: true,
          icon: Icon(Icons.close, color: Colors.red),
          maxWidth: 500
      );
      setState(() {
        _isLoading = false;
      });
    }
    else {
      Get.snackbar(
        'Authentication',
        'mmhmm, 🤔 seems like something went wrong. Please try again.',
        shouldIconPulse: true,
        maxWidth: 500,
        icon: Icon(Icons.close, color: Colors.red),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(deviceModel.id==null){
      SocketManager().initPlatform();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final secColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final bold = TextStyle(fontWeight: FontWeight.bold, color: revers);
    final boldBtn = TextStyle(color: secColor, fontWeight: FontWeight.bold);
    final style = TextStyle(color: revers);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RowLogo(text: 'Login Account',),
                      // IconButton(onPressed: (){dialogIpAddress(context);}, icon: Icon(Icons.settings)),
                    ],
                  ),
                  Expanded(
                      child: Padding( 
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SizedBox(width: 450,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Hello',style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Sign in to TallyApp or '),
                                  InkWell(
                                      onTap: (){
                                        Get.to(() => SignUp(), transition: Transition.rightToLeft);
                                      },
                                      child: Text("Create Account", style: boldBtn,))
                                ],
                              ),
                              SizedBox(height: 30,),
                              EmailTextFormWidget(
                                controller: _emailController,
                              ),
                              SizedBox(height: 20,),
                              TextFieldInput(
                                textEditingController: _passwordController,
                                labelText: "Password",
                                textInputType: TextInputType.text,
                                isPass: obsecure,
                                srfIcon: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        obsecure = !obsecure;
                                      });
                                    },
                                    icon: Icon(obsecure?Icons.remove_red_eye: Icons.remove_red_eye_outlined)
                                ),
                                prxIcon:Icon(Icons.lock_outline),
                              ),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                      onTap: (){
                                        Get.to(() => Reset(), transition: Transition.rightToLeft);
                                      },
                                      borderRadius: BorderRadius.circular(5),
                                      child: Text("Forgot your password?", style: TextStyle(color: secColor),)
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: InkWell(
                                  onTap: (){
                                    _loginUser();
                                  },
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.cyan,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(child: _isLoading
                                        ? SizedBox(
                                        width: 15,height: 15,
                                        child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,))
                                        :Text("Continue", style: TextStyle(color: Colors.black),),),
                                  ),
                                ),
                              ),
                              SizedBox(height: 30,),
                              Platform.isAndroid || Platform.isIOS ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                      height: 1,
                                    ),
                                  ),
                                  Text('  or  '),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ) : SizedBox(),
                              Platform.isAndroid || Platform.isIOS ? SizedBox(height: 10,) : SizedBox(),
                              Platform.isAndroid || Platform.isIOS ? Text('Continue login') : SizedBox(),
                              Platform.isAndroid || Platform.isIOS ? SizedBox(height: 10,) : SizedBox(),
                              Platform.isAndroid || Platform.isIOS ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Tooltip(
                                  //   message: "Register with Facebook",
                                  //   child: InkWell(
                                  //     onTap:(){},
                                  //     borderRadius: BorderRadius.circular(15),
                                  //     splashColor: CupertinoColors.activeBlue,
                                  //     child: Container(
                                  //       padding: EdgeInsets.all(15),
                                  //       decoration: BoxDecoration(
                                  //           color: CupertinoColors.activeBlue,
                                  //           borderRadius: BorderRadius.circular(15),
                                  //           border: Border.all(
                                  //               width: 2, color: Colors.blue
                                  //           )
                                  //       ),
                                  //       child: Image.asset(
                                  //         'assets/add/fb.png',
                                  //         height: 30,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(width: 10,),
                                  Tooltip(
                                    message: "Register with Google",
                                    child: InkWell(
                                      onTap:signIn,
                                      borderRadius: BorderRadius.circular(15),
                                      splashColor: CupertinoColors.activeBlue,
                                      child: Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: color2,
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                                width: 2, color: color1
                                            )
                                        ),
                                        child: Image.asset(
                                          'assets/add/google_2.png',
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width:Platform.isIOS ?10:0,),
                                  Platform.isIOS
                                      ? Tooltip(
                                    message: "Register with Apple",
                                    child: InkWell(
                                      onTap: (){},
                                      borderRadius: BorderRadius.circular(15),
                                      splashColor: CupertinoColors.activeBlue,
                                      child: Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: color2,
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                                width: 2, color: color1
                                            )
                                        ),
                                        child: Image.asset(
                                          Theme.of(context).brightness == Brightness.dark? 'assets/add/apple_2.png' : 'assets/add/apple.png',
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                  )
                                      : SizedBox(),
                                ],
                              ) : SizedBox(),
                            ],
                          ),
                        ),
                      )
                  ),
                  Text(Data().message,
                    style: TextStyle(color: secondaryColor, fontSize: 10),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
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
              borderRadius: BorderRadius.circular(20)
          ),
          child: SizedBox(width: 400,
            child: DialogIpaddress(),
          ),
        ), context: context
    );
  }
  Future signIn()async{
    final user = await GoogleSignInApi.login();
    if(user==null){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login unsuccessful'),
            showCloseIcon: true,
          )
      );
    } else {
      email = user.email;
      _loginUser();
      await GoogleSignInApi.logout();
    }
  }
}
