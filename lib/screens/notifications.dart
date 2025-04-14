import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    final List<String> photoUrls = [
      'https://picsum.photos/200/300?random=1',
      'https://picsum.photos/200/300?random=2',
      'https://picsum.photos/200/300?random=3',
      'https://picsum.photos/200/300?random=4',
    ];

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 17),
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.07,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 27),
                    onPressed: () => Navigator.pop(context),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  Text(
                    'Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.notifications, size: 25),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      //for new notifications
                      width: double.infinity,

                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,

                            height: MediaQuery.of(context).size.height * 0.05,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              border: Border.all(width: 3, color: Colors.red),
                            ),
                            child: Text(
                              'New',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.09,
                            decoration: BoxDecoration(
                              border: Border.all(width: 3, color: Colors.red),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      width: 1,
                                      color: const Color.fromARGB(
                                        255,
                                        21,
                                        20,
                                        20,
                                      ),
                                    ),
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/icons/profile.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  decoration: BoxDecoration(),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Chef Arsene',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.42,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Now Following',
                                              style: TextStyle(fontSize: 17),
                                            ),
                                            Icon(Icons.circle, size: 4),
                                            Text(
                                              '1hr',
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(
                                      "Follow",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(),
                        ],
                      ),
                    ),
                    SizedBox(
                      //container for today
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            height: MediaQuery.of(context).size.height * 0.05,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: Colors.red),
                            ),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 19,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.1,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: Colors.black),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.23,
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,

                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.red,
                                    ),
                                  ),

                                  child: Expanded(
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.03,
                                          backgroundImage: NetworkImage(
                                            'https://i.pravatar.cc/150?img=3',
                                          ),
                                        ),
                                        Positioned(
                                          right: 12,
                                          top: 0,
                                          child: CircleAvatar(
                                            radius:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.03,
                                            backgroundImage: NetworkImage(
                                              'https://i.pravatar.cc/150?img=4',
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 18,
                                          top: 18,
                                          child: CircleAvatar(
                                            radius:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.03,
                                            child: Center(child: Text('+3')),
                                          ),
                                        ),
                                      ],
                                    ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
