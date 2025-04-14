import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/providers/app_main_provider.dart';
import 'package:flutter_recipe_app/screens/favorite_screen.dart';
import 'package:flutter_recipe_app/screens/home_screen.dart';
import 'package:flutter_recipe_app/screens/myprofile.dart';
import 'package:flutter_recipe_app/screens/recipe_upload_flow.dart';
import 'package:flutter_recipe_app/utils/constants.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  late final List<Widget> pages;
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        pages = [
          HomeScreen(),
          FavoriteScreen(),
          RecipeFormFlow(edit: false),
          MyProfile(userId: prefs.getString('uid') ?? ''),
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabProvider = AppMainProvider.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        iconSize: 28,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: tabProvider.selectedTab,
        onTap: (index) {
          tabProvider.setSelectedTab(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              tabProvider.selectedTab == 0 ? Iconsax.home5 : Iconsax.home,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              tabProvider.selectedTab == 1 ? Iconsax.heart5 : Iconsax.heart,
            ),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              tabProvider.selectedTab == 2
                  ? Iconsax.document_upload5
                  : Iconsax.document_upload,
            ),
            label: "Upload",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              tabProvider.selectedTab == 3 ? Iconsax.user4 : Iconsax.user,
            ),
            label: "Profile",
          ),
        ],
      ),
      body: pages[tabProvider.selectedTab],
    );
  }
}
