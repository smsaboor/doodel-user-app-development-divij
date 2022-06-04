import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductModel {
  String productDocId;
  String cat;
  String subCat;
  String productName;
  String productPrice;
  String storeID;
  String productImageRef;
  int productStock;
  bool isInStock;
  int momOption;
  List keywords;
  String description;
  String offerPrice;
  List<dynamic> images;

  ProductModel({@required this.productPrice, @required this.keywords, @required this.offerPrice, @required this.productName, @required this.productDocId, @required this.productImageRef, @required this.isInStock, @required this.subCat, @required this.storeID, @required this.cat, @required this.momOption, @required this.productStock, @required this.images, @required this.description});
}

class Product with ChangeNotifier {
  ///naming conventions for store model for firebase
  String _productName = "productName";
  String _productPrice = "productPrice";
  String _productImageRef = "productImage";

  ProductModel _storeProfile;

  ProductModel get storeProfile => _storeProfile;

//  Future<void> addNewProduct(
//      {@required ProductModel productModel,
//      @required File image,
//      @required String storeDocId,
//      @required String categoryDocId}) async {
//    final ref =
//        FirebaseStorage.instance.ref().child('images').child("fjijj" + ".jpg");
//    await ref.putFile(image).onComplete;
//
//    final url = await ref.getDownloadURL();
//
//    await Firestore.instance
//        .collection(stores_collection)
//        .document(storeDocId)
//        .collection(category_collection)
//        .document(categoryDocId)
//        .collection(products_collection)
//        .add({
//      _productName: productModel.productName,
//      _productPrice: productModel.productPrice,
//      _productImageRef: url
//    }).catchError((error) {
//      throw error;
//    });
//    notifyListeners();
//  }

//  Future<void> updateProduct(
//      {@required ProductModel updatedProductModel,
//      @required String storeDocId,
//      @required categoryDocId}) async {
//    await Firestore.instance
//        .collection(stores_collection)
//        .document(storeDocId)
//        .collection(category_collection)
//        .document(categoryDocId)
//        .collection(products_collection).document(updatedProductModel.productDocId)
//        .updateData({
//      _productName: updatedProductModel.productName,
//      _productPrice: updatedProductModel.productPrice,
//    }).catchError((error) {
//      throw error;
//    });
//    notifyListeners();
//  }

  ProductModel convertToProductModel(DocumentSnapshot docu, {index}) {
    var doc = docu.data() as Map;
    return ProductModel(
      productDocId: docu.id,
      productName: doc[_productName],
      productPrice: doc[_productPrice],
      productImageRef: doc[_productImageRef] == null || doc[_productImageRef].isEmpty ? "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/300px-No_image_available.svg.png" : doc[_productImageRef][0],
      offerPrice: doc['offerPrice'],
      storeID: doc['storeId'],
      productStock: doc['productStock'],
      momOption: doc['momOption'],
      isInStock: doc['isInStock'],
      description: doc['description'],
      cat: doc['catID'] ?? "",
      subCat: doc['subcatID'] ?? "",
      keywords: doc['keywords'] ?? [],
      images: doc['productImage'] == null ? ["https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/300px-No_image_available.svg.png"] : doc['productImage'],
    );
  }

  ProductModel convertToProductModel2(DocumentSnapshot docu) {
    var doc = docu.data() as Map;
    return ProductModel(
      keywords: doc['keywords'] ?? [],
      productDocId: docu.id,
      productName: doc[_productName],
      productPrice: doc[_productPrice],
      productImageRef: doc[_productImageRef],
      offerPrice: doc['offerPrice'],
      storeID: doc['storeId'],
      productStock: doc['productStock'],
      momOption: doc['momOption'],
      isInStock: doc['isInStock'],
      description: doc['description'],
      cat: doc['catID'] ?? "",
      subCat: doc['subcatID'] ?? "",
      images: [doc[_productImageRef]],
    );
  }
}
