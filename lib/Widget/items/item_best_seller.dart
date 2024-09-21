import 'dart:convert';

import 'package:TallyApp/Widget/profile_images/user_profile.dart';
import 'package:TallyApp/Widget/shimmer_widget.dart';
import 'package:TallyApp/Widget/text/text_format.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/sales.dart';
import 'package:TallyApp/models/users.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../models/data.dart';

class ItemBestSeller extends StatefulWidget {
  final SaleModel sale;
  final double percentage;
  final double revenue;
  const ItemBestSeller({super.key, required this.sale, required this.percentage, required this.revenue});

  @override
  State<ItemBestSeller> createState() => _ItemBestSellerState();
}

class _ItemBestSellerState extends State<ItemBestSeller> {
  List<UserModel> _usr = [];
  List<UserModel> _newUser = [];
  late UserModel user;
  bool _loading = false;

  _getDetails()async{
    _getData();
    _newUser = await Services().getCrntUsr(widget.sale.sellerid!);
    Data().addOrUpdateUserList(_newUser);
    _getData();
  }

  _getData()async{
    setState(() {
      _loading = true;
    });
    _usr = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    setState(() {
      user = _usr.firstWhere((test) => test.uid == widget.sale.sellerid, orElse: ()=> UserModel(uid: "", username: ""));
      _loading = false;
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ?SizedBox(width: 500,
      child: ListView.builder(
          itemCount: 5,
          shrinkWrap: true,
          itemBuilder: (context, index){
            return Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: 200,
              child: Row(
                children: [
                  ShimmerWidget.circular(height: 40, width: 40,),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerWidget.rectangular(height: 10, width: 100,),
                        SizedBox(height: 4,),
                        ShimmerWidget.rectangular(height: 10, width: double.infinity,),
                        SizedBox(height: 2,),
                        ShimmerWidget.rectangular(height: 10, width: double.infinity,),
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
    )
        :Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          UserProfile(image: user.image.toString()),
          SizedBox(width: 5,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username.toString(), style: TextStyle(fontSize: 13),),
                Row(
                  children: [
                    Text(user.firstname.toString()+" ${user.lastname}", style: TextStyle(color: secondaryColor,fontSize: 12)),
                    Expanded(child: SizedBox()),
                    Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(widget.revenue)}", style: TextStyle(color: secondaryColor,fontSize: 12)),
                  ],
                ),
                LinearPercentIndicator(
                  animation: true,
                  animateFromLastPercent: true,
                  animationDuration: 800,
                  padding: EdgeInsets.zero,
                  lineHeight: 5,
                  percent: widget.percentage,
                  progressColor: Colors.cyan,
                  backgroundColor: Colors.cyan.withOpacity(0.2),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
