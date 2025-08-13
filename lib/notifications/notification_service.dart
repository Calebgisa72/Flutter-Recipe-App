import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_recipe_app/notifications/navigationhelpers.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static FlutterLocalNotificationsPlugin get plugin => _notificationsPlugin;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool _channelCreated = false;

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
            } else {}
          } catch (e) {
            debugPrint('❌ PARSE ERROR: $e');
          }
        } else {
          debugPrint('⚠️ EMPTY PAYLOAD');
        }
      },
    );

    await _ensureNotificationChannel();
    await _configureFirebaseMessaging();
  }

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

  static Future<void> _configureFirebaseMessaging() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> displayNotification(RemoteMessage message) async {
    try {
      final title = message.data['title'];
      final body = message.data['body'];
      final type = message.data['type'];
      final imageUrl = message.data['imageurl'];

      if ((title == null || title.isEmpty) && (body == null || body.isEmpty))
        return;

      AndroidBitmap<Object> largeIcon;

      if (type == 'follow') {
        final bytes = await _loadImageBytes(imageUrl);
        largeIcon = ByteArrayAndroidBitmap(await _createCircularBitmap(bytes));
      } else if (type == 'liked') {
        final imageUrl1 = message.data['imageurl1'];
        final bytes = await _loadImageBytes(imageUrl1);
        largeIcon = ByteArrayAndroidBitmap(await _createCircularBitmap(bytes));
      } else {
        largeIcon = ByteArrayAndroidBitmap(await _loadImageBytes(imageUrl));
      }

      await _notificationsPlugin.show(
        message.data['collapseKey']?.hashCode ??
            DateTime.now().millisecondsSinceEpoch,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            largeIcon: largeIcon,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            tag: message.data['collapseKey'],
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  static Future<Uint8List> _loadImageBytes(String url) async {
    return (await NetworkAssetBundle(
      Uri.parse(url),
    ).load("")).buffer.asUint8List();
  }

  static Future<Uint8List> _createCircularBitmap(Uint8List imageBytes) async {
    final image = await decodeImageFromList(imageBytes);
    final size = min(image.width, image.height);
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final radius = size / 2;

    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      Paint()
        ..isAntiAlias = true
        ..shader = ImageShader(
          image,
          TileMode.clamp,
          TileMode.clamp,
          Matrix4.identity().storage,
        ),
    );

    final img = await recorder.endRecording().toImage(size, size);
    return (await img.toByteData(
      format: ImageByteFormat.png,
    ))!.buffer.asUint8List();
  }

  static void handleNavigation(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    try {
      debugPrint('Received data: $data');
      final type = data['type']?.toString() ?? '';

      switch (type) {
        case 'liked':
        case 'new_recipe':
          final recipeId = data['productInfo']?.toString();
          if (recipeId != null && recipeId.isNotEmpty) {
            debugPrint('Navigating to recipe: $recipeId');
            navigateToRecipe(context, recipeId);
          } else {
            debugPrint('Missing or invalid recipe ID');
          }
          break;
        case 'follow':
          final userId = data['sender']?.toString();
          if (userId != null && userId.isNotEmpty) {
            debugPrint('Navigating to profile: $userId');
            navigateToProfile(context, userId);
          } else {
            debugPrint('Missing or invalid user ID');
          }
          break;
        default:
          debugPrint('Unknown notification type: $type');
          break;
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }
}
