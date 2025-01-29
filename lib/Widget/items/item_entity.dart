import 'dart:async';
import 'dart:io';

import 'package:TallyApp/Widget/logos/prop_logo.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/models/sales.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:TallyApp/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/data.dart';
import '../../views/entity_dash.dart';
import '../frosted_glass.dart';
import '../text/text_format.dart';

class ItemEntity extends StatefulWidget {
  final EntityModel entity;
  final Function getEntities;
  const ItemEntity({super.key, required this.entity, required this.getEntities});

  @override
  State<ItemEntity> createState() => _ItemEntityState();
}

class _ItemEntityState extends State<ItemEntity> {
  List<SaleModel> _sale = [];
  EntityModel entity = EntityModel(eid: "", image: "", title: "");
  bool _loading = false;
  double totalSprice= 0;
  String image = '';
  late Timer timer;
  List<String> _managers = [];

  _getSales()async{
    setState(() {
      _loading = true;
    });
    _sale = await Services().getCmptSale(widget.entity.eid);
    setState(() {
      totalSprice = _sale.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.sprice.toString()) * double.parse(element.quantity.toString())));
      _loading = false;
    });
  }

  _getDetails()async {
    setState(() {
      entity = widget.entity;
    });
    print("Updated Item");
  }

  _updateEntity()async{
    print("Update Entity callback called");
    entity.checked = 'true';
    timer.cancel();
    widget.getEntities();
    setState(() {
      entity.image = widget.entity.image!.split("\\").last;
      image = entity.image!;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
    image = entity.image!;
    _managers = entity.pid!.split(",");
    _managers.removeAt(0);
  }

  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final style = TextStyle(color: revers, fontSize: 13);
    final secondary = TextStyle(color: secondaryColor, fontSize: 13);
    return InkWell(
      onTap: (){
        Get.to(()=> EntityDash(entity: entity, getData: widget.getEntities), transition: Transition.rightToLeft);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            SizedBox(width: double.infinity, height: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: entity.image == "" && entity.checked == "true"
                    ? SizedBox()
                    : entity.checked == "false"
                    ? Opacity(opacity: 0.05,
                  child: Image.file(
                    File(entity.image!),
                    fit: BoxFit.cover,
                  ),
                )
                    : Opacity(
                  opacity: 0.05,
                  child: CachedNetworkImage(
                    cacheManager: customCacheManager,
                    imageUrl: Services.HOST + '/logos/${image}',
                    key: UniqueKey(),
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(
                          height: 40,
                          width: 40,
                        ),
                    errorWidget: (context, url, error) => Container(
                      height: 40,
                      width: 40,
                      child: Center(child: Icon(Icons.error_outline_rounded, size: 25,),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
                child: FrostedGlass(width: double.infinity, height: double.infinity)
            ),
            Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Hero(
                      tag: entity,
                      child: PropLogo(entity: entity, radius: 40,from: 'GRID',)),
                )),
            entity.checked == "false"
                ? Positioned(
                    top: 5,right: 10,
                    child: Icon(Icons.cloud_upload_rounded, color: Colors.red)
                )
                : SizedBox(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                margin: EdgeInsets.all(1),
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                    color: normal,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)
                    )
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.entity.title!.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(
                                  text: '${TFormat().getCurrency()}${formatNumberWithCommas(totalSprice)} ',
                                  style: style
                              ),
                              TextSpan(
                                  text: "total revenue",
                                  style: secondary
                              )
                            ]
                        )
                    ) ,
                    RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _managers.length.toString(),
                              style: style
                            ),
                            TextSpan(
                                text: _managers.length == 1? " manager" : " managers",
                                style: TextStyle(fontSize: 13, color: secondaryColor)
                            ),
                          ]
                        )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  static final customCacheManager = CacheManager(
      Config(
        'customCacheManager',
        maxNrOfCacheObjects: 1,
      )
  );

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
