import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_bunchichi/scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'ticketData.dart';
import 'order.dart';

class OrderApi extends StatefulWidget {
  final String data;
  const OrderApi({super.key, required this.data});
  @override
  State<OrderApi> createState() => _OrderApiState();
}

class _OrderApiState extends State<OrderApi> {

  //variables
  late var orderUrl = widget.data;
  late var orderId = '';
  late var massage = '';
  late bool _isLoading = false;
  dynamic data;

  @override
  void initState() {
    super.initState();
    getOrderId();
    getOrder();
  }

  // UI image logo
  _logoHandler() {
    return const Image(
      image: AssetImage('assets/images/logo.png'),
      width: 200.0,
      fit: BoxFit.fitHeight,
    );
  }

  //get order id from url
  getOrderId() {
    RegExp regExp = RegExp(r'\d+$');
    Match? match = regExp.firstMatch(orderUrl);
    if (match != null) {
      String parsedOrderId = int.parse(match.group(0)!).toString();
      setState(() {
        orderId = parsedOrderId.toString();
      });
    }
  }

  //error file handler
  errorFile() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children:  [
              const SizedBox(height: 80),
              const Image(image: AssetImage('assets/images/logo.png'), width: 200.0, fit: BoxFit.fitHeight),
              const SizedBox(height: 50),
              const Text('כרטיס לא נמצא ',
                style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold, fontSize: 15),
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
                  )
              ),
            ],
          )
      ),
    );
  }


  //get order from http req
  Future getOrder() async {
    setState(() {
      _isLoading = true;
    });
    // order url
    var reqOrderUrl = Uri.parse("https://shop.bunchichi.co.il/wp-json/api/get-order");

    //get local storage data
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final username = prefs.getString('username');

    //http post req
    try {
      final http.Response response = await http.post(
          reqOrderUrl,
          headers: {"Accept": "Application/json"},
          body: {
            "username": username.toString(),
            "token": token.toString(),
            "order_id": orderId.toString(),
          }
      );

      //handling with response
      dynamic responseData = jsonDecode(response.body);
      final orderData = responseData['order'];
      if(responseData['status_code']  == 200) {
        Order myOrder = Order.fromJson(orderData);
        setState(() {
          data = myOrder;
          _isLoading = false;
        });
      } else if(responseData['status_code'] == 404){
        setState(() {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => errorFile()),
          );
        });
      }

    } catch (error) {
      debugPrint('http post error $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _logoHandler(),
                  const SizedBox(height: 80),
                  const Text('אנא המתן . . .',
                    style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold, fontSize: 15),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 50),
                  const CupertinoActivityIndicator(
                    color: Colors.red,
                    radius: 40,
                  ),
                ],
              )
          )],
      ): TicketData(data: data),
    );
  }
}
