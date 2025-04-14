import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_recipe_app/notifications/navigationhelpers.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool _channelCreated = false;

  /// Initialize both local and Firebase messaging settings
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _notificationsPlugin.initialize(
      const InitializationSettings(android: initializationSettingsAndroid),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final data = jsonDecode(response.payload!);
            final context = navigatorKey.currentContext;
            if (context != null && context.mounted) {
              handleNavigation(context, data);
            }
          } catch (e) {
            debugPrint('Navigation error: $e');
          }
        }
      },
    );

    await _ensureNotificationChannel();
    await _configureFirebaseMessaging();
  }

  /// Creates the Android channel for notifications if not already created
  static Future<void> _ensureNotificationChannel() async {
    if (_channelCreated) return;

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _channelCreated = true;
  }

  /// Configure foreground notification behavior
  static Future<void> _configureFirebaseMessaging() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Show a local notification based on remote message
  static Future<void> displayNotification(RemoteMessage message) async {
    try {
      final title = message.data['title'];
      final body = message.data['body'];

      if ((title == null || title.isEmpty) && (body == null || body.isEmpty))
        return;

      await _ensureNotificationChannel();

      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        showWhen: true,
      );

      await _notificationsPlugin.show(
        message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
        title,
        body,
        const NotificationDetails(android: androidDetails),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint('Notification display error: $e');
    }
  }

  /// Handle navigation when context is valid
  static void handleNavigation(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final type = data['type'];

    switch (type) {
      case 'liked':
      case 'new_recipe':
        if (data['productInfo'] != null) {
          navigateToRecipe(context, data['productInfo']);
        }
        break;
      case 'follow':
        if (data['sender'] != null) {
          navigateToProfile(context, data['sender']);
        }
        break;
      default:
        break;
    }
  }
}
