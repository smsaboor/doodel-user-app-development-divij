import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchResults with ChangeNotifier {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> searchResults = [];

  bool hasData = false;

  String currentStoreId;

  void startListeningToProductsStream(String storeId) {
    if (storeId == currentStoreId) {
      return;
    }
    currentStoreId = storeId;
    print('Listen Called !!!!!');
    stopListening();
    // Time the execution time of the query
    final startTime = DateTime.now();
    subscription = FirebaseFirestore.instance.collectionGroup('products').where('storeId', isEqualTo: storeId).snapshots().listen(
      (event) {
        searchResults = event.docs;
        hasData = true;
        final endTime = DateTime.now();
        print('Query len:: ${event.docs.length} took ${endTime.difference(startTime).inMilliseconds} ms, ${endTime.difference(startTime).inSeconds} seconds');
        notifyListeners();
      },
    );
  }

  void stopListening() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
      hasData = false;
    }
  }
}
