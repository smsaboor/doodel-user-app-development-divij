import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';

class DatabaseService {
  static final FirebaseFirestore _instance = FirebaseFirestore.instance;
  static double bagCharges;
  static double minimumOrderLimit;
  static int bagNeeded;
  static double credit;
  static List<QueryDocumentSnapshot> cartsSnap;
  static CouponData couponData;
  static StoreTimeData storeTimeData;
  static List<dynamic> deliveryTiming = [];
  static List<dynamic> allDeliveryTiming = [];

  Future<List<bool>> optionActive(String id) async {
    QuerySnapshot snap = await _instance.collection('deliveryTimingsCollection').doc(id).collection('deliveryTimingsCollection').orderBy('deliveryTime').get();
    return snap.docs.map((e) => (e.data() as Map)['status'] == 'active').toList();
  }

  Future<String> uploadImage(File file) async {
    Reference ref = FirebaseStorage.instance.ref('orderImage').child(FirebaseAuth.instance.currentUser.uid);
    TaskSnapshot task = await ref.putFile(file);
    print(await task.ref.getDownloadURL());
    return task.ref.getDownloadURL();
  }

  getCredit() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).get();
      credit = double.tryParse((doc.data() as Map)['credits'].toString());
    } catch (e) {
      credit = 0;
    }
  }

  updateCredit(double usedCredits) async {
    double newBalance = credit - usedCredits;
    _instance.collection('credits').doc(FirebaseAuth.instance.currentUser.uid).update({'credits': newBalance});
  }

  getBagCharges() async {
    DocumentSnapshot doc = await _instance.collection('helpdata').doc('bagCharges').get();
    bagCharges = double.tryParse((doc.data() as Map)['price'].toString());
  }

  getMinimumOrderLimit(String storeId) async {
    DocumentSnapshot doc = await _instance.collection('groceryShops').doc(storeId).get();
    minimumOrderLimit = double.tryParse((doc.data() as Map)['minimumOrderPrice'].toString());
  }

  Stream<List<QueryDocumentSnapshot>> cartItems() {
    Stream<QuerySnapshot> docs = _instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('cart').snapshots();
    return docs.map((event) {
      cartsSnap = event.docs;
      // bagNeeded = event.docs.length/10;
      return event.docs;
    });
  }

  Future<void> updateQuanity(String docID, int qty, double price) async {
    await _instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('cart').doc(docID).update({'quantity': qty, 'subtotal': price * qty});
  }

  clearCart() {
    _instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('cart').get().then((value) => value.docs.forEach((element) {
          element.reference.delete();
        }));
  }

  getStoreOpeningClosingTime(String storeID) async {
    DocumentSnapshot docs = await _instance.collection('groceryShops').doc(storeID).get();
    print(docs.data());
    storeTimeData = StoreTimeData.fromJson(docs.data());
  }

  Future<bool> applyCoupon(BuildContext context, couponCode, total) async {
    QuerySnapshot docs = await _instance.collection('discountCoupons').doc(Provider.of<AppUser>(context, listen: false).userStoreDocId).collection('discountCoupons').where('promoCode', isEqualTo: couponCode).get();
    if (docs.docs.length > 0) {
      couponData = CouponData.fromJson(docs.docs[0].data());
      couponData.couponID = docs.docs[0].id;
      if (total < couponData.limitAmount) {
        return false;
      }
      return true;
    } else {
      couponData = null;
      return false;
    }
  }

  Future<dynamic> getlimitCoupon(BuildContext context, couponCode, total) async {
    QuerySnapshot docs = await _instance.collection('discountCoupons').doc(Provider.of<AppUser>(context, listen: false).userStoreDocId).collection('discountCoupons').where('promoCode', isEqualTo: couponCode).get();
    if (docs.docs.length > 0) {
      couponData = CouponData.fromJson(docs.docs[0].data());
      if (total < couponData.limitAmount) {
        return couponData.limitAmount;
      }
      // couponData.couponID = docs.docs[0].id;
      // return true;
    } else {
      return 0;
    }
  }

  Future<void> getDeliveryTiming(String storeID) async {
    int hour = DateTime.now().hour;
    print("dT$hour");
    String currentTime;
    if (hour < 5 || (hour < 6 && DateTime.now().minute <= 59)) {
      currentTime = '0${hour + (DateTime.now().minute <= 59 ? 4 : 5)}';
    } else {
      currentTime = '${hour + (DateTime.now().minute <= 59 ? 4 : 5)}';
    }
    // if (hour < 6 ) {
    //   currentTime = '0${hour + 4}';
    // } else {
    //   currentTime = '${hour + 4}';
    // }
    QuerySnapshot snap = await _instance.collection('deliverySchedule').doc(storeID).collection('deliverySchedule').where('status', isEqualTo: 'active').orderBy('deliveryTime').startAt([currentTime]).get();

    deliveryTiming = snap.docs.map((e) => (e.data() as Map)['deliveryTime']).toList();

    print("dT$deliveryTiming");
  }

  Future<void> getAllActiveDeliveryTiming(String storeID) async {
    int hour = DatabaseService.storeTimeData.openingHour;
    DateTime now = DateTime.now();
    String currentDay = DateFormat.EEEE().format(now);
    // DateTime.now().hour;
    String currentTime;
    if (hour < 9) {
      currentTime = '0$hour';
    } else {
      currentTime = '$hour';
    }
    int hr = DatabaseService.storeTimeData.closingHour;

    // DateTime.now().hour;
    String endTime;
    if (hr < 9) {
      endTime = '0$hr';
    } else {
      endTime = '$hr';
    }
    QuerySnapshot snap = await _instance.collection('deliverySchedule').doc(storeID).collection(currentDay).where('status', isEqualTo: 'active').orderBy('deliveryTime').startAt([currentTime]).endAt([endTime]).get();

    allDeliveryTiming = snap.docs.map((e) => (e.data() as Map)['deliveryTime']).toList();
    print("the all delivery times are $allDeliveryTiming");
  }
}

class CouponData {
  CouponData({this.discPercentage, this.limitAmount, this.promoCode, this.type, this.couponID});

  int discPercentage;
  String couponID;
  int limitAmount;
  String promoCode;
  int type;

  factory CouponData.fromJson(Map<String, dynamic> json) {
    int discount = 0;
    if (json["type"] == 1) {
      discount = int.parse(json["discPercentage"]);
    } else {
      discount = json["discPercentage"];
    }
    return CouponData(
      discPercentage: discount,
      limitAmount: int.parse(json["limitAmount"]),
      promoCode: json["promoCode"],
      type: json["type"],
    );
  }
}

class StoreTimeData {
  StoreTimeData({this.closingHour, this.openingHour, this.monTimings, this.tueTimings, this.wedTimings, this.thuTimings, this.friTimings, this.satTimings, this.sunTimings});

  int openingHour;
  int closingHour;
  Map<String, dynamic> monTimings = {};
  Map<String, dynamic> tueTimings = {};
  Map<String, dynamic> wedTimings = {};
  Map<String, dynamic> thuTimings = {};
  Map<String, dynamic> friTimings = {};
  Map<String, dynamic> satTimings = {};
  Map<String, dynamic> sunTimings = {};

  factory StoreTimeData.fromJson(Map<String, dynamic> json) {
    DateTime now = DateTime.now();
    String currentDay = DateFormat.EEEE().format(now);
    if (json['daytimes'][currentDay] != 'Close') {
      return StoreTimeData(
        openingHour: int.parse(json['daytimes'][currentDay]['startingTime'].toString() != 'Close' ? json['daytimes'][currentDay]['startingTime'].toString() : '0') ?? 0,
        closingHour: int.parse(json['daytimes'][currentDay]['endingTime'].toString() != 'Close' ? json['daytimes'][currentDay]['endingTime'].toString() : '0') ?? 0,
        monTimings: json['daytimes']['Monday'] != 'Close' ? json['daytimes']['Monday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
        tueTimings: json['daytimes']['Tuesday'] != 'Close' ? json['daytimes']['Tuesday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
        wedTimings: json['daytimes']['Wednesday'] != 'Close' ? json['daytimes']['Wednesday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
        thuTimings: json['daytimes']['Thursday'] != 'Close' ? json['daytimes']['Thursday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
        friTimings: json['daytimes']['Friday'] != 'Close' ? json['daytimes']['Friday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
        satTimings: json['daytimes']['Saturday'] != 'Close' ? json['daytimes']['Saturday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
        sunTimings: json['daytimes']['Sunday'] != 'Close' ? json['daytimes']['Sunday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
      );
    }
    return StoreTimeData(
      openingHour: 0,
      closingHour: 0,
      monTimings: json['daytimes']['Monday'] != 'Close' ? json['daytimes']['Monday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
      tueTimings: json['daytimes']['Tuesday'] != 'Close' ? json['daytimes']['Tuesday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
      wedTimings: json['daytimes']['Wednesday'] != 'Close' ? json['daytimes']['Wednesday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
      thuTimings: json['daytimes']['Thursday'] != 'Close' ? json['daytimes']['Thursday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
      friTimings: json['daytimes']['Friday'] != 'Close' ? json['daytimes']['Friday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
      satTimings: json['daytimes']['Saturday'] != 'Close' ? json['daytimes']['Saturday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
      sunTimings: json['daytimes']['Sunday'] != 'Close' ? json['daytimes']['Sunday'] : {'startingTime': 'Close', 'endingTime': 'Close'},
    );
  }
}
