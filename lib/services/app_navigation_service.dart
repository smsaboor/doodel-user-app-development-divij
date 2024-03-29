// This is only to give rough overview of the structure of the fix.

// allow usage of navigator without context if the need arise
import 'package:doodeluser/grocerry_kit/maintenance_page.dart';
import 'package:flutter/material.dart';
abstract class AppNavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<dynamic> pushNamed(String routeName) {
    debugPrint('route by navigatorKey: $routeName');
    return AppNavigatorService.navigatorKey.currentState?.pushNamed(routeName);
  }

  static Future<dynamic> pushNamedUntil(String routeName) {
    debugPrint('route by navigatorKey: $routeName');
    return AppNavigatorService.navigatorKey.currentState?.pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (BuildContext context) =>  MaintenancePage()),
      ModalRoute.withName('/MaintenencePage'),
    );
  }

  static void pop() {
    debugPrint('route by navigatorKey pop');
    return AppNavigatorService.navigatorKey.currentState?.pop();
  }
  static void popUntil() {
    debugPrint('route by navigatorKey pop');
    return AppNavigatorService.navigatorKey.currentState?.popUntil((route) => false);
  }
}