import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/user.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  TextEditingController _improvementController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _improvementController.dispose();
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
        title: Text('Feedback', style: TextStyle(color: Colors.white, fontSize: 24)),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: devHeight * 0.036,
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16, top: 4),
              child: Text(
                "Feedback Section",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: devHeight * 0.05,
            ),
            _feedbackInput(
              controller: _improvementController,
              hint: "Please let us know how we can improve...",
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                onPressed: () async {
                  // final Email email = Email(
                  //   body: 'Sender Name :${userProfile.name} \n Sender No : ${userProfile.phoneCode.toString() + userProfile.phoneNumber.toString()} \nSender Email :${userProfile.email} \nSender Address :${userProfile.address} \nMessage : ${_improvementController.text} ',
                  //   subject: 'Feedback',
                  //   recipients: ['support@doodel.se'],
                  //   isHTML: false,
                  // );
                  // await FlutterEmailSender.send(email);
                  if (!await DataConnectionChecker().hasConnection) {
                    ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                    ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
                    return;
                  }
                  if (_improvementController.text.isEmpty) {
                    ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                    ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Feedback text is required')));
                    return;
                  }
                  FirebaseFirestore.instance.collection('improvements').add({'name': userProfile.name, 'message': _improvementController.text, 'number': userProfile.phoneCode.toString() + userProfile.phoneNumber.toString(), 'email': userProfile.email, 'address': userProfile.address.address, 'userId': userProfile.userId}).then((value) {
                    ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(
                      duration: kSnackBarDuration,
                      content: Text(
                        "Your Feedback has been submitted.",
                      ),
                      backgroundColor: Color(0xff0644e3),
                    ));
                  });
                  setState(() {
                    _improvementController.clear();
                  });
                },
                //color: Colors.white,
                child: Text(
                  'Submit',
                  style: TextStyle(color: Color(0xff0644e3), fontSize: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedbackInput({
    controller,
    hint,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        //margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 2), shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8), color: Colors.white70),
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
