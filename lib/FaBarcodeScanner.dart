import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class FaBarcodeScanner extends StatefulWidget {
  const FaBarcodeScanner({Key? key}) : super(key: key);

  @override
  _FaBarcodeScannerState createState() => _FaBarcodeScannerState();
}

class _FaBarcodeScannerState extends State<FaBarcodeScanner> {
  String _scanBarcode = 'No scan result yet';
  bool _isScanning = false;
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _startBarcodeScan() {
    setState(() {
      _isScanning = true;
      _scanBarcode = 'Scanning...';
    });
  }

  void _stopBarcodeScan() {
    setState(() {
      _isScanning = false;
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
              Navigator.pop(context);
            },
          ),
        ),
        body: _isScanning
            ? Stack(
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        setState(() {
                          _scanBarcode =
                              barcodes.first.rawValue ?? 'No value detected';
                          _isScanning = false;
                        });
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
                    Text(
                      'Scan result: $_scanBarcode\n',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
