import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/notifications/navigationhelpers.dart';
import 'package:flutter_recipe_app/utils/constants.dart';

import 'follow_receipe_notification.dart';
import 'multiuser.dart';

Future<void> showNotificationDialog(
  BuildContext context,
  Map<String, dynamic> data,
  String type,
) async {
  await showDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    useRootNavigator: true,
    builder: (_) {
      return NotificationDialog(data: data, type: type);
    },
  );
}

class NotificationDialog extends StatefulWidget {
  final Map<String, dynamic> data;
  final String type;

  const NotificationDialog({Key? key, required this.data, required this.type})
    : super(key: key);

  @override
  _NotificationDialogState createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0),
      end: Offset.zero,
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
        child: Stack(
          children: [
            Positioned(
              top: 4,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: Dialog(
                  insetPadding: EdgeInsets.zero,
                  backgroundColor: modalscolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _buildNotificationWrapper(
                    context,
                    widget.data,
                    widget.type,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationWrapper(
    BuildContext context,
    Map<String, dynamic> data,
    String type,
  ) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context, rootNavigator: true).pop();
        await Future.delayed(const Duration(milliseconds: 100));

        if (type == 'follow') {
          navigateToProfile(context, data['sender']);
        } else {
          navigateToRecipe(context, data['productInfo']);
        }
      },
      child: buildNotificationWidget(context, data, type),
    );
  }

  Widget buildNotificationWidget(
    BuildContext context,
    Map<String, dynamic> data,
    String type,
  ) {
    debugPrint('🔨 Building widget for type: $type');

    try {
      if (type == 'follow') {
        return UserFollowRecipeCard(
          ismodal: true,
          notType: 'follow',
          userInfo: data['sender'],
          time: _parseTimestamp(data['time']),
          productInfo: '',
        );
      } else if (type == 'new_recipe') {
        return UserFollowRecipeCard(
          ismodal: true,
          notType: 'new_recipe',
          userInfo: data['sender'],
          time: _parseTimestamp(data['time']),
          productInfo: data['productInfo'] ?? '',
        );
      } else if (type == 'liked') {
        final userIds = (data['userIds'] as String).split(',');
        if (userIds.length == 1) {
          return UserFollowRecipeCard(
            ismodal: true,
            notType: 'liked',
            userInfo: data['sender'],
            time: _parseTimestamp(data['time']),
            productInfo: data['productInfo'] ?? '',
          );
        } else {
          return MultiUserNotification(
            ismodal: true,
            usersIds: userIds,
            recipeId: data['productInfo'],
            time: _parseTimestamp(data['time']),
          );
        }
      }
    } catch (e) {
      debugPrint('‼️ Widget build error: $e');
      return _buildErrorWidget();
    }

    return _buildErrorWidget();
  }

  Timestamp _parseTimestamp(dynamic time) {
    try {
      return time is String
          ? Timestamp.fromDate(DateTime.parse(time))
          : time as Timestamp;
    } catch (e) {
      debugPrint('⚠️ Error parsing timestamp: $e');
      return Timestamp.now();
    }
  }

  Widget _buildErrorWidget() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Text(
          'Notification preview unavailable',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
