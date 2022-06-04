import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../grocerry_kit/announcements.dart';
import '../grocerry_kit/feedback_page.dart';
import '../grocerry_kit/help_Page.dart';
import '../grocerry_kit/model/cart_model.dart';
import '../grocerry_kit/order_history/order_history.dart';
import '../grocerry_kit/profile.dart';
import '../grocerry_kit/store_package/stores_list_screen.dart';
import '../providers/user.dart';
import '../services/preferences.dart';
import '../services/push_notification_service.dart';
import '../ui/login_page.dart';

class CustomDrawer extends StatelessWidget {
  final int isGuest;
  CustomDrawer(this.isGuest);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        DrawerHeader(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isGuest != 1) Text('${Provider.of<AppUser>(context, listen: false).userProfile.name}', style: TextStyle(color: Colors.white, fontSize: 17)),
              if (isGuest != 1) Text('${Provider.of<AppUser>(context, listen: false).userProfile.email}', style: TextStyle(color: Colors.white, fontSize: 17)),
              if (isGuest == 1) Text('Welcome Guest!', style: TextStyle(color: Colors.white, fontSize: 17)),
            ],
          ),
          decoration: BoxDecoration(color: Color(0xff0644e3), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0))),
        ),
        _customListTile(
          'Change Store',
              () async {
            final dialog = Material(
              color: Colors.white.withOpacity(0.1),
              child: AlertDialog(
                title: const Text('Changing store?'),
                content: const Text('All the items in the cart will be removed, is it ok ?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No', style: TextStyle(color: Color(0xFF6200EE))),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => StoresListPage(
                                isGuest: isGuest,
                              )));
                    },
                    child: const Text('Yes', style: TextStyle(color: Color(0xFF6200EE))),
                  ),
                ],
              ),
            );

            if (isGuest == 1) {
              CartModel cart = Preferences.getCartItems();
              if (cart.items.isNotEmpty) {
                showDialog(context: context, builder: (_) => dialog);
              } else {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => StoresListPage(
                          isGuest: isGuest,
                        )));
              }
            } else {
              QuerySnapshot docs;
              try {
                docs = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('cart').get();
              } catch (e) {
                print(e);
              }
              if (docs.docs.isEmpty) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => StoresListPage(
                          isGuest: isGuest,
                        )));
              } else {
                showDialog(context: context, builder: (_) => dialog);
              }
            }
          },
          Icons.store,
        ),
        if (isGuest == 1)
          _customListTile(
            'Signin / SignUp',
            () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                return LoginPage();
              }), (Route<dynamic> route) => false);
            },
            Icons.power_settings_new,
          ),
        if (isGuest != 1)
          _customListTile(
            'Order History',
            () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderHistory()));
            },
            Icons.receipt,
          ),
        if (isGuest != 1)
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _customListTile(
                    'Credit Balance : ${((snapshot.data.data() as Map)['credits'] ?? 0).toStringAsFixed(2)} SEK',
                    () {},
                    Icons.money,
                  );
                } else {
                  return _customListTile(
                    'Credit Balance : ... SEK',
                    () {},
                    Icons.money,
                  );
                }
              }),
        if (isGuest != 1)
          _customListTile(
            'My Profile',
            () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyProfile()));
            },
            Icons.person_rounded,
          ),
        if (isGuest != 1)
          _customListTile(
            'Announcements',
            () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => Announcements()));
            },
            Icons.volume_up_rounded,
          ),
        if (isGuest != 1)
          _customListTile(
            'Feedback',
            () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => FeedbackPage()));
            },
            Icons.feedback,
          ),
        if (isGuest != 1)
          _customListTile(
            'Help',
            () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => HelpPage()));
            },
            Icons.help,
          ),
        if (isGuest != 1)
          _customListTile(
            'Logout',
            () async {
              bool val = await showDialog<bool>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    content: Text('Are you sure you want to logout?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                          'No',
                          style: TextStyle(color: Color(0xff0644e3)),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false); // Dismiss alert dialog
                        },
                      ),
                      TextButton(
                        child: Text(
                          'Yes',
                          style: TextStyle(color: Color(0xff0644e3)),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true); // Dismiss alert dialog
                        },
                      ),
                    ],
                  );
                },
              );
              if (val == true) {
                await PushNotificationService.unsubscribeFromAnnouncements();
                await Provider.of<AppUser>(context, listen: false).clearSharedPreferences();
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }), (Route<dynamic> route) => false);
              }
            },
            Icons.power_settings_new,
          ),
      ],
    ));
  }



  Widget _customListTile(String text, Function function, IconData iconN) {
    return Column(
      children: [
        Container(
          //color: Colors.grey.withOpacity(0.4),
            child: ListTile(
              leading: Icon(
                iconN,
                color: text != 'Change Store' ? null : Color(0xff0644e3),
              ),
              title: Text(
                text,
                style: text != 'Change Store' ? null : TextStyle(fontSize: 15, color: Color(0xff0644e3), fontWeight: FontWeight.bold),
              ),
              onTap: function,
            )),
        Divider(height: 0.0),
      ],
    );
  }

}
