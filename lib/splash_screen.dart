import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../ui/login_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _url = '';

  // Splash Screen Time
  @override
  void initState() {
    Timer(const Duration(milliseconds: 5000), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return LoginPage();
      }));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    devHeight = MediaQuery.of(context).size.height;
    devWidth = MediaQuery.of(context).size.width;
    print(devHeight);
//    Firestore.instance.collection('splashImage').document('splashImage').get().then((value){
//      _url = value.data()['url'];
//    });
    return Scaffold(
      backgroundColor: Color(0xff0644e3),
      body: Center(
        child: Container(
          height: devHeight * 0.366,
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
              // color: product.color,
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(image: AssetImage('images/splash.png'), fit: BoxFit.fitWidth)),
        ),
      ),
    );
  }
}
