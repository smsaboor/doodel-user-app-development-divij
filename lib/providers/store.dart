import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'collection_names.dart';

class StoreModel {
  String storeDocId;
  String storeName;
  String storeId;
  String storePassword;
  String storeAddress;
  String storeImageRef;
  double lat;
  double lng;
  int startingTime;
  int endingTime;

  StoreModel({@required this.storeId, @required this.storePassword, @required this.storeName, @required this.storeDocId, @required this.storeAddress, @required this.storeImageRef, @required this.startingTime, @required this.endingTime});
}

class Store with ChangeNotifier {
  ///naming conventions for store model for firebase
  String _storeName = "storeName";
  String _storeId = "storeId";
  String _storePassword = "storePassword";
  String _storeAddress = "storeAddress";
  String _storeImageRef = "storeImage";

  StoreModel _storeProfile;

  StoreModel get storeProfile => _storeProfile;

  Future<void> addNewStore(StoreModel storeModel, File image) async {
    final ref = FirebaseStorage.instance.ref().child('images').child("fjijj" + ".jpg");
    await ref.putFile(image);

    final url = await ref.getDownloadURL();
    print('saboor::::::::::: ${FirebaseFirestore.instance.collection(stores_collection)}');
    await FirebaseFirestore.instance.collection(stores_collection).add({_storeName: storeModel.storeName, _storePassword: storeModel.storePassword, _storeId: storeModel.storeId, _storeAddress: storeModel.storeAddress, _storeImageRef: url}).catchError((error) {
      throw error;
    });
    notifyListeners();
  }

  Future<void> updateStore(StoreModel updatedStoreModel) async {
//    final ref = FirebaseStorage.instance
//        .ref()
//        .child('images');
//    await ref.putFile(image).onComplete;
//
//    final url = ref.getDownloadURL();

    FirebaseFirestore.instance.collection(stores_collection).doc(updatedStoreModel.storeDocId).update({
      _storeName: updatedStoreModel.storeName,
      _storePassword: updatedStoreModel.storePassword,
      _storeId: updatedStoreModel.storeId,
      _storeAddress: updatedStoreModel.storeAddress,
    }).catchError((error) {
      throw error;
    });
    notifyListeners();
  }

  StoreModel convertToStoreModel(DocumentSnapshot docu) {
    var doc = docu.data() as Map;
    DateTime now = DateTime.now();
    String currentDay = DateFormat.EEEE().format(now);
    var data = doc['daytimes'];
    int startingTime = 0, endingTime = 0;
    try {
      startingTime = data[currentDay]['startingTime'];
      endingTime = data[currentDay]['endingTime'];
    } catch (e) {
      print('----->>>>>>      ${data[currentDay]}');
      print(e);
    }
    return StoreModel(storeDocId: docu.id, storeName: doc[_storeName], storePassword: doc[_storePassword], storeId: doc[_storeId], storeAddress: doc[_storeAddress], storeImageRef: doc[_storeImageRef], startingTime: startingTime, endingTime: endingTime);
  }
}
