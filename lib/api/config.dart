import 'dart:developer';

import 'package:TallyApp/resources/services.dart';

import '../main.dart';


class Config{
  static String apiURL = "$domain:4000";

  static String otpLoginAPI = Services.HOST + "api/otpLogin";
  static String otpVerifyAPI = Services.HOST + "api/verifyOTP";
} 