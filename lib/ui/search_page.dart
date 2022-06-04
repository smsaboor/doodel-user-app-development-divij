import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../grocerry_kit/detailedProductPage.dart';
import '../grocerry_kit/model/cart_model.dart';
import '../grocerry_kit/sub_pages/cartPage.dart';
import '../grocerry_kit/sub_pages/guest_cart_page.dart';
import '../main.dart';
import '../providers/collection_names.dart';
import '../providers/product.dart';
import '../providers/user.dart';
import '../services/preferences.dart';
import '../ui/custom_widgets/button_widget.dart';
import '../widgets/empty_products_widget.dart';

const PAGE_SIZE = 10;

class SearchScreen extends StatefulWidget {
  final String storeID;
  final String storeDocId;
  final String categoryDocid;
  final String subcatID;
  final String subcatName;
  final String catName;
  SearchScreen({
    this.storeID,
    this.storeDocId,
    this.categoryDocid,
    this.subcatID,
    this.subcatName,
    this.catName,
  });

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _allFetched = false;
  DocumentSnapshot _lastDocument;
  DocumentSnapshot _lastDocumentForDescProducts;
  QuerySnapshot<Map<String, dynamic>> initDataSearchRes;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> data = [];
  String _searchTerm = '';
  QuerySnapshot<Map<String, dynamic>> initialData;
  Stream<QuerySnapshot<Map<String, dynamic>>> initialStream;
  Stream<QuerySnapshot<Map<String, dynamic>>> searchStream;
  int pageSize = 20;
  StreamSubscription initStreamSub;
  bool showDescProducts = false;

  @override
  void initState() {
    super.initState();
    initialStream = FirebaseFirestore.instance
        .collectionGroup('products')
        .where('storeId', isEqualTo: widget.storeID)
        .limit(15)
        .snapshots();
    listenToInitDataStream();
  }

  void listenToInitDataStream() {
    initStreamSub = initialStream.listen(
      (event) {
        if (event.docs.isNotEmpty) {
          setState(() {
            initialData = event;
          });
        }
      },
    );
  }

  final StreamController<List<DocumentSnapshot>> searchResController =
      StreamController<List<DocumentSnapshot>>.broadcast();


  List<List<DocumentSnapshot>> _allPagedResults = [<DocumentSnapshot>[]];
  bool _hasMoreData = true;
  bool _hasMoreDataForDesc = true;
  Stream<List<DocumentSnapshot>> listenToSearchResultsRealTime() {
    _getSearchResults();
    return searchResController.stream;
  }

  void _getSearchResults() async {

    var searchQuery = FirebaseFirestore.instance
        .collectionGroup('products')
        .where('storeId', isEqualTo: widget.storeID)
        .where(
          showDescProducts ? 'keywordsDescription' : 'keywords',
          arrayContainsAny: _searchTerm.toLowerCase().split(' '),
        )
        .limit(pageSize);

    if (!showDescProducts) {
      if (_lastDocument != null) {
        searchQuery =  searchQuery.startAfterDocument(_lastDocument);
      }
    } else {
      if (_lastDocumentForDescProducts != null) {
        searchQuery =
            searchQuery.startAfterDocument(_lastDocumentForDescProducts);
      }
    }
    // if (!_hasMoreData) return;
    if (!_hasMoreData && !_hasMoreDataForDesc) return;

    print(
        'Searching for: $_searchTerm, Page: $pageSize, LastDoc: $_lastDocument, isDesc: $showDescProducts, HasMoreDes: $_hasMoreDataForDesc, HasMore: $_hasMoreData, AllFetched: $_allFetched');
    var currentRequestIndex = _allPagedResults.length;
    searchQuery.snapshots().distinct().listen(
      (snapshot) {
        print('IS EMPTYL:: ${snapshot.docs.isEmpty}');
        print('IS EMPTYL:: ${snapshot.docs}');
        if (snapshot.docs.isNotEmpty) {
          var generalSearch = snapshot.docs.toList();
          var pageExists = currentRequestIndex < _allPagedResults.length;
          // if (pageExists && !showDescProducts) {
          //   _allPagedResults[currentRequestIndex] = generalSearch;
          // } else {
          //   _allPagedResults.add(generalSearch);
          // }
          _allPagedResults.add(generalSearch);
          var allSearch = _allPagedResults.fold<List<DocumentSnapshot>>(
            <DocumentSnapshot>[],
            (initialValue, pageItems) => initialValue..addAll(pageItems),
          );
          searchResController.add(allSearch);
          if (currentRequestIndex == _allPagedResults.length - 1) {
            if (showDescProducts) {
              _lastDocumentForDescProducts = snapshot.docs.last;
            } else {
              _lastDocument = snapshot.docs.last;
            }
          }
          if (showDescProducts) {
            _hasMoreDataForDesc = generalSearch.length == pageSize;
          } else {
            _hasMoreData = generalSearch.length == pageSize;
            if (!_hasMoreData) {
              showDescProducts = true;
              _getSearchResults();
            }
          }
        } else {
          // searchResController.add(_allPagedResults);
          print('searching again');
          if (!showDescProducts) {
            _hasMoreDataForDesc = true;
            _hasMoreData = false;
            showDescProducts = true;
            _getSearchResults();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    initStreamSub.cancel();
    searchResController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel userProfile = Provider.of<AppUser>(context).userProfile;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          title: TextField(
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (val) {
              if (_searchTerm.trim().toLowerCase() !=
                  val.trim().toLowerCase()) {
                setState(() {
                  _searchTerm = val.trim();
                  pageSize = 10;
                  _hasMoreData = true;
                  _hasMoreDataForDesc = true;
                  showDescProducts = false;
                  _lastDocument = null;
                  _lastDocumentForDescProducts = null;
                  _allPagedResults = [<DocumentSnapshot>[]];
                  _allFetched = false;
                  searchResController.add(null);
                  _getSearchResults();
                });
              }
            },
            style: TextStyle(color: Colors.white, fontSize: 20),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Type to search...',
              hintStyle: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          actions: [
            GestureDetector(
                onTap: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Provider.of<AppUser>(context, listen: false)
                                .userProfile ==
                            null
                        ? GuestCartPage(true, widget.storeDocId)
                        : CartPage(true, widget.storeDocId);
                  }));
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                    ),
                    Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                    )
                  ],
                )),
          ],
          elevation: 8,
          backgroundColor: Color(0xff0644e3),
        ),
        body: Builder(
          builder: (BuildContext context) {
            QuerySnapshot<Map<String, dynamic>> data;
            if (_searchTerm.isEmpty) {
              data = initialData;
              if (initialData == null) return ShimmeringProductTilesList();
              if (data.docs.length != 0) {
                List<ProductModel> initialProducts = [];
                data.docs.forEach((element) {
                  var pData = element.data();
                  ProductModel product = ProductModel(
                      keywords: pData['keywords'],
                      images: [],
                      productDocId: element.id,
                      offerPrice: pData['offerPrice'],
                      productImageRef: pData['productImage'].isEmpty
                          ? "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/300px-No_image_available.svg.png"
                          : pData['productImage'][0],
                      productName: pData['productName'],
                      productPrice: pData['productPrice'],
                      productStock: pData['productStock'],
                      momOption: pData['momOption'],
                      storeID: widget.storeID,
                      isInStock: pData['isInStock'],
                      cat: pData['catID'],
                      subCat: pData['subcatID'],
                      description: pData['description']);
                  initialProducts.add(product);
                });
                if (initialProducts.length == 0) {
                  return const NoProductsWidget();
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    FocusScope.of(context).unfocus();
                    return true;
                  },
                  child: ListView.builder(
                    itemCount: initialProducts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SearchProduct(
                        product: initialProducts[index],
                        userProfile: userProfile,
                        index: index,
                      );
                    },
                  ),
                );
              } else {
                print('No products found00000');

                return const NoProductsWidget();
              }
            } else {
              return StreamBuilder<List<DocumentSnapshot>>(
                stream: listenToSearchResultsRealTime(),
                builder: (BuildContext context, snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting)
                  if (!snapshot.hasData || snapshot.data == null){
                    print('empty 2');
                    return ShimmeringProductTilesList();
                  }

                  if (snapshot.hasData) if (snapshot.hasError) {
                    print(snapshot.error.toString());
                  }
                  if (snapshot.data.length == 0) {
                    print('No products found1111111');

                    return const NoProductsWidget();
                  } else {
                    List<ProductModel> queryProducts = [];
                    snapshot.data.forEach((element) {
                      var data = element.data() as Map<String, dynamic>;
                      ProductModel product = ProductModel(
                          keywords: data['keywords'],
                          images: [],
                          productDocId: element.id,
                          offerPrice: data['offerPrice'],
                          productImageRef: data['productImage'].isEmpty
                              ? "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/300px-No_image_available.svg.png"
                              : data['productImage'][0],
                          productName: data['productName'],
                          productPrice: data['productPrice'],
                          productStock: data['productStock'],
                          momOption: data['momOption'],
                          storeID: widget.storeID,
                          isInStock: data['isInStock'],
                          cat: data['catID'],
                          subCat: data['subcatID'],
                          description: data['description']);
                      queryProducts.add(product);


                    });
                    final ids = Set();
                    queryProducts.retainWhere((x) => ids.add(x.productDocId));
                    // queryProducts.toSet().toList();
                    print('length is here ${queryProducts.length}');

                    if (queryProducts.length == 0) {
                      print('No products found22222');
                      return const NoProductsWidget();
                    } else if (queryProducts.length == 0) {
                      // Future.delayed(Duration(seconds: 2), () {
                      //   setState(() {
                      //     showDescProducts = true;
                      //   });
                      // });
                      print('empty hai');
                      return ShimmeringProductTilesList();
                    }
                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        FocusScope.of(context).unfocus();
                        if (notification.metrics.atEdge &&
                            notification.metrics.pixels > 0) {
                          print('Getting More Data!!');
                          _getSearchResults();
                        }
                        return true;
                      },
                      child: ListView.builder(
                        itemCount: _hasMoreData
                            ? queryProducts.length +1
                            : queryProducts.length,
                        itemBuilder: (BuildContext context, int index) {

                          if (index >= (queryProducts.length)) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return SearchProduct(
                            product: queryProducts[index],
                            userProfile: userProfile,
                            index: index,
                          );
                        },
                      ),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class SearchProduct extends StatefulWidget {
  final ProductModel product;
  final userProfile;
  final dynamic index;

  const SearchProduct({Key key, this.product, this.userProfile, this.index})
      : super(key: key);

  @override
  _SearchProductState createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  int _quantity = 1;

  generalDialog(BuildContext context, String image, String name) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black45,
        builder: (context) {
          return AlertDialog(
            title: Text(name),
            content: Container(
              width: devWidth * 0.4866,
              height: devHeight * 0.292,
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: PhotoView(
                tightMode: true,
                maxScale: PhotoViewComputedScale.covered * 2,
                backgroundDecoration: BoxDecoration(color: Colors.white),
                imageProvider: NetworkImage(image),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => DetailedProductPage(
                storeId: widget.product.storeID,
                catId: widget.product.cat,
                subcatName: widget.product.subCat,
                id: widget.product.productDocId,
              ),
            ));
          },
          child: Container(
            margin: EdgeInsets.only(top: 10),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10),
                  width: 100,
                  height: 100,
                  child: !widget.product.isInStock
                      ? widget.product.productStock <= 0
                          ? Center(
                              child: Container(
                                height: 35,
                                width: double.infinity,
                                color: Colors.red,
                                child: Center(
                                  child: Text('OUT OF STOCK',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            )
                          : widget.product.offerPrice != null
                              ? Center(
                                  child: Container(
                                    height: 35,
                                    width: double.infinity,
                                    color: Colors.green,
                                    child: Center(
                                      child: Text('LIMITED OFFER',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                )
                              : null
                      : widget.product.offerPrice != null
                          ? Center(
                              child: Container(
                                height: 35,
                                width: double.infinity,
                                color: Colors.green,
                                child: Center(
                                  child: Text('LIMITED OFFER',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            )
                          : null,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(widget.product.productImageRef))),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.product.productName,
                          softWrap: false,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${widget.product.offerPrice != null ? double.parse(widget.product.offerPrice).toStringAsFixed(2) : double.parse(widget.product.productPrice).toStringAsFixed(2)}  SEK",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomButton(
                                  text: 'Buy',
                                  borderColor: Color(0xff0644e3),
                                  bgColor: Colors.white,
                                  onPress: () async {
                                    if (widget.userProfile == null) {
                                      updateGuestCart();
                                    } else {
                                      updateUserCart();
                                    }
                                  },
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
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
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color(0xff0644e3)),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: Colors.white),
                                          child: Icon(Icons.remove,
                                              color: Color(0xff0644e3),
                                              size: 25)),
                                    ),
                                    SizedBox(width: 10),
                                    Text(_quantity.toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black45,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          if (widget.product.isInStock ||
                                              widget.product.productStock >
                                                  _quantity) {
                                            setState(() {
                                              _quantity += 1;
                                            });
                                          }
                                        },
                                        child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: Color(0xff0644e3)),
                                            child: Icon(Icons.add,
                                                color: Colors.white,
                                                size: 25))),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 5)
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        Divider(height: 1),
        SizedBox(height: 5),
      ],
    );
  }

  updateGuestCart() async {
    if (_quantity >= widget.product.productStock && !widget.product.isInStock) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: kSnackBarDuration,
          content: Text("Out of stock", style: TextStyle(fontSize: 16)),
          backgroundColor: Theme.of(context).errorColor));
    } else {
      CartModel cart = Preferences.getCartItems();
      if (cart.items.isNotEmpty) {
        if (cart.items.first.storeId != widget.product.storeID) {
          Preferences.deleteCartItems();
          cart = CartModel();
        }
      }
      CartItemModel item;
      try {
        item = cart.items.singleWhere(
            (element) => element.productID == widget.product.productDocId);
      } catch (e) {
        print(e);
      }
      if (item != null) {
        if (item.quantity + _quantity > widget.product.productStock &&
            !widget.product.isInStock) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: kSnackBarDuration,
              content: Text("Out of stock", style: TextStyle(fontSize: 16)),
              backgroundColor: Theme.of(context).errorColor));
        } else {
          item.quantity = item.quantity + _quantity;
          print(item.toMap());
          Preferences.saveCartItems(cart);
          return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: kSnackBarDuration,
              content:
                  Text("Item updated in cart", style: TextStyle(fontSize: 16)),
              backgroundColor: Color(0xff0644e3)));
        }
      } else {
        double price = double.parse(widget.product.offerPrice != null
            ? widget.product.offerPrice
            : widget.product.productPrice);
        CartItemModel cartItem = CartItemModel.fromMap({
          'price': price,
          'image': widget.product.productImageRef,
          'productID': widget.product.productDocId,
          'momOption': widget.product.momOption,
          'name': widget.product.productName,
          'quantity': _quantity,
          'catID': widget.product.cat,
          'storeId': widget.product.storeID,
          'subcatID': widget.product.subCat,
          'subtotal': _quantity * price,
          'description': widget.product.description,
          'productStock': widget.product.productStock,
          'isInStock': widget.product.isInStock
        });
        cart.items.add(cartItem);
        Preferences.saveCartItems(cart);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: kSnackBarDuration,
            content: Text("Item added to cart", style: TextStyle(fontSize: 16)),
            backgroundColor: Color(0xff0644e3)));
      }
    }
  }

  updateUserCart() async {
    if (!await DataConnectionChecker().hasConnection) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: kSnackBarDuration,
          content: Text('Please check your internet connection'),
          backgroundColor: Theme.of(context).errorColor));
    } else {
      if (_quantity >= widget.product.productStock &&
          !widget.product.isInStock) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: kSnackBarDuration,
            content: Text("Out of stock", style: TextStyle(fontSize: 16)),
            backgroundColor: Theme.of(context).errorColor));
      } else {
        final QuerySnapshot queryCheck = await FirebaseFirestore.instance
            .collection(users_collection)
            .doc(widget.userProfile.userId)
            .collection('cart')
            .where('productID', isEqualTo: widget.product.productDocId)
            .limit(1)
            .get();
        if (queryCheck.docs.length != 0) {
          if ((queryCheck.docs[0].data() as Map)['quantity'] + _quantity >
                  widget.product.productStock &&
              !widget.product.isInStock) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: kSnackBarDuration,
                content: Text("Out os stock", style: TextStyle(fontSize: 16)),
                backgroundColor: Theme.of(context).errorColor));
          } else {
            return queryCheck.docs[0].reference.update({
              'quantity':
                  ((queryCheck.docs[0].data() as Map)['quantity'] + _quantity),
            }).then((value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: kSnackBarDuration,
                  content: Text("Item updated in cart",
                      style: TextStyle(fontSize: 16)),
                  backgroundColor: Color(0xff0644e3)));
            }).catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: kSnackBarDuration,
                  content: Text("Please Check your internet connection.",
                      style: TextStyle(fontSize: 16)),
                  backgroundColor: Theme.of(context).errorColor));
            });
          }
        } else {
          double price = double.parse(widget.product.offerPrice != null
              ? widget.product.offerPrice
              : widget.product.productPrice);
          FirebaseFirestore.instance
              .collection(users_collection)
              .doc(widget.userProfile.userId)
              .collection('cart')
              .add({
            'price': price,
            'image': widget.product.productImageRef,
            'productID': widget.product.productDocId,
            'momOption': widget.product.momOption,
            'name': widget.product.productName,
            'quantity': _quantity,
            'catID': widget.product.cat,
            'storeId': widget.product.storeID,
            'subcatID': widget.product.subCat,
            'subtotal': _quantity * price,
            'description': widget.product.description,
            'productStock': widget.product.productStock,
            'isInStock': widget.product.isInStock,
          }).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: kSnackBarDuration,
                content:
                    Text("Item added to cart", style: TextStyle(fontSize: 16)),
                backgroundColor: Color(0xff0644e3)));
          }).catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: kSnackBarDuration,
                content: Text("Please Check your internet connection.",
                    style: TextStyle(fontSize: 16)),
                backgroundColor: Theme.of(context).errorColor));
          });
        }
      }
    }
  }
}

class NoProductsWidget extends StatefulWidget {
  const NoProductsWidget({Key key}) : super(key: key);

  @override
  State<NoProductsWidget> createState() => _NoProductsWidgetState();
}

class _NoProductsWidgetState extends State<NoProductsWidget> {
  bool _isLoading = false;
  // @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(Duration(seconds: 60), () {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const ShimmeringProductTilesList()
        : Center(
            child: Text('No Product Found'),
          );
  }
}
