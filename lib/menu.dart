import 'package:flutter/material.dart';
import 'package:qr_bunchichi/scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  //UI logo image
  _logoHandler() {
    return const Image(
      image: AssetImage('assets/images/logo.png'),
      width: 200.0,
      fit: BoxFit.fitHeight,
    );
  }

  //logout button
  logoutButton() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.black),
            ),
            SizedBox(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _logoHandler(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            logoutButton();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Login()),
                            );
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('יציאה'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            backgroundColor: (Colors.red[700]),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: const MaterialStatePropertyAll(
                                EdgeInsets.all(10)),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.red[700]),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ScannerPage()),
                            );
                          },
                          child: const Text(
                            'סרוק ברקוד',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onWillPop: () async {
        logoutButton();
        return true;
      },
    );
  }
}
