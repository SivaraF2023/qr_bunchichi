import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';

import 'orderApi.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  State<ScannerPage> createState() => _QRViewState();
}

class _QRViewState extends State<ScannerPage> {
  bool _camState = false;
  String _errorMessage = '';

  _qrCallback(String? data) {
    setState(() {
      _camState = false;
    });
  }

  _scanCode() {
    setState(() {
      _camState = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _scanCode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //error file handler
  errorFile() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          const Image(
              image: AssetImage('assets/images/logo.png'),
              width: 200.0,
              fit: BoxFit.fitHeight),
          const SizedBox(height: 50),
          const Text(
            'סוג קובץ לא נתמך ',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 50),
          ElevatedButton(
              style: const ButtonStyle(
                padding: MaterialStatePropertyAll(EdgeInsets.all(10)),
                backgroundColor: MaterialStatePropertyAll(Colors.red),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScannerPage()),
                );
              },
              child: const Text(
                'סרוק שוב',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              )),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _camState
            ? Center(
                child: SizedBox(
                  height: 600,
                  width: 500,
                  child: QRBarScannerCamera(
                    onError: (context, error) => Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                    qrCodeCallback: (data) {
                      if (data!.isNotEmpty) {
                        _qrCallback(data);
                        //navigate data(url) to another page
                        if (data.startsWith('http') ||
                            data.startsWith('https')) {
                          try {
                            var orderUrl = data;
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    OrderApi(data: orderUrl)));
                          } catch (e) {
                            _errorMessage = e.toString();
                          }
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => errorFile()),
                          );
                        }
                      }
                    },
                  ),
                ),
              )
            : const Center(
                child: Text('scan code'),
              ),
      ),
      onWillPop: () async {
        return true;
      },
    );
  }
}
