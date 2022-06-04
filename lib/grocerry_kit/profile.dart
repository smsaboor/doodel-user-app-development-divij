import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../grocerry_kit/sub_pages/edit_profile_page.dart';
import '../main.dart';
import '../providers/collection_names.dart';
import '../providers/user.dart';
import '../ui/login_page.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  TextEditingController _addressController = TextEditingController();
  TextEditingController _helpController = TextEditingController();
  Color _cartItemColor = Colors.white70;

  @override
  void dispose() {
    _addressController.dispose();
    _helpController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel userProfile = Provider.of<AppUser>(context, listen: true).userProfile;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        centerTitle: true,
        backgroundColor: Color(0xff0644e3),
        elevation: 0,
        title: Text('My Profile', style: TextStyle(color: Colors.white, fontSize: 24)),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(
                  height: devHeight * 0.029,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance.collection(users_collection).doc(userProfile.userId).snapshots(),
                      builder: (context, AsyncSnapshot snapshot) {
                        var data = snapshot.data;
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ///Profile Data Section
                            _myProfileData(icon: Icons.person, data: data['name']),
                            _myProfileData(icon: Icons.email, data: data['email']),
                            Row(
                              children: [
                                Container(
                                  width: 132,
                                  child: _myProfileData(data: data['phoneCode']),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width - 150,
                                  child: _myProfileData(icon: Icons.phone, data: data['phoneNumber']),
                                ),
                              ],
                            ),
                            _myaddressData(icon: Icons.location_city, heading: "address", data: data['address']),
                            SizedBox(
                              height: devHeight * 0.0234,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                color: Color(0xff0644e3),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return EditProfilePage();
                                  }));
                                },
                                child: Text(
                                  'Edit Profile',
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                color: Colors.red,
                                onPressed: () {
                                  Provider.of<AppUser>(context, listen: false).clearSharedPreferences().then((value) {
                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                                      return LoginPage();
                                    }), (Route<dynamic> route) => false);
                                  });
                                },
                                child: Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _myProfileData({IconData icon, data}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          height: devHeight * 0.103,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 2), shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8), color: _cartItemColor),
          child: Container(
            child: Row(
              mainAxisAlignment: icon != null ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      icon,
                      size: 20,
                      color: Colors.grey[500],
                    ),
                  ),
                Text(
                  data,
                  maxLines: 5,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _myaddressData({IconData icon, heading, data}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          color: _cartItemColor,
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.location_city, size: 25, color: Colors.grey[500]),
            SizedBox(width: 10.0),
            Expanded(
              child: Text(
                '$data',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//  Widget _textAddressInput({TextEditingController controller, hint, icon}) {
//    return Padding(
//      padding: const EdgeInsets.all(8.0),
//      child: Container(
//        height: devHeight * 0.1024,
//        //margin: EdgeInsets.only(top: 10),
//        decoration: BoxDecoration(
//            border: Border.all(color: Colors.grey, width: 2),
//            shape: BoxShape.rectangle,
//            borderRadius: BorderRadius.circular(8),
//            color: _cartItemColor),
//        padding: EdgeInsets.only(top: 13),
//        child: TextFormField(
//          keyboardType: TextInputType.multiline,
//          minLines: 1,
//          //Normal textInputField will be displayed
//          maxLines: 5,
//          // when user presses enter it will adapt to it
//          controller: controller,
//          decoration: InputDecoration(
//            border: InputBorder.none,
//            hintText: hint,
//            prefixIcon: Icon(icon),
//          ),
//        ),
//      ),
//    );
//  }
}
