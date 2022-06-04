import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Announcements extends StatelessWidget {
  const Announcements({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        centerTitle: true,
        brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: Color(0xff0644e3),
        title: const Text('Announcements', style: TextStyle(color: Colors.white, fontSize: 24)),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('helpdata').doc('announcement').snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

            final docData = (snapshot.data.data()as Map);
            String message = '';
            if (snapshot.data.exists) {
              message = docData['message'];

              if (message.isEmpty) message = 'No announcement!';
            } else {
              message = 'No announcement!';
            }

            return Center(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Text('$message', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 20)),
              ),
            ));
          },
        ),
      ),
    );
  }
}
