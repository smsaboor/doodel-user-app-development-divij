import 'dart:async';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../grocerry_kit/store_package/stores_list_screen.dart';
import '../main.dart';
import '../providers/user.dart';
import '../ui/login_page.dart';

class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // FirebaseAuth.instance.currentUser.sendEmailVerification();
    Timer.periodic(Duration(seconds: 5), (t) async {
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.currentUser.reload();
        if (FirebaseAuth.instance.currentUser.emailVerified) {
          t.cancel();
          Navigator.push(context, MaterialPageRoute(builder: (context) => StoresListPage()));
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/logo.png',
                  width: 200,
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Color(0xff0644e3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.25), blurRadius: 6, spreadRadius: .6)], borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email verification needed',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Hello,\nYou have registered an account on Doodel, before being able to use your account you need to verify by clicking on the link sent to your email. You can leave this page as it is. ',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  color: Color(0xff0644e3),
                  onPressed: () async {
                    if (!await DataConnectionChecker().hasConnection) {
                      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
                      return;
                    }
                    await FirebaseAuth.instance.currentUser.sendEmailVerification();
                    ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                    ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Verification email sent again')));
                  },
                  height: 40,
                  minWidth: double.infinity,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Text(
                    'Resend Verification Email',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                MaterialButton(
                  color: Color(0xff0644e3),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut().then((value) => Provider.of<AppUser>(context, listen: false).clearSharedPreferences().then((value) {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                            return LoginPage();
                          }), (Route<dynamic> route) => false);
                        }));
                  },
                  height: 40,
                  minWidth: double.infinity,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
