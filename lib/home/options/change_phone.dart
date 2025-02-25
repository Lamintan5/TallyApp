import 'dart:convert';

import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/widget/text_filed_input.dart';
import 'package:country_picker/country_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/text/text_format.dart';
import '../../utils/colors.dart';


class ChangePhone extends StatefulWidget {
  final Function reload;
  const ChangePhone({super.key, required this.reload});

  @override
  State<ChangePhone> createState() => _ChangePhoneState();
}

class _ChangePhoneState extends State<ChangePhone> {
  TextEditingController _phone = TextEditingController();
  TextEditingController _password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Country _country = CountryParser.parseCountryCode(currentUser.country.toString());
  
  bool obsecure = true;
  bool _loading = false;
  

  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text("Phone", style: TextStyle(fontWeight: FontWeight.normal),),
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
                              Icon(Icons.phone_android, size: 25,),
                              SizedBox(width: 10,),
                              Text("Change Phone Number",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
                            ],
                          ),
                          Text(
                            'In order to change your current phone number, please enter your new phone number and ensure that you have entered your current password. An OTP code will be sent to your new phone number to verify your contact',
                            style: TextStyle(fontSize: 12, color: secondaryColor),
                            textAlign: TextAlign.center,
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
                                  textEditingController: _phone,
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
                              if (TFormat().encryptText(_password.text.trim(), currentUser.uid) != currentUser.password) {
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
                    _changePhone();
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
                      ? SizedBox(width: 20,height: 20, child: CircularProgressIndicator(color: reverse,strokeWidth: 2,))
                      : Text("Change Phone")),
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        ),
      )
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
  _changePhone()async{
    setState(() {
      _loading = true;
    });
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Services.updatePhone("+${_country.phoneCode}${_phone.text}").then((response){
      if(response=="success"){
        sharedPreferences.setString('phone', "+${_country.phoneCode}${_phone.text}");
        currentUser.phone = "+${_country.phoneCode}${_phone.text}";
        widget.reload();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Phone number was updated successfully"),
              showCloseIcon: true,
            )
        );
        setState(() {
          _loading = false;
        });

      } else if (response=="error"){
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Phone number was not updated."),
              action: SnackBarAction(label: "Try again", onPressed: _changePhone),
              showCloseIcon: true,
            )
        );
      } else {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Data().failed),
              action: SnackBarAction(label: "Try again", onPressed: _changePhone),
              showCloseIcon: true,
            )
        );
      }
    });
  }

}
