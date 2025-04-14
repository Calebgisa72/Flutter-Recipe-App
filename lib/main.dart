import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/notifications/notificationsdialogs.dart';
import 'package:flutter_recipe_app/providers/app_main_provider.dart';
import 'package:flutter_recipe_app/providers/favorite_provider.dart';
import 'package:flutter_recipe_app/providers/notification_providers.dart';
import 'package:flutter_recipe_app/providers/notificationpush.dart';
import 'package:flutter_recipe_app/screens/initial_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import './notifications/notification_service.dart';

AppLifecycleState? _appLifecycleState;

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['handled'] == true) return;
  message.data['handled'] = true;

  debugPrint('📢 BACKGROUND NOTIFICATION recieved: ${message.data}');
  try {
    await NotificationService.displayNotification(message);
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();

  WidgetsBinding.instance.addObserver(
    LifecycleObserver((state) => _appLifecycleState = state),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  await NotificationService.initialize();

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

  await _setupFCM();
}

Future<void> _setupFCM() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('📢 Foreground notification received: ${message.data}');
    final context = NotificationService.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      showNotificationDialog(context, message.data, message.data['type'] ?? '');
    }
  });

  FirebaseMessaging.instance.onTokenRefresh.listen(_updateTokenInFirestore);
  debugPrint("✅ onMessageOpenedApp LISTENER REGISTERED");
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
        .set({
          'fcmToken': token,
          'lastActive': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
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
      navigatorKey: NotificationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Cookmate',
      home: const InitialScreen(),
    );
  }
}
