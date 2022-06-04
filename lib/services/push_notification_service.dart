import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doodeluser/services/app_navigation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../grocerry_kit/announcements.dart';
import '../grocerry_kit/model/push_notification_model.dart';
import '../providers/user.dart';
import '../widgets/notification_dialog.dart';

class PushNotificationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static StreamSubscription messageSubscription;
  static bool _initialized = false;

  static Future<void> initialise(BuildContext context) async {
    if (_initialized) {
      return;
    }
    if (Platform.isIOS) {
      await _fcm.requestPermission();
    }
    await _fcm.setAutoInitEnabled(true);
    final _userToken = Provider.of<AppUser>(context, listen: false).userProfile?.notificationToken ?? null;
    if (_userToken == null || _userToken.dateCreated.add(Duration(days: 25)).isBefore(DateTime.now())) {
      await saveTokenToFirestore(await _fcm.getToken(), Platform.isIOS ? await _fcm.getAPNSToken() : null);
    }

    await _fcm.subscribeToTopic('announcement');

    await setupInteractedMessage();

    messageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message data: ${message.data}');
      PushNotification notification = PushNotification.fromRemoteMessage(message);
      // Get.dialog(NotificationDialog(notification), barrierDismissible: true);
    });
    _initialized = true;
  }

  static Future<void> saveTokenToFirestore(String token, [String apnsToken]) async {
    try{
      print('saboor::::::::::: ${_auth.currentUser?.uid.toString() ?? ''}');
      await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser?.uid.toString() ?? '').update({'notificationToken': NotificationToken(token: token, apnsToken: apnsToken, dateCreated: DateTime.now()).toJson()});
    }catch(e){
      print('saboor----------  :: $e');
    }
  }

  // Future<void> deleteInstanceID() async {
  //   await _fcm.deleteToken();
  //   await saveTokenToFirestore(await _fcm.getToken(), Platform.isIOS ? await _fcm.getAPNSToken() : null);
  // }

  static Future<void> unsubscribeFromAnnouncements() async {
    await messageSubscription?.cancel();
    await _fcm.unsubscribeFromTopic('announcement');
  }

  static Future<void> setupInteractedMessage() async {
    RemoteMessage initialMessage = await _fcm.getInitialMessage();

    if (initialMessage != null) {
      // _handleMessage(initialMessage);
      var notification = PushNotification.fromRemoteMessage(initialMessage);
      if (notification.route == 'announcements') {
        AppNavigatorService.pushNamed('/Announcements');
      }
    }

    // FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  // void _handleMessage(RemoteMessage message) {
  //   var notification = PushNotification.fromRemoteMessage(message);
  //   if (notification.route == 'announcements') {
  //     Get.to(() => Announcements());
  //   }
  // }
}

Future<dynamic> _backgroundMessageHandler(Map<String, dynamic> message) async {
  print("onBackgroundMessage: $message");
}
