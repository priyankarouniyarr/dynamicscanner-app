import 'package:dynamicemrapp/FaBarcodeScanner.dart';
import 'package:flutter/material.dart';
import 'package:dynamicemrapp/signIn.dart';
import 'package:dynamicemrapp/patientInfo.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddImage.dart';
import 'FaCardDetails.dart';
import 'appSettings.dart';
import 'patientInfo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DynamicEMR',
      theme: ThemeData(primarySwatch: Colors.pink),
      //home: MyHomePage(title: 'Image'),
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
          })),
    );
  }

  Future<bool> get isJwtValid async {
    final prefs = await SharedPreferences.getInstance();
    String jwtToken = (prefs.getString('DynamicEmrLoginToken') ?? "");
    if (jwtToken == "") {
      return false;
    }

    bool isExpired = Jwt.isExpired(jwtToken);
    return !isExpired;
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
            Color.fromRGBO(46, 25, 96, 1),
            Color.fromRGBO(93, 16, 73, 1)
          ])),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Dynamic EMR'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.lock_person_rounded),
                tooltip: 'Log Out',
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignIn()));
                },
              ),
            ],
          ),
          body: Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        "Scan Document",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 30),
                          child: Text(
                            "Take picture from camera and upload it to the server. Click Below to add Image",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromRGBO(0, 0, 0, 0.1),
                            padding: const EdgeInsets.symmetric(
                                vertical: 30, horizontal: 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text(
                            "Add an Image",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          onPressed: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddImage()))
                          },
                        ),
                      ],
                    )
                  ]),
            ),
          ),
          drawer: Drawer(
              child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.pink),
                child: Text('DynamicEMR'),
              ),
              ListTile(
                title: const Text('Document Scanner'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('FA Barcode Scanner'),
                onTap: () {
                  // Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FaBarcodeScanner()));
                },
              ),              
              ListTile(
                title: const Text('FA Details'),
                onTap: () {
                  // Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AccordionPage()));
                },
              ),
            ],
          ))),
    );
  }
}
