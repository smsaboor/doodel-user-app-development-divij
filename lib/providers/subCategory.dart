import 'package:cloud_firestore/cloud_firestore.dart';

class SubCategory{
  final String id;
  final String storeID;
  final String catID;
  final String name;
  final String imageURL;

  SubCategory({this.id,this.storeID,this.catID,this.name,this.imageURL});

  factory SubCategory.fromDocument(DocumentSnapshot doc){
    return SubCategory(
      id: doc.id,
      catID: (doc.data()as Map)['catID'],
      name: (doc.data()as Map)['name'],
      storeID: (doc.data()as Map)['storeID'],
      imageURL: (doc.data()as Map)['imageURL']
    );
  }
}