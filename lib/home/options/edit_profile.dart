import 'dart:io';

import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/Widget/dialogs/call_actions/single_call_action.dart';
import 'package:TallyApp/Widget/profile_images/current_profile.dart';
import 'package:TallyApp/Widget/text_filed_input.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/dialogs/dialog_title.dart';
import '../../auth/camera.dart';
import '../../models/avatars.dart';
import '../../models/users.dart';

class EditProfile extends StatefulWidget {
  final Function reload;
  const EditProfile({super.key, required this.reload});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _username = TextEditingController();
  TextEditingController _first = TextEditingController();
  TextEditingController _last = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _pass = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  final _key = GlobalKey<FormState>();

  bool _loading = false;
  bool _isLoading = false;
  File? _image;
  String oldImage = "";
  final picker = ImagePicker();

  late UserModel user;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    oldImage = currentUser.image.toString();
    _username.text = currentUser.username.toString();
    _first.text = currentUser.firstname.toString();
    _last.text = currentUser.lastname.toString();
    _email.text = currentUser.email.toString();
    _phone.text = currentUser.phone.toString();
    user = currentUser;
  }



  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: normal,
        foregroundColor: reverse,
        title: Text("Profile"),
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formkey,
        child: Column(
          children: [
            Row(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(width: 400,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LineIcon.userEdit(size: 30,),
                            SizedBox(width: 10,),
                            Expanded(child: Text("Change User Profile Details",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),)),
                          ],
                        ),
                        Text(
                          'To update your profile, select the fields to modify, enter the new information, and tap \'Update.\' You can change your name, email, password, and photo. Your profile will be updated immediately.',
                          style: TextStyle(fontSize: 12, color: secondaryColor),
                          textAlign: TextAlign.center,
                        ),
                        Expanded(child: SizedBox()),
                        Container(width: 95, height: 95,
                          child: Stack(
                            children: [
                              _image != null
                                  ? CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: FileImage(
                                        File(_image!.path)
                                    ),
                                  )
                                  : Center(child: CurrentImage(radius: 45),),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: MaterialButton(
                                  onPressed: (){dialogPickProfile(context);},
                                  color: secBtn,
                                  minWidth: 5,
                                  elevation: 8,
                                  shape: CircleBorder(),
                                  splashColor: CupertinoColors.systemBlue,
                                  child: Icon(Icons.edit, size: 16,color: normal,),
                                ),
                              ),
                              _isLoading
                                  ? Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: secBtn,strokeWidth: 3,)))
                                  : SizedBox()
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        TextFieldInput(
                          textEditingController: _username,
                          labelText: "Username",textInputType: TextInputType.text,
                          validator: (value){
                            if (value == null || value.isEmpty) {
                              return 'Please enter username.';
                            }
                          },
                        ),
                        SizedBox(height: 20,),
                        TextFieldInput(
                          textEditingController: _first,
                          labelText: "First Name", textInputType: TextInputType.text,
                          validator: (value){
                            if (value == null || value.isEmpty) {
                              return 'Please enter first name.';
                            }
                          },
                        ),
                        SizedBox(height: 20,),
                        TextFieldInput(
                          textEditingController: _last,
                          labelText: "Last Name",textInputType: TextInputType.text,
                          validator: (value){
                            if (value == null || value.isEmpty) {
                              return 'Please enter last name';
                            }
                          },
                        ),
                        SizedBox(height: 30,),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: (){
                final form = _formkey.currentState!;
                if(form.validate()) {
                  _pass.text = "";
                  dialogPassword(context);
                }
              },
              child: Container(
                width: 350,
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      width: 1,color: reverse
                  ),
                ),
                child: Center(child: _loading
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: reverse,strokeWidth: 2,))
                    : Text("Update")),
              ),
            ),
            SizedBox(height: 5,),
            Text(Data().message,
              style: TextStyle(color: secondaryColor, fontSize: 10),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
  void dialogPickProfile(BuildContext context){
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    showDialog(
        builder: (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
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
                _image != null
                    ? InkWell(
                  onTap: (){
                    Navigator.pop(context);
                    setState(() {
                      _image = null;
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
            ),
          ),
        ), context: context
    );
  }
  void dialogPassword(BuildContext context){
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          backgroundColor: dilogbg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: Form(
            key: _key,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Container(
              width: 450,
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTitle(title: "P A S S W O R D"),
                  const Text('Please enter your current password to update your profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryColor, ),
                  ),
                  SizedBox(height: 10,),
                  TextFieldInput(
                    textEditingController: _pass,
                    labelText: "Password",
                    isPass: true,
                    validator: (value){
                      if(value!=currentUser.password){
                        return "Please enter the correct password";
                      }
                    },
                  ),
                  DoubleCallAction(
                    title: "Update",
                      action: (){
                    final form = _key.currentState!;
                    if(form.validate()) {
                      Navigator.pop(context);
                      _update();
                    }}
                  )
                ],
              ),
            ),
          ),
        )
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

  _setPicture(File? image){
    setState(() {
      _image = image;
    });
  }
  _update()async{
    setState(() {
      _loading = true;
    });
    await Services.updateProfile(_username.text.toString(), _first.text.toString(), _last.text.toString(), _image).then((response)async{
      final String responseString = await response.stream.bytesToString();
      print(responseString);
      if(responseString.contains("success")){
        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('first', _first.text.toString());
        sharedPreferences.setString('last', _last.text.toString());
        sharedPreferences.setString('username', _username.text.toString());
        sharedPreferences.setString('image', _image == null? currentUser.image.toString() : _image!.path);
        sharedPreferences.setString('type', _image == null? currentUser.type.toString() : "FILE");
        currentUser = UserModel(
          uid: user.uid.toString(),
          firstname: _first.text.toString(),
          lastname: _last.text.toString(),
          username: _username.text.toString(),
          email: user.email.toString(),
          phone: user.phone.toString(),
          image: _image == null? currentUser.image.toString() : _image!.path,
          type: _image == null? currentUser.type.toString() : "FILE",
          url: user.url,
          password: user.password,
          status: user.status,
        );
        widget.reload();
        Navigator.pop(context);
        Get.snackbar(
            "Success",
            "User Profile was updated successfully.",
            icon: Icon(CupertinoIcons.checkmark_alt, color: Colors.green),
            shouldIconPulse: true,
            maxWidth: 500,
        );
      } else if(responseString.contains("Exists")){
        Get.snackbar(
          "Error",
          "Username already Exists. Please try a different user name.",
          icon: Icon(Icons.warning_amber_rounded, color: Colors.red),
          shouldIconPulse: true,
          maxWidth: 500,
        );
      } else if(responseString.contains("error")){
        Get.snackbar(
          "Error",
          "User Account was not updated. Please try again later.",
          icon: Icon(Icons.warning_amber_rounded, color: Colors.red),
          shouldIconPulse: true,
          maxWidth: 500,
        );
      } else {
        Get.snackbar(
          "Error",
          "mhmm🤔 seems like something went wrong. Please try again later",
          icon: Icon(Icons.warning_amber_rounded, color: Colors.red),
          shouldIconPulse: true,
          maxWidth: 500,
        );
      }
      setState(() {
        _loading = false;
      });
    });

  }

  Future choiceImage() async {
    setState(() {
      _isLoading = true;
    });
    var pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage!.path);
      _isLoading = false;
    });
  }
}
