import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/screens/home_screen.dart';
import 'package:flutter_recipe_app/utils/constants.dart';
import 'package:iconsax/iconsax.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  late final List<Widget> pages;
  @override
  void initState() {
    pages = [
      HomeScreen(),
      navBarPage(Iconsax.heart5),
      navBarPage(Iconsax.calendar5),
      navBarPage(Iconsax.setting_21),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        iconSize: 28,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 0 ? Iconsax.home5 : Iconsax.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 2 ? Iconsax.calendar5 : Iconsax.calendar,
            ),
            label: "Meal Plan",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 3 ? Iconsax.setting_21 : Iconsax.setting,
            ),
            label: "Settings",
          ),
        ],
      ),
      body: pages[selectedIndex],
    );
  }

  navBarPage(iconName) {
    return Center(child: Icon(iconName, size: 100, color: primaryColor));
  }
}
