import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/empty_data.dart';
import 'package:TallyApp/models/users.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icon.dart';
import 'package:uuid/uuid.dart';

import '../../../Widget/MessCards/mess_items/item_chat.dart';
import '../../../Widget/MessCards/mess_items/item_chat_group.dart';
import '../../../Widget/MessCards/own_file_card.dart';
import '../../../Widget/MessCards/own_mess_card.dart';
import '../../../Widget/MessCards/target_file_card.dart';
import '../../../Widget/MessCards/target_mes_card.dart';
import '../../../Widget/buttons/options_button.dart';
import '../../../Widget/profile_images/user_profile.dart';
import '../../../main.dart';
import '../../../models/chats.dart';
import '../../../models/data.dart';
import '../../../models/messages.dart';
import '../../../resources/services.dart';
import '../../../resources/socket.dart';

class WebChat extends StatefulWidget {
  final UserModel selected;
  const WebChat({super.key, required this.selected});

  @override
  State<WebChat> createState() => _WebChatState();
}

class _WebChatState extends State<WebChat> {
  TextEditingController _search = TextEditingController();

  UserModel selectedUser = UserModel(uid: "");
  final TextEditingController messageController = TextEditingController();

  late ScrollController _scrollcontroller;
  late GlobalKey<AnimatedListState> _key;

  bool isShowEmojiContainer = false;
  bool isFilled = false;

  final isDialOpen =ValueNotifier(false);
  FocusNode focusNode = FocusNode();
  bool isShowSendButton = false;
  FocusNode _focusNode = FocusNode();
  bool more = false;
  String mid = '';
  String imageUrl = '';
  String chatType = '';
  List<String> _uidList = [];
  final picker = ImagePicker();
  File? _image;
  List<String> gidList = [];
  List<MessModel> mess = [];
  List<MessModel> messages = [];
  List<UserModel> _users = [];
  List<UserModel> _newUsers = [];
  final socketManager = Get.find<SocketManager>();

  void setMessage(String mid, String gid,String sourceId, String targetId, String message, String path, String type,String time){
    MessModel messageModel = MessModel(
      mid: mid,
      gid: gid,
      targetId: targetId,
      sourceId: sourceId,
      message: message,
      time: time,
      path: path,
      type: type,
      deleted: "",
      seen: "",
      delivered: "",
      checked: "false",
    );
    if(messages.contains(messageModel)){

    } else {
      messages.add(messageModel);
      Data().addOrUpdateMessagesList(messages);
      // widget.changeMess(messageModel);
      List<String> _cidList = [sourceId,targetId];
      _cidList.sort();
      ChatsModel chatsModel = ChatsModel(
        cid: _cidList.join(","),
        title: "",
        time: time,
        type: type,
      );
      final socketManager = Get.find<SocketManager>();
      List<ChatsModel> _chats = socketManager.chats;
      if(_chats.contains(chatsModel)){
        _chats.firstWhere((element) => element.cid == chatsModel.cid).time = chatsModel.time;
        _chats.firstWhere((element) => element.cid == chatsModel.cid).type = chatsModel.type;
      } else {
        _chats.add(chatsModel);
      }
      Data().addOrUpdateChats(_chats);

      if (mounted && _key.currentState != null) {
        _key.currentState!.insertItem(messages.length - 1, duration: Duration(milliseconds: 800));
      }
    }
  }
  void sendMessage(String mid,String message, String sourceId, String targetId,String path, String type,String time){
    setMessage(mid, gidList.join(','), sourceId, targetId, message,path, type, time);
    SocketManager().socket.emit("message", {
      "mid": mid,
      "gid": gidList.join(','),
      "sourceId":sourceId,
      "targetId":targetId,
      "message":message,
      "path":path.isEmpty? "" : "${Services.HOST}uploads/${path}",
      "time":time,
      "type":type,
      "title": currentUser.username,
      "token": selectedUser.token.toString().split(","),
      "profile": currentUser.image.toString().isEmpty
          ? ""
          : currentUser.image!.contains("https://")
          ? currentUser.image
          : currentUser.image.toString().contains("/")
          ? Services.HOST + 'profile/${currentUser.image.toString().split("/").last}'
          : currentUser.image.toString().contains("\\")
          ? Services.HOST + 'profile/${currentUser.image.toString().split("\\").last}'
          : Services.HOST + 'profile/${currentUser.image.toString()}',
    });
  }
  void connect() {
    SocketManager().socket.on("message", (msg) {
      setMessage(
        msg['mid'],
        msg['gid'],
        msg['sourceId'],
        msg['targetId'],
        msg['message'],
        msg["path"],
        msg["type"],
        msg['time'],
      );
    });
  }

  _getDetails()async{
    _getData();
    _getData();
  }

  _getData(){
    _users = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    setState(() {
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedUser = widget.selected;
    connect();
    _getDetails();
    chatType = 'individual';
    _scrollcontroller = ScrollController();
    _key = GlobalKey();
    gidList = [selectedUser.uid, currentUser.uid];
    gidList.sort();
    mess = myMess.map((jsonString) => MessModel.fromJson(json.decode(jsonString))).toList();
    messages = mess.where((element) => "${element.sourceId},${element.targetId}".contains(currentUser.uid) && "${element.sourceId},${element.targetId}".contains(selectedUser.uid) && element.type.toString()== "individual").toList();
    _uidList.add(selectedUser.uid.toString());
    _uidList.add(currentUser.uid);
    if(messages.isNotEmpty && selectedUser.uid != ""){
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollcontroller.jumpTo(_scrollcontroller.position.extentTotal);
      });
    }
    // _updateSeen();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _search.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final image =  Theme.of(context).brightness == Brightness.dark
        ? "assets/logo/5logo_72.png"
        : "assets/logo/5logo_72_black.png";
    final socketManager = Get.find<SocketManager>();
    List<ChatsModel> mychats = socketManager.chats;
    mychats.sort((a, b) => b.time!.compareTo(a.time.toString()));

    List<ChatsModel> chats = [];

    if (_search.text.isNotEmpty) {
      chats = mychats.where((item) =>
          item.title.toString().toLowerCase().contains(_search.text.toLowerCase()))
          .toList();
    } else {
      chats = mychats;
    }
    return Scaffold(
      backgroundColor: normal,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: (){Navigator.pop(context);},
                      borderRadius: BorderRadius.circular(5),
                      hoverColor: color1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(CupertinoIcons.arrow_left),
                      )
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: CupertinoColors.activeBlue
                    ),
                    child: Text("Beta", style: TextStyle(fontSize: 12, color: Colors.black),),
                  )
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [

                        Expanded(child: SizedBox()),
                        Image.asset(
                            height: 30,
                            image
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: 450,
                        minWidth: 300
                    ),
                    decoration: BoxDecoration(
                        color: color1,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)
                        )
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Obx(() => Text("${mychats.length} C H A T S", style: TextStyle(fontWeight: FontWeight.w100, fontSize: 20))),
                            Expanded(child: SizedBox()),
                            InkWell(
                                onTap: (){},
                                borderRadius: BorderRadius.circular(5),
                                hoverColor: color1  ,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: LineIcon.editAlt(),
                                )
                            ),
                            SizedBox(width: 5,),
                            InkWell(
                                onTap: (){},
                                borderRadius: BorderRadius.circular(5),
                                hoverColor: color1  ,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.filter_list),
                                )
                            ),
                            SizedBox(width: 5,),
                            InkWell(
                                onTap: (){},
                                borderRadius: BorderRadius.circular(5),
                                hoverColor: color1  ,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.more_vert),
                                )
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: _search,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Search",
                            fillColor: color1,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(5)
                              ),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
                            prefixIcon: Icon(CupertinoIcons.search, size: 20,color: secondaryColor),
                            prefixIconConstraints: BoxConstraints(
                                minWidth: 40,
                                minHeight: 30
                            ),
                            suffixIcon: isFilled?InkWell(
                                onTap: (){
                                  _search.clear();
                                  setState(() {
                                    isFilled = false;
                                  });
                                },
                                borderRadius: BorderRadius.circular(100),
                                child: Icon(Icons.cancel, size: 20,color: secondaryColor)
                            ) :SizedBox(),
                            suffixIconConstraints: BoxConstraints(
                                minWidth: 40,
                                minHeight: 30
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
                            filled: true,
                            isDense: true,
                          ),
                          onChanged:  (value) => setState((){
                            if(value.isNotEmpty){
                              isFilled = true;
                            } else {
                              isFilled = false;
                            }
                          }),
                        ),
                        SizedBox(height: 10,),
                        Expanded(
                          child: Obx(
                                  ()=> ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount:chats.length,
                                  itemBuilder: (context, index){
                                    ChatsModel chat = chats[index];
                                    late UserModel usr;
                                    var eids = [];
                                    if(chat.type=="individual"){
                                      eids = chat.cid.split(',');
                                      eids.remove(currentUser.uid);
                                      usr = _users.firstWhere((test) => test.uid == eids.first, orElse: () => UserModel(uid: ""));
                                    }
                                    return chat.type != "individual"
                                        ? InkWell(
                                            onTap: (){
                                            },
                                            child: ItemChatGroup(chats: chat,from: "WEB",)
                                          )
                                        : InkWell(
                                            onTap: (){
                                              setState(() {
                                                selectedUser = usr;
                                                messages = mess.where((element) => "${element.sourceId},${element.targetId}".contains(currentUser.uid) && "${element.sourceId},${element.targetId}".contains(selectedUser.uid) && element.type.toString()== "individual").toList();
                                              });
                                            },
                                            child: ItemChat(chatmodel: chat, from: "WEB",))
                                          ;
                                  })
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 1,),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: color1,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomLeft: Radius.circular(5),
                          )
                      ),
                      margin: EdgeInsets.only(right: 10),
                      child:selectedUser.uid==""
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/add/box.png"),
                          Text("Studio5ive Messaging", style: TextStyle(fontSize: 18),),
                          Text("Please select any user to start a conversation", style: TextStyle(color: secondaryColor),)
                        ],
                      )
                          : Stack(
                        children: [
                          Theme.of(context).brightness == Brightness.dark
                              ? Container(
                            width:double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  opacity: 0.6,
                                  fit: BoxFit.cover,
                                  image: AssetImage('assets/wallpaper/damascus.jpg'),
                                )
                            ),
                          )
                              : SizedBox(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                                child: Row(
                                  children: [
                                    UserProfile(image: selectedUser.image!),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(selectedUser.username.toString(), style: TextStyle(color: reverse)),
                                          Text("${selectedUser.firstname.toString()} ${selectedUser.lastname.toString()}", style: TextStyle(color: secondaryColor,fontSize: 12),),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: color1,
                                          child: IconButton(onPressed: (){}, icon: Icon(Icons.video_call), color: Colors.blue,),
                                        ),
                                        SizedBox(width: 5,),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: color1,
                                          child: IconButton(onPressed: (){}, icon: Icon(Icons.call), color: Colors.blue,),
                                        ),

                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: 950,
                                            minWidth: 500
                                          ),
                                          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                          child: AnimatedList(
                                              physics: BouncingScrollPhysics(),
                                              key: _key,
                                              controller: _scrollcontroller,
                                              initialItemCount: messages.length,
                                              itemBuilder: (((context, index, animation){
                                                MessModel mess = messages[index];
                                                if(mess.sourceId==currentUser.uid){
                                                  if(mess.path==""){
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: SizeTransition(
                                                        key: UniqueKey(),
                                                        sizeFactor: animation,
                                                        child: OwnMessCard(messModel: mess,),
                                                      ),
                                                    );
                                                  } else {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: SizeTransition(
                                                        key: UniqueKey(),
                                                        sizeFactor: animation,
                                                        child: OwnFileCard(messModel: mess,),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  if(mess.path==""){
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: SizeTransition(
                                                        key: UniqueKey(),
                                                        sizeFactor: animation,
                                                        child: TargetMessCard(messModel: mess,),
                                                      ),
                                                    );
                                                  } else {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: SizeTransition(
                                                        key: UniqueKey(),
                                                        sizeFactor: animation,
                                                        child: TargetFileCard(messModel: mess,),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }))
                                          ),
                                        ),
                                      ),
                                      const Positioned(
                                        top: 10,
                                        left: 0,right: 0,
                                        child:
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.lock, size: 10, color: CupertinoColors.systemBlue,),
                                            SizedBox(width: 5,),
                                            Text("end-to-end-encryption", style: TextStyle(color: CupertinoColors.systemBlue,fontSize: 11),),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                              ),
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: (){
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        if (more == false){
                                          hideEmojiContainer();
                                        }
                                        setState(() {
                                          more = !more;
                                        });
                                      },
                                      icon: Icon(more ? Icons.add_circle : Icons.add_circle_outline_outlined)),
                                  IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.photo_on_rectangle)),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: color1,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: TextFormField(
                                                focusNode: _focusNode,
                                                onChanged: (val) {
                                                  if(val.isNotEmpty) {
                                                    setState((){
                                                      isShowSendButton = true;
                                                    });
                                                  } else {
                                                    setState((){
                                                      isShowSendButton = false;
                                                    });
                                                  }
                                                },
                                                controller: messageController,
                                                keyboardType: TextInputType.multiline,
                                                minLines: 1,
                                                maxLines: 7,
                                                decoration: InputDecoration(
                                                  hintText: "Message @${selectedUser.username}",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  filled: false,
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                                onTap: (){
                                                  more = false;
                                                },
                                              )
                                          ),
                                          InkWell(onTap: (){
                                            setState(() {
                                              more = false;
                                            });
                                            toggleEmojiContainer();
                                          },child: Icon(isShowEmojiContainer? Icons.emoji_emotions  : Icons.emoji_emotions_outlined)),
                                          SizedBox(width: 10,),
                                          isShowSendButton
                                              ? InkWell(
                                            onTap: (){
                                              Uuid uuid = Uuid();
                                              mid = uuid.v1();
                                              String time = DateTime.now().toString();
                                              sendMessage(
                                                mid,
                                                messageController.text.toString(),
                                                currentUser.uid,
                                                selectedUser.uid,
                                                "",
                                                "individual",
                                                time,
                                              );
                                              _scrollcontroller.animateTo(_scrollcontroller.position.maxScrollExtent, duration: Duration(milliseconds: 800), curve: Curves.easeInOut);
                                              messageController.clear();
                                            },
                                            child: Icon(CupertinoIcons.location_fill),
                                          )
                                              : Icon(CupertinoIcons.mic),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              isShowEmojiContainer
                                  ? SizedBox()
                                  : AnimatedContainer(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                height: more ? 310 : 0,
                                duration: const Duration(milliseconds:500),
                                child: Wrap(
                                  spacing: 40,
                                  runSpacing: 20,
                                  children: [
                                    InkWell(onTap: choiceImage,child: OptionsButton( icon: LineIcon.photoVideo(color: reverse,), text: 'Gallery')),
                                    OptionsButton( icon: Icon(Icons.gif, color: reverse,), text: 'GIFs'),
                                    OptionsButton( icon: LineIcon.stickyNote(color: reverse,), text: 'Sticker'),
                                    OptionsButton( icon: Icon(Icons.attach_file, color: reverse,), text: 'Files'),
                                    OptionsButton( icon: Icon(Icons.location_on, color: reverse,), text: 'Location'),
                                    OptionsButton( icon: LineIcon.user(color: reverse,), text: 'Contacts'),
                                    OptionsButton( icon: LineIcon.clock(color: reverse,), text: 'Schedule'),
                                  ],
                                ),
                              ),
                              isShowEmojiContainer
                                  ? SizedBox(
                                height: 310,
                                child: EmojiPicker(
                                    config: Config(
                                      emojiViewConfig: EmojiViewConfig(
                                        columns: 10,
                                        emojiSizeMax: 20,
                                        backgroundColor: Colors.transparent,
                                        noRecents: Text(
                                          'No Recents',
                                          style: TextStyle(fontSize: 20, color: reverse),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      categoryViewConfig: CategoryViewConfig(
                                          indicatorColor: reverse,
                                          iconColorSelected: reverse,
                                          backgroundColor: Colors.transparent
                                      ),
                                      bottomActionBarConfig: BottomActionBarConfig(
                                          backgroundColor: Colors.transparent,
                                          buttonColor: normal
                                      ),
                                      searchViewConfig: SearchViewConfig(
                                        backgroundColor: Colors.transparent,
                                        buttonIconColor: reverse,
                                      ),
                                    ),
                                    onEmojiSelected: (category, emoji) {
                                      final currentPosition = messageController.selection.baseOffset;
                                      final newText = messageController.text.replaceRange(
                                        currentPosition,
                                        currentPosition,
                                        emoji.emoji,
                                      );
                                      setState(() {
                                        messageController.value = messageController.value.copyWith(
                                          text: newText,
                                          selection: TextSelection.collapsed(
                                            offset: currentPosition + emoji.emoji.length,
                                          ),
                                        );
                                      });
                                    },
                                    onBackspacePressed: (){
                                      final currentPosition = messageController.selection.baseOffset;
                                      final currentText = messageController.text;

                                      if (currentPosition > 0) {
                                        final newText = currentText.substring(0, currentPosition - 1) +
                                            currentText.substring(currentPosition);

                                        setState(() {
                                          messageController.value = messageController.value.copyWith(
                                            text: newText,
                                            selection: TextSelection.collapsed(
                                              offset: currentPosition - 1,
                                            ),
                                          );
                                        });
                                      }
                                    }
                                ),
                              )
                                  : const SizedBox(),
                            ],
                          ),
                        ],
                      ),

                    ),
                  ),
                ],
              ),
            ),
            Text(
              Data().message,
              style: TextStyle(fontSize: 12, color: secondaryColor),
            )
          ],
        ),
      ),
    );
  }
  Future choiceImage() async {
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageUrl = '';
      _image = File(pickedImage!.path);
      // Get.to(()=>MediaView(path: _image!.path, onImageSend: onImageSend));
    });
  }

  void _clearValues() {
    messageController.text = '';
  }
  void hideEmojiContainer(){
    setState((){
      more = false;
      isShowEmojiContainer = false;
    });
  }
  void showEmojiContainer(){
    setState((){
      more = false;
      isShowEmojiContainer = true;
    });
  }
  void showKeyBoard() => focusNode.requestFocus();
  void hideKeyBoard() => focusNode.unfocus();
  void toggleEmojiContainer(){
    if(isShowEmojiContainer){
      showKeyBoard();
      hideEmojiContainer();
    } else {
      hideKeyBoard();
      showEmojiContainer();
    }
  }
}
