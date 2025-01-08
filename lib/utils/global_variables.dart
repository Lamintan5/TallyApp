import 'package:TallyApp/home/tabs/payments.dart';
import 'package:TallyApp/home/tabs/reports.dart';
import 'package:TallyApp/home/tabs/sell_buy.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:showcaseview/showcaseview.dart';

import '../home/tabs/profile.dart';
import '../home/tabs/scanner.dart';


List<StatefulWidget> homeScreenItems = [
  ProfilePage(),
  SellOrBuy(),
  Payments(entity: EntityModel(eid: ""),),
  Reports(entity: EntityModel(eid: ""),),
];