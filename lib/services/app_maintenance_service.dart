import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doodeluser/services/app_navigation_service.dart';


import '../grocerry_kit/maintenance_page.dart';

appMaintenanceChecker() {
  FirebaseFirestore.instance.collection('settings').doc('maintenance').snapshots().distinct().listen((event) {
    if (event.data() != null) {
      if (((event.data())['underMaintenance']) ?? false) {
        print('app is under maintenance');
        AppNavigatorService.pushNamedUntil('maintenencepage');
      } else {
        print('not under maintenance');
      }
    }
  }, onError: (err, StackTrace stackTrace) {
    print('error occurred in roleValidator stream');
    print(err);
  }, onDone: () {
    print('roleValidator has been completed');
  });
}
