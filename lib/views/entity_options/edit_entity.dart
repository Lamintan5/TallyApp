import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/models/entities.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/text_filed_input.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';

class EditEntity extends StatefulWidget {
  final EntityModel entity;
  final Function getData;
  const EditEntity({super.key, required this.entity, required this.getData});

  @override
  State<EditEntity> createState() => _EditEntityState();
}

class _EditEntityState extends State<EditEntity> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  File? _image;
  String? category;
  bool _loading = false;
  bool _isLoading = false;
  List<String> items = ['Store One', 'Store Two', 'Store Three', 'Store Four' , 'Store Five'];
  final picker = ImagePicker();
  String? currentUserId;
  String oldImage = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      oldImage = widget.entity.image.toString();
      _title.text = widget.entity.title.toString();
      category = widget.entity.category;
    });
  }


  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final dgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: reverse,
        title: Text("Entity Details"),
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            LineIcon.briefcase(size: 30,),
                            SizedBox(width: 10,),
                            Expanded(child: Text("Change Entity Details",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),)),
                          ],
                        ),
                        Text(
                          'To change your user profile by selecting the fields you want to modify and enter the new information. You can update your name, email, password and photo. Tap on update to confirm your edits. Your profile will be updated immediately.',
                          style: TextStyle(fontSize: 12, color: secondaryColor),
                          textAlign: TextAlign.center,
                        ),
                        Expanded(child: SizedBox()),
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
                                              oldImage = "";
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
                                : oldImage != ""
                                ? SizedBox(width: 100, height: 100,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                  widget.entity.image.toString().contains("/") || widget.entity.image.toString().contains("\\")
                                      ? Container(
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
                                                File(oldImage)
                                            )
                                        )
                                    ),
                                  )
                                      : CachedNetworkImage(
                                    cacheManager: customCacheManager,
                                    imageUrl: Services.HOST + '/logos/${oldImage}',
                                    key: UniqueKey(),
                                    fit: BoxFit.cover,
                                    imageBuilder: (context, imageProvider) => Container(
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
                                              image: imageProvider
                                          )
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        Container(
                                          height: 70,
                                          width: 70,
                                        ),
                                    errorWidget: (context, url, error) => Container(
                                      height: 70,
                                      width: 70,
                                      child: Center(child: Icon(Icons.error_outline_rounded, size: 25,),
                                      ),
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
                                              oldImage = "";
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
                        ),
                        SizedBox(height: 30,),
                        Row(
                          children: [
                            Text(' Category :  ', style: TextStyle(color: secondaryColor),),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12,),
                                decoration: BoxDecoration(
                                    color: color1,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        width: 1,
                                        color: color1
                                    )
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: category,
                                    dropdownColor: dgColor,
                                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                                    isExpanded: true,
                                    items: items.map(buildMenuItem).toList(),
                                    onChanged: (value) => setState(() => this.category = value),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: InkWell(
                            onTap: ()async{
                              Navigator.pop(context);
                              EntityModel newEntity = EntityModel(
                                eid: widget.entity.eid,
                                pid: widget.entity.pid,
                                title: _title.text,
                                category: category.toString(),
                                checked: "${widget.entity.checked}, EDIT",
                                image: _image == null ? oldImage : _image!.path,
                                time: widget.entity.time,
                              );
                              await Data().editEntity(context, widget.getData, newEntity, _image, oldImage);
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
                                  : Text('UPDATE', style: TextStyle(color: Colors.black, fontSize: 15,fontWeight: FontWeight.w500),)),
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
    ),
  );
}
