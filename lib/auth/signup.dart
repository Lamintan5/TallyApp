import 'dart:io';
import 'package:TallyApp/Widget/dialogs/call_actions/single_call_action.dart';
import 'package:TallyApp/Widget/logos/row_logo.dart';
import 'package:TallyApp/auth/password.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:TallyApp/Widget/emailTextFormWidget.dart';
import 'package:TallyApp/Widget/text_filed_input.dart';
import 'package:TallyApp/auth/verify_email.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icon.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uuid/uuid.dart';

import '../Widget/dialogs/dialog_ipaddress.dart';
import '../Widget/dialogs/dialog_title.dart';
import '../api/api_service.dart';
import '../api/google_signin_api.dart';
import '../main.dart';
import '../models/avatars.dart';
import '../models/data.dart';
import '../models/users.dart';
import 'camera.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _secondName = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  File? _image;

  bool obsecure = true;
  bool obsecureConfirm = true;
  bool loading = false;

  String imageUrl = '';
  String type = '';

  bool _isLoading = false;

  final picker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  DateTime now = DateTime.now();

  var pickedImage;
  Country _country = CountryParser.parseCountryCode('US');


  @override
  Widget build(BuildContext context) {
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final secColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final bold = TextStyle(fontWeight: FontWeight.bold, color: revers);
    final boldBtn = TextStyle(color: secColor, fontWeight: FontWeight.bold);
    final style = TextStyle(color: revers);
    return Scaffold(
      body: Stack(
        children: [
          Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RowLogo(text: 'Login Account',),
                        IconButton(onPressed: (){dialogIpAddress(context);}, icon: Icon(Icons.settings)),
                      ],
                    ),
                    SizedBox(height: 30,),
                    Expanded(
                      child: Container(
                        width: 450,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: SingleChildScrollView(
                          child: Column(
                              children: [
                                Row(
                                  children: [
                                    LineIcon.user(size: 26),SizedBox(width: 10,),
                                    Text('Profile', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),),
                                  ],
                                ),
                                SizedBox(height: 20,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        _image != null
                                            ? ClipOval(
                                          child: Image.file(_image!, width: 100, height: 100, fit: BoxFit.cover,),
                                        )
                                            : imageUrl == ''? ClipOval(
                                          child: Image.asset("assets/add/default_profile.png", width: 100, height: 100,),
                                        ) : ClipOval(
                                          child: Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover,),
                                        ),
                                        loading ? CircularProgressIndicator() : SizedBox(),
                                        Positioned(
                                          bottom: -10,
                                          left: 65,
                                          child: IconButton(
                                            onPressed: () {
                                              dialogPickProfile(context);
                                            },
                                            icon: Icon(Icons.add_a_photo, color: secColor,),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 20,),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: TextFieldInput(
                                                  textEditingController: _firstName,
                                                  labelText: 'First Name',
                                                  textInputType: TextInputType.text,
                                                  validator: (value){
                                                    if (value == null || value.isEmpty) {
                                                      return 'Please enter your First Name';
                                                    }
                                                    return null;
                                                  },

                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Expanded(
                                                child: TextFieldInput(
                                                  textEditingController: _secondName,
                                                  labelText: 'Second Name',
                                                  textInputType: TextInputType.text,
                                                  validator: (value){
                                                    if (value == null || value.isEmpty) {
                                                      return 'Please enter your Second Name';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          TextFieldInput(
                                            textEditingController: _usernameController,
                                            labelText: 'Username',
                                            textInputType: TextInputType.text,
                                            validator: (value){
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your Username';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20,),
                                Row(
                                  children: [
                                    LineIcon.mobilePhone(size: 26),SizedBox(width: 10,),
                                    Text('Contact', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),),
                                  ],
                                ),
                                SizedBox(height: 20,),
                                EmailTextFormWidget(
                                  controller: _emailController,
                                  action: 'no',
                                ),
                                SizedBox(height: 20,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: _showPicker,
                                      child: Container(
                                        width: 60, height: 48,
                                        decoration: BoxDecoration(
                                          color: color1,
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              width: 1, color: color1
                                          ),
                                        ),
                                        child: Center(
                                            child: Text("+${_country.phoneCode}")
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5,),
                                    Expanded(
                                      child: TextFieldInput(
                                        textEditingController: _phoneController,
                                        labelText: "Phone",
                                        maxLength: 10,
                                        textInputType: TextInputType.phone,
                                        validator: (value){
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a phone number.';
                                          }
                                          if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
                                            return null; // Valid input (contains only digits)
                                          } else {
                                            return 'Please enter a valid phone number';
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 20,),
                                Row(
                                  children: [
                                    LineIcon.lock(size: 26),SizedBox(width: 10,),
                                    Text('Security', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),),
                                  ],
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
                                          obsecure =! obsecure;
                                        });
                                      },
                                      icon: Icon(obsecure?Icons.remove_red_eye_outlined : Icons.remove_red_eye)),
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
                                SizedBox(height: 20,),
                                TextFieldInput(
                                  textEditingController: _confirmPassword,
                                  labelText: "Confirm Password",
                                  textInputType: TextInputType.text,
                                  isPass: obsecureConfirm,
                                  validator: (value){
                                    if(value != _passwordController.text.trim()){
                                      return 'Passwords don\'t match. Please check your new password';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20,),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: MaterialButton(
                                    onPressed: (){
                                      final form = formKey.currentState!;
                                      if(form.validate()) {
                                        if(_isLoading){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Please wait!", style: TextStyle(color: revers),),
                                                backgroundColor: dilogbg,
                                                behavior: SnackBarBehavior.floating,
                                              )
                                          );
                                        } else {
                                          _verifyEmail();
                                        }
                                      }
                                    },
                                    child: _isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,)) : Text("Create Account"),
                                    minWidth: 500,
                                    color: secColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Already have an account? '),
                                    InkWell(
                                        onTap: (){
                                          Get.to(() => Login(), transition: Transition.rightToLeft);
                                        },
                                        child: Text("Login", style: boldBtn,))
                                  ],
                                ),
                                SizedBox(height: 10,),
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
                                Platform.isAndroid || Platform.isIOS ? Text('Continue with...') : SizedBox(),
                                Platform.isAndroid || Platform.isIOS ? SizedBox(height: 10,) : SizedBox(),
                                Platform.isAndroid || Platform.isIOS ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Tooltip(
                                      message: "Register with Facebook",
                                      child: InkWell(
                                        onTap:(){},
                                        borderRadius: BorderRadius.circular(15),
                                        splashColor: CupertinoColors.activeBlue,
                                        child: Container(
                                          padding: EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                              color: CupertinoColors.activeBlue,
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(
                                                  width: 2, color: Colors.blue
                                              )
                                          ),
                                          child: Image.asset(
                                            'assets/add/fb.png',
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
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
                                    SizedBox(width: Platform.isAndroid || Platform.isIOS ?10:0,),
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
                                                Theme.of(context).brightness == Brightness.dark?'assets/add/apple_2.png' : 'assets/add/apple.png',
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        )
                                        : SizedBox(),
                                  ],
                                ) : SizedBox(),
                              ]
                          ),
                        ),
                      ),
                    ),
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            children: [
                              TextSpan(
                                  text: 'By ',
                                  style: style
                              ),
                              TextSpan(
                                  text: 'creating an account, ',
                                  style: bold
                              ),
                              TextSpan(
                                  text: 'you agree to our ',
                                  style: style
                              ),
                              WidgetSpan(
                                child: InkWell(
                                  onTap: () {
                                    // Handle button press
                                  },
                                  child: Text('User Agreement ',style: boldBtn),
                                ),
                              ),
                              TextSpan(
                                  text: 'and acknowledge reading our ',
                                  style: style
                              ),
                              WidgetSpan(
                                child: InkWell(
                                  onTap: () {
                                    // Get.to(() => PrivacyPolicy(), transition: Transition.rightToLeft);
                                  },
                                  child: Text('User Privacy Notice.',style: boldBtn),
                                ),
                              ),
                            ]
                        ), textScaler: TextScaler.linear(0.8)
                    ),
                  ],
                ),
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
  void dialogAvatar(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final size =MediaQuery.of(context).size;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            )
        ),
        backgroundColor: dilogbg,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        constraints: BoxConstraints(
            maxHeight: size.height - 100,
            minHeight: size.height/2,
            maxWidth: 500,minWidth: 400
        ),
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DialogTitle(title: "C H O O S E  A V A T A R"),
                SizedBox(height: 5,),
                Text('${avatars.length.toString()} avatars'),
                SizedBox(height: 5,),
                Expanded(
                  child: GridView.builder(
                    itemCount: avatars.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1
                    ),
                    itemBuilder: (context, index){
                      return InkWell(
                        onTap: (){
                          setState(() {
                            imageUrl =avatars[index].toString();
                            _image = null;
                          });
                          Navigator.pop(context);
                        },
                        child: CachedNetworkImage(
                          cacheManager: customCacheManager,
                          imageUrl: avatars[index].toString(),
                          key: UniqueKey(),
                          fit: BoxFit.cover,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(avatars[index].toString()),
                                )
                            ),
                          ),
                          placeholder: (context, url) => SizedBox(),
                          errorWidget: (context, url, error) => Center(child: Icon(Icons.error_outline_rounded,),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        }
    );
  }
  void _showPicker(){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context, color: color1,)
    );
    showCountryPicker(
        context: context,
        countryListTheme: CountryListThemeData(
            textStyle: TextStyle(fontWeight: FontWeight.w400),
            bottomSheetHeight: MediaQuery.of(context).size.height / 2,
            backgroundColor: dilogbg,
            borderRadius: BorderRadius.circular(10),
            inputDecoration:  InputDecoration(
              hintText: "🔎 Search for your country here",
              hintStyle: TextStyle(color: secondaryColor),
              border: inputBorder,
              isDense: true,
              fillColor: color1,
              contentPadding: const EdgeInsets.all(10),

            )
        ),
        onSelect: (country){
          setState(() {
            this._country = country;
          });
        });
  }
  void dialogPickProfile(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    showDialog(
        builder: (context) => Dialog(
          backgroundColor: dilogbg,
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          child: Container(width: 450,
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DialogTitle(title: "P R O F I L E"),
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                    choiceImage();
                  },
                  borderRadius: BorderRadius.circular(5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Icon(Icons.photo_sharp, color: secondaryColor,),
                        SizedBox(width: 10,),
                        Text("Gallery", style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w500),)
                      ],
                    ),
                  ),
                ),
                Platform.isWindows || Platform.isLinux || Platform.isMacOS
                    ? SizedBox()
                    :  InkWell(
                  onTap: (){
                    Navigator.pop(context);
                    Get.to(()=>CameraScreen(setPicture: _setPicture,), transition: Transition.downToUp);
                  },
                  borderRadius: BorderRadius.circular(5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        LineIcon.camera(color: secondaryColor),
                        SizedBox(width: 10,),
                        Text("Camera", style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w500))
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                    dialogAvatar(context);
                  },
                  borderRadius: BorderRadius.circular(5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_emotions, color: secondaryColor),
                        SizedBox(width: 10,),
                        Text("Avatar", style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w500),)
                      ],
                    ),
                  ),
                ),
                _image != null || imageUrl != ""
                    ? InkWell(
                  onTap: (){
                    Navigator.pop(context);
                    setState(() {
                      _image = null;
                      imageUrl = "";
                    });
                  },
                  borderRadius: BorderRadius.circular(5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Icon(Icons.remove),
                        SizedBox(width: 10,),
                        Text("Remove Photo")
                      ],
                    ),
                  ),
                )
                    : SizedBox(),
                SingleCallAction()
              ],
            )
          ),
        ), context: context
    );
  }
  Future choiceImage() async {
    setState(() {
      loading = true;
    });
    pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageUrl = '';
      _image = File(pickedImage!.path);
      loading = false;
    });
  }
  _setPicture(File? image){
    setState(() {
      _image = image;
    });
  }
  _verifyEmail()async{
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final dilogbg = Theme.of(context).brightness ==  Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    const uuid = Uuid();
    String id = uuid.v1();
    setState(() {
      _isLoading = true;
      if(imageUrl!=""){
        type = "AVATAR";
      } else if(_image != null) {
        type = "FILE";
      } else {
        type = "";
      }
    });
    UserModel userModel = UserModel(
      uid: id,
      username: _usernameController.text.trim().toString(),
      firstname: _firstName.text.trim().toString(),
      lastname: _secondName.text.trim().toString(),
      email: _emailController.text.trim().toString(),
      phone: "+"+ _country.phoneCode+_phoneController.text.trim().toString(),
      password: _passwordController.text.trim().toString(),
      type: type,
      image: _image!=null?_image!.path:"",
      status: "",
      url: imageUrl,
      token: "",
      time: DateTime.now().toString(),
    );
    APIService.otpLogin(_emailController.text.trim()).then((response)async{
      print(response.data);
      setState(() {
        _isLoading = false;
      });
      if(response.data != null){
        await Get.to(()=>VerifyEmail(otpHash: response.data.toString(), userModel: userModel, reload: (){setState(() {});},), transition: Transition.rightToLeft);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Data().failed),
              showCloseIcon: true,
            )
        );
      }
    });
  }

  Future signIn()async{
    final user = await GoogleSignInApi.login();
    if(user==null){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed'),
            showCloseIcon: true,
          )
      );
    } else {
      Get.to(() => PasswordScreen(user: user), transition: Transition.rightToLeft);
    }
// _registerUsers()async{
//   const uuid = Uuid();
//   String id = uuid.v1();
//   setState(() {
//     _isLoading = true;
//   });
//   Services.registerUsers(
//       id,
//       _usernameController.text.trim().toString(),
//       _firstName.text.trim().toString(),
//       _secondName.text.trim().toString(),
//       _emailController.text.trim().toString(),
//       _phoneController.text.trim().toString(),
//       _confirmPassword.text.trim().toString(),
//       type, _image,"",)
//       .then((response) async{
//     final String responseString = await response.stream.bytesToString();
//     if (responseString.contains('Exists'))
//     {
//       Get.snackbar(
//         'Authentication',
//         'Username already exists.',
//         shouldIconPulse: true,
//         icon: Icon(Icons.error, color: Colors.red),
//       );
//     } else if (responseString.contains('Error'))
//     {
//       Get.snackbar(
//         'Authentication',
//         'Email already registered.',
//         shouldIconPulse: true,
//         icon: Icon(Icons.error, color: Colors.red),
//       );
//     } else if (responseString.contains('Success'))
//     {
//       final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//       sharedPreferences.setString('uid', id);
//       sharedPreferences.setString('first', _firstName.text.trim());
//       sharedPreferences.setString('last', _secondName.text.trim());
//       sharedPreferences.setString('username', _usernameController.text.trim());
//       sharedPreferences.setString('email', _emailController.text.trim());
//       sharedPreferences.setString('image', imageUrl.trim());
//       sharedPreferences.setString('phone', _phoneController.text.trim());
//       sharedPreferences.setString('type', type.toString());
//       sharedPreferences.setString('password', _passwordController.text.trim());
//       currentUser.uid = id;
//       currentUser.username = _usernameController.text.trim().toString();
//       currentUser.firstname = _firstName.text.trim().toString();
//       currentUser.lastname = _secondName.text.trim().toString();
//       currentUser.image = '';
//       currentUser.email = _emailController.text.trim().toString();
//       currentUser.phone = _phoneController.text.trim().toString();
//       currentUser.type = type.toString();
//       currentUser.password = _passwordController.text.trim().toString();
//       //Get.offAll(()=>ShowCaseWidget(builder: (context) => HomeScreen()), transition: Transition.fadeIn);
//       Get.snackbar(
//         'Authentication',
//         'User account created successfully.',
//         shouldIconPulse: true,
//         icon: Icon(Icons.check, color: Colors.green),
//       );
//     } else
//     {
//       Get.snackbar(
//         'Authentication',
//         'An error occurred. please try again0',
//         shouldIconPulse: true,
//         icon: Icon(Icons.error, color: Colors.red),
//       );
//     }
//     setState(() {
//       _isLoading = false;
//     });
//   });
// }
  }
}
