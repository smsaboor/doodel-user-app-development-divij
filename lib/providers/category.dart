import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'collection_names.dart';

class CategoryModel {
  String categoryName;
  String categoryImageRef;
  String categoryDocId;

  CategoryModel(
      {@required this.categoryName,
      @required this.categoryImageRef,
      @required this.categoryDocId});
}

class Category with ChangeNotifier {
  ///naming conventions for store model for firebase
  String _categoryName = "categoryName";
  String _categoryImageRef = "categoryImage";

  CategoryModel _storeProfile;

  CategoryModel get storeProfile => _storeProfile;

  Future<void> addNewCategory(
      CategoryModel categoryModel, File image, String storeDocId) async {
    final ref =
        FirebaseStorage.instance.ref().child('images').child("fjijj" + ".jpg");
    await ref.putFile(image);

    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection(stores_collection)
        .doc(storeDocId)
        .collection(category_collection)
        .add({
      _categoryName: categoryModel.categoryName,
      _categoryImageRef: url
    }).catchError((error) {
      throw error;
    });
    notifyListeners();
  }

  Future<void> updateCategory(
      CategoryModel updatedCategoryModel, String storeDocId) async {
    await FirebaseFirestore.instance
        .collection(stores_collection)
        .doc(storeDocId)
        .collection(category_collection)
        .doc(updatedCategoryModel.categoryDocId)
        .update({
      _categoryName: updatedCategoryModel.categoryName,
    }).catchError((error) {
      throw error;
    });
    notifyListeners();
  }

  CategoryModel convertToCategoryModel(DocumentSnapshot docu) {
    var doc = docu.data() as Map;

    return CategoryModel(
        categoryDocId: docu.id,
        categoryName: doc[_categoryName],
        categoryImageRef: doc[_categoryImageRef]);
  }
}
