import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../const.dart';
import '../main.dart';
import '../packages/gmap_place_picker/gmap_place_picker.dart';
import '../providers/collection_names.dart';
import '../providers/user.dart';
import '../services/preferences.dart';
import '../ui/custom_widgets/button_widget.dart';
import '../ui/custom_widgets/textField_widget.dart';
import '../ui/email_verification_page.dart';
import '../utils/address_bottomsheet.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = auth.FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email;
  String _password;
  String _lastName;
  String _firstName;

  String _address = '';
  String _adrsErr;
  double _lat, _lng;

  String _phoneNumber;
  String _phoneCode;
  var _isLoading = false;
  bool isChecked = false;

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  _addressValidator() {
    if (_address.isEmpty || _lat == null || _lng == null) {
      _adrsErr = 'You must select an Address';
    } else {
      _adrsErr = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xff0644e3),
        title: Text(
          "Signup",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  label: "First Name",
                  hint: "First Name",
                  onChange: (v) {
                    setState(() {
                      _firstName = v.trim();
                    });
                  },
                ),
                SizedBox(height: 10),
                TextFieldWidget(
                  label: "Last Name",
                  hint: "Last Name",
                  onChange: (v) {
                    setState(() {
                      _lastName = v.trim();
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  label: "E-Mail",
                  hint: "E-mail",
                  onChange: (v) {
                    setState(() {
                      _email = v.trim();
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  pass: _obscureText ? true : false,
                  icon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      _toggle();
                    },
                  ),
                  label: "Password",
                  hint: "Password",
                  onChange: (v) {
                    setState(() {
                      _password = v.trim();
                    });
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 80,
                      child: TextFieldWidget(
                        label: "code",
                        hint: "",
                        inputType: TextInputType.phone,
                        onChange: (v) {
                          setState(() {
                            _phoneCode = v.trim();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFieldWidget(
                        label: "Mobile Number",
                        hint: "Mobile Number",
                        inputType: TextInputType.phone,
                        onChange: (v) {
                          setState(() {
                            _phoneNumber = v.trim();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    PlaceInfo result = await openPlacePicker(
                      context,
                      mapsKey,
                      initialCenter: LatLng(59.85882, 17.63889),
                      myLocationButtonEnabled: true,
                      layersButtonEnabled: true,
                      desiredAccuracy: LocationAccuracy.high,
                      countries: ['SE'],
                    );
                    if (result != null && result.address != null) {
                      String fAddress = await showAddressBottomSheet(context, result.address);
                      if (fAddress != null) {
                        _adrsErr = null;
                        _address = fAddress;
                        _lat = result.latLng.latitude;
                        _lng = result.latLng.longitude;
                        setState(() {});
                      }
                    }
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: _address.isEmpty
                            ? Text(
                                _adrsErr == null ? 'Select your delivery address' : _adrsErr,
                                style: TextStyle(color: _adrsErr == null ? Colors.black54 : Colors.red, fontSize: 17),
                              )
                            : Text(
                                _address,
                                style: TextStyle(color: Color(0xff0644e3), fontSize: 17),
                              ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Color(0xff0644e3)),
                        ),
                        child: Icon(
                          Icons.add_location,
                          color: Color(0xff0644e3),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      activeColor: Colors.blue,
                      value: isChecked,
                      onChanged: (value) {
                        setState(() => isChecked = value);
                      },
                    ),
                    Text('I accept the ', style: TextStyle(color: Colors.black87, fontSize: 16)),
                    InkWell(
                      onTap: () {
                        launch('https://m.doodel.se/terms-and-conditions/');
                      },
                      child: Text('Terms and Conditions', style: TextStyle(color: Colors.black87, fontSize: 16, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        textColor: Color(0xff0644e3),
                        bgColor: Colors.white,
                        borderColor: Color(0xff0644e3),
                        onPress: () {
                          Navigator.pop(context);
                        },
                        text: "Sign in",
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomButton(
                        textColor: Colors.white,
                        bgColor: Color(0xff0644e3),
                        borderColor: Color(0xff0644e3),
                        onPress: _isLoading
                            ? null
                            : () {
                                if (!isChecked) {
                                  ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                                  return ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please accept terms and conditions to continue')));
                                }
                                _addressValidator();
                                if (_formKey.currentState.validate() && _adrsErr == null) {
                                  //Only gets here if the fields pass
                                  _formKey.currentState.save();
                                  _signUp(_email.trim(), _password, context);
                                }
                              },
                        text: "Sign Up",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signUp(String email, password, BuildContext ctx) async {
    if (!await DataConnectionChecker().hasConnection) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      String currentUserId;
      var result = await _auth.createUserWithEmailAndPassword(email: email, password: password).then((auth.UserCredential value) {
        value.user.sendEmailVerification();
        currentUserId = value.user.uid.toString();
        FirebaseFirestore.instance.collection(users_collection).doc(value.user.uid).set({
          'address': _address,
          'email': _email,
          'lat': _lat,
          'lng': _lng,
          'name': '${_firstName.toString()} ${_lastName.toString()}',
          "phoneNumber": _phoneNumber,
          "phoneCode": _phoneCode,
          "androidNotificationToken": null,
          "credits": 0,
          "admin": null,
          "userId": value.user.uid,
          "shopkeeperStoreID": null,
          "shopOwnerStoreID": null,
          "userRoles": null,
          "WorkerStores": null,
        });
      }).catchError((message) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          duration: kSnackBarDuration,
          content: Text(
            message.message,
          ),
          backgroundColor: Theme.of(ctx).errorColor,
        ));
      });

      await Provider.of<AppUser>(context, listen: false).getCurrentUser(currentUserId);
      final userData = json.encode(
        {
          'userUid': currentUserId,
        },
      );
      Preferences.wipeAllData();
      Preferences.instance.setString('userData', userData);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return EmailVerificationPage();
      }));
    } on PlatformException catch (err) {
      var message = "An error has occurred, please check your credentials.";

      if (err.message != null) {
        message = err.message;
      }

      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: kSnackBarDuration,
        content: Text(
          message,
        ),
        backgroundColor: Theme.of(ctx).errorColor,
      ));

      setState(() {
        _isLoading = false;
      });
    } on SocketException catch (e) {
      print(e.message);
      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }
}
