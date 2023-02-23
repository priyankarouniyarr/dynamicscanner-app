import 'dart:async';

import 'package:dynamicemrapp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamicemrapp/FaBarcodeScanner.dart';
import 'main.dart';

class FaBarcodeScannerPage extends StatelessWidget {
  FaBarcodeScannerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MyHomePage()));
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
      ],
    ));
  }
}
