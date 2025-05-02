import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_recipe_app/providers/app_main_provider.dart';
import 'package:flutter_recipe_app/screens/app_main_screen.dart';
import 'package:flutter_recipe_app/screens/login.dart';
import 'package:flutter_recipe_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Entrypage extends StatefulWidget {
  const Entrypage({super.key});

  @override
  State<Entrypage> createState() => _EntrypageState();
}

class _EntrypageState extends State<Entrypage> {
  bool isLoading = false;
  late AppMainProvider provider;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    provider = Provider.of<AppMainProvider>(context, listen: false);
    await provider.loadUserId();
  }

  void checkLoginStatus() async {
    setState(() => isLoading = true);

    var user = FirebaseAuth.instance.currentUser;

    await user?.reload();
    user = FirebaseAuth.instance.currentUser;

    setState(() => isLoading = false);

    if (user != null && provider.userId == user.uid) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AppMainScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('uid');
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.only(top: 20),

        decoration: BoxDecoration(border: Border(), color: bgColor),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
              margin: EdgeInsets.only(top: 30),

              child: Image.asset(
                'assets/images/backgroundimage.png',
                fit: BoxFit.cover,
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 20),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.06,

              child: Center(
                child: Text(
                  'Start Cooking',
                  style: TextStyle(
                    fontSize: 30,
                    color: const Color.fromARGB(255, 7, 7, 7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Join Our Community',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,

                        color: const Color.fromARGB(255, 106, 106, 106),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'To Cook Better Food',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 106, 106, 106),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.075,
              margin: EdgeInsets.only(top: 40),
              child: ElevatedButton(
                onPressed: () => {checkLoginStatus()},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(bRadius),
                  ),
                ),
                child:
                    isLoading
                        ? Center(
                          child: SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              color: Colors.white,

                              strokeWidth: 4,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        )
                        : Text(
                          'Get  Started',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
