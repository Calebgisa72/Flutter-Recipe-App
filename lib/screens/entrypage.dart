import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/screens/app_main_screen.dart';
import 'package:flutter_recipe_app/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Entrypage extends StatefulWidget {
  const Entrypage({super.key});

  @override
  State<Entrypage> createState() => _EntrypageState();
}

class _EntrypageState extends State<Entrypage> {
  bool isLoading = false;

  void checkLoginStatus() async {
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    var user = FirebaseAuth.instance.currentUser;

    await user?.reload();
    user = FirebaseAuth.instance.currentUser;

    setState(() => isLoading = false);

    if (user != null && uid == user.uid) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AppMainScreen()),
      );
    } else {
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
        margin: EdgeInsets.only(top: 0),

        decoration: BoxDecoration(
          border: Border(),
          color: const Color.fromARGB(255, 233, 230, 230),
        ),

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
                      'Lets join Our Community',
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
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.09,
              margin: EdgeInsets.only(top: 40),
              child: ElevatedButton(
                onPressed: () => {checkLoginStatus()},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
