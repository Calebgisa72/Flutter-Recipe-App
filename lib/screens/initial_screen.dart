import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_recipe_app/notifications/notification_service.dart';
import 'package:flutter_recipe_app/screens/entrypage.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _handleInitialNavigation();
  }

  Future<void> _handleInitialNavigation() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null && mounted) {
      NotificationService.handleNavigation(context, initialMessage.data);
    } else if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Entrypage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
