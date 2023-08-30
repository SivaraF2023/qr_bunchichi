import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'menu.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  // form input for email/ username and password
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  //variables
  late bool _isAuth = false;
  late bool _isLoading = false;
  late bool formSaved = false;
  late String massage = "";

  @override
  void initState() {
    super.initState();
    massage = '';
  }

  //submit form and navigate to another page
  _submit() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var email = emailController.text;
      var password = passwordController.text;
      login(email, password);
    } catch (error) {
      const errorMsg = 'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMsg);
    }
  }

  //login handler response and error
  Future login(String email, String password) async {
    // Url for Login user
    final url = Uri.parse("https://shop.bunchichi.co.il/wp-json/api/login");
    final revokeUrl =
        Uri.parse("https://shop.bunchichi.co.il/wp-json/api/revoke");

    //get local storage in the device
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final username = prefs.getString('username');

    //check if token and username exist
    if (token != null &&
        token.isNotEmpty &&
        username != null &&
        username.isNotEmpty) {
      try {
        // http req to login
        final http.Response response = await http.post(url,
            headers: {"Accept": "Application/json"},
            body: {"username": username.toString(), "token": token.toString()});
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          setState(() {
            _isAuth = true;
            _isLoading = false;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Menu()),
            );
          });
        } else if (responseData['status_code'] == 403) {
          setState(() {
            _isAuth = false;
          });
          massage = 'אין לך גישה לדף זה';
          _showErrorDialog(massage);
        } else if (responseData['status_code'] == 401) {
          setState(() {
            _isAuth = false;
          });
          massage = 'שם המשתמש או הסיסמה לא נכונים';
          _showErrorDialog(massage);
        } else if (response.statusCode == 500) {
          setState(() {
            _isAuth = false;
          });
          massage = 'יש תקלה בשרת אנא נסה שנית מאוחר יותר';
          _showErrorDialog(massage);
        }
      } catch (error) {
        debugPrint('error $error');
        setState(() {
          massage = 'Error $error';
        });
        _showErrorDialog(massage);
      }
    } else {
      try {
        // http req to revoke
        final http.Response response = await http.post(revokeUrl, headers: {
          "Accept": "Application/json"
        }, body: {
          "username": email.toString(),
          "password": password.toString()
        });

        // http res
        final responseData = jsonDecode(response.body);
        if (responseData["status_code"] == 200) {
          //saving data to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseData["token"]);
          await prefs.setString('username', email.toString());

          setState(() {
            _isAuth = true;
            _isLoading = false;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Menu()),
            );
          });
        } else if (responseData['status_code'] == 403) {
          setState(() {
            _isAuth = false;
          });
          massage = 'אין לך גישה לדף זה';
          _showErrorDialog(massage);
        } else if (responseData['status_code'] == 401) {
          setState(() {
            _isAuth = false;
          });
          massage = 'שם המשתמש או הסיסמה לא נכונים';
          _showErrorDialog(massage);
        } else if (response.statusCode == 500) {
          setState(() {
            _isAuth = false;
          });
          massage = 'יש תקלה בשרת אנא נסה שנית מאוחר יותר';
          _showErrorDialog(massage);
        }
      } catch (error) {
        debugPrint('error $error');
        setState(() {
          massage = 'Error $error';
        });
        _showErrorDialog(massage);
      }
    }
  }

  //pop message box
  void _showErrorDialog(String message) async {
    setState(() {
      _isLoading = false;
    });
    await showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('שגיאה'),
            content: Text(message),
            actions: [
              MaterialButton(
                onPressed: () {
                  emailController.clear();
                  passwordController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('לנסות שוב'),
              ),
            ],
          );
        });
  }

  //UI image logo
  _logoHandler() {
    return const Image(
      image: AssetImage('assets/images/logo.png'),
      width: 200.0,
      fit: BoxFit.fitHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHigh = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        reverse: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.black),
            ),
            SizedBox(
              width: (screenWidth * 0.8),
              height: (screenHigh),
              child: _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _logoHandler(),
                        const SizedBox(height: 80),
                        const Text(
                          'אנא המתן . . .',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 50),
                        const CupertinoActivityIndicator(
                          color: Colors.red,
                          radius: 40,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: _logoHandler(),
                          padding: const EdgeInsets.only(bottom: 30.0),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Form(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                // Email / UserName input field
                                TextFormField(
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.text,
                                  validator: (value) => value!.isEmpty
                                      ? 'שדה שם המשתמש לא יכול להיות ריק'
                                      : null,
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    hintTextDirection: TextDirection.rtl,
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.only(top: 15.0),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Colors.white,
                                    ),
                                    hintText: ' אנא הכנס אימייל או שם משתמש',
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  onSaved: (value) {
                                    value = emailController.text;
                                  },
                                ),
                                // Password input field
                                TextFormField(
                                  onSaved: (value) {
                                    value = passwordController.text;
                                  },
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? 'שדה הסיסמה לא יכול להיות ריק'
                                      : null,
                                  textInputAction: TextInputAction.send,
                                  obscureText: true,
                                  keyboardType: TextInputType.text,
                                  controller: passwordController,
                                  decoration: const InputDecoration(
                                    hintTextDirection: TextDirection.rtl,
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.only(top: 15.0),
                                    prefixIcon: Icon(
                                      Icons.password_outlined,
                                      color: Colors.white,
                                    ),
                                    hintText: 'אנא הכנס סיסמה ',
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                // Login button
                                Container(
                                  width: 100.0,
                                  margin: const EdgeInsets.only(top: 40.0),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.red[700]),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                        _submit();
                                      } else {
                                        print('the form isn\'t valid');
                                      }
                                    },
                                    child: const Text(
                                      'כניסה',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
