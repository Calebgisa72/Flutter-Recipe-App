import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/utils/constants.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          homescreen(context),
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 1,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(bRadius),
                    topRight: Radius.circular(bRadius),
                  ),
                  color: Colors.white,
                  border: Border.all(
                    width: 1,
                    color: const Color.fromARGB(255, 194, 191, 191),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 23),
                        height: MediaQuery.of(context).size.height * 0.01,
                        width: MediaQuery.of(context).size.width * 0.1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromARGB(255, 195, 192, 192),
                          border: Border.all(
                            width: 1,
                            color: const Color.fromARGB(255, 219, 218, 218),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 12),
                            width: MediaQuery.of(context).size.width * 0.9,

                            child: Text(
                              'cocoa Maca Walnut Milk',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width * 0.39,

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('food', style: TextStyle(fontSize: 15)),
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: const Color.fromARGB(
                                    255,
                                    128,
                                    127,
                                    127,
                                  ),
                                ),

                                Text('60', style: TextStyle(fontSize: 15)),
                                Text('Minutes', style: TextStyle(fontSize: 15)),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.08,

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.42,
                                  height:
                                      MediaQuery.of(context).size.height * 1,

                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.11,
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            bRadius,
                                          ),
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Image.asset(
                                          'assets/icons/profile.png',
                                        ),
                                      ),

                                      Text(
                                        'Elen Shebah',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.34,
                                  height:
                                      MediaQuery.of(context).size.height * 1,

                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.11,
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.05,

                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            bRadius,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons
                                                .favorite, // filled favorite icon
                                            color: const Color.fromARGB(
                                              255,
                                              231,
                                              227,
                                              226,
                                            ),
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '773 likes',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Divider(color: Colors.grey, thickness: 0.5),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.08,

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'description',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8, bottom: 8),

                        width: MediaQuery.of(context).size.width * 0.9,

                        child: Text(
                          'Your receipe has been uploaded, you can see it on your profile,Your receipe has been uploaded, you can see it on your profile ',
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 138, 137, 137),
                            fontSize: 17,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Divider(color: Colors.grey, thickness: 0.5),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.08,

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ingredients',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        margin: EdgeInsets.only(bottom: 6),
                        // decoration: BoxDecoration(
                        //   border: Border.all(width: 1, color: Colors.black),
                        // ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: MediaQuery.of(context).size.height * 0.04,

                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '4 Eggs',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: MediaQuery.of(context).size.height * 0.04,

                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '1/2 Buffer',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: MediaQuery.of(context).size.height * 0.04,

                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text('1/2 Buffer'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Divider(color: Colors.grey, thickness: 0.5),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 3),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.1,

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Steps',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,

                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.10,

                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.04,

                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        92,
                                        101,
                                        121,
                                      ),
                                      borderRadius: BorderRadius.circular(bRadius),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '1',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.77,

                                  child: Column(
                                    children: [
                                      Text(
                                        'Your receipe has been uploaded successfully,Your receipe has been uploaded successf ',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.8,
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.23,

                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          image: DecorationImage(
                                            image: AssetImage(
                                              'assets/images/ingredients.png',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget homescreen(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 28),

      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black),
              image: DecorationImage(
                image: AssetImage('assets/images/bagger.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 20,
            child: Container(
              width: 40,
              height: 40,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                    255,
                    236,
                    233,
                    233,
                  ).withOpacity(0.5),
                  shadowColor: const Color.fromARGB(0, 211, 205, 205),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {},
                child: Icon(
                  Icons.arrow_back, // Built-in arrow icon
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
