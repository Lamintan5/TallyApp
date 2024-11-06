import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/text_filed_input.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import '../models/entities.dart';

import 'package:encrypt/encrypt.dart' as encrypt;

class Create extends StatefulWidget {
  final Function getData;
  const Create({super.key, required this.getData});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  final TextEditingController _title = TextEditingController();
  TextEditingController _location = TextEditingController();
  File? _image; String? category;
  bool _loading = false;
  bool _isLoading = false;
  List<String> items = ['Store One', 'Store Two', 'Store Three', 'Store Four' , 'Store Five'];
  final picker = ImagePicker();
  String? currentUserId;
  List<String> _utilities = [];
  List<EntityModel> _entity = [];
  String eid = '';
  final formKey = GlobalKey<FormState>();

  final _key = encrypt.Key.fromUtf8('f2caaf40-68db-11ee-b339-f1847070'); // 256-bit key
  final _iv = encrypt.IV.fromLength(16);


  Future getValidations() async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var obtainId = sharedPreferences.getString('uid');
    setState(() {
      currentUserId = obtainId;
    });
  }
  Future choiceImage() async {
    setState(() {
      _loading = true;
    });
    var pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage!.path);
      _loading = false;
    });
  }

  String encryptText(String text) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  Future<void> publish()async {
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    List<String> pids = [];
    pids.add(currentUser.uid);
    Uuid uuid = Uuid();
    eid = uuid.v1();

    EntityModel entityModel = EntityModel(
      eid: eid,
      pid: pids.join(","),
      admin: currentUser.uid,
      title: _title.text.trim().toString(),
      category: category.toString(),
      location: _location.text.trim().toString(),
      image: _image==null?"":_image!.path,
      checked: "false",
      time: DateTime.now().toString(),
    );

    _entity.add(entityModel);
    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    widget.getData();
    Navigator.pop(context);

    final response =  await Services.addEntity(eid, pids, _title.text.trim().toString(), category.toString(),
        _location.text.trim().toString(), _image);
    final String responseString = await response.stream.bytesToString();
    if(responseString.contains("Success")){
      _entity.firstWhere((test) => test.eid == eid).checked = "true";
      _entity.firstWhere((test) => test.eid == eid).image = entityModel.image.toString().contains("\\")
          ? entityModel.image.toString().split("\\").last
          : entityModel.image.toString().split("/").last;
      uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList('myentity', uniqueEntities);
      myEntity = uniqueEntities;
      widget.getData();
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    category = "Store One";
    getValidations();

  }

  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final reverse =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final appBarColor =  Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: reverse,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Row(),
              Expanded(
                child: Container(
                  width: 400,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Create Business', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),),
                      Text(
                        'Embark on Your Entrepreneurial Journey with TallyApp: Simplify your first business venture with TallyApp\'s user-friendly tools for inventory management, record-keeping, expense tracking, and financial reporting. Elevate your business growth by focusing on what truly matters while we handle the details. Start shaping your success story today!',
                      style: TextStyle(fontWeight: FontWeight.w200, color: secondaryColor),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _image != null
                              ? SizedBox(width: 100, height: 100,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                        width: 70, height: 70,
                                        margin: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: secondaryColor,
                                            width: 2,
                                          ),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: FileImage(
                                                _image!
                                            )
                                          )
                                        ),
                                      ),
                                    Positioned(
                                      bottom: 0, right: 0,
                                        child: IconButton(
                                            onPressed: (){
                                              choiceImage();
                                            },
                                            icon: Icon(Icons.change_circle))),
                                    Positioned(
                                        top: 0, left: 0,
                                        child: IconButton(
                                            onPressed: (){
                                              setState(() {
                                                _image = null;
                                              });
                                            },
                                            icon: Icon(Icons.cancel))),
                                    _loading ? SizedBox(
                                        width: 40,height: 40,
                                        child: CircularProgressIndicator(strokeWidth: 1 ,color: Colors.white,))
                                        : SizedBox(),
                                  ],
                                ),
                              )
                              : InkWell(
                              onTap: (){
                                choiceImage();
                              },
                              child: Image.asset("assets/add/add-image.png", width: 80, height: 80,)
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10,),
                                Text('Business Logo',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                Text('Add a logo to this Business. This action is optional', style: TextStyle(color: secondaryColor, fontSize: 11),),
                                SizedBox(height: 5,),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20,),
                      TextFieldInput(
                        textEditingController: _title,
                        labelText: 'Business Title',
                        textInputType: TextInputType.text,
                        validator: (value){
                          if(value == null || value == ""){
                            return 'Please enter your Business title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20,),
                      // Row(
                      //   children: [
                      //     Text(' Category :  ', style: TextStyle(color: secondaryColor),),
                      //     Expanded(
                      //       child: Container(
                      //         padding: EdgeInsets.symmetric(horizontal: 12,),
                      //         decoration: BoxDecoration(
                      //           color: color1,
                      //             borderRadius: BorderRadius.circular(5),
                      //           border: Border.all(
                      //             width: 1,
                      //             color: color1
                      //           )
                      //         ),
                      //         child: DropdownButtonHideUnderline(
                      //           child: DropdownButton<String>(
                      //             dropdownColor: appBarColor,
                      //             value: category,
                      //             icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                      //             isExpanded: true,
                      //             items: items.map(buildMenuItem).toList(),
                      //             onChanged: (value) => setState(() => this.category = value),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: 30,),
                      TextFieldInput(
                        textEditingController: _location,
                        labelText: 'Location',
                        textInputType: TextInputType.text,
                        srfIcon: IconButton(icon: Icon(Icons.location_on_outlined), onPressed: (){},),
                        validator: (value){
                          if(value == null || value == ""){
                            return 'Please enter your property location';
                          }
                        },
                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: InkWell(
                          onTap: (){
                            final form = formKey.currentState!;
                            if(form.validate()) {
                              publish();
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.cyan,
                            ),
                            child: Center(child: _isLoading
                                ? SizedBox(width: 15, height: 15,
                                  child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,))
                                : Text('Publish', style: TextStyle(color: Colors.black, fontSize: 15,fontWeight: FontWeight.w500),)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Text(Data().message,
                style: TextStyle(color: secondaryColor, fontSize: 11),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
    ),
  );
// _createEntity()async{
//   const uuid = Uuid();
//   String eid = uuid.v1();
//   List<String> pidList = [];
//   setState(() {
//     pidList.add(currentUserId!);
//     _isLoading = true;
//   });
//   Services.addEntity(
//       eid,
//       pidList,
//       _title.text.trim().toString(),
//       category!,
//       _image).then((response)async {
//     final String responseString = await response.stream.bytesToString();
//     if (responseString.contains('Success')) {
//       Get.snackbar(
//         'Entity',
//         'Entity was created successfully',
//         shouldIconPulse: true,
//         icon: Icon(Icons.check, color: Colors.green),
//       );
//       widget.getEntity();
//       Navigator.pop(context);
//     } else {
//       Get.snackbar(
//         'Entity',
//         'Something went wrong while creating entity. Please try again.',
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
