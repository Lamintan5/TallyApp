import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';

import '../../models/entities.dart';
import '../../models/products.dart';


class ItemSlctPrdSle extends StatefulWidget {
  final ProductModel product;
  final EntityModel entity;
  final String saleId;
  final int quantity;
  final String supplier;
  const ItemSlctPrdSle({super.key, required this.product, required this.entity, required this.saleId, required this.quantity, required this.supplier});

  @override
  State<ItemSlctPrdSle> createState() => _ItemSlctPrdSleState();
}

class _ItemSlctPrdSleState extends State<ItemSlctPrdSle> {
  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
      child: Container(
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color1,
              child: Center(child: LineIcon.box(color: normal,)),
            ),
            SizedBox(width: 10,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(widget.product.name.toString(), style: TextStyle(color: normal, fontWeight: FontWeight.w600),),
                      SizedBox(width: 10,),
                      Text('${widget.product.category}, ', style: TextStyle(color: color, fontSize: 11),),
                    ],
                  ),
                  Wrap(
                    spacing: 5,
                    children: [
                      Text('Volume : ${widget.product.volume},', style: TextStyle(fontSize: 11, color: normal)),
                      Text('Supplier : ${widget.supplier}', style: TextStyle(fontSize: 11, color: normal  ),)
                    ],
                  )
                ],
              ),
            ),
            Text('quantity :  ${widget.quantity}',style: TextStyle(color: normal, fontSize: 11, fontWeight: FontWeight.w700),),
            // _loading
            //     ? SizedBox()
            //     : _qnty == "0"
            //     ? SizedBox()
            //     : _sale.length != 0
            //     ? SizedBox()
            //     : IconButton(
            //       onPressed: (){
            //         _addSale(_inventories.first);
            //       },
            //       icon: Icon(Icons.add)
            //      )
          ],
        ),
      ),
    );
  }
}
