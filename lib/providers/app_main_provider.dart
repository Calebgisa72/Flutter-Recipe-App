import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppMainProvider extends ChangeNotifier {
  String? _userId;
  int selectedTab = 0;

  String get userId => _userId ?? '';

  AppMainProvider() {
    loadUserId();
  }

  void setSelectedTab(int index) {
    selectedTab = index;
    notifyListeners();
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('uid') ?? '';
    notifyListeners();
  }

  static AppMainProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<AppMainProvider>(context, listen: listen);
  }
}
