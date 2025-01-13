import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';

import '../../main.dart';
import '../../models/entities.dart';
import '../../models/products.dart';
import '../../utils/colors.dart';
import '../text/text_format.dart';

class SelectProduct extends StatefulWidget {
  final EntityModel entity;
  final Function selectingProduct;
  const SelectProduct({super.key, required this.selectingProduct, required this.entity});

  @override
  State<SelectProduct> createState() => _SelectProductState();
}

class _SelectProductState extends State<SelectProduct> {
  TextEditingController _search = TextEditingController();

  List<ProductModel> _products = [];

  bool isFilled = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _products = myProducts.map((jsonString) => ProductModel.fromJson(json.decode(jsonString))).where((test) => test.eid == widget.entity.eid).toList();
  }


  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      _products.forEach((item) {
        if (item.name.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.category.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.supplier.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _products;
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
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
        ),
        Expanded(
          child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index){
                ProductModel product = filteredList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: (){
                      widget.selectingProduct(product);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: color1,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color1,
                            radius: 20,
                            child: LineIcon.box(color: revers,),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name.toString()),
                                Wrap(
                                  spacing: 5,
                                  runSpacing: 2,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: color1
                                      ),
                                      child: Text(product.category.toString(), style: TextStyle(fontSize: 12, color: secondaryColor),),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: color1
                                      ),
                                      child: Text(product.volume.toString(), style: TextStyle(fontSize: 12, color: secondaryColor),),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: color1
                                      ),
                                      child: Text(product.volume.toString(), style: TextStyle(fontSize: 12, color: secondaryColor),),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text("BP ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(product.buying.toString()))}", style: TextStyle(fontSize: 12, color: secondaryColor),),
                              Text("SP ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(product.buying.toString()))}", style: TextStyle(fontSize: 12, color: secondaryColor),),

                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
        )
      ],
    );
  }
}