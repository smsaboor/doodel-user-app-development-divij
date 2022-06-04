import 'package:flutter/material.dart';


import '../grocerry_kit/model/push_notification_model.dart';

class NotificationDialog extends StatefulWidget {
  const NotificationDialog(this.notification, {Key key}) : super(key: key);
  final PushNotification notification;

  @override
  _NotificationDialogState createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.only(left: 30, top: 5, right: 5),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            widget.notification.title ?? 'Alert',
          ),
          // IconButton(
          //   icon: Icon(Icons.close),
          //   onPressed: () async {
          //     Get.back();
          //   },
          // )
        ],
      ),
      content: Text(widget.notification.body ?? 'You have received a new announcement'),
      actions: <Widget>[
        ElevatedButton(
          child: Text('OK'),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
