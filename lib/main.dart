import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:dynamicemrapp/screen/homepage.dart';
import 'package:dynamicemrapp/screen/sign%20in/signIn.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DynamicEMR',
      theme: ThemeData(primarySwatch: Colors.pink),

      home: FutureBuilder(
        future: isJwtValid,
        builder: ((context, snapshot) {
          if (snapshot.data != null) {
            if (snapshot.data == true) {
              return MyHomePage(title: 'DynamicEmr');
            } else {
              return SignIn();
            }
          } else {
            return SignIn();
          }
        }),
      ),
    );
  }

  Future<bool> get isJwtValid async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = (prefs.getString('DynamicEmrLoginToken') ?? "");
    if (jwtToken == "") {
      return false;
    }

    bool isExpired = Jwt.isExpired(jwtToken);
    log("isExpired: $isExpired");
    String expiryDate = (prefs.getString('DyanmicEmrLoginExpiration') ?? "");
    log(expiryDate);
    DateTime todayDate = DateTime.now();
    if (expiryDate != "") {
      DateTime expiryDateTime = DateTime.parse((expiryDate));
      if (expiryDateTime.compareTo(todayDate) < 0) {
        isExpired = true;
      }
    }

    return !isExpired;
  }
}
