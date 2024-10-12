import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'login_response.dart';

class APIService {
  static var client  = http.Client();

  static Future<LogInResponseModel> otpLogin (String email) async {
    var url = Uri.http(Config.apiURL, "/api/otp-login");
    var response = await client.post(
        url,
        headers: {'Content-type':"application/json"},
        body: jsonEncode({
          "email":email
        })
    );
    return logInResponseModel(response.body);
  }

  static Future<LogInResponseModel> verifyOTP (String email, String otpHash, String otpCode) async {
    var url = Uri.http(Config.apiURL, "/api/otp-verify");
    var response = await client.post(
        url,
        headers: {'Content-type':"application/json"},
        body: jsonEncode({
          "email":email,
          "otp": otpCode,
          "hash": otpHash
        })
    );
    return logInResponseModel(response.body);
  }

  static Future<LogInResponseModel> otpSmsLogin(String mobileNo) async{
    Map<String, String> requestHeaders = {
      'Content-Type' : 'application/json'
    };
    var url = Uri.http(Config.apiURL, Config.otpLoginAPI);
    var response = await client.post(url, headers: requestHeaders,
      body: jsonEncode(
        {
          "phone":mobileNo
        },
      ),
    );
    return logInResponseModel(response.body);
  }

  static Future<LogInResponseModel> verifySmsLogin(String mobileNo, String otpHash, String otpCode) async{
    Map<String, String> requestHeaders = {
      'Content-Type' : 'application/json'
    };
    var url = Uri.http(Config.apiURL, Config.otpVerifyAPI);
    var response = await client.post(url, headers: requestHeaders,
      body: jsonEncode(
        {
          "phone":mobileNo,
          "otp": otpCode,
          "hash": otpHash
        },
      ),
    );
    return logInResponseModel(response.body);
  }

  Future<void> getUserData(String onesignalId) async {
    // Define the API URL and headers
    String url = 'https://api.onesignal.com/apps/41db0b95-b70f-44a5-a5bf-ad849c74352e/users/by/onesignal_id/$onesignalId';

    // Authorization header: replace with your OneSignal API key
    Map<String, String> headers = {
      'Authorization': 'Basic 41db0b95-b70f-44a5-a5bf-ad849c74352e',
      'Content-Type': 'application/json'
    };

    try {
      // Make the GET request
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        // Parse the JSON data
        Map<String, dynamic> data = json.decode(response.body);

        // Example: Access a specific value from the response
        String? onesignalId = data['identity']?['onesignal_id'];
        String? token = data['subscriptions']?[0]?['token'];

        print('OneSignal ID: $onesignalId');
        print('Device Token: $token');
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

}