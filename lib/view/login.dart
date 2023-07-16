import 'dart:async';

import 'package:coders_bucket/view/news_page.dart';
import 'package:coders_bucket/view/signup.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Login successful
        print('Login successful!');
        // Perform additional actions after successful login

        Get.offAll(() => NewsScreen()); // Navigate to NewsScreen after successful login
      } catch (e) {
        // Handle login errors here
        print('Error during login: ${e.toString()}');
        if (e is FirebaseAuthException && e.code == 'invalid-email') {
          Get.snackbar('Email formatted badly', 'Enter a properly formatted email',backgroundColor: Colors.red);
        }
        if (e is FirebaseAuthException && e.code == 'user-not-found') {
          Get.snackbar('Email not found', 'Enter valid email or sign up',backgroundColor: Colors.red);
        }
        if (e is FirebaseAuthException && e.code == 'wrong-password') {
          Get.snackbar('Wrong Password', 'Enter right password',backgroundColor: Colors.red);
        }
      }
    } else {
      // Validation failed, do not navigate
      print('Validation failed. Login not performed.');
    }
  }

  late StreamSubscription<ConnectivityResult> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> checkConnectivity() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    setState(() {
      isDeviceConnected = isDeviceConnected;
    });

    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!isDeviceConnected && !isAlertSet) {
        showDialogBox();
        setState(() {
          isAlertSet = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 100),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    Get.snackbar('Email is empty', 'Enter a valid email');
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                     Get.snackbar('Password is empty', 'Enter password');
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Container(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(

                    padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    backgroundColor: Colors.green, // Change the background color here
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),

              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Get.to(()=>SignUpPage());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Not Registered?',style: TextStyle(color: Colors.white),),
                    Text('Sign Up',style: TextStyle(color: Colors.greenAccent),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
  showDialogBox() => showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('No Connection'),
      content: const Text('Please check your internet connectivity'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.pop(context, 'Cancel');
            setState(() => isAlertSet = false);
            isDeviceConnected =
            await InternetConnectionChecker().hasConnection;
            if (!isDeviceConnected && isAlertSet == false) {
              showDialogBox();
              setState(() => isAlertSet = true);
            }
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}


