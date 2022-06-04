import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../const.dart';
import '../grocerry_kit/home_page.dart';
import '../grocerry_kit/model/address_model.dart';
import '../grocerry_kit/store_package/stores_list_screen.dart';
import '../packages/gmap_place_picker/gmap_place_picker.dart';
import '../services/preferences.dart';
import '../ui/email_verification_page.dart';
import '../utils/address_bottomsheet.dart';
import 'collection_names.dart';

class UserModel {
  String userId;
  String name;
  Address address;
  String phoneNumber;
  String email;
  String phoneCode;
  // String userId;
  double credits;
  NotificationToken notificationToken;

  UserModel({
    this.address,
    this.userId,
    this.phoneNumber,
    this.credits,
    this.name,
    this.phoneCode,
    this.email,
    this.notificationToken,
  });

  UserModel.fromMap(Map<String, dynamic> json) {
    userId = json['userId'];
    phoneNumber = json['phoneNumber'];
    address = Address.fromMap(json);
    credits = double.parse(json['credits'].toString());
    name = json['name'];
    phoneCode = json['phoneCode'];
    email = json['email'];
    notificationToken = json['notificationToken'] != null ? NotificationToken.fromJson(json['notificationToken']) : null;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['phoneNumber'] = this.phoneNumber;
    data['credits'] = this.credits;
    data['name'] = this.name;
    data['phoneCode'] = this.phoneCode;
    data['email'] = this.email;
    data['notificationToken'] = this.notificationToken?.toJson() ?? null;
    data.addAll(address.toMap());
    return data;
  }

  // UserModel({
  //   @required this.address,
  //   @required this.email,
  //   @required this.name,
  //   @required this.userDocId,
  //   @required this.phoneNumber,
  //   @required this.phoneCode,
  // });

  // Map<String, dynamic> toMap() {
  //   Map<String, dynamic> map = {
  //     'email': email,
  //     'name': name,
  //     'phoneCode': phoneCode,
  //     'phoneNumber': phoneNumber,
  //     'userDocId': userDocId,
  //   };
  //   map.addAll(address.toMap());
  //   return map;
  // }
  //
  // UserModel.fromMap(Map<String, dynamic> map) {
  //   this.email = map['email'];
  //   this.name = map['name'];
  //   this.phoneCode = map['phoneCode'];
  //   this.address = Address.fromMap(map);
  //   this.phoneNumber = map['phoneNumber'];
  //   this.userDocId = map['userDocId'];
  // }
}

class NotificationToken {
  String token;
  String apnsToken;
  DateTime dateCreated;
  NotificationToken({this.token, this.dateCreated, this.apnsToken});

  NotificationToken.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    apnsToken = json['apnsToken'];
    dateCreated = DateTime.parse(json['dateCreated']);
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'dateCreated': dateCreated.toString(), 'apnsToken': apnsToken};
  }
}

class AppUser with ChangeNotifier {
  String first;
  String second;
  String third;

  // String _name = 'name';
  // String _address = 'address';
  // String _phoneNumber = 'phoneNumber';
  // String _email = 'email';

  UserModel _userProfile;
  // UserModel _userProfile = UserModel(address: null, email: 'Guest', name: 'Guest', userDocId: 'Guest', phoneNumber: '', phoneCode: '');
  UserModel get userProfile => _userProfile;
  String _userStoreId;
  String get userStoreId => _userStoreId;
  String _userStoreDocId;
  String get userStoreDocId => _userStoreDocId;
  String _userStoreName;
  String get userStoreName => _userStoreName;

  int quoteNumber = 0;

  final imagesLoc = '';

  AppUser() {
    quoteNumber = Preferences.instance.getInt('quoteNumber');
    if (quoteNumber == null) {
      quoteNumber = 0;
    }
    print(quoteNumber);
  }

  final List<List> _quotes = [
    ['images/quotes/01_Carrot.gif', 'Carrots have zero fat content.'],
    ['images/quotes/02_Potato.gif', 'Potatoes were the first food to be grown in space. In 1996 potato plants were taken to space with space shuttle COLUMBIA.'],
    ['images/quotes/03_Lemon.gif', 'Lemons contain more sugar than strawberries.'],
    ['images/quotes/04_Pineapple.gif', 'Pineapple juice is 5 times more effective than cough syrup. It also prevents cold and flu.'],
    ['images/quotes/05_Avacado.gif', 'The Avocado contains more fat than most fruits.'],
    ['images/quotes/06_Choco.gif', 'Eating chocolates while studying helps the brain retain new information easily.'],
    ['images/quotes/07_banana_PS_gif.gif', 'Banana contains no fat, cholesterol or sodium.'],
    ['images/quotes/08_Apple.gif', 'Eating an apple is more reliable method of staying awake than consuming a cup of coffee.'],
    ['images/quotes/09_Onion.gif', 'Hold slice of bread in your mouth to avoid crying while cutting onions.'],
    ['images/quotes/10_Strawberry.gif', 'The strawberry is the only fruit with exposed seeds.'],
  ];

  List<List> get quotes => _quotes;

  List getQuote({int changeQuoteNumber}) {
    final List toReturn = _quotes[changeQuoteNumber];
    // if (changeQuoteNumber == 1) {
    //   if (quoteNumber == 9) {
    //     quoteNumber = 0;
    //   } else {
    //     quoteNumber++;
    //   }
    // }
    // SharedPreferences.getInstance().then((value) {
    //   value.setInt('quoteNumber', quoteNumber);
    // });
    // print(quoteNumber);
    return toReturn;
  }

  Future<void> clearSharedPreferences() async {
    _userStoreId = null;
    _userStoreDocId = null;
    _userStoreName = null;
    _userProfile = null;
    Preferences.instance.clear();
  }

  Future<void> setUserStoreId({String storeId, String storeName, String storeDocId, int isGuest}) async {
    _userStoreId = storeId;
    _userStoreDocId = storeDocId;
    _userStoreName = storeName;

    final userStoreData = json.encode(
      {'userStoreName': storeName, 'userStoreId': storeId, 'userStoreDocId': storeDocId},
    );
    setDeliveryCharges();
    Preferences.instance.setString('userStoreData', userStoreData);
  }

  Future<bool> tryAutoLogin(BuildContext context) async {
    final prefs = Preferences.instance;
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userUid = extractedUserData['userUid'];
    await getCurrentUser(userUid);
    await checkUserCoordinates(context, userUid);
    if (!prefs.containsKey('userStoreData')) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FirebaseAuth.instance.currentUser.emailVerified ? StoresListPage() : EmailVerificationPage()));
    } else {
      final extractedStoreData = json.decode(prefs.getString('userStoreData')) as Map<String, Object>;
      _userStoreName = extractedStoreData['userStoreName'];
      _userStoreId = extractedStoreData['userStoreId'];
      _userStoreDocId = extractedStoreData['userStoreDocId'];

      setDeliveryCharges();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => FirebaseAuth.instance.currentUser.emailVerified
                // ? StoresListPage()
                ? HomePage(storeDocId: _userStoreDocId, storeName: _userStoreName)
                : EmailVerificationPage()),
      );
    }
    notifyListeners();
    return true;
  }

  void setDeliveryCharges() async {
    await FirebaseFirestore.instance.collection('helpdata').doc('deliverycharges').collection(_userStoreDocId).doc('deliverycharges').get().then((DocumentSnapshot value) {
      first = (value.data() as Map)['first'];
      second = (value.data() as Map)['second'];
      third = (value.data() as Map)['third'];
    });
  }

  Future<void> getCurrentUser(String currentUserId) async {
    await FirebaseFirestore.instance.collection(users_collection).doc(currentUserId).get().then((value) {
      _userProfile = convertToUserModel(value);
    }).catchError((error) {
      throw error;
    });

    notifyListeners();
  }

  updateUserAddress(PlaceInfo result, String userId) async {
    print(result.address);
    final address = Address(address: result.address, lat: result.latLng.latitude, lng: result.latLng.longitude);
    _userProfile.address = address;
    Preferences.deleteUserStoreData();
    FirebaseFirestore.instance.collection(users_collection).doc(userId).update({'lat': result.latLng.latitude, 'lng': result.latLng.longitude, 'address': result.address});
    notifyListeners();
  }

  Future<void> checkUserCoordinates(BuildContext context, String userId) async {
    if ((_userProfile.address?.lat == null || _userProfile.address?.lng == null || _userProfile.address?.address == null) ?? true) {
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
          updateUserAddress(result, userId);
        } else {
          checkUserCoordinates(context, userId);
        }
      } else {
        checkUserCoordinates(context, userId);
      }
    }
  }

  UserModel convertToUserModel(DocumentSnapshot docu) {
    var doc = docu.data() as Map<String, dynamic>;
    return UserModel.fromMap(doc);
    // return UserModel(
    //   email: doc[_email],
    //   name: doc[_name],
    //   phoneCode: doc['phoneCode'],
    //   address: Address(address: doc[_address], lat: doc['lat'], lng: doc['lng']),
    //   phoneNumber: doc[_phoneNumber],
    //   userId: docu.id,
    // );
  }
}
