import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../grocerry_kit/model/cart_model.dart';
import '../../main.dart';
import '../../providers/user.dart';
import '../../services/database_service.dart';
import '../../services/preferences.dart';
import '../../style_functions.dart';
import '../../ui/custom_widgets/button_widget.dart';
import '../../ui/custom_widgets/heading_widget.dart';
import '../../ui/login_page.dart';
import '../detailedProductPage.dart';

enum SelectDeliveryTime {
  optionOne,
  optionTwo,
  optionThree,
  none,
}

class GuestCartPage extends StatefulWidget {
  final bool isPushed;
  final String storeID;
  final bool isPagePushed;
  final PageController controller;

  const GuestCartPage(this.isPushed, this.storeID, {this.isPagePushed, this.controller, Key key}) : super(key: key);

  @override
  _GuestCartPageState createState() => _GuestCartPageState();
}

class _GuestCartPageState extends State<GuestCartPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  StyleFunctions formFieldStyle = StyleFunctions();

  int _totalItemInOrder = 0;
  double _productsSubtotal = 0;
  double _total = 0;
  int _bagNeed = 1;

  bool _useCredits = false;
  double _useCreditsAmount = 0.0;
  double _deliveryCharges = 0;
  String deliveryTime;

  String couponCode = '';
  bool validCoupon;
  double _discount = 0;

  double serviceFee = 0.0;
  double minmimumLimit = 0.0;
  bool onschedule = false;

  double height;
  double width;
  final formKey = new GlobalKey<FormState>();
  List<DropdownMenuItem<String>> deliveryDates = [];

  SelectDeliveryTime selectedDeliveryTime = SelectDeliveryTime.none;
  DateTime scheduledDeliveryDate = DateTime.now();
  List<bool> optionsActive = [false, false];
  bool isStoreClosed = false;
  bool canStoreOpen = false;
  bool isNextDaySlots = false;

  @override
  void initState() {
    super.initState();
    DatabaseService.couponData = null;
    DatabaseService().getAllActiveDeliveryTiming(widget.storeID);
    DatabaseService().getCredit();
    DatabaseService().getMinimumOrderLimit(widget.storeID);
    DatabaseService().optionActive(widget.storeID).then((value) {
      setState(() {
        if (value.length != 2) {
          value.add(false);
          value.add(false);
        }
        optionsActive = value.sublist(0, 2);
      });
    });
    DatabaseService().getDeliveryTiming(widget.storeID).then((value) {
      setState(() {});
    });
    DatabaseService().getStoreOpeningClosingTime(widget.storeID).then((value) {
      DateTime now = DateTime.now();
      if (now.minute > 0) {
        now = DateTime(now.year, now.month, now.day, now.hour + 1);
      }
      if (DatabaseService.storeTimeData.closingHour <= now.hour + 4) {
        if (DatabaseService.storeTimeData.closingHour > DatabaseService.storeTimeData.openingHour) {
          scheduledDeliveryDate = DateTime(now.year, now.month, now.day + 1);
        }
        if (!checkStoreIsOpen(scheduledDeliveryDate.weekday)) {
          for (int i = scheduledDeliveryDate.weekday; i <= scheduledDeliveryDate.weekday + 7; i++) {
            if (checkStoreIsOpen(scheduledDeliveryDate.weekday)) {
              canStoreOpen = true;
              break;
            }
            scheduledDeliveryDate = DateTime(now.year, now.month, scheduledDeliveryDate.day + 1);
          }
        } else {
          canStoreOpen = true;
        }
        isNextDaySlots = true;
      } else {
        canStoreOpen = true;
        scheduledDeliveryDate = now;
        if (!checkStoreIsOpen(scheduledDeliveryDate.weekday)) {
          for (int i = scheduledDeliveryDate.weekday; i <= scheduledDeliveryDate.weekday + 7; i++) {
            if (checkStoreIsOpen(scheduledDeliveryDate.weekday)) {
              break;
            }
            scheduledDeliveryDate = DateTime(now.year, now.month, scheduledDeliveryDate.day + 1);
          }
        }
      }
      var v = DateTime.now();
      if (DatabaseService.storeTimeData.openingHour > v.hour || DatabaseService.storeTimeData.closingHour <= v.hour) {
        isStoreClosed = true;
      }
      setState(() {});
      dropDownMenuItems();
    });
  }

  bool checkStoreIsOpen(int wDay) {
    wDay = wDay % 8;
    if (wDay == 1) {
      return DatabaseService.storeTimeData.monTimings['startingTime'] != 'Close' && DatabaseService.storeTimeData.monTimings['endingTime'] != 'Close';
    } else if (wDay == 2) {
      return DatabaseService.storeTimeData.tueTimings['startingTime'] != 'Close' && DatabaseService.storeTimeData.tueTimings['endingTime'] != 'Close';
    } else if (wDay == 3) {
      return DatabaseService.storeTimeData.wedTimings['startingTime'] != 'Close' && DatabaseService.storeTimeData.wedTimings['endingTime'] != 'Close';
    } else if (wDay == 4) {
      return DatabaseService.storeTimeData.thuTimings['startingTime'] != 'Close' && DatabaseService.storeTimeData.thuTimings['endingTime'] != 'Close';
    } else if (wDay == 5) {
      return DatabaseService.storeTimeData.friTimings['startingTime'] != 'Close' && DatabaseService.storeTimeData.friTimings['endingTime'] != 'Close';
    } else if (wDay == 6) {
      return DatabaseService.storeTimeData.satTimings['startingTime'] != 'Close' && DatabaseService.storeTimeData.satTimings['endingTime'] != 'Close';
    } else if (wDay == 7) {
      return DatabaseService.storeTimeData.sunTimings['startingTime'] != 'Close' && DatabaseService.storeTimeData.sunTimings['endingTime'] != 'Close';
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    height=MediaQuery.of(context).size.height;
    width=MediaQuery.of(context).size.width;
    CartModel cart = Preferences.getCartItems();
    return WillPopScope(
      onWillPop: () {
        if (!Navigator.of(context).canPop() && widget.controller != null) {
          widget.controller.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.linear);
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              if (widget.controller != null) {
                widget.controller.jumpToPage(0);
                return;
              }
              Navigator.pop(context);
            },
          ),
          backgroundColor: Color(0xff0644e3),
          title: Text(
            "Cart",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            if (Provider.of<AppUser>(context, listen: false).userProfile == null)
              GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false);
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.account_circle_outlined,
                        color: Colors.white,
                        size: 32.0,
                      ),
                      Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                      )
                    ],
                  )),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: cart.items.isEmpty
              ? Center(child: Text('Cart Empty'))
              : Builder(builder: (context) {
                  _totalItemInOrder = 0;
                  _productsSubtotal = 0;
                  cart.items.forEach((element) {
                    _totalItemInOrder += element.quantity;
                    _productsSubtotal += element.price * element.quantity;
                  });
                  CrossFadeState bannerState = CrossFadeState.showSecond;
                  if (DatabaseService.minimumOrderLimit != null && DatabaseService.minimumOrderLimit > _productsSubtotal) {
                    bannerState = CrossFadeState.showFirst;
                  }
                  _bagNeed = int.parse(((_totalItemInOrder / 10).toString()).split('.').first) + 1;
                  _total = _productsSubtotal + _deliveryCharges + (DatabaseService.bagCharges * _bagNeed);
                  if (couponCode != '' && validCoupon != null) {
                    DatabaseService().applyCoupon(context, couponCode, _productsSubtotal).then((value) {
                      validCoupon = value;
                    });
                  }
                  if (validCoupon == true) {
                    if (DatabaseService.couponData.type == 1) {
                      _discount = _productsSubtotal * (DatabaseService.couponData.discPercentage / 100);
                    } else {
                      _discount = DatabaseService.couponData.discPercentage.toDouble();
                    }
                  } else {
                    _discount = 0.0;
                  }
                  _total = _total - _discount;
                  if (_useCredits) {
                    if (_total <= DatabaseService.credit) {
                      _total = _total + (_total * .05);
                      _useCreditsAmount = _total;
                    } else {
                      _useCreditsAmount = DatabaseService.credit;
                    }
                  } else {
                    _useCreditsAmount = 0;
                  }
                  _total = _total + (_total * .05);
                  _total = _total - _useCreditsAmount;

                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 35),
                              HeadingWidget(heading: "Cart Products", underline: true),
                              SizedBox(height: 10),
                              Container(
                                height: 280,
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.zero,
                                  child: Column(
                                    children: [
                                      ...cart.items.map(
                                        (e) {
                                          return CartItem(cartItem: e, stState: () => setState(() {}));
                                        },
                                      ).toList()
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    cart.items.clear();
                                    Preferences.deleteCartItems();
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Color(0xff0644e3)),
                                    ),
                                    child: Text(
                                      "Remove all items",
                                      style: TextStyle(color: Color(0xff0644e3), fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Divider(color: Colors.grey, thickness: 1),
                              SizedBox(height: 20),
                              HeadingWidget(heading: "Extra information for delivery (Optional)"),
                              SizedBox(height: 5),
                              TextField(
                                onChanged: (v) {},
                                decoration: InputDecoration(hintText: "Portkod, Comments to shopper or rider etc", border: OutlineInputBorder()),
                                keyboardType: TextInputType.multiline,
                                minLines: 1,
                                maxLines: 6,
                              ),
                              SizedBox(height: 20),
                              HeadingWidget(heading: "Delivery Time"),
                              Card(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomButton(
                                                textColor: isStoreClosed
                                                    ? Colors.grey
                                                    : (DateTime.now().hour < DatabaseService.storeTimeData.openingHour || !optionsActive[0] || DatabaseService.storeTimeData.closingHour < (DateTime.now().hour + 1))
                                                        ? Colors.grey
                                                        : !(selectedDeliveryTime == SelectDeliveryTime.optionOne)
                                                            ? Color(0xff0644e3)
                                                            : Colors.white,
                                                bgColor: selectedDeliveryTime == SelectDeliveryTime.optionOne ? Color(0xff0644e3) : Colors.white,
                                                borderColor: isStoreClosed
                                                    ? Colors.grey
                                                    : (DateTime.now().hour < DatabaseService.storeTimeData.openingHour || !optionsActive[0] || DatabaseService.storeTimeData.closingHour < (DateTime.now().hour + 1))
                                                        ? Colors.grey
                                                        : Color(0xff0644e3),
                                                onPress: isStoreClosed
                                                    ? null
                                                    : (DateTime.now().hour < DatabaseService.storeTimeData.openingHour || !optionsActive[0] || DatabaseService.storeTimeData.closingHour < (DateTime.now().hour + 1))
                                                        ? null
                                                        : () {
                                                            setState(() {
                                                              deliveryTime = null;

                                                              selectedDeliveryTime = SelectDeliveryTime.optionOne;
                                                              _deliveryCharges = Provider.of<AppUser>(context, listen: false).first != "" && Provider.of<AppUser>(context, listen: false).first != null ? double.parse(Provider.of<AppUser>(context, listen: false).first) : 0.0;
                                                            });
                                                          },
                                                text: "Within 1-2 Hours",
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            Expanded(
                                              child: CustomButton(
                                                textColor: isStoreClosed
                                                    ? Colors.grey
                                                    : (DateTime.now().hour < DatabaseService.storeTimeData.openingHour || !optionsActive[1] || DatabaseService.storeTimeData.closingHour < (DateTime.now().hour + 4))
                                                        ? Colors.grey
                                                        : !(selectedDeliveryTime == SelectDeliveryTime.optionTwo)
                                                            ? Color(0xff0644e3)
                                                            : Colors.white,
                                                bgColor: selectedDeliveryTime == SelectDeliveryTime.optionTwo ? Color(0xff0644e3) : Colors.white,
                                                borderColor: isStoreClosed
                                                    ? Colors.grey
                                                    : (DateTime.now().hour < DatabaseService.storeTimeData.openingHour || !optionsActive[1] || DatabaseService.storeTimeData.closingHour < (DateTime.now().hour + 4))
                                                        ? Colors.grey
                                                        : Color(0xff0644e3),
                                                onPress: isStoreClosed
                                                    ? null
                                                    : (DateTime.now().hour < DatabaseService.storeTimeData.openingHour || !optionsActive[1] || DatabaseService.storeTimeData.closingHour < (DateTime.now().hour + 4))
                                                        ? null
                                                        : () {
                                                            setState(() {
                                                              deliveryTime = null;
                                                              selectedDeliveryTime = SelectDeliveryTime.optionTwo;
                                                              _deliveryCharges = Provider.of<AppUser>(context, listen: false).second == "" || Provider.of<AppUser>(context, listen: false).second == null ? 0.0 : double.parse(Provider.of<AppUser>(context, listen: false).second);
                                                              // .first);
                                                            });
                                                          },
                                                text: "Within 2-4 Hours",
                                              ),
                                            ),
                                          ],
                                        ),
                                        Visibility(
                                          visible: true,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Center(
                                                child: Text(
                                                  canStoreOpen ? 'Scheduled Delivery Date : ${DateFormat.yMMMd().format(scheduledDeliveryDate)}' : 'The store is closed for now.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(color: selectedDeliveryTime == SelectDeliveryTime.optionThree ? Color(0xff0644e3) : Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Color(0xff0644e3))),
                                          height: 40,
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          child: DropdownButton<String>(
                                            underline: Container(),
                                            iconEnabledColor: selectedDeliveryTime == SelectDeliveryTime.optionThree ? Colors.white : Color(0xff0644e3),
                                            iconDisabledColor: selectedDeliveryTime == SelectDeliveryTime.optionThree ? Colors.white : Color(0xff0644e3),
                                            hint: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Schedule your own time',
                                                  style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Roboto', fontSize: 16, color: selectedDeliveryTime == SelectDeliveryTime.optionThree ? Colors.white : Color(0xff0644e3)),
                                                ),
                                              ],
                                            ),
                                            isExpanded: true,
                                            items: deliveryDates,
                                            onChanged: (value) {
                                              deliveryTime = value;
                                              selectedDeliveryTime = SelectDeliveryTime.optionThree;
                                              _deliveryCharges = Provider.of<AppUser>(context, listen: false).third != "" && Provider.of<AppUser>(context, listen: false).third != null ? double.parse(Provider.of<AppUser>(context, listen: false).third) : 0.0;
                                              setState(() {});
                                            },
                                            value: deliveryTime,
                                            dropdownColor: Color(0xff0644e3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: height * 0.070,
                                child: Row(
                                  children: [
                                    if (couponCode != '' && (validCoupon == true))
                                      Expanded(
                                          flex: 8,
                                          child: Text(
                                            'Coupon "$couponCode" is applied',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                          )),
                                    if (couponCode != '' && validCoupon == false)
                                      Expanded(
                                        flex: 8,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Coupon "$couponCode" is not valid',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                            ),
                                            if (DatabaseService.couponData != null)
                                              Text(
                                                'The minimum value to use the code is ${DatabaseService.couponData.limitAmount} SEK',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                                              ),
                                          ],
                                        ),
                                      ),
                                    if (validCoupon == null || couponCode.isEmpty)
                                      Expanded(
                                          flex: 8,
                                          child: TextField(
                                              onChanged: (v) {
                                                couponCode = v;
                                              },
                                              decoration: InputDecoration(fillColor: Colors.white, labelText: "Add Coupon", border: OutlineInputBorder()))),
                                    SizedBox(width: 10),
                                    CustomButton(
                                      textColor: Colors.white,
                                      bgColor: Color(0xff0644e3),
                                      borderColor: Color(0xff0644e3),
                                      text: validCoupon != null && couponCode.isNotEmpty ? 'Cancel' : "Apply",
                                      onPress: validCoupon != null && couponCode.isNotEmpty
                                          ? () {
                                              setState(() {
                                                validCoupon = null;
                                                couponCode = '';
                                                _discount = 0.0;
                                              });
                                            }
                                          : () async {
                                              if (couponCode == '') {
                                                ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                                                ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(
                                                  duration: kSnackBarDuration,
                                                  content: Text("Coupon code should not be empty", style: TextStyle(fontSize: 16)),
                                                  backgroundColor: Theme.of(context).errorColor,
                                                ));
                                              } else {
                                                validCoupon = await DatabaseService().applyCoupon(context, couponCode, _productsSubtotal);
                                                if (validCoupon == false) {
                                                  _discount = 0.0;
                                                }
                                                setState(() {});
                                              }
                                            },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              _customContainer(
                                headingOne: "Price per Bag: ",
                                detailOne: "${DatabaseService.bagCharges.toStringAsFixed(2)} SEK",
                                headingTwo: "Needed Bags: ",
                                detailTwo: "$_bagNeed",
                              ),
                              SizedBox(height: 20),
                              _customContainerUserCredit(
                                  headingOne: "Total Credits: ",
                                  detailOne: "${DatabaseService.credit.toStringAsFixed(2)} SEK",
                                  headingTwo: "Remaining: ",
                                  detailTwo: "${(DatabaseService.credit - _useCreditsAmount).toStringAsFixed(2)} SEK",
                                  value: _useCredits,
                                  onChanged: (v) {
                                    setState(() {
                                      _useCredits = v;
                                    });
                                  }),
                              SizedBox(height: 20),
                              finalPriceCard(
                                subTotal: _productsSubtotal.toStringAsFixed(2),
                                devCharges: _deliveryCharges.toStringAsFixed(2),
                                bagCharges: (DatabaseService.bagCharges * _bagNeed).toStringAsFixed(2),
                                total: _useCredits && _useCreditsAmount < DatabaseService.credit ? "0.00" : _total.toStringAsFixed(2),
                                usedCredits: _useCreditsAmount.toStringAsFixed(2),
                              ),
                              SizedBox(height: 10),
                              Center(
                                child: Container(
                                  width: width * 0.7,
                                  child: CustomButton(
                                      textColor: Colors.white,
                                      bgColor: Color(0xff0644e3),
                                      borderColor: Color(0xff0644e3),
                                      text: "Proceed To Checkout",
                                      onPress: () async {
                                        if (Provider.of<AppUser>(context, listen: false).userProfile == null) {
                                          final timer = Timer(Duration(seconds: 5), () {
                                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false);
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Moving to sign-in page in 5 seconds', overflow: TextOverflow.ellipsis),
                                                IconButton(
                                                  color: Colors.red,
                                                  icon: Icon(
                                                    Icons.cancel,
                                                    size: 30.0,
                                                  ),
                                                  onPressed: () {
                                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                    timer.cancel();
                                                  },
                                                )
                                              ],
                                            ),
                                            backgroundColor: Colors.black,
                                            duration: Duration(seconds: 5),
                                          ));
                                          return;
                                        }
                                      }
                                      // },
                                      ),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: Container(
                          height: 30,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            "Minimum Order should be of ${DatabaseService.minimumOrderLimit.toStringAsFixed(2)} SEK",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          color: Theme.of(context).errorColor,
                        ),
                        secondChild: SizedBox(height: 30, width: double.infinity),
                        crossFadeState: bannerState,
                        duration: Duration(milliseconds: 300),
                      ),
                    ],
                  );
                }),
        ),
      ),
    );
  }

  finalPriceCard({String subTotal, String devCharges, String bagCharges, String total, String usedCredits, String couponDiscount}) {
    return Card(
      elevation: 10.0,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Sub Total:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Tooltip(verticalOffset: 15, preferBelow: false, message: "Sum of the prices of all the products put in the cart", triggerMode: TooltipTriggerMode.tap, child: Icon(Icons.info_outline, size: 20)),
                  ],
                ),
                Text('$subTotal SEK'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Charges: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('$devCharges SEK'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grocery Bag Charges: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('$bagCharges SEK'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('- ${_discount.toStringAsFixed(2)} SEK'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Used Credits: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '' + double.parse(usedCredits).toStringAsFixed(2) + " SEK",
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '(Including 5% Service Fee)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                Text('$total SEK'),
              ],
            ),
          ],
        ),
        // height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(6.0),
        ),
      ),
    );
  }

  _customContainer({String headingOne, String headingTwo, String detailOne, String detailTwo}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 10,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.black,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        headingOne,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Tooltip(verticalOffset: 15, preferBelow: false, message: "Sustainable paper bag for carrying grocery products", triggerMode: TooltipTriggerMode.tap, child: Icon(Icons.info_outline, size: 20)),
                    ],
                  ),
                  Text(detailOne)
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headingTwo,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    detailTwo,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _customContainerUserCredit({String headingOne, String headingTwo, String detailOne, String detailTwo, Function onChanged, bool value}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 10,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headingOne,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(detailOne)
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headingTwo,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(detailTwo)
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Use Credits: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Checkbox(value: value, onChanged: onChanged),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void dropDownMenuItems() async {
    List<DropdownMenuItem<String>> deliverytiming = [];
    List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    int today = scheduledDeliveryDate.weekday - 1;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('deliverySchedule').doc(widget.storeID).collection(weekdays[today]).where('status', isEqualTo: 'active').get();
    if (querySnapshot.docs.length > 0) {
      for (var each in querySnapshot.docs) {
        int startTime = int.parse((each.data() as Map)['deliveryTime'].toString().split('-')[0]);
        int endTime = int.parse((each.data() as Map)['deliveryTime'].toString().split('-')[1]);
        if (isNextDaySlots) {
          deliverytiming.add(
            DropdownMenuItem<String>(
              value: '$startTime-$endTime',
              child: Text(
                '${weekdays[today]}    ${startTime < 10 ? '0$startTime' : startTime}:00 - ${endTime < 10 ? '0$endTime' : endTime}:00',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        } else if (scheduledDeliveryDate.hour + 3 <= startTime && endTime <= DatabaseService.storeTimeData.closingHour) {
          deliverytiming.add(
            DropdownMenuItem<String>(
              value: '$startTime-$endTime',
              child: Text(
                '${weekdays[today]}    ${startTime < 10 ? '0$startTime' : startTime}:00 - ${endTime < 10 ? '0$endTime' : endTime}:00',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
      }
    }
    deliverytiming.sort((DropdownMenuItem<String> a, DropdownMenuItem<String> b) {
      int av = int.parse(a.value.split('-')[0]);
      int bv = int.parse(b.value.split('-')[0]);
      return av.compareTo(bv);
    });
    setState(() {
      deliveryDates = deliverytiming;
    });
  }
}

class CartItem extends StatefulWidget {
  // final ProductModel product;
  final Function stState;
  final CartItemModel cartItem;

  // const CartItem({Key key, this.cartItem, this.product, this.stState}) : super(key: key);
  const CartItem({Key key, this.cartItem, this.stState}) : super(key: key);

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  int quantity = 1;

  @override
  void initState() {
    quantity = widget.cartItem.quantity;
    print(quantity);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DetailedProductPage(
                    id: widget.cartItem.productID,
                    storeId: widget.cartItem.storeId,
                    catId: widget.cartItem.catID,
                    subcatName: widget.cartItem.subcatID,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 100,
                child: FadeInImage.assetNetwork(
                  fadeInDuration: const Duration(milliseconds: 100),
                  fadeOutDuration: const Duration(milliseconds: 100),
                  width: 100,
                  height: 100,
                  placeholder: 'assets/images/image_loading.gif',
                  fit: BoxFit.cover,
                  image: widget.cartItem.image,
                ),
              ),
            ),
          ),
          Expanded(
              child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  child: Text(
                    widget.cartItem.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Price : ${double.parse(widget.cartItem.price.toString()).toStringAsFixed(2)} SEK'),
                        Text('Quantity  : $quantity'),
                        Text('Sub Total : ${double.parse((widget.cartItem.price * widget.cartItem.quantity).toString()).toStringAsFixed(2)} SEK'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final cart = Preferences.getCartItems();
                            cart.items.removeWhere((element) => element.productID == widget.cartItem.productID);
                            await Preferences.saveCartItems(cart);
                            widget.stState();
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (quantity > 1) {
                          print('decreasing quantity');
                          final cart = Preferences.getCartItems();
                          CartItemModel item = cart.items.singleWhere((element) => element.productID == widget.cartItem.productID);
                          print(item.toMap());
                          quantity = quantity - 1;
                          item.quantity = quantity;
                          print(item.toMap());
                          await Preferences.saveCartItems(cart);
                          widget.stState();
                        }
                      },
                      // : null,
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(border: Border.all(color: Color(0xff0644e3)), borderRadius: BorderRadius.circular(4), color: Colors.white),
                        child: Icon(
                          Icons.remove,
                          color: Color(0xff0644e3),
                          size: 25,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.cartItem.quantity.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: widget.cartItem.isInStock || widget.cartItem.productStock > quantity
                          ? () async {
                              print('decreasing quantity');
                              final cart = Preferences.getCartItems();
                              CartItemModel item = cart.items.singleWhere((element) => element.productID == widget.cartItem.productID);
                              print(item.toMap());
                              quantity = quantity + 1;
                              item.quantity = quantity;
                              print(item.toMap());
                              await Preferences.saveCartItems(cart);
                              widget.stState();
                            }
                          : null,
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Color(0xff0644e3)),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ))
        ],
      ),
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10),
      height: 120,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
    );
  }
}
