import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'menu.dart';

void main() {
  runApp(const TicketManagement());
}

class TicketManagement extends StatefulWidget {
  const TicketManagement({Key? key}) : super(key: key);
  @override
  State<TicketManagement> createState() => _TicketManagementState();
}

class _TicketManagementState extends State<TicketManagement> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoggedIn = false;
  String userName = '';
  String token = '';

  @override
  void initState() {
    super.initState();
    autoLogIn();
  }

  //checking if the user is logged in
  void autoLogIn() async {
    //get data from local storage
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userName = prefs.getString('username');

    //checking and passing data
    if (token != null &&
        token.isNotEmpty &&
        userName != null &&
        userName.isNotEmpty) {
      setState(() {
        isLoggedIn = true;
        this.userName = userName;
        this.token = token;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? const Menu() : const Login();
  }
}
