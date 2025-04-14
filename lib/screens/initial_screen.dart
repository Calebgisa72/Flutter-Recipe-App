import 'package:flutter/material.dart';

import 'package:flutter_recipe_app/notifications/notification_service.dart';
import 'package:flutter_recipe_app/screens/entrypage.dart';
import 'dart:convert';

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
    final details =
        await NotificationService.plugin.getNotificationAppLaunchDetails();

    final payload = details?.notificationResponse?.payload;

    if (details?.didNotificationLaunchApp == true &&
        payload != null &&
        mounted) {
      try {
        final data = jsonDecode(payload);
        NotificationService.handleNavigation(context, data);
      } catch (e) {
        debugPrint('Payload parse error: $e');
      }
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
