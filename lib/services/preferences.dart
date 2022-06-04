import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../grocerry_kit/model/address_model.dart';
import '../grocerry_kit/model/cart_model.dart';
import '../providers/user.dart';

class Preferences {
  static SharedPreferences instance;
  static const String _session = 'user_session';
  static const String _cartItems = 'cart_items';
  static const String _selectedAddress = 'selected_address';
  static const String _userStoreData = 'userStoreData';

  static Future<void> init() async {
    instance = await SharedPreferences.getInstance();
  }

  static Future<void> saveUserSession(UserModel user) async {
    await instance.setString(_session, jsonEncode(user.toMap()));
  }

  static UserModel loadUserSession() {
    String encodedString = instance.getString(_session);
    return encodedString != null ? UserModel.fromMap(jsonDecode(encodedString)) : null;
  }

  static Future<void> wipeAllData() async {
    await instance.clear();
  }

  static Future<void> deleteUserSession() async {
    await instance.remove(_session);
  }

  static Future<void> deleteCartItems() async {
    await instance.remove(_cartItems);
  }

  static Future<void> deleteUserStoreData() async {
    await instance.remove(_userStoreData);
  }

  static Future<void> deleteSelectedAddress() async {
    await instance.remove(_selectedAddress);
  }

  static Future<void> saveCartItems(CartModel cart) async {
    await instance.setString(_cartItems, jsonEncode(cart.toMap()));
  }

  static CartModel getCartItems() {
    String encodedString = instance.getString(_cartItems);
    return encodedString != null ? CartModel.fromMap(jsonDecode(encodedString) as Map) : CartModel();
  }

  static Future<void> saveGuestAddress(Address address) async {
    await instance.setString(_selectedAddress, jsonEncode(address.toMap()));
  }

  static Address getGuestAddress() {
    String encodedString = instance.getString(_selectedAddress);
    return encodedString != null ? Address.fromMap(jsonDecode(encodedString) as Map<String, dynamic>) : null;
  }
}
