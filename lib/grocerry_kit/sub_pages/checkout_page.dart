import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:provider/provider.dart';

import '../../const.dart';
import '../../grocerry_kit/home_page.dart';
import '../../main.dart';
import '../../providers/collection_names.dart';
import '../../providers/store.dart';
import '../../providers/user.dart';
import '../../services/database_service.dart';
import '../../services/preferences.dart';
import '../../ui/custom_widgets/button_widget.dart';
import '../../ui/custom_widgets/checkout_card.dart';
import '../../ui/custom_widgets/heading_widget.dart';
import '../../widgets/mail_template.dart';

enum selectedPaymentMethod { masterCard, none }

class CheckoutPage extends StatefulWidget {
  final DateTime orderDeliveryDate;
  final double discountPercentage;
  final double deliveryCharges;
  final double subtotal;
  final double total;
  final String extraStuffOrdered;
  final File extraStuffFile;
  final String storeID;
  final String deliveryTime;
  final bool orderSuccessful;
  final double creditUsedAmount;
  final bool usedCredits;
  final double bagCharges;
  final double couponDiscount;
  final String couponID;
  final String couponAmount;
  final int couponType;
  final String couponName;

  CheckoutPage(
      {@required this.discountPercentage,
      @required this.deliveryCharges,
      @required this.subtotal,
      @required this.total,
      @required this.extraStuffOrdered,
      @required this.extraStuffFile,
      @required this.storeID,
      @required this.deliveryTime,
      @required this.bagCharges,
      @required this.couponDiscount,
      @required this.couponAmount,
      @required this.couponType,
      @required this.couponID,
      @required this.orderDeliveryDate,
      @required this.usedCredits,
      @required this.creditUsedAmount,
      this.orderSuccessful,
      this.couponName});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  selectedPaymentMethod paymentMethod = selectedPaymentMethod.none;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _selectPaymentMethod = false;
  String _paymentMethod = '';
  // bool _isLoading = false;
  Color _cartItemColor = Colors.white70;
  String _deliveryTime = "";

  bool _orderSuccessful;
  bool isLoadingStore = true;
  bool showdialog = false;
  bool payPressed = false;
  StoreModel store;
  DateTime date = DateTime.now();

  TextEditingController _numberController;
  TextEditingController _nameController;
  TextEditingController _emailController;
  TextEditingController _codeController;

  String name;
  String number;
  String code;
  String email;
  String address;

  // PaymentMethod cardRequest;
  Map<String, dynamic> paymentIntentData;

  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  @override
  void dispose() {
    _emailController.dispose();
    _numberController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getNumber();
    _deliveryTime = widget.deliveryTime;
    if (widget.orderSuccessful == true) {
      _orderSuccessful = true;
    } else {
      _orderSuccessful = false;
    }
    Future.delayed(Duration(seconds: 0), () async {
      final result = await FirebaseFirestore.instance.collection('groceryShops').doc(widget.storeID).get();
      store = Provider.of<Store>(context, listen: false).convertToStoreModel(result);
      setState(() {
        isLoadingStore = false;
      });
      UserModel userProfile = Provider.of<AppUser>(context, listen: false).userProfile;
      address = userProfile.address.address;
      _nameController = TextEditingController(text: userProfile.name);
      name = userProfile.name;

      _numberController = TextEditingController(text: userProfile.phoneNumber);
      number = userProfile.phoneNumber;

      _emailController = TextEditingController(text: userProfile.email);
      email = userProfile.email;

      _codeController = TextEditingController(text: userProfile.phoneCode.replaceAll('+', ""));
      code = userProfile.phoneCode.replaceAll('+', "");
    });

    // StripePayment.setOptions(StripeOptions(publishableKey: stripePublicKey, androidPayMode: 'test'));
    super.initState();
  }

  Future<dynamic> sendInvoiceEmail({dynamic email, dynamic html}) async {
    try {
      final String apiurl = "https://doodelemail.herokuapp.com";
      var res = await http.post(Uri.parse("$apiurl/send"), headers: <String, String>{
        'Context-Type': 'application/json;charSet=UTF-8'
      }, body: <String, String>{
        'email': email,
        'html': html,
      });
      if (res.statusCode == 200) {
        final data = await json.decode(res.body);
        return data;
      } else {
        print("error");
      }
    } catch (e) {
      print(e);
    }
  }

  var getNumbers;
  getNumber() async {
    setState(() {
      getNumbers = Preferences.instance.getInt('quoteNumber');
      if (getNumbers == null) {
        getNumbers = 0;
      }
    });
    getQuoteNumber(getNumbers);
  }

  getQuoteNumber(getNumber) {
    if (getNumber == 9) {
      getNumber = 0;
    } else {
      getNumber = getNumber + 1;
    }
    Preferences.instance.setInt('quoteNumber', getNumber);
  }

  UserModel userProfile;

  @override
  Widget build(BuildContext context) {
    userProfile = Provider.of<AppUser>(context, listen: false).userProfile;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage(storeDocId: storeID, storeName: nameStore)), (Route<dynamic> route) => false);
        return Future.value(false);
      },
      child: Scaffold(
          key: _scaffoldKey,
          appBar: widget.orderSuccessful == true
              ? null
              : AppBar(
                  centerTitle: true,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  elevation: 0,
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
                  title: Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 22)),
                ),
          bottomNavigationBar: widget.orderSuccessful ?? false
              ? null
              : Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  height: 80,
                  child: Row(
                    children: [
                      ///Cancel Order Buttons
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: devHeight * 0.02342, bottom: devHeight * 0.02342),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              border: Border.all(
                                color: Color(0xff0644e3),
                              )),
                          child: TextButton(
                            child: Text('Cancel Order',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff0644e3),
                                )),
                            onPressed: () async {
                              // setState(() {
                              //   _isLoading = true;
                              // });
                              await FirebaseFirestore.instance.collection(users_collection).doc(userProfile.userId).collection('cart').get().then((QuerySnapshot snapshot) {
                                for (DocumentSnapshot doc in snapshot.docs) {
                                  doc.reference.delete();
                                }
                              }).then((value) {
                                // setState(() {
                                //   _isLoading = false;
                                // });
                                Navigator.pop(context);
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: devHeight * 0.02342, bottom: devHeight * 0.02342),
                          decoration: BoxDecoration(
                            color: Color(0xff0644e3),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Builder(
                            builder: (context) => TextButton(
                              child: payPressed ? CircularProgressIndicator() : Text('PAY NOW', style: TextStyle(fontSize: 14, color: Colors.white)),
                              onPressed: payPressed
                                  ? null
                                  : () async {
                                      setState(() => payPressed = true);
                                      print('payPressed $payPressed');
                                      try {
                                        if (DatabaseService.storeTimeData.openingHour > DateTime.now().hour || DatabaseService.storeTimeData.closingHour < DateTime.now().hour) {
                                          if (_deliveryTime == "") {
                                            ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                                            ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(
                                              duration: kSnackBarDuration,
                                              content: Text("Please select a delivery time."),
                                              backgroundColor: Color(0xff0644e3),
                                            ));
                                          } else if (_paymentMethod == "") {
                                            ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                                            ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(
                                              duration: kSnackBarDuration,
                                              content: Text("Please select a payment method."),
                                              backgroundColor: Color(0xff0644e3),
                                            ));
                                          }
                                          if (_deliveryTime != "" && _paymentMethod != "") {
                                            bool desc = await showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                      title: const Text('Scheduled Order'),
                                                      content: Text(
                                                          'Delivery is scheduled on ${DateFormat.yMMMd().format(widget.orderDeliveryDate)} at ${widget.deliveryTime.split('-')[0].length == 1 ? '0${widget.deliveryTime.split('-')[0]}' : widget.deliveryTime.split('-')[0] + '.00'} - ${widget.deliveryTime.split('-')[1].length == 1 ? '0${widget.deliveryTime.split('-')[1]}' : widget.deliveryTime.split('-')[1] + '.00'}'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop(false);
                                                          },
                                                          child: const Text('No', style: TextStyle(color: Color(0xFF6200EE))),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            Navigator.of(context).pop(true);
                                                          },
                                                          child: const Text('Yes', style: TextStyle(color: Color(0xFF6200EE))),
                                                        ),
                                                      ],
                                                    ));
                                            if (desc == true) {
                                              await _placeOrder();
                                            }
                                          }
                                        } else {
                                          // setState(() => _isLoading = true);
                                          if (_deliveryTime == "") {
                                            ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(
                                              duration: kSnackBarDuration,
                                              content: Text("Please select a delivery time."),
                                              backgroundColor: Color(0xff0644e3),
                                            ));
                                          } else if (_paymentMethod == "") {
                                            ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(
                                              duration: kSnackBarDuration,
                                              content: Text("Please select a payment method."),
                                              backgroundColor: Color(0xff0644e3),
                                            ));
                                          }
                                          await _placeOrder();
                                        }
                                      } catch (e) {}
                                      setState(() => payPressed = false);
                                      print('payPressed $payPressed');
                                    },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          body: SafeArea(
            child: isLoadingStore
                ? Center(child: CircularProgressIndicator())
                : _orderSuccessful == true
                    ? SingleChildScrollView(
                        child: GestureDetector(
                          onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage(
                                        storeDocId: storeID,
                                        storeName: nameStore,
                                      )),
                              (Route<dynamic> route) => false),
                          child: Center(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(
                              Icons.thumb_up,
                              color: Colors.green,
                              size: 220,
                            ),
                            SizedBox(height: devHeight * 0.0292),
                            RichText(
                              text: TextSpan(children: [TextSpan(text: 'Your order has been placed! ', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)), TextSpan(text: '🙂', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))]),
                            ),
                            Text('(Tap anywhere to continue)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            SizedBox(height: 30),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipPath(
                                  clipper: CustomClip(),
                                  child: Container(height: 450, width: 500, decoration: BoxDecoration(color: Colors.amberAccent.withOpacity(0.2))),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 40),
                                    Text(
                                      "Did you know?",
                                      style: TextStyle(fontSize: 23.0),
                                    ),
                                    Image.asset(
                                      '${Provider.of<AppUser>(context, listen: false).getQuote(changeQuoteNumber: getNumbers)[0]}',
                                      height: 200,
                                      width: 200,
                                    ),
                                    SizedBox(height: 40),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        '${Provider.of<AppUser>(context, listen: false).getQuote(changeQuoteNumber: getNumbers)[1]}',
                                        style: TextStyle(color: Colors.green.shade900, fontSize: 19.5),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ])),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ///Column for Payment Methods,
                            Column(
                              children: [
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: HeadingWidget(
                                        heading: "Payment Method",
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Text(paymentMethod == selectedPaymentMethod.masterCard ? "Credit / Debit card" : ""),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Divider(
                                  endIndent: 30,
                                  indent: 30,
                                  thickness: 1,
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.35,
                                        child: CustomButton(
                                          textColor: _selectPaymentMethod ? Colors.white : Color(0xff0644e3),
                                          bgColor: _selectPaymentMethod ? Color(0xff0644e3) : Colors.white,
                                          borderColor: _selectPaymentMethod ? Colors.white : Color(0xff0644e3),
                                          onPress: () {
                                            setState(() {
                                              if (_selectPaymentMethod) {
                                                paymentMethod = selectedPaymentMethod.none;
                                                _paymentMethod = '';
                                                _selectPaymentMethod = false;
                                              } else {
                                                paymentMethod = selectedPaymentMethod.masterCard;
                                                _paymentMethod = 'Credit / Debit card';
                                                _selectPaymentMethod = true;
                                              }
                                            });
                                          },
                                          text: "Credit / Debit card",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 2),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(0),
                                color: _cartItemColor,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: CheckoutCard(
                                      onChange: (v) {
                                        name = v;
                                      },
                                      hint: "Name",
                                      controller: _nameController,
                                      label: "",
                                      email: "",
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 90,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: CheckoutCard(
                                            onChange: (v) {
                                              if (v.length == 1 && v == '+') {
                                              } else {
                                                code = v;
                                              }
                                            },
                                            hint: "code",
                                            controller: _codeController,
                                            label: "",
                                            email: "",
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 10),
                                          child: CheckoutCard(
                                            onChange: (v) {
                                              number = v;
                                            },
                                            hint: "Number",
                                            controller: _numberController,
                                            label: "",
                                            email: "",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: RichText(
                                      text: TextSpan(text: 'Email:', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500, decoration: TextDecoration.underline, height: 1.5), children: [
                                        TextSpan(text: '   ', style: TextStyle(fontSize: 16, color: Color(0xff0644e3), decoration: TextDecoration.none, height: 1.5)),
                                        TextSpan(text: '${userProfile.email}', style: TextStyle(fontSize: 16, color: Color(0xff0644e3), decoration: TextDecoration.none, height: 1.5)),
                                      ]),
                                      maxLines: 2,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: RichText(
                                      text: TextSpan(text: 'Delivery Address:', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500, decoration: TextDecoration.underline, height: 1.5), children: [
                                        TextSpan(text: '   ', style: TextStyle(fontSize: 16, color: Color(0xff0644e3), decoration: TextDecoration.none, height: 1.5)),
                                        TextSpan(text: '${userProfile.address.address}', style: TextStyle(fontSize: 16, color: Color(0xff0644e3), decoration: TextDecoration.none, height: 1.5)),
                                      ]),
                                      maxLines: 2,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'To Pay : ',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '${widget.total.toStringAsFixed(2)} SEK',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
          )),
    );
  }

  Future<List> calculateMomOfTheCart(QuerySnapshot cartItems) async {
    double firstMom = 0;
    double secondMom = 0;

    for (DocumentSnapshot snapshot in cartItems.docs) {
      final double totalPrice = (snapshot.data() as Map)['quantity'] * (snapshot.data() as Map)['price'];
      if ((snapshot.data() as Map)['momOption'] == 1) {
        // firstMom = (totalPrice) * 0.10714286;
        firstMom = (totalPrice + widget.deliveryCharges + widget.bagCharges) * 0.10714286;
      } else {
        secondMom += totalPrice * 0.20;
      }
    }

    return [firstMom, secondMom];
  }

  Future<bool> _addOrder(UserModel userProfile, DateTime date) async {
    setState(() {
      showdialog = true;
    });

    try {
      QuerySnapshot cartItems;
      await FirebaseFirestore.instance.collection(users_collection).doc(userProfile.userId).collection('cart').get().then((QuerySnapshot value) {
        cartItems = value;
      });
      DateTime timestamp = DateTime.now();
      if (widget.extraStuffFile != null) {
        final ref = FirebaseStorage.instance.ref().child('images').child(DateTime.now().toString() + ".jpg");
        await ref.putFile(widget.extraStuffFile);
      }
      Random _rnd = Random();
      String orderID = String.fromCharCodes(Iterable.generate(6, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
      final moms = await calculateMomOfTheCart(cartItems);
      // String url = 'https://us-central1-doodel-a748b.cloudfunctions.net/charge?amount=${widget.total.toInt()}&receipt_email=${_emailController.text}&token=$stripeToken';
      // final response = await http.post(Uri.parse(url));
      String extraURL = '';
      if (widget.extraStuffFile != null) {
        extraURL = await DatabaseService().uploadImage(widget.extraStuffFile);
      }
      // if (response.statusCode != 200) return false;
      DocumentSnapshot<Map<String, dynamic>> feeDoc = await FirebaseFirestore.instance.collection('groceryShops').doc(widget.storeID).get();
      double doodelFee = feeDoc.data()['doodelFee'] ?? 0;
      await FirebaseFirestore.instance.collection(orders_Collection).add({
        'orderID': orderID,
        'totalPrice': widget.total,
        'orderDeliveryDate': date,
        'storeId': Provider.of<AppUser>(context, listen: false).userStoreDocId,
        'storeName': Provider.of<AppUser>(context, listen: false).userStoreName,
        'status': 'Pending',
        'couponID': widget.couponID != null ? widget.couponID : '',
        'couponType': widget.couponType,
        'couponAmount': widget.couponID != null ? widget.couponAmount : '',
        'couponName': widget.couponID != null ? widget.couponName : '',
        'couponDiscount': widget.couponID != null ? widget.couponDiscount : '',
        'moms12': moms[0],
        'moms24': moms[1],
        'name': _nameController.text,
        'phoneNumber': '+${_codeController.text}${_numberController.text}',
        "Address": userProfile.address.address,
        'creditsUsed': widget.creditUsedAmount,
        'bagCharges': widget.bagCharges,
        "email": _emailController.text,
        "userUid": userProfile.userId,
        'deliveryCharges': widget.deliveryCharges.toStringAsFixed(2),
        'subTotal': widget.subtotal.toString(),
        'discPercentage': widget.discountPercentage.toStringAsFixed(2),
        'deliveryTime': _deliveryTime,
        'dateTime': timestamp.toIso8601String(),
        'serialNumber': _rnd.nextInt(74365783).toString(),
        'completed': false,
        'doodelFee': doodelFee,
        'paymentMethod': _paymentMethod,
        'extraStuffOrdered': widget.extraStuffOrdered,
        'extraStuffUrl': extraURL,
        'products': cartItems.docs
            .map(
              (DocumentSnapshot cp) => {
                'productId': (cp.data() as Map)['productID'],
                'productName': (cp.data() as Map)['name'],
                'productImageRef': (cp.data() as Map)['image'],
                'productQuantity': (cp.data() as Map)['quantity'].toString(),
                'productPrice': (cp.data() as Map)['price'].toString(),
                "product": (cp.data() as Map)['subtotal'].toString(),
                "description": (cp.data() as Map)['description'],
                "catId": (cp.data() as Map)['catID'],
                "subcatId": (cp.data() as Map)['subcatID'],
                "storeId": (cp.data() as Map)['storeId'],
              },
            )
            .toList(),
      });
      String productRows = '';
      try {
        for (DocumentSnapshot cpI in cartItems.docs) {
          String toReplace = '$productRow'.toString().replaceAll('{{productName}}', (cpI.data() as Map)['name']).replaceAll('{{productQuantity}}', (cpI.data() as Map)['quantity'].toString()).replaceAll(
                '{{productTotal}}',
                '${(cpI.data() as Map)['subtotal'].toStringAsFixed(2)}',
              );
          productRows += '\n$toReplace';
        }
      } catch (error) {
        print(' Replacing ProductRow Error: $error ');
      }

      await FirebaseFirestore.instance.collection(users_collection).doc(userProfile.userId).collection('cart').get().then((QuerySnapshot snapshot) async {
        for (DocumentSnapshot doc in snapshot.docs) {
          if (!(doc.data() as Map)['isInStock']) {
            DocumentReference prodRef = FirebaseFirestore.instance.collection('groceryShops').doc((doc.data() as Map)['storeId']).collection('categoryCollection').doc((doc.data() as Map)['catID']).collection('subCategory').doc((doc.data() as Map)['subcatID']).collection('products').doc((doc.data() as Map)['productID']);
            DocumentSnapshot product = await prodRef.get();
            await prodRef.update({'productStock': (product.data() as Map)['productStock'] - (doc.data() as Map)['quantity']});
          }
          doc.reference.delete();
        }
      });

      print('preparing email message');
      mailer.Message message = mailer.Message();
      message.from = mailer.Address('invoices@doodel.se', 'Order Placed! $orderID');
      message.recipients.add(mailer.Address(_emailController.text.trim()));
      message.subject = 'Order Placed! $orderID';
      message.html = '$html_template'
          .replaceAll('{{products}}', productRows)
          .replaceAll('{{sName}}', Provider.of<AppUser>(context, listen: false).userStoreName)
          .replaceAll('{{cName}}', _nameController.text)
          .replaceAll('{{cAddress}}', userProfile.address.address)
          .replaceAll('{{orderNo}}', orderID)
          .replaceAll('{{mobileNo}}', '${_codeController.text} ${_numberController.text}')
          .replaceAll('{{deliveryCharges}}', '${widget.deliveryCharges.toStringAsFixed(2)}')
          .replaceAll('{{BagCharges}}', '${widget.bagCharges.toStringAsFixed(2)}')
          .replaceAll('{{subSTotal}}', '${widget.subtotal.toStringAsFixed(2)}')
          .replaceAll('{{moms12}}', moms[0].toStringAsFixed(2))
          .replaceAll('{{moms25}}', moms[1].toStringAsFixed(2))
          .replaceAll('{{totalmoms}}', (moms[0] + moms[1]).toStringAsFixed(2))
          .replaceAll('{{priceTotal}}', '${widget.total.toStringAsFixed(2)}')
          .replaceAll('{{orderTime}}', '${timestamp.toLocal().hour.toString().length == 1 ? '0${timestamp.toLocal().hour}' : timestamp.toLocal().hour}:${timestamp.toLocal().minute.toString().length == 1 ? '0${timestamp.toLocal().minute}' : timestamp.toLocal().minute}')
          .replaceAll('{{orderDate}}', '${DateFormat.yMMMd().format(timestamp)}')
          .replaceAll('{{discount}}', widget.discountPercentage.toStringAsFixed(2))
          .replaceAll('{{coupon}}', widget.couponID == null ? '' : getTableRowHTML('Coupon Code', widget.couponName + ' (${widget.couponAmount}${widget.couponType == 1 ? '%' : ' SEK'})'))
          .replaceAll('{{CreditsUsed}}', widget.creditUsedAmount.toStringAsFixed(2))
          .replaceAll('{{ScheduledFor}}', date.hour >= store.startingTime && date.hour < store.endingTime ? '' : getTableRowHTML('Scheduled for', '${DateFormat.yMMMd().format(widget.orderDeliveryDate)} at ${widget.deliveryTime.split('-')[0] + '.00'}-${widget.deliveryTime.split('-')[1] + '.00'}.'));
      try {
        sendInvoiceEmail(email: _emailController.text.trim(), html: message.html).then((value) {
          sendInvoiceEmail(email: 'doodelservicesinvoice@gmail.com', html: message.html);
        });
      } catch (e) {
        print(e.runtimeType);
        print('${e.toString()}');
      }
      setState(() {
        showdialog = false;
      });

      return true;
    } on SocketException catch (e) {
      print(e.message);
      setState(() {
        showdialog = false;
        _orderSuccessful = false;
      });
      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
      return false;
    } catch (err) {
      setState(() {
        showdialog = false;
        _orderSuccessful = false;
      });
      print(err);
      var message = "An error occurred, please try again";
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text(message), backgroundColor: Colors.red));
      return false;
    }
  }

  Future<bool> makePayment() async {
    try {
      paymentIntentData = await createPaymentIntent('${widget.total}', 'SEK');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        billingDetails: BillingDetails(email: userProfile.email, phone: userProfile.phoneCode + userProfile.phoneNumber, name: userProfile.name, address: Address(city: 'Uppsala', country: 'Sweden', line1: '', line2: '', postalCode: '', state: '')),
        paymentIntentClientSecret: paymentIntentData['client_secret'],
        googlePay: false,
        applePay: false,
        testEnv: false,
        // testEnv: true,
        primaryButtonColor: Color(0xff0644e3),
        merchantDisplayName: 'Doodel Services',
        merchantCountryCode: 'SE',
      ));

      bool data = await displayPaymentSheet();
      return data != true ? null : data;
    } catch (e, s) {
      print('exception:$e$s');
      return false;
    }
  }

  Future<bool> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((newValue) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Payment is successful")));
      });
      paymentIntentData = null;
      return true;
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      return false;
    } catch (e) {
      print('$e');
      return false;
    }
  }

  Future createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {'amount': calculateAmount(amount), 'currency': currency, 'payment_method_types[]': 'card'};
      var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'), body: body, headers: {'Authorization': 'Bearer $stripeLiveSecret', 'Content-Type': 'application/x-www-form-urlencoded'});
      // var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'), body: body, headers: {'Authorization': 'Bearer $stripeTestSecret', 'Content-Type': 'application/x-www-form-urlencoded'});
      print('Create Intent reponse ===> ${response.body.toString()}');
      if (response.statusCode != 200) {
        throw 'response status not equal to success';
      }
      Map data = jsonDecode(response.body);
      if (!data.containsKey('error')) {
        return data;
      } else {
        throw StripeError.fromJson(data);
      }
    } catch (err) {
      print('err charging user: ${err.toString()}');
      throw err;
    }
  }

  calculateAmount(String amount) {
    final a = (double.parse(amount)) * 100;
    return a.toInt().toString();
  }

  Future _placeOrder() async {
    try {
      if (_deliveryTime != "" && _paymentMethod != "") {
        bool isSuccess = await makePayment();
        if (isSuccess == false) {
          return showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Warning'),
                    content: Text('Payment unsuccessful. Please try again'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      )
                    ],
                  ));
        } else if (isSuccess == true) {
          setState(() => showdialog = true);
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context1) => AlertDialog(
                    title: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 10),
                        Text('Please wait'),
                      ],
                    ),
                  ));
          await _addOrder(userProfile, widget.orderDeliveryDate).then((value) async {
            if (!value) {
              Navigator.pop(context);
              setState(() {
                showdialog = false;
              });
              return showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Warning'),
                        content: Text('Order not placed successfully.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          )
                        ],
                      ));
            }
            if (widget.usedCredits) {
              FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).get().then((value) {
                double.parse(value.data()['credits'].toString());
                var newBalance = double.parse(value.data()['credits'].toString()) - widget.creditUsedAmount;
                FirebaseFirestore.instance.collection('users').doc(value.id).update({'credits': newBalance}).then((value) => null);
              });
            }
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
              return CheckoutPage(
                deliveryTime: widget.deliveryTime,
                couponID: widget.couponID,
                couponDiscount: widget.couponDiscount,
                couponType: widget.couponType,
                couponAmount: widget.couponAmount,
                bagCharges: widget.bagCharges,
                usedCredits: widget.usedCredits,
                creditUsedAmount: widget.creditUsedAmount,
                deliveryCharges: widget.deliveryCharges,
                discountPercentage: widget.discountPercentage,
                extraStuffOrdered: widget.extraStuffOrdered,
                extraStuffFile: widget.extraStuffFile,
                subtotal: widget.subtotal,
                total: widget.total,
                storeID: widget.storeID,
                orderDeliveryDate: widget.orderDeliveryDate,
                orderSuccessful: true,
              );
            }), (Route<dynamic> route) => false);
          }).catchError((err) {
            print(e.toString());
            setState(() {
              showdialog = false;
              _orderSuccessful = false;
            });
            ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(
              duration: kSnackBarDuration,
              content: Text("An error has occurred, Please try again"),
              backgroundColor: Colors.red,
            ));
          });
        }
      }
    } catch (e) {}
  }
}

class CustomClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height * 0.10);
    path.quadraticBezierTo(size.width * 0.25, 0.0, size.width * 0.5, size.height * 0.05);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.10, size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
