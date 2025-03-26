import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/screens/login.dart';
import 'package:flutter_recipe_app/utils/constants.dart';

class Entrypage extends StatelessWidget {
  const Entrypage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
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
                        color: const Color.fromARGB(255, 106, 106, 106),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'To Cook Better Food',
                      style: TextStyle(
                        fontSize: 17,
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(bRadius),
                  ),
                ),
                child: Text(
                  'Get Started',
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
