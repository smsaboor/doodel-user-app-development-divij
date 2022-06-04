import 'package:flutter/material.dart';

class CartItem {
  String image;
  String name;
  double price;
  int quantity;
  double subTotal;

  CartItem({this.image, this.name, this.price, this.quantity, this.subTotal});
}

class Cart with ChangeNotifier {
  List<CartItem> cartItemList = [];
  double _deliveryCharges = 0.0;

  double get deliveryCharges {
    return _deliveryCharges;
  }

  set setDeliveryCharges(double value) {
    _deliveryCharges = value;
    notifyListeners();
  }

  void addCartItemToList(CartItem item) {
    cartItemList.add(item);
    notifyListeners();
  }

  List<CartItem> getCartItemList() {
    return cartItemList;
  }

  void clearCartItemList() {
    cartItemList = [];
    notifyListeners();
  }
}
