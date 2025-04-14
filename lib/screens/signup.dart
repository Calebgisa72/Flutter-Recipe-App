import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/utils/constants.dart';
import '../screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _emailController = TextEditingController();
  final _fullNamesController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isPasswordLong = false;
  bool hasPasswordNumber = false;
  bool isPasswordVisible = false;
  bool isLoading = false;
  bool emailerror = false;
  bool isEmailEmpty = false;
  bool isNamesEmpty = false;
  bool isPasswordEmpty = false;
  String emptyMessage = '';
  String responseMessage = '';

  Future<void> signUp(String email, String password, String fullNames) async {
    setState(() => isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'fullNames': fullNames.trim(),
        'profilePhoto':
            'https://cdn-icons-png.flaticon.com/128/3135/3135715.png',
      });

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('devices')
          .add({'createdAt': FieldValue.serverTimestamp()});

      await FirebaseFirestore.instance.collection('Connectivity').doc(uid).set({
        'Followedby': [],
        'Follows': [],
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        setState(() => responseMessage = "email already in use");
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void onPasswordChanged(String password) {
    setState(() {
      isPasswordLong = password.length > 6;
      hasPasswordNumber = password.contains(RegExp(r'[0-9]'));
      emptyMessage = '';
      isPasswordEmpty = false;
      responseMessage = '';
    });
  }

  bool _validateEmail(String email) {
    final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    final isGmail = email.toLowerCase().contains("@gmail.com");

    return isValid && (!isGmail || !email.contains(RegExp(r'[A-Z]')));
  }

  bool get isButtonEnabled {
    final bothEmpty =
        _fullNamesController.text.isEmpty &&
        _emailController.text.isEmpty &&
        _passwordController.text.isEmpty;
    return bothEmpty || (!emailerror && isPasswordLong && hasPasswordNumber);
  }
  // bool isButtonEnabled = false;

  bool isdataVerified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 60),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.13,

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
                        fontSize: 20,
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
                    color: isEmailEmpty ? Colors.red : textInputBorderColor,
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
                      child: Container(
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
                        ), //
                      ),
                    ),
                  ],
                ),
              ),

              if (emailerror != false)
                Container(
                  margin: EdgeInsets.only(top: 4),
                  width: MediaQuery.of(context).size.width * 0.80,
                  alignment: Alignment.centerLeft,

                  child: Text(
                    'invalid email',
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              Container(
                margin: EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isPasswordEmpty ? Colors.red : textInputBorderColor,
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
                          hintText: "password",
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
                margin: EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isNamesEmpty ? Colors.red : textInputBorderColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(bRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: Icon(Icons.person),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        child: TextFormField(
                          controller: _fullNamesController,
                          decoration: InputDecoration(
                            hintText: 'full names',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              emptyMessage = '';

                              isNamesEmpty = false;
                              responseMessage = '';
                            });
                          },
                        ), //
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.13,
                margin: EdgeInsets.only(top: 10),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your password must contain',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 9),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check,

                          color:
                              isPasswordLong
                                  ? Colors.green
                                  : const Color.fromARGB(255, 17, 17, 17),
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Atleast 6 characters',
                          style: TextStyle(
                            fontSize: 18,
                            color: isPasswordLong ? Colors.green : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 9),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check,
                          color:
                              hasPasswordNumber
                                  ? Colors.green
                                  : const Color.fromARGB(255, 17, 17, 17),
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Contains a number',
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                hasPasswordNumber ? Colors.green : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                              isNamesEmpty = _fullNamesController.text.isEmpty;
                              isPasswordEmpty =
                                  _passwordController.text.isEmpty;

                              emptyMessage =
                                  isEmailEmpty && isPasswordEmpty
                                      ? 'Enter email and password'
                                      : '';
                            });

                            if (!isEmailEmpty &&
                                !isPasswordEmpty &&
                                !isNamesEmpty) {
                              signUp(
                                _emailController.text,
                                _passwordController.text,
                                _fullNamesController.text,
                              );
                            }
                          }
                          : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isButtonEnabled
                            ? primaryColor
                            : const Color.fromARGB(255, 116, 142, 116),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(bRadius),
                    ),
                  ),
                  child:
                      isButtonEnabled
                          ? isLoading
                              ? Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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

                                    SizedBox(width: 16),
                                    Text(
                                      'Processing data',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              )
                              : Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                          : Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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

                                SizedBox(width: 16),
                                Text(
                                  'validating data',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                ),
              ),
              if (emptyMessage.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 5),
                  width: MediaQuery.of(context).size.width * 0.80,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    emptyMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              if (responseMessage.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 5),
                  width: MediaQuery.of(context).size.width * 0.80,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
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
                      'Already have an account?',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),

                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        'Login',
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

  @override
  void dispose() {
    _emailController.dispose();
    _fullNamesController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
