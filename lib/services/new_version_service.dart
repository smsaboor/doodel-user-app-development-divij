import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_version/new_version.dart';
import 'package:url_launcher/url_launcher.dart';

class NewVersionCheckerService {
  static NewVersion _newVersion;

  static init() {
    _newVersion = NewVersion(
      iOSId: 'se.doodel.user',
      androidId: 'se.doodel.user',
    );
  }

  static void showUpdateDialog(context) {
    _newVersion.getVersionStatus().then((value) {
      if (value != null && value.canUpdate) {
        _dialog(value, context);
      }
    });
  }

  static void _dialog(VersionStatus versionStatus, context) async {
    final title = Text('Update Available');
    final content = Text(
      'Please update to continue using the app',
    );
    final updateText = Text('Update');
    final updateAction = () {
      _launchAppStore(versionStatus.appStoreLink);
    };

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Platform.isAndroid
            ? AlertDialog(
                title: title,
                content: content,
                actions: <Widget>[
                  FlatButton(
                    child: updateText,
                    onPressed: updateAction,
                  ),
                ],
              )
            : CupertinoAlertDialog(
                title: title,
                content: content,
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: updateText,
                    onPressed: updateAction,
                  ),
                ],
              );
      },
    );
    // if (Platform.isAndroid) SystemNavigator.pop();
    exit(0);
  }

  static void _launchAppStore(String appStoreLink) async {
    if (await canLaunch(appStoreLink)) {
      await launch(appStoreLink);
    } else {
      throw 'Could not launch appStoreLink';
    }
  }
}
