import 'package:flutter/material.dart';
import 'package:barcode_scanner/core.dart';
import 'package:barcode_scanner/rtu_ui_common.dart';
import 'package:barcode_scanner/rtu_ui_barcode.dart';
import 'package:barcode_scanner/classic_components.dart';
import 'package:barcode_scanner/scanbot_barcode_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

class FaBarcodeScanner extends StatefulWidget {
  const FaBarcodeScanner({Key? key}) : super(key: key);

  @override
  _FaBarcodeScannerState createState() => _FaBarcodeScannerState();
}

class _FaBarcodeScannerState extends State<FaBarcodeScanner> {
  String _scanBarcode = 'Unknown';

  Future<void> scanBarcodeNormal() async {
    // Check for camera permission
    if (await Permission.camera.request().isGranted) {
      try {
        // final barcodeScanRes = await BarcodeScanner.scan();
        // if (!mounted) return;

        // setState(() {
        //   _scanBarcode = barcodeScanRes.rawContent.isNotEmpty
        //       ? barcodeScanRes.rawContent
        //       : 'No barcode detected';
        // });
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _scanBarcode = 'Error: $e';
        });
      }
    } else {
      if (!mounted) return;

      setState(() {
        _scanBarcode = 'Camera permission denied';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Scan')),
      body: Center(
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: scanBarcodeNormal,
              child: const Text('Start barcode scan'),
            ),

            Text(
              'Scan result: $_scanBarcode\n',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
