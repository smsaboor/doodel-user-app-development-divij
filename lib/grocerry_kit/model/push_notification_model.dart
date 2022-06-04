import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotification {
  String title;
  String body;
  String route;
  PushNotification({
    this.title,
    this.body,
  });

  PushNotification.fromMap(Map<String, dynamic> json) {
    if (Platform.isAndroid) {
      title = json['notification']['title'];
      body = json['notification']['body'];
    } else if (Platform.isIOS) {
      title = json['aps']['alert']['title'];
      body = json['aps']['alert']['body'];
    }
  }

  PushNotification.fromRemoteMessage(RemoteMessage message) {
    title = message.notification.title;
    body = message.notification.body;
    if (message.data['navigate'] != null) {
      route = message.data['navigate'];
    }
  }
}
