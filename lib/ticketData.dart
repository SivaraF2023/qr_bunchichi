import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:qr_bunchichi/scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'order.dart';

class TicketData extends StatefulWidget {
  final Order data;
  const TicketData({super.key, required this.data});
  @override
  State<TicketData> createState() => _TicketState();
}

class _TicketState extends State<TicketData> {
  late var order = widget.data;
  late var guests = order.guests;
  late String massage = "";
  bool complete = false;

  @override
  initState() {
    super.initState();
    if (order.order.orderStatus == 'completed') {
      setState(() {
        complete = true;
      });
    }
  }

  //image logo handler
  _logoHandler() {
    return Container(
      margin: const EdgeInsets.only(top: 25, bottom: 25),
      child: const Image(
        image: AssetImage('assets/images/logo.png'),
        width: 200,
        height: 90,
      ),
    );
  }

  //logout button
  logoutButton() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
  }

  //UI of order number
  _orderNumber() {
    return Container(
      padding: const EdgeInsets.only(right: 17, left: 17, top: 8, bottom: 8),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red,
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Text(
        'מספר הזמנה: ${order.orderId.toString()}',
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }

  //UI order info
  _orderInfo() {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: (screenWidth) * 0.9,
      child: Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('פרטי המזמין ',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Wrap(
                  direction: Axis.vertical,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(order.firstName),
                            const SizedBox(width: 20),
                            const Text('שם פרטי :',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.lastName),
                            const SizedBox(width: 20),
                            const Text('שם משפחה :',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(order.email),
                            const SizedBox(width: 20),
                            const Text('אימייל :',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(order.phone),
                            const SizedBox(width: 20),
                            const Text('טלפון :',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                SvgPicture.asset(
                  'assets/images/person.svg',
                  height: 35,
                  width: 35,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //UI ticket order info
  _ticketInfo() {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: (screenWidth) * 0.9,
      child: Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('פרטי כרטיס',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Wrap(
                  direction: Axis.vertical,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Wrap(
                              direction: Axis.vertical,
                              children: [Text(order.order.title)],
                            ),
                            const SizedBox(width: 20),
                            const Text('שם האירוע :',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.order.date),
                            const SizedBox(width: 20),
                            const Text('תאריך :',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(order.order.orderStatus),
                            const SizedBox(width: 20),
                            const Text('סטטוס הזמנה :',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(order.order.qty.toString()),
                            const SizedBox(width: 20),
                            const Text('כמות :',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(order.order.totalPrice.toString()),
                            const SizedBox(width: 20),
                            const Text('מחיר סופי :',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                SvgPicture.asset(
                  'assets/images/ticket.svg',
                  height: 35,
                  width: 35,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //UI guests info
  _guestsInfo() {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: (screenWidth * 0.9),
      child: Column(
        children: guests.map((val) {
          return Card(
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('אורח',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Wrap(
                      direction: Axis.vertical,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(val.firstName),
                                const SizedBox(width: 20),
                                const Text('שם פרטי :',
                                    textDirection: TextDirection.rtl,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                Text(val.age),
                                const SizedBox(width: 20),
                                const Text('גיל :',
                                    textDirection: TextDirection.rtl,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                Text(val.gender),
                                const SizedBox(width: 20),
                                const Text('מגדר :',
                                    textDirection: TextDirection.rtl,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                Text(val.phone),
                                const SizedBox(width: 20),
                                const Text('טלפון :',
                                    textDirection: TextDirection.rtl,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                Wrap(
                                  direction: Axis.vertical,
                                  children: [
                                    Text(val.socialMedia),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                const Text('לינק למדיה :',
                                    textDirection: TextDirection.rtl,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    SvgPicture.asset(
                      'assets/images/guest.svg',
                      height: 35,
                      width: 35,
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,
                  color: Colors.grey,
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  //UI dashed line
  _separator() {
    return Center(
      child: SizedBox(
        width: 323.8,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boxWidth = constraints.constrainWidth();
            const dashWidth = 8.0;
            final dashCount = (boxWidth / (2 * dashWidth)).floor();
            return Flex(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              direction: Axis.horizontal,
              children: List.generate(dashCount, (_) {
                return const SizedBox(
                  width: dashWidth,
                  height: 1.3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  //UI ticket view with dashed line and circles
  _ticketMaker() {
    return SizedBox(
      height: 50,
      width: 400,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: 40,
            width: 21.4,
            decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                )),
          ),
          _separator(),
          Container(
            height: 40,
            width: 21.4,
            decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                )),
          ),
        ],
      ),
    );
  }

  //pop message box
  void _showErrorDialog(String message) async {
    await showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('שגיאה'),
            content: Text(message),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('לנסות שוב'),
              ),
            ],
          );
        });
  }

  //complete order http req
  completeOrder() async {
    // Url for complete order
    final url =
        Uri.parse("https://shop.bunchichi.co.il/wp-json/api/complete-order");
    // http req to login
    final http.Response response = await http.post(url,
        headers: {"Accept": "Application/json"},
        body: {"order_id": order.orderId.toString()});
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        complete = true;
      });
    } else if (responseData['status_code'] == 404) {
      massage = 'לא הצלחנו לסגור את ההזמנה, מספר כרטיס לא נמצא';
      _showErrorDialog(massage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      child: Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              Container(
                  decoration: const BoxDecoration(
                color: Colors.black,
              )),
              ListView(
                children: [
                  Container(
                    width: screenWidth,
                    constraints:
                        const BoxConstraints(maxHeight: double.infinity),
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 15,
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              color: Colors.red[600],
                              iconSize: 30,
                              onPressed: () {
                                logoutButton();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const Login()),
                                );
                              },
                              icon: const Icon(Icons.logout_outlined),
                            ),
                          ),
                          _logoHandler(),
                          _orderNumber(),
                          const SizedBox(height: 10),
                          _ticketMaker(),
                          const SizedBox(height: 10),
                          _orderInfo(),
                          const Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          _ticketInfo(),
                          const Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          _guestsInfo(),
                          const SizedBox(height: 10),
                          complete
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                        style: const ButtonStyle(
                                          padding: MaterialStatePropertyAll(
                                              EdgeInsets.all(10)),
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.red),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const ScannerPage()),
                                          );
                                        },
                                        child: const Text(
                                          'סרוק שוב',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        )),
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    const ElevatedButton(
                                        style: ButtonStyle(
                                          padding: MaterialStatePropertyAll(
                                              EdgeInsets.all(10)),
                                        ),
                                        onPressed: null,
                                        child: Text(
                                          'הזמנה הושלמה',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        )),
                                  ],
                                )
                              : ElevatedButton(
                                  style: const ButtonStyle(
                                    padding: MaterialStatePropertyAll(
                                        EdgeInsets.all(10)),
                                    backgroundColor:
                                        MaterialStatePropertyAll(Colors.green),
                                  ),
                                  onPressed: completeOrder,
                                  child: const Text(
                                    'השלם הזמנה',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  )),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
      onWillPop: () async {
        return true;
      },
    );
  }
}
