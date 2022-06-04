// To parse this JSON data, do
//
//     final orderModel = orderModelFromJson(jsonString);

import 'dart:convert';

OrderModel orderModelFromJson(String str) => OrderModel.fromJson(json.decode(str));

String orderModelToJson(OrderModel data) => json.encode(data.toJson());

class OrderModel {
  OrderModel({
    this.name,
    this.address,
    this.bagCharges,
    this.completed,
    this.creditsUsed,
    this.dateTime,
    this.deliveryCharges,
    this.deliveryTime,
    this.disPercentage,
    this.email,
    this.extraStuffOrdered,
    this.extraStuffUrl,
    this.mom12,
    this.mom24,
    this.orderDeliveryDate,
    this.orderId,
    this.paymentMethod,
    this.phoneNumber,
    this.serialNumber,
    this.status,
    this.storeId,
    this.storeName,
    this.subTotal,
    this.totalPrice,
    this.userUid,
    this.products,
  });

  String name;
  String address;
  String bagCharges;
  String completed;
  String creditsUsed;
  DateTime dateTime;
  String deliveryCharges;
  String deliveryTime;
  String disPercentage;
  String email;
  String extraStuffOrdered;
  String extraStuffUrl;
  String mom12;
  String mom24;
  String orderDeliveryDate;
  String orderId;
  String paymentMethod;
  String phoneNumber;
  String serialNumber;
  String status;
  String storeId;
  String storeName;
  String subTotal;
  String totalPrice;
  String userUid;
  List<Product1> products;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        name: json["name"],
        address: json["Address"],
        bagCharges: json["bagCharges"],
        completed: json["completed"],
        creditsUsed: json["creditsUsed"],
        dateTime: DateTime.parse(json["dateTime"]),
        deliveryCharges: json["deliveryCharges"],
        deliveryTime: json["deliveryTime"],
        disPercentage: json["disPercentage"],
        email: json["email"],
        extraStuffOrdered: json["extraStuffOrdered"],
        extraStuffUrl: json["extraStuffUrl"],
        mom12: json["mom12"],
        mom24: json["mom24"],
        orderDeliveryDate: json["orderDeliveryDate"],
        orderId: json["orderID"],
        paymentMethod: json["paymentMethod"],
        phoneNumber: json["phoneNumber"],
        serialNumber: json["serialNumber"],
        status: json["status"],
        storeId: json["storeId"],
        storeName: json["storeName"],
        subTotal: json["subTotal"],
        totalPrice: json["totalPrice"],
        userUid: json["userUid"],
        products: List<Product1>.from(json["products"].map((x) => Product1.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "Address": address,
        "bagCharges": bagCharges,
        "completed": completed,
        "creditsUsed": creditsUsed,
        "dateTime": dateTime.toIso8601String(),
        "deliveryCharges": deliveryCharges,
        "deliveryTime": deliveryTime,
        "disPercentage": disPercentage,
        "email": email,
        "extraStuffOrdered": extraStuffOrdered,
        "extraStuffUrl": extraStuffUrl,
        "mom12": mom12,
        "mom24": mom24,
        "orderDeliveryDate": orderDeliveryDate,
        "orderID": orderId,
        "paymentMethod": paymentMethod,
        "phoneNumber": phoneNumber,
        "serialNumber": serialNumber,
        "status": status,
        "storeId": storeId,
        "storeName": storeName,
        "subTotal": subTotal,
        "totalPrice": totalPrice,
        "userUid": userUid,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
      };
}

class Product1 {
  Product1({
    this.productID,
    this.productName,
    this.productQuantity,
    this.productPrice,
    this.description,
    this.productImageRef,
    this.product,
  });

  String productID;
  String productName;
  String productQuantity;
  String productPrice;
  String description;
  String productImageRef;
  String product;

  factory Product1.fromJson(Map<String, dynamic> json) => Product1(
        productID: json["productID"] ?? '',
        productName: json["productName"],
        productQuantity: json["productQuantity"],
        productPrice: json["productPrice"],
        description: json["description"],
        productImageRef: json["productImageRef"],
        product: json["product"],
      );

  Map<String, dynamic> toJson() => {
        "productID": productID ?? '',
        "productName": productName,
        "productQuantity": productQuantity,
        "productPrice": productPrice,
        "description": description,
        "productImageRef": productImageRef,
        "product": product,
      };
}
