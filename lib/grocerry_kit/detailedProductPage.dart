import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';

import '../grocerry_kit/expandedPhoto.dart';
import '../grocerry_kit/product_grid_view_page.dart';
import '../grocerry_kit/sub_category_grid_view.dart';
import '../main.dart';
import '../providers/collection_names.dart';
import '../providers/product.dart';
import '../providers/user.dart';
import '../services/preferences.dart';
import 'model/cart_model.dart';

class DetailedProductPage extends StatefulWidget {
  final String storeId, catId, id;
  final String subcatName;

  DetailedProductPage({this.storeId, this.catId, this.id, this.subcatName});
  @override
  _DetailedProductPageState createState() => _DetailedProductPageState();
}

class _DetailedProductPageState extends State<DetailedProductPage> {
  ProductModel product;
  bool loading = false;
  int _quantity = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  initData() async {
    setState(() {
      loading = true;
    });
    // Measuring the time taken to fetch data
    final startTime = DateTime.now();
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('groceryShops').doc(widget.storeId).collection('categoryCollection').doc(widget.catId).collection('subCategory').doc(widget.subcatName).collection('products').doc(widget.id).get();
    print(snap.reference.path);
    final endTime = DateTime.now();
    print('Detail Page Query took ${endTime.difference(startTime).inMilliseconds} ms, ${endTime.difference(startTime).inSeconds} seconds');
    if (mounted) {
      setState(() {
        product = Provider.of<Product>(context, listen: false).convertToProductModel(snap);
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    UserModel userProfile = Provider.of<AppUser>(context).userProfile;
    return Scaffold(
      key: _scaffoldKey,
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Column(
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.45,
                            child: PageView(
                              children: [
                                ...product.images.map(
                                      (e) => GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ExpandedPhoto(
                                                        imageURL: e,
                                                      )));
                                        },
                                        child: Container(
                                            // padding: EdgeInsets.symmetric(horizontal: devWidth * 10 / 411, vertical: devHeight * 30 / 683),
                                            width: double.infinity,
                                            height: devHeight * 350 / 683,
                                            child: Stack(
                                              children: [
                                                FadeInImage.assetNetwork(
                                                  fadeInDuration: const Duration(milliseconds: 100),
                                                  fadeOutDuration: const Duration(milliseconds: 100),
                                                  height: devHeight * 350 / 683,
                                                  width: double.infinity,
                                                  placeholder: 'assets/images/image_loading.gif',
                                                  image: e,
                                                  fit: BoxFit.fill,
                                                ),
                                                Positioned(
                                                  left: 10,
                                                  top: 10,
                                                  child: ClipOval(
                                                    child: Material(
                                                      color: Colors.black54,
                                                      child: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.of(context).pop()),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    )
                                    .toList()
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: devHeight * 10 / 683),
                                Text(
                                  product.productName != null ? product.productName : '',
                                  style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.w500),
                                ),
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance.collection('groceryShops').doc(product.storeID).collection('categoryCollection').doc(product.cat).get(),
                                  builder: (context, snap) {

                                    if (snap.hasData && snap.data.exists) {
                                      return Visibility(
                                        visible: (snap.data.data() as Map)[''] != '' && snap.data.data() != null,
                                        child: Wrap(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                  return SubcategoryGridView(categoryDocid: product.cat, categoryName: (snap.data.data() as Map)['categoryName'], storeDocId: product.storeID);
                                                }));
                                              },
                                              child: Chip(
                                                label: Text((snap.data.data() as Map)['categoryName']),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            FutureBuilder<DocumentSnapshot>(
                                                future: FirebaseFirestore.instance.collection('groceryShops').doc(product.storeID).collection('categoryCollection').doc(product.cat).collection('subCategory').doc(widget.subcatName).get(),
                                                builder: (context, snap) {
                                                  print(widget.subcatName);
                                                  if (snap.hasData) {
                                                    String subCatName = snap.data.get('name').toString();
                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                          return ProductGridView(
                                                            catName: '',
                                                            categoryDocid: product.cat,
                                                            storeID: product.storeID,
                                                            subcatName: subCatName,
                                                            subcatID: product.subCat,
                                                            hasSubcatID: true,
                                                          );
                                                        }));
                                                      },
                                                      child: Chip(
                                                        label: Text(
                                                          subCatName,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    return SizedBox();
                                                  }
                                                })
                                          ],
                                        ),
                                      );
                                    } else {
                                      return SizedBox();
                                    }
                                  },
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    product.description,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.grey.shade300,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${double.parse(product.offerPrice != null ? product.offerPrice : product.productPrice).toStringAsFixed(2)} SEK',
                              style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (userProfile == null) {
                                  updateGuestCart();
                                } else {
                                  updateUserCart(userProfile);
                                }
                              },
                              child: Card(
                                  elevation: 4,
                                  shadowColor: Colors.grey[700],
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    height: ScreenUtil().setHeight(40),
                                    decoration: BoxDecoration(
                                      color: product.isInStock || product.productStock > 0 ? Theme.of(context).primaryColor : Colors.grey,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Center(
                                        child: Text(
                                      'ADD TO CART',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(22, allowFontScalingSelf: true), fontWeight: FontWeight.w900),
                                    )),
                                  )),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (_quantity > 1) {
                                      setState(() {
                                        _quantity -= 1;
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
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
                                  _quantity.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black45,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  softWrap: true,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: product.isInStock || product.productStock > _quantity
                                      ? () {
                                          setState(() {
                                            _quantity += 1;
                                          });
                                        }
                                      : null,
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Color(0xff0644e3)),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  updateGuestCart() async {
    print('updating guest cart  detailed product');
    if (_quantity >= product.productStock && !product.isInStock) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Out of stock", style: TextStyle(fontSize: 16)), backgroundColor: Theme.of(context).errorColor));
    } else {
      CartModel cart = Preferences.getCartItems();
      if (cart.items.isNotEmpty) {
        if (cart.items.first.storeId != product.storeID) {
          Preferences.deleteCartItems();
          cart = CartModel();
        }
      }
      CartItemModel item;
      try {
        item = cart.items.singleWhere((element) => element.productID == product.productDocId);
      } catch (e) {
        print(e);
        print('did not find cart item');
      }
      if (item != null) {
        print('item != null');
        print(item.toMap());
        if (item.quantity + _quantity > product.productStock && !product.isInStock) {
          ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Out of stock", style: TextStyle(fontSize: 16)), backgroundColor: Theme.of(context).errorColor));
        } else {
          item.quantity = item.quantity + _quantity;
          print(item.toMap());
          Preferences.saveCartItems(cart);
          return ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Item updated in cart", style: TextStyle(fontSize: 16)), backgroundColor: Color(0xff0644e3)));
        }
      } else {
        print('item null');
        double price = double.parse(product.offerPrice != null ? product.offerPrice : product.productPrice);
        CartItemModel cartItem = CartItemModel.fromMap(
            {'price': price, 'image': product.productImageRef, 'productID': product.productDocId, 'momOption': product.momOption, 'name': product.productName, 'quantity': _quantity, 'catID': product.cat, 'storeId': product.storeID, 'subcatID': product.subCat, 'subtotal': _quantity * price, 'description': product.description, 'productStock': product.productStock, 'isInStock': product.isInStock});
        cart.items.add(cartItem);
        Preferences.saveCartItems(cart);
        ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Item added to cart", style: TextStyle(fontSize: 16)), backgroundColor: Color(0xff0644e3)));
      }
    }
  }

  updateUserCart(UserModel userProfile) async {
    if (!await DataConnectionChecker().hasConnection) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
    } else {
      if (_quantity > product.productStock && !product.isInStock) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Out of stock", style: TextStyle(fontSize: 16)), backgroundColor: Theme.of(context).errorColor));
      } else {
        final QuerySnapshot queryCheck = await FirebaseFirestore.instance.collection(users_collection).doc(userProfile.userId).collection('cart').where('productID', isEqualTo: product.productDocId).limit(1).get();
        print(queryCheck.docs.length);
        if (queryCheck.docs.length != 0) {
          if ((queryCheck.docs[0].data() as Map)['quantity'] + _quantity > product.productStock && !product.isInStock) {
            ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Out of stock", style: TextStyle(fontSize: 16)), backgroundColor: Theme.of(context).errorColor));
          } else {
            return queryCheck.docs[0].reference.update({
              'quantity': ((queryCheck.docs[0].data() as Map)['quantity'] + _quantity),
            }).then((value) {
              ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Item updated in cart", style: TextStyle(fontSize: 16)), backgroundColor: Color(0xff0644e3)));
            }).catchError((e) {
              ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Please Check your internet connection.", style: TextStyle(fontSize: 16)), backgroundColor: Theme.of(context).errorColor));
            });
          }
        } else {
          print('Adding Product');
          double price = double.parse(product.productPrice);
          FirebaseFirestore.instance.collection(users_collection).doc(userProfile.userId).collection('cart').add({
            'price': price,
            'image': product.productImageRef,
            'productID': product.productDocId,
            'momOption': product.momOption,
            'name': product.productName,
            'quantity': _quantity,
            'subtotal': price,
            'catID': product.cat,
            'storeId': product.storeID,
            'subcatID': product.subCat,
            'description': product.description,
            'productStock': product.productStock,
            'isInStock': product.isInStock,
          }).then((value) {
            ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Item added to cart", style: TextStyle(fontSize: 16)), backgroundColor: Color(0xff0644e3)));
          }).catchError((e) {
            ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Out of stock", style: TextStyle(fontSize: 16)), backgroundColor: Theme.of(context).errorColor));
          });
        }
      }
    }
  }
}
