import 'dart:async';

import 'package:coders_bucket/view/login.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _snackbarController = Get.put(SnackbarController());

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (userCredential.user != null) {
          Get.to(() => LoginPage());
          // Account creation successful
          print('Account created successfully!');
          // Additional actions after successful sign-up
        } else {
          // Account creation failed
          print('Account creation failed.');
        }
      } on FirebaseAuthException catch (e) {
        // Handle sign-up errors here
        if (e.code == 'invalid-email') {
          Get.snackbar('Invalid Email formation', 'Enter valid email',backgroundColor: Colors.red);
        } else if (e.code == 'weak-password') {
          Get.snackbar('Password is too short', 'Enter at least 6 digit',backgroundColor: Colors.red);
        } else {
          _snackbarController.showSnackbar('Error during account creation: ${e.message}');
        }
      } catch (e) {
        // Handle generic errors here
        print('Error during account creation: ${e.toString()}');
      }
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
        title: Text('Sign Up'),
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
                  hintStyle: TextStyle(color: Colors.grey[300]),
                  helperStyle: TextStyle(color: Colors.grey[300]),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!isValidEmail(value)) {
                    return '';
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
                  hintStyle: TextStyle(color: Colors.grey[300]),
                  helperStyle: TextStyle(color: Colors.grey[300]),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Container(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    backgroundColor: Colors.green, // Change the background color here
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: Size(200.0, 60.0), // Set the desired button size
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Obx(() {
                if (_snackbarController.snackbarMessage.isNotEmpty) {
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    _snackbarController.showSnackbar(_snackbarController.snackbarMessage.value);
                    _snackbarController.clearMessage();
                  });
                }
                return SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );

  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
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

class SnackbarController extends GetxController {
  final snackbarKey = GlobalKey<ScaffoldMessengerState>();
  final snackbarMessage = ''.obs;

  void showSnackbar(String message) {
    snackbarMessage.value = message;
  }

  void clearMessage() {
    snackbarMessage.value = '';
  }
}


