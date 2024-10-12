import 'dart:convert';

import 'package:TallyApp/Widget/emailTextFormWidget.dart';
import 'package:TallyApp/Widget/text_filed_input.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/api_service.dart';
import '../../auth/verify_email.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key});

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool obsecure = true;
  bool _loading = false;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: Text("E-mail", style: TextStyle(fontWeight: FontWeight.normal),),
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 20,),
              Row(),
              Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(width: 450,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.mail, size: 25,),
                              SizedBox(width: 10,),
                              Text("Change E-mail Address",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
                            ],
                          ),
                          Text(
                            'In order to change your current email address, please enter your new email and ensure that you have entered your current password. An OTP code will be sent to your new email to verify your email address',
                            style: TextStyle(fontSize: 12, color: secondaryColor),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20,),
                          EmailTextFormWidget(controller: _email),
                          SizedBox(height: 20,),
                          TextFieldInput(
                            textEditingController: _password,
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
                              if (md5.convert(utf8.encode(value!)).toString()!= currentUser.password) {
                                return 'Please Enter the correct password';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  )
              ),
              InkWell(
                onTap: (){
                  final form = formKey.currentState!;
                  if(form.validate()) {
                    setState(() {
                      _loading = true;
                    });
                    APIService.otpLogin(_email.text.trim()).then((response)async{
                      print(response.data);
                      setState(() {
                        _loading = false;
                      });
                      if(response.data != null){
                        await Get.to(()=>VerifyEmail(otpHash: response.data.toString(), userModel: currentUser, reload: (){setState(() {});}, email: _email.text.trim(),), transition: Transition.rightToLeft);
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
                      ?  SizedBox(width: 20,height: 20, child: CircularProgressIndicator(color: reverse,strokeWidth: 2,))
                      : Text("Change Email")),
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        ),
      ),
    );
  }
}
