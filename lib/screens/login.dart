import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_recipe_app/screens/app_main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../screens/signup.dart';
import 'package:uuid/uuid.dart';
import 'dart:io' show Platform;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool emailerror = false;
  bool isPasswordLong = true;
  bool isPasswordVisible = false;
  bool isEmailEmpty = true;
  String emptyMessage = '';
  bool isPasswordEmpty = true;
  String errorMessage = '';
  String responseMessage = '';
  bool isLoading = false;

  bool _validateEmail(String email) {
    final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    final isGmail = email.toLowerCase().contains("@gmail.com");

    return isValid && (!isGmail || !email.contains(RegExp(r'[A-Z]')));
  }

  void handleLogin() async {
    setState(() => isLoading = true);

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = userCred.user!.uid;

      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('deviceId') ?? const Uuid().v4();
      await prefs.setString('deviceId', deviceId);

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .collection('devices')
            .doc(deviceId)
            .set({
              'fcmToken': fcmToken,
              'lastActive': FieldValue.serverTimestamp(),
              'platform': Platform.operatingSystem,
            }, SetOptions(merge: true));
      }

      await prefs.setString('uid', uid);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppMainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        responseMessage =
            e.code == 'user-not-found'
                ? 'User does not exist'
                : e.code == 'wrong-password'
                ? 'Incorrect password'
                : 'Login failed';
      });
    } catch (e) {
      setState(() => responseMessage = 'An error occurred');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void onPasswordChanged(String password) {
    setState(() {
      isPasswordLong = (password.length > 6 || password.isEmpty);
      isPasswordEmpty = false;
      emptyMessage = '';
      responseMessage = '';
    });
  }

  bool get isButtonEnabled {
    final bothEmpty =
        _emailController.text.isEmpty && _passwordController.text.isEmpty;
    return bothEmpty ||
        (!emailerror && isPasswordLong && _passwordController.text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.10,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Please enter your account here',
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color.fromARGB(255, 96, 93, 93),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: emailerror ? Colors.red : textInputBorderColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(bRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: Image.asset(
                        'assets/icons/email.png',
                        height: 20,
                        width: 20,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter email',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            emailerror = !_validateEmail(value);
                            emptyMessage = '';
                            isEmailEmpty = false;
                            responseMessage = '';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isPasswordLong ? textInputBorderColor : Colors.red,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(bRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: Image.asset(
                        'assets/icons/lock.png',
                        height: 20,
                        width: 20,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _passwordController,
                        onChanged: onPasswordChanged,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Password",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          MediaQuery.of(context).size.width * 0.13,
                          0,
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                      child: Center(
                        child: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 29,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.07,
                margin: EdgeInsets.only(top: 10),

                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'Forget password?',
                      style: TextStyle(
                        fontSize: 18,
                        color: foreGround,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.07,
                margin: EdgeInsets.only(top: 20),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(bRadius),
                ),
                child: ElevatedButton(
                  onPressed:
                      isButtonEnabled
                          ? () {
                            setState(() {
                              isEmailEmpty = _emailController.text.isEmpty;
                              isPasswordEmpty =
                                  _passwordController.text.isEmpty;

                              emptyMessage =
                                  isEmailEmpty && isPasswordEmpty
                                      ? 'Enter email and password!'
                                      : '';
                            });
                            if (!isEmailEmpty && !isPasswordEmpty) {
                              handleLogin();
                            }
                          }
                          : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isButtonEnabled
                            ? primaryColor
                            : const Color.fromARGB(255, 125, 137, 126),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(bRadius),
                    ),
                  ),
                  child:
                      isLoading
                          ? Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,

                                    strokeWidth: 4,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),

                                SizedBox(width: 18),
                                Text(
                                  'Processing..',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),

              SizedBox(height: 5),
              if (emptyMessage.isNotEmpty)
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    emptyMessage,
                    style: TextStyle(color: Colors.red, fontSize: 17),
                  ),
                ),
              if (responseMessage.isNotEmpty)
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    responseMessage,
                    style: TextStyle(color: Colors.red, fontSize: 17),
                  ),
                ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    'or continue with',
                    style: TextStyle(fontSize: 19),
                  ),
                ),
              ),

              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.07,
                margin: EdgeInsets.only(top: 20),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(bRadius),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 199, 37, 37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(bRadius),
                    ),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/google.png',
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Google',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.width * 0.15,
                margin: EdgeInsets.only(top: 20),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t you have an account?',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Signup()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
