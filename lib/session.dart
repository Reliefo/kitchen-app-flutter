import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class Session {
  Map<String, String> headers = {};
  String jwt;

  Future<Map> get(String url) async {
    http.Response response = await http.get(url, headers: headers);
    updateCookie(response);
    return json.decode(response.body);
  }

  Future<Map> post(String url, dynamic data) async {
    http.Response response = await http.post(url, body: data, headers: headers);
    updateCookie(response);
    return json.decode(response.body);
  }

  void updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    var decoded = json.decode(response.body);
    jwt = decoded['jwt'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}

//import 'dart:convert';
//
//import 'package:http/http.dart' as http;
//
//class Session {
//  Map<String, String> headers = {};
//  String jwt;
//
//  Future<Map> get(String url) async {
//    http.Response response = await http.get(url, headers: headers);
//    updateCookie(response);
//    return json.decode(response.body);
//  }
//
//  Future<Map> post(String url, dynamic data,
//      {String refresh = "notrequired"}) async {
//    Map<String, String> customHeaders = {};
//    if (refresh != "notrequired") {
//      customHeaders['Authorization'] = "Bearer " + refresh;
//    } else {
//      customHeaders = this.headers;
//    }
//    http.Response response =
//        await http.post(url, body: data, headers: customHeaders);
//    updateCookie(response);
//    return json.decode(response.body);
//  }
//
//  void updateCookie(http.Response response) {
//    String rawCookie = response.headers['set-cookie'];
//    var decoded = json.decode(response.body);
//    jwt = decoded['access_token'];
//    if (rawCookie != null) {
//      int index = rawCookie.indexOf(';');
//      headers['cookie'] =
//          (index == -1) ? rawCookie : rawCookie.substring(0, index);
//    }
//  }
//}
