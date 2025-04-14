import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/providers/app_main_provider.dart';
import 'package:flutter_recipe_app/providers/favorite_provider.dart';
import 'package:flutter_recipe_app/providers/notification_providers.dart';
import 'package:flutter_recipe_app/providers/notificationpush.dart';
import 'package:flutter_recipe_app/screens/entrypage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import './notifications/notification_service.dart';

AppLifecycleState? _appLifecycleState;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  WidgetsBinding.instance.addObserver(
    LifecycleObserver((state) => _appLifecycleState = state),
  );

  await NotificationService.initialize();
  await _setupFCM();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PushNotificationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => AppMainProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _setupFCM() async {
  await FirebaseMessaging.instance.requestPermission();

  // Foreground handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint(
      'FOREGROUND NOTIFICATION RECEIVED - Title: ${message.notification?.title}',
    );
    if (_appLifecycleState == AppLifecycleState.resumed) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        debugPrint('CALLING PROVIDER FOR CUSTOM DIALOG');
        Provider.of<PushNotificationProvider>(
          context,
          listen: false,
        ).showNotificationDialog(
          context: context,
          notificationData: message.data,
        );
      }
    }
  });

  // Background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // Token updates
  FirebaseMessaging.instance.onTokenRefresh.listen(_updateTokenInFirestore);

  // Terminated state handler
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    debugPrint('APP OPENED FROM TERMINATED STATE VIA NOTIFICATION');
    _handleNotificationClick(initialMessage);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint(
    'BACKGROUND NOTIFICATION RECEIVED - Title: ${message.notification?.title}',
  );
  debugPrint('SYSTEM NOTIFICATION WILL SHOW AUTOMATICALLY');
}

Future<void> _updateTokenInFirestore(String token) async {
  final prefs = await SharedPreferences.getInstance();
  final uid = prefs.getString('uid');
  if (uid != null) {
    final deviceId = prefs.getString('deviceId') ?? const Uuid().v4();
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('devices')
        .doc(deviceId)
        .update({
          'fcmToken': token,
          'lastActive': FieldValue.serverTimestamp(),
        });
  }
}

void _handleNotificationClick(RemoteMessage message) async {
  debugPrint('HANDLING NOTIFICATION CLICK - Payload: ${message.data}');
  final context = navigatorKey.currentContext;
  if (context != null) {
    debugPrint('PROVIDER CALLED FOR NOTIFICATION ACTION');
    Provider.of<PushNotificationProvider>(
      context,
      listen: false,
    ).showNotificationDialog(context: context, notificationData: message.data);
  }
}

class LifecycleObserver extends WidgetsBindingObserver {
  final Function(AppLifecycleState) onStateChanged;
  LifecycleObserver(this.onStateChanged);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onStateChanged(state);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Cookmate',
      home: Entrypage(),
    );
  }
}
