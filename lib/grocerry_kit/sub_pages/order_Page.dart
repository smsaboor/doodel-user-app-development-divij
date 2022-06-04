import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

import '../../grocerry_kit/expandedPhoto.dart';
import '../../main.dart';
import '../../providers/cart.dart';
import '../../providers/order_model.dart';

class OrderPage extends StatefulWidget {
  OrderPage(this.orderSnapshot);

  final DocumentSnapshot orderSnapshot;

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  OrderItem _orderItem;
  Color _cartItemColor = Colors.white70;
  final TextStyle subHdngStyle = TextStyle(
    fontSize: 15,
    // fontWeight: FontWeight.w500,
  );
  final TextStyle subValueStyle = TextStyle(
    fontSize: 15,
    // fontWeight: FontWeight.w500,
  );

  @override
  void initState() {
    _orderItem = _covertToOrderItem(widget.orderSnapshot);
    super.initState();
  }

  OrderItem _covertToOrderItem(var snapshot) {
    var data = snapshot.data();
    List<dynamic> cartItemsList = data['products'];
    List<CartItem> clist = [];
    cartItemsList.forEach((item) {
      print('item $item');
      clist.add(
        CartItem(image: item['productImageRef'], price: double.parse(item['productPrice']), quantity: int.parse(item['productQuantity']), name: item['productName'], subTotal: double.parse(item['product'])),
      );
    });
    return OrderItem(
      cartItemList: clist,
      creditUsed: data['creditsUsed'].toString(),
      bagCharges: data['bagCharges'].toString(),
      total: double.parse(data['totalPrice'].toString()).toStringAsFixed(2),
      subTotal: data['subTotal'],
      name: data['name'],
      storeId: data['storeId'],
      storeName: data['storeName'],
      status: data['status'],
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      orderDeliveryDate: data['orderDeliveryDate'],
      address: data['Address'],
      dateTime: data['dateTime'],
      deliveryCharges: data['deliveryCharges'],
      deliveryTime: data['deliveryTime'],
      discPercentage: data['discPercentage'],
      extraStuffOrdered: data['extraStuffOrdered'],
      paymentMethod: data['paymentMethod'],
      couponName: data['couponName'],
      userUid: data['userUid'],
      couponType: data['couponType'],
      couponAmount: data['couponAmount'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff0644e3),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        title: Text("Order Details", style: TextStyle(color: Colors.white, fontSize: 22)),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 10),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: devWidth * 0.0389, top: 4),
                child: Text(
                  "Cart Products",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(shape: BoxShape.rectangle, border: Border.all(color: Colors.grey, width: 2), borderRadius: BorderRadius.circular(8), color: Colors.white70),
                height: MediaQuery.of(context).size.height * .55,
                padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _orderItem.cartItemList.length,
                  itemBuilder: (context, index) {
                    return _listItem(_orderItem.cartItemList[index]);
                  },
                ),
              ),

              ///Extra stuff column
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.grey), shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8), color: _cartItemColor),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Extra information.",
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Colors.black),
                    ),
                    if ((widget.orderSnapshot.data() as Map)['extraStuffUrl'] != "" && (widget.orderSnapshot.data() as Map)['extraStuffUrl'] != null)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ExpandedPhoto(
                                        imageURL: (widget.orderSnapshot.data() as Map)['extraStuffUrl'],
                                      )));
                        },
                        child: Container(
                          margin: EdgeInsets.all(10),
                          //padding: EdgeInsets.all(10),
                          width: devWidth * 0.316,
                          height: devHeight * 0.190,
                          alignment: Alignment.bottomCenter,
                          child: PhotoView(
                            maxScale: PhotoViewComputedScale.covered * 2,
                            tightMode: true,
                            //alignment: Alignment.topRight,
                            imageProvider: NetworkImage(
                              (widget.orderSnapshot.data() as Map)['extraStuffUrl'],
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(left: devWidth * 0.0389, right: devWidth * 0.0389, top: 8, bottom: 8),
                      child: Text(
                        _orderItem.extraStuffOrdered,
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
              ),

              ///Column for total price , discount etc
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: devWidth * 0.0389, top: 4),
                child: Text(
                  "Coupon Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.grey), shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8), color: _cartItemColor),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Coupon code: ",
                          style: subHdngStyle,
                        ),
                        Text(
                          _orderItem.couponName,
                          style: subValueStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Coupon Discount:",
                          style: subHdngStyle,
                        ),
                        Text(_orderItem.couponType == null ? '' : _orderItem.couponAmount + (_orderItem.couponType == 1 ? '%' : ' SEK'), style: subValueStyle),
                      ],
                    ),
                  ],
                ),
              ),

              ///Column for total price , discount etc
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: devWidth * 0.0389, top: 4),
                child: Text(
                  "Payment Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.grey), shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8), color: _cartItemColor),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Sub-Total:",
                          style: subHdngStyle,
                        ),
                        Text(
                          double.parse(_orderItem.subTotal).toStringAsFixed(2) + " SEK",
                          style: subValueStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Delivery Charges:",
                          style: subHdngStyle,
                        ),
                        Text(
                          double.parse(_orderItem.deliveryCharges).toStringAsFixed(2) + " SEK",
                          style: subValueStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Grocery Bag charges:",
                          style: subHdngStyle,
                        ),
                        Text(double.parse(_orderItem.bagCharges).toStringAsFixed(2) + " SEK", style: subValueStyle),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Discount: ",
                          style: subHdngStyle,
                        ),
                        Text(double.parse(_orderItem.discPercentage).toStringAsFixed(2) + ' SEK', style: subValueStyle),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Used Credits",
                          style: subHdngStyle,
                        ),
                        Text(
                          double.parse(_orderItem.creditUsed).toStringAsFixed(2) + " SEK",
                          style: subValueStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Total:",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          double.parse(_orderItem.total).toStringAsFixed(2) + " SEK",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "(including 5% Service Fee)",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              ///Column for Delivery Timings and Payment Methods
              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 2), shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8), color: _cartItemColor),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Order scheduled for :",
                          style: subHdngStyle,
                        ),
                        Text(
                          "${DateFormat.yMMMd().format(_orderItem.orderDeliveryDate.toDate())}\n ${_orderItem.deliveryTime.contains('hours') ? 'within ${_orderItem.deliveryTime}' : 'at ${_orderItem.deliveryTime.split('-')[0] + '.00'}-${_orderItem.deliveryTime.split('-')[1] + '.00'}'}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Color(0xff0644e3),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Order placed on :",
                          style: subHdngStyle,
                        ),
                        Text(
                          "${DateFormat.yMMMd().format(DateTime.parse('${_orderItem.dateTime.split('T')[0]} ${_orderItem.dateTime.split('T')[1]}'))}\n Time: ${_orderItem.dateTime.split('T').last.split('.').first.substring(0, 5)}",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Color(0xff0644e3),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              ///Column for Delivery Timings and Payment Methods
              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 2), shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8), color: _cartItemColor),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Delivery Time:",
                          style: subHdngStyle,
                        ),
                        Text(
                          "${_orderItem.deliveryTime.contains('hours') ? 'within ${_orderItem.deliveryTime}' : 'at ${_orderItem.deliveryTime.split('-')[0] + '.00'}-${_orderItem.deliveryTime.split('-')[1] + '.00'}'}",
                          style: TextStyle(
                            color: Color(0xff0644e3),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Payment Method:",
                          style: subHdngStyle,
                        ),
                        Text(
                          _orderItem.paymentMethod,
                          style: TextStyle(
                            color: Color(0xff0644e3),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              ///Column for user details
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: devWidth * 0.0389, top: 4),
                child: Text(
                  "Customer Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 2), shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8), color: _cartItemColor),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Name:",
                          style: subHdngStyle,
                        ),
                        Text(
                          _orderItem.name,
                          style: subValueStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Number:",
                          style: subHdngStyle,
                        ),
                        Text(
                          _orderItem.phoneNumber,
                          style: subValueStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "E-Mail:",
                          style: subHdngStyle,
                        ),
                        Text(
                          _orderItem.email,
                          style: subValueStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Address:",
                          style: subHdngStyle,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            _orderItem.address,
                            maxLines: 7,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: subValueStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///An item in Cart
  Widget _listItem(CartItem cartItem) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8), color: Colors.white70),
      height: 140,
      child: Row(children: <Widget>[
        Container(
          margin: EdgeInsets.all(10),
          height: devHeight * 0.33177,
          width: devWidth * 0.2189,
          child: FadeInImage.assetNetwork(
            fadeInDuration: const Duration(milliseconds: 100),
            fadeOutDuration: const Duration(milliseconds: 100),
            fit: BoxFit.fill,
            image: cartItem.image,
            placeholder: 'assets/images/image_loading.gif',
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                  width: devWidth * 0.55,
                  child: Text(
                    "${cartItem.name}",
                    maxLines: 3,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Text(
                "Unit Price: " + cartItem.price.toStringAsFixed(2) + "SEK",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Quantity: " + cartItem.quantity.toString(),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Subtotal: " + cartItem.subTotal.toStringAsFixed(2) + " SEK",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }
}
