import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../providers/user.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  TextEditingController _helpController = TextEditingController();
  Color _cartItemColor = Colors.white70;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _helpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel userProfile = Provider.of<AppUser>(context, listen: false).userProfile;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        centerTitle: true,
        backgroundColor: Color(0xff0644e3),
        elevation: 0,
        title: Text('Help', style: TextStyle(color: Colors.white, fontSize: 24)),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('helpdata').doc('helpdata').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: devHeight * 0.036,
                  ),

                  ///FeedBack Section
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      "Help Section",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: devHeight * 0.036,
                  ),

                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Row(
                      children: [
                        Text(
                          "Email: ",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchEmailApp(snapshot.data.data()['email']);
                          },
                          child: Text(
                            snapshot.data.data()['email'],
                            style: TextStyle(decoration: TextDecoration.underline, fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xff0644e3)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Row(
                      children: [
                        Text(
                          "Number: ",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchDialer(snapshot.data.data()['number']);
                          },
                          child: Text(
                            snapshot.data.data()['number'],
                            style: TextStyle(decoration: TextDecoration.underline, fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xff0644e3)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: devHeight * 0.0439,
                  ),

                  _feedbackInput(
                    controller: _helpController,
                    hint: "Ask your question here.",
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      onPressed: () async {
                        // final Email email = Email(
                        //   body: 'Sender Name :${userProfile.name} \n Sender No : ${userProfile.phoneCode.toString() + userProfile.phoneNumber.toString()}  \nSender Address :${userProfile.address}\nSender Email :${userProfile.email}\nMessage : ${_helpController.text} ',
                        //   subject: 'Help',
                        //   recipients: ['support@doodel.se'],
                        //   isHTML: false,
                        // );
                        // await FlutterEmailSender.send(email);
                        if (!await DataConnectionChecker().hasConnection) {
                          ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                          ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
                          return;
                        }
                        if (_helpController.text.isEmpty) {
                          ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                          ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Feedback text is required')));
                          return;
                        }
                        FirebaseFirestore.instance.collection('help').add({'message': _helpController.text, 'number': userProfile.phoneNumber, 'name': userProfile.name, 'email': userProfile.email, 'address': userProfile.address.address, 'userId': userProfile.userId}).then((value) {
                          ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(
                            duration: kSnackBarDuration,
                            content: Text(
                              "Your question has been submitted.",
                            ),
                            backgroundColor: Color(0xff0644e3),
                          ));
                        });
                        setState(() {
                          _helpController.clear();
                        });
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 25,
                          color: Color(0xff0644e3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Future<void> _launchEmailApp(String email) async {
    final String url = 'mailto:$email?subject=Doodel%20App%20Help';
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('No email app found to complete the action')));
    }
  }

  Future<void> _launchDialer(String number) async {
    String url = 'tel:$number';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('No app found to complete the action')));
    }
  }

  Widget _feedbackInput({
    controller,
    hint,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        //margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 2), shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8), color: _cartItemColor),
        padding: EdgeInsets.only(left: 10),
        child: TextFormField(
          keyboardType: TextInputType.multiline,
          minLines: 3,
          //Normal textInputField will be displayed
          maxLines: 10,
          // when user presses enter it will adapt to it
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
          ),
        ),
      ),
    );
  }
}
