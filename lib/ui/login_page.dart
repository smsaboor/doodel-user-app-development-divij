import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../const.dart';
import '../grocerry_kit/home_page.dart';
import '../grocerry_kit/store_package/stores_list_screen.dart';
import '../main.dart';
import '../packages/gmap_place_picker/gmap_place_picker.dart';
import '../providers/collection_names.dart';
import '../providers/user.dart';
import '../services/app_maintenance_service.dart';
import '../services/new_version_service.dart';
import '../services/preferences.dart';
import '../ui/custom_widgets/button_widget.dart';
import '../ui/custom_widgets/heading_widget.dart';
import '../ui/custom_widgets/textField_widget.dart';
import '../ui/sign_up_screen.dart';
import '../utils/address_bottomsheet.dart';
import 'email_verification_page.dart';

bool isFirstLaunch = false;

class LoginPage extends StatefulWidget {
  static const routeName = "signInPage";
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double height;

  double width;
  String _email = '';
  String _pass = '';
  final _auth = auth.FirebaseAuth.instance;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  bool _isLoadingReset = false;

  @override
  void initState() {
    appMaintenanceChecker();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      NewVersionCheckerService.showUpdateDialog(context);
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('settings').doc('maintenance').get();
      if (doc.data() == null) {
        return;
      }
      if (((doc.data() as Map)['underMaintenance']) ?? false) {
        return;
      }
      if (auth.FirebaseAuth.instance.currentUser != null) {
        Provider.of<AppUser>(context, listen: false).tryAutoLogin(context).then((value) {
          isFirstLaunch = value;
        });
      }
    });
    super.initState();
  }

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    height=MediaQuery.of(context).size.height;
    width=MediaQuery.of(context).size.width;
    devHeight = MediaQuery.of(context).size.height;
    devWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                        height: height * 0.12,
                        child: Image(
                          fit: BoxFit.fill,
                          image: AssetImage("images/logo.png"),
                        )),
                  ),
                  SizedBox(
                    height: height * 0.1,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.8, horizontal: 8.0),
                      child: HeadingWidget(
                        heading: "Welcome",
                      )),
                  TextFieldWidget(
                    onChange: (v) {
                      setState(() {
                        _email = v;
                      });
                    },
                    hint: "Email",
                    label: "Email",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    onChange: (v) {
                      setState(() {
                        _pass = v;
                      });
                    },
                    icon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        _toggle();
                      },
                    ),
                    pass: _obscureText ? true : false,
                    hint: "Password",
                    label: "Password",
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: _isLoadingReset
                        ? SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(strokeWidth: 1, valueColor: AlwaysStoppedAnimation(Colors.grey)),
                          )
                        : SizedBox(
                            height: 20,
                            child: InkWell(
                              onTap: _isLoading || _isLoadingReset
                                  ? null
                                  : () {
                                      if (_email != null && _email.isNotEmpty) {
                                        _resetPassword(_email.trim(), context);
                                      } else {
                                        ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          duration: kSnackBarDuration,
                                          content: Text('Email must not be empty.'),
                                          backgroundColor: Theme.of(context).primaryColor,
                                        ));
                                      }
                                    },
                              child: Text(
                                "Forgot Password",
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ),
                          ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          textColor: Colors.white,
                          bgColor: Color(0xff0644e3),
                          borderColor: Color(0xff0644e3),
                          onPress: _isLoading || _isLoadingReset
                              ? null
                              : () {
                                  if (_email.isEmpty) {
                                    ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Email field is required'), backgroundColor: Theme.of(context).errorColor));
                                    return;
                                  }
                                  if (_pass.isEmpty) {
                                    ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Password field is required'), backgroundColor: Theme.of(context).errorColor));
                                    return;
                                  }

                                  _login(_email.trim(), _pass, context);
                                },
                          text: "Login",
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: CustomButton(
                          textColor: Color(0xff0644e3),
                          bgColor: Colors.white,
                          borderColor: Color(0xff0644e3),
                          onPress: () async{
                            final paymentMethod = await Stripe.instance.createPaymentMethod(PaymentMethodParams.card());
                            // Navigator.push(context, MaterialPageRoute(builder: (context) {
                            //   return SignUpScreen();
                            // }
                            //
                            // ));
                          },
                          text: "Sign Up",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(child: SizedBox()),
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          textColor: Color(0xff0644e3),
                          bgColor: Colors.white,
                          borderColor: Color(0xff0644e3),
                          onPress: () async {
                            if (await DataConnectionChecker().hasConnection) {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                return StoresListPage(isGuest: 1);
                              }));
                            } else {
                              ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                              ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
                            }
                          },
                          text: "Use As Guest Mode",
                        ),
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Visibility(visible: _isLoading, child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword(String email, BuildContext ctx) async {
    if (!await DataConnectionChecker().hasConnection) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
      return;
    }
    setState(() {
      _isLoadingReset = true;
    });
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(
        duration: kSnackBarDuration,
        content: Text(
          "A recovery email has been sent to you.",
        ),
      ));
    } on auth.FirebaseAuthException catch (err) {
      var message = "An error has occurred, please check your credentials.";

      if (err.message != null) {
        message = err.message;
      }

      if (email == null || email.isEmpty) {
        message = "Please enter your registered email";
      }

      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(
        duration: kSnackBarDuration,
        content: Text(
          message,
        ),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
    } on SocketException catch (e) {
      print(e.message);
      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
    } catch (_) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('An error occurred while processing your request'), backgroundColor: Theme.of(context).errorColor));
    }
    setState(() {
      _isLoadingReset = false;
    });
  }

  void _login(email, password, BuildContext ctx) async {
    if (!await DataConnectionChecker().hasConnection) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
      return;
    }
    print('Logging In');
    setState(() {
      _isLoading = true;
    });
    try {
      auth.UserCredential value = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (value.user.emailVerified == false) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
        ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Your email is not verified. Please verify your email to log in.')));
        // await value.user.sendEmailVerification();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return EmailVerificationPage();
        }));
        return;
      }
      print('it');
      String currentUserId = value.user.uid;
      var prefs = Preferences.instance;
      final address = Preferences.getGuestAddress();
      print('is');
      bool goToHome = true;
      if (address != null) {
        await FirebaseFirestore.instance.collection(users_collection).doc(currentUserId).update(address.toMap());
        Preferences.deleteSelectedAddress();
        final cart = Preferences.getCartItems();
        if (cart.items.isNotEmpty) {
          cart.items.forEach((element) async {
            await FirebaseFirestore.instance.collection(users_collection).doc(currentUserId).collection('cart').add(element.toMap().cast<String, dynamic>());
          });
          Preferences.deleteCartItems();
        }
        goToHome = false;
      } else {
        await Preferences.deleteUserStoreData();
      }
      print('still');

      await Provider.of<AppUser>(context, listen: false).getCurrentUser(currentUserId);
      await checkUserCoordinates(context, currentUserId);
      final userData = json.encode({'userUid': currentUserId});
      prefs.setString('userData', userData);
      isFirstLaunch = false;
      print('running');
      if (!prefs.containsKey('userStoreData') && goToHome) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StoresListPage()));
      } else {
        final extractedStoreData = json.decode(prefs.getString('userStoreData')) as Map<String, Object>;
        String userStoreName = extractedStoreData['userStoreName'];
        String userStoreDocId = extractedStoreData['userStoreDocId'];
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(storeDocId: userStoreDocId, storeName: userStoreName)));
      }
    } on SocketException catch (e) {
      print(e.message);
      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
    } on auth.FirebaseAuthException catch (err) {
      print(err);
      var message = "An error has occurred, please check your credentials.";

      if (err.message != null) {
        if (err.message == 'The email address is badly formatted.') {
          message = 'Please enter a valid email';
        }
      }

      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
    } catch (err) {
      print(err);
      var message = "An error has occurred, please check your credentials.";

      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> checkUserCoordinates(BuildContext context, String userId) async {
    final UserModel user = Provider.of<AppUser>(context, listen: false).userProfile;
    if ((user.address?.lat == null || user.address?.lng == null || user.address?.address == null) ?? true) {
      await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext dialogContext) {
            return AlertDialog(content: Text('Please select your delivery address to continue'), actions: <Widget>[
              TextButton(
                child: Text(
                  'Ok',
                  style: TextStyle(color: Color(0xff0644e3)),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              )
            ]);
          });
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
          result.address = fAddress;
          Provider.of<AppUser>(context, listen: false).updateUserAddress(result, userId);
        } else {
          checkUserCoordinates(context, userId);
        }
      } else {
        checkUserCoordinates(context, userId);
      }
    }
  }
}
