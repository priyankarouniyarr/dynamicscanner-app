import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FaBarcodeScanner extends StatefulWidget {
  const FaBarcodeScanner({Key? key}) : super(key: key);

  @override
  _FaBarcodeScannerState createState() => _FaBarcodeScannerState();
}

class _FaBarcodeScannerState extends State<FaBarcodeScanner> {
  bool _isScanning = false;
  bool _showWebView = false;
  String _webViewUrl = '';
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _startBarcodeScan() {
    setState(() {
      _isScanning = true;
      _showWebView = false;
      // _scanBarcode = 'Scanning...';
    });
  }

  void _stopBarcodeScan() {
    setState(() {
      _isScanning = false;
    });
  }

  // Function to convert string to Base64
  String _toBase64(String input) {
    return base64Encode(utf8.encode(input));
  }

  void _openWebView(String barcode) {
    final encodedBarcode = _toBase64(barcode);
    log("Encoded Barcode: $encodedBarcode");
    setState(() {
      // _scanBarcode = encodedBarcode;
      _showWebView = true;
      _webViewUrl =
          'http://45.117.153.90:5001/FaCardFrontEnd/FaCardDetails?cardBarcode=$encodedBarcode';
      log(_webViewUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(46, 25, 96, 1),
            Color.fromRGBO(93, 16, 73, 1),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Barcode scan',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          centerTitle: true,
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              log(_showWebView.toString());

              Navigator.pop(context);
            },
          ),
        ),
        body: _showWebView
            ? WebViewWidget(
                controller: WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..loadRequest(Uri.parse(_webViewUrl)),
              )
            : _isScanning
            ? Stack(
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: (capture) {
                      log(
                        "Barcode detected: ${capture.barcodes.first.rawValue}",
                      );
                      final List<Barcode> barcodes = capture.barcodes;
                      log("Barcodes: $barcodes");
                      if (barcodes.isNotEmpty) {
                        final rawValue =
                            barcodes.first.rawValue ?? 'No value detected';
                        log("Raw Value: $rawValue");
                        _openWebView(rawValue);
                      }
                    },
                  ),
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: ElevatedButton(
                      onPressed: _stopBarcodeScan,
                      child: const Text(
                        'Cancel Scan',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _startBarcodeScan,
                      child: const Text(
                        'Start barcode scan',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
