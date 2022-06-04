import 'package:flutter/material.dart';

import '../providers/cart.dart';

class OrderItem {
  String address;
  String dateTime;
  String deliveryCharges;
  String deliveryTime;
  String discPercentage;
  String email;
  String extraStuffOrdered;
  String name;
  dynamic orderDeliveryDate; //Timestamp
  String paymentMethod;
  String phoneNumber;
  List<CartItem> cartItemList;
  String status;
  String storeId;
  String storeName;
  String subTotal;
  String userUid;
  String total;
  String creditUsed = '0';
  String bagCharges = '0';
  String couponName = '';
  final String couponAmount;
  final int couponType;

  OrderItem({
    @required this.address,
    @required this.dateTime,
    @required this.deliveryTime,
    @required this.deliveryCharges,
    @required this.discPercentage,
    @required this.email,
    @required this.extraStuffOrdered,
    @required this.name,
    @required this.paymentMethod,
    @required this.phoneNumber,
    @required this.cartItemList,
    @required this.status,
    @required this.subTotal,
    @required this.userUid,
    @required this.creditUsed,
    @required this.bagCharges,
    @required this.storeName,
    @required this.orderDeliveryDate,
    @required this.total,
    @required this.couponName,
    @required this.couponAmount,
    @required this.couponType,
    @required this.storeId,
  });
}
