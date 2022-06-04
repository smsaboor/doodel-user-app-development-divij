import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../../grocerry_kit/model/cart_model.dart';
import '../../grocerry_kit/store_package/stores_list_screen.dart';
import '../../grocerry_kit/sub_pages/cartPage.dart';
import '../../main.dart';
import '../../providers/category.dart';
import '../../providers/collection_names.dart';
import '../../providers/product.dart';
import '../../providers/subCategory.dart';
import '../../providers/user.dart';
import '../../services/database_service.dart';
import '../../services/preferences.dart';
import '../../ui/custom_widgets/button_widget.dart';
import '../../ui/login_page.dart';
import '../../ui/search_page.dart';
import '../../utils/custom_drawer.dart';
import '../../widgets/empty_products_widget.dart';
import '../category_grid_view_Page.dart';
import '../detailedProductPage.dart';
import '../expandedPhoto.dart';
import '../sub_category_grid_view.dart';
import 'guest_cart_page.dart';

class HomeList extends StatefulWidget {
  final int isGuest;
  HomeList(this.storeDocId, this.isGuest);

  final String storeDocId;

  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ProductModel> products = [];

  initState() {
    super.initState();
    DatabaseService().getBagCharges();
    DatabaseService().getCredit();
    DatabaseService().getStoreOpeningClosingTime(widget.storeDocId);
    DatabaseService().getMinimumOrderLimit(widget.storeDocId);
    Timer(Duration(seconds: 1), () {
      if (isFirstLaunch == false) {
        isFirstLaunch = true;
        showTutorials();
      }
    });
  }

  showTutorials() async {
    await ecoTutorial(context);
    await timeTutorial(context);
    await deliveryTutorial(context);
    await serviceTutorial(context);
  }

  final ScrollController _scrollController2 = ScrollController();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(411, 683));
    return WillPopScope(
      onWillPop: () async {
        bool val = await _onWillPop();
        if (val == true) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => StoresListPage(
                        isGuest: widget.isGuest,
                      )));
        }
        return Future.value(false);
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: CustomDrawer(widget.isGuest),
        appBar: AppBar(
          centerTitle: true,
          // ignore: deprecated_member_use
          brightness: Brightness.dark,
          elevation: 0,
          backgroundColor: Color(0xff0644e3),
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                  child: Icon(Icons.dehaze, color: Colors.white, size: 32)),
              Container(
                height: 50,
                // width: 220,
                width: MediaQuery.of(context).size.width / 1.7,
                child: Scrollbar(
                  controller: _scrollController2,
                  child: Center(
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        Center(
                          child: Text('${Provider.of<AppUser>(context).userStoreName}', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                  onTap: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return Provider.of<AppUser>(context, listen: false).userProfile == null ? GuestCartPage(true, widget.storeDocId) : CartPage(true, widget.storeDocId);
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
          ),
        ),
        body: Container(
          color: const Color(0xffF4F7FA),
          child: ListView(
            padding: EdgeInsets.only(bottom: 20),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: devWidth * 0.0389, top: 4),
                    child: Text(
                      'All Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: devWidth * 0.0389, top: 4),
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      onPressed: () async {
                        if (!await DataConnectionChecker().hasConnection) {
                          ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                          ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return CategoryGridView(widget.storeDocId);
                        }));
                      },
                      child: Text(
                        'more..',
                        style: TextStyle(color: Color(0xff0644e3), fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              _buildCategoryList(),
              Padding(
                padding: const EdgeInsets.only(left: 0.0),
                child: _buildCategoryList2(),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue[800],
          onPressed: () async {
            if (!await DataConnectionChecker().hasConnection) {
              ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
              ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
            } else {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchScreen(storeID: widget.storeDocId)));
            }
          },
          child: Icon(Icons.search, size: 30, color: Colors.white),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Text('Do you want to exit the store?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: Color(0xff0644e3)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(color: Color(0xff0644e3)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  SubCategory subCategory;

  Widget _buildCategoryList() {
    return Container(
        height: 170,
        alignment: Alignment.topLeft,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection(stores_collection).doc(widget.storeDocId).collection(category_collection).snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                  break;
                default:
                  return snapshot.data.docs.length == 0
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("No categories added."),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.only(left: 5),
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            var data = snapshot.data.docs[index];
                            var category = Provider.of<Category>(context).convertToCategoryModel(data);
                            return Padding(
                              padding: EdgeInsets.only(left: devWidth * 0.0189),
                              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                GestureDetector(
                                  onTap: () async {
                                    if (!await DataConnectionChecker().hasConnection) {
                                      ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
                                    } else {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                                        return SubcategoryGridView(
                                          categoryDocid: category.categoryDocId,
                                          categoryName: category.categoryName,
                                          storeDocId: widget.storeDocId,
                                        );
                                      }));
                                    }
                                  },
                                  child: ClipOval(
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      child: CachedNetworkImage(
                                        placeholder: (ctx, _) => Image.asset(
                                          'assets/images/image_loading.gif',
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                        imageUrl: category.categoryImageRef,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: devWidth * 0.317,
                                      child: Text(
                                        category.categoryName,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff0644e3)),
                                      ),
                                    ),
                                  ],
                                )
                              ]),
                            );
                          },
                        );
              }
            }));
  }

  bool isloading = false;

  Widget _buildCategoryList2() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(stores_collection).doc(widget.storeDocId).collection(category_collection).snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              // return Center(child: CircularProgressIndicator());
              return ShimmeringCategoryProducts();
              break;
            default:
              return snapshot.data.docs.length == 0
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("No categories added."),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            padding: EdgeInsets.only(left: 15),
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data.docs.length > 5 ? 5 : snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              // This is the Category Builder
                              QueryDocumentSnapshot data = snapshot.data.docs[index];
                              var category = Provider.of<Category>(context).convertToCategoryModel(data);
                              return Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: devHeight * 0.0204,
                                  ),
                                  Container(
                                    width: devWidth,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            child: Text(
                                              category.categoryName,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: ScreenUtil().setSp(20, allowFontScalingSelf: true),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // ignore: deprecated_member_use
                                        FlatButton(
                                          onPressed: () async {
                                            if (!await DataConnectionChecker().hasConnection) {
                                              ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                                              ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
                                              return;
                                            }
                                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                                              return SubcategoryGridView(
                                                categoryDocid: category.categoryDocId,
                                                categoryName: category.categoryName,
                                                storeDocId: widget.storeDocId,
                                              );
                                            }));
                                          },
                                          child: Text(
                                            'more..',
                                            style: TextStyle(color: Color(0xff0644e3), fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _getProducts(category.categoryDocId),
                                ],
                              );
                            },
                          ),
                        ),
                        if (snapshot.data.docs.length > 5)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: Color(0xff0644e3)),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: TextButton(
                              onPressed: () async {
                                if (!await DataConnectionChecker().hasConnection) {
                                  ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
                                } else {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return CategoryGridView(widget.storeDocId);
                                  }));
                                }
                              },
                              child: Text(
                                'More Categories and Products...',
                                style: TextStyle(color: Color(0xff0644e3), fontSize: 16),
                              ),
                            ),
                          ),
                      ],
                    );
          }
        });
  }

  Widget _getProducts(String categoryId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(stores_collection).doc(widget.storeDocId).collection(category_collection).doc(categoryId).collection('subCategory').where('catID', isEqualTo: categoryId).limit(3).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("No products added."),
              );
            } else {
              return SizedBox(
                height: 300,
                // height: devWidth * 0.4,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.docs.length > 3 ? 3 : snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    subCategory = SubCategory.fromDocument(snapshot.data.docs[index]);
                    return FutureBuilder(
                        future: _buildCategoryProductsList(subCategory.catID, subCategory.id, subCategory.name, products.length),
                        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                          // products.clear();
                          if (snapshot.hasData) {
                            return snapshot.data;
                          }
                          return Center(child: CircularProgressIndicator());
                        });
                  },
                ),
              );
            }
          }
          // return Center(child: CircularProgressIndicator());
          return ShimmeringProductsList();
        });
  }

  Future<Widget> _buildCategoryProductsList(String categoryDocId, String subcatid, String subcatname, int productsLength) {
    return Future.delayed(Duration.zero, () {
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection(stores_collection).doc(widget.storeDocId).collection(category_collection).doc(categoryDocId).collection('subCategory').doc(subcatid).collection('products').orderBy("productName").limit(2).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(''),
                );
              } else {
                List<dynamic> p = [];
                for (DocumentSnapshot each in snapshot.data.docs) {
                  ProductModel product = Provider.of<Product>(context, listen: false).convertToProductModel(each);
                  p.add(product);
                }
                return Row(
                  children: List<Widget>.generate(p.length > 2 ? 2 : p.length, (index) {
                    return _getProduct(p[index], categoryDocId);
                  }),
                );
              }
            }
            // return Center(child: CircularProgressIndicator());
            return ShimmeringProduct();
          });
    });
  }

  Widget _getProduct(ProductModel product, String categoryDocId) {
    return Container(
      width: devWidth * 0.3,
      margin: EdgeInsets.only(right: devWidth * 0.050),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
              onDoubleTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ExpandedPhoto(
                        imageURL: product.productImageRef,
                      ))),
              onTap: () async {
                //this logic is for getting subcategory name
                if (!await DataConnectionChecker().hasConnection) {
                  ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
                  ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
                } else {
                  var data = await FirebaseFirestore.instance.collection(stores_collection).doc(widget.storeDocId).collection(category_collection).doc(categoryDocId).collection('subCategory').where('catID', isEqualTo: product.cat).get();
                  print(data.docs[0].data()['name']);

                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return DetailedProductPage(
                      storeId: widget.storeDocId,
                      catId: categoryDocId,
                      subcatName: product.subCat,
                      id: product.productDocId,
                    );
                  }));
                }
              },
              child: Container(
                margin: EdgeInsets.all(2.0),
                alignment: Alignment.center,
                width: devHeight * 0.15,
                height: devHeight * 0.15,
                child: Stack(
                  children: [
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(12),
                    //   child: FadeInImage.assetNetwork(
                    //     placeholder: 'assets/images/image_loading.gif',
                    //     image: product.productImageRef,
                    //     fit: BoxFit.cover,
                    //     width: devHeight * 0.15,
                    //     height: devHeight * 0.15,
                    //   ),
                    // ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        placeholder: (ctx, _) => Image.asset(
                          'assets/images/image_loading.gif',
                          fit: BoxFit.cover,
                          width: devHeight * 0.15,
                          height: devHeight * 0.15,
                        ),
                        imageUrl: product.productImageRef,
                        fit: BoxFit.cover,
                        width: devHeight * 0.15,
                        height: devHeight * 0.15,
                      ),
                    ),
                    !product.isInStock
                        ? product.productStock <= 0
                            ? Align(
                                alignment: Alignment.center,
                                child: Container(
                                  height: ScreenUtil().setHeight(30),
                                  width: double.infinity,
                                  color: Colors.red,
                                  child: Center(
                                    child: Text('OUT OF STOCK', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              )
                            : product.offerPrice != null
                                ? Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
                                      height: ScreenUtil().setHeight(20),
                                      width: double.infinity,
                                      color: Colors.green,
                                      child: Center(
                                        child: Text('LIMITED OFFER', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  )
                                : SizedBox()
                        : product.offerPrice != null
                            ? Align(
                                alignment: Alignment.center,
                                child: Container(
                                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
                                  height: ScreenUtil().setHeight(20),
                                  width: double.infinity,
                                  color: Colors.green,
                                  child: Center(
                                    child: Text('LIMITED OFFER', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(12, allowFontScalingSelf: true), fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              )
                            : SizedBox(),
                  ],
                ),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black)),
              )),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5),
            child: Container(
              height: 45,
              // width: 100,
              child: Text(
                "${product.productName}",
                //     softWrap: true,
                maxLines: 3,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          if (product.productPrice != '' || product.productPrice == null) PriceContainer(product, widget.storeDocId),
        ],
      ),
    );
  }

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

  Future ecoTutorial(context) {
    return showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0.8),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Image.asset(
                'assets/images/ecofriendlypng.png',
              ),
            ),
          );
        });
  }

  Future timeTutorial(context) {
    return showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0.8),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Image.asset(
                'assets/images/timepng.png',
              ),
            ),
          );
        });
  }

  Future deliveryTutorial(context) {
    return showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0.8),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Image.asset(
                'assets/images/deliverypng.png',
              ),
            ),
          );
        });
  }

  Future serviceTutorial(context) {
    return showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0.8),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Image.asset(
                'assets/images/service_availability.png',
              ),
            ),
          );
        });
  }
}

// ignore: must_be_immutable
class PriceContainer extends StatefulWidget {
  PriceContainer(this.product, this.storeDocId);

  final String storeDocId;
  final ProductModel product;
  int _quantity = 1;

  @override
  _PriceContainerState createState() => _PriceContainerState();
}

class _PriceContainerState extends State<PriceContainer> {
  @override
  Widget build(BuildContext context) {
    UserModel userProfile = Provider.of<AppUser>(context).userProfile;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // SizedBox(height:10),
        Container(
          width: devWidth * 0.29,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "${double.parse(widget.product.offerPrice != null ? widget.product.offerPrice : widget.product.productPrice).toStringAsFixed(2)}  SEK",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: GestureDetector(
                  onTap: () {
                    if (widget._quantity > 1) {
                      setState(() {
                        widget._quantity -= 1;
                      });
                    }
                  },
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(border: Border.all(color: Color(0xff0644e3)), borderRadius: BorderRadius.circular(4), color: Colors.white),
                    child: Icon(
                      Icons.remove,
                      color: Color(0xff0644e3),
                      size: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 7,
              ),
              Text(
                widget._quantity.toString(),
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
                //alignment: Alignment.center,

                onTap: widget.product.isInStock || widget.product.productStock > widget._quantity
                    ? () {
                        setState(() {
                          widget._quantity += 1;
                        });
                      }
                    : null,
                child: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Color(0xff0644e3)),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(
                width: 9,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 9,
        ),
        Container(
            width: devWidth * 0.29,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: CustomButton(
                  text: 'Buy',
                  textColor: Colors.black,
                  borderColor: Color(0xff0644e3),
                  bgColor: Colors.white,
                  onPress: () async {
                    if (userProfile == null) {
                      updateGuestCart();
                    } else {
                      updateUserCart(userProfile);
                    }
                  }),
            ))
      ],
    );
  }

  updateGuestCart() async {
    print('updating guest cart1');
    if (widget._quantity >= widget.product.productStock && !widget.product.isInStock) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Out of stock", style: TextStyle(fontSize: 16)), backgroundColor: Theme.of(context).errorColor));
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
        item = cart.items.singleWhere((element) => element.productID == widget.product.productDocId);
      } catch (e) {
        print(e);
        print('did not find cart item');
      }
      if (item != null) {
        print('item != null');
        print(item.toMap());
        if (item.quantity + widget._quantity > widget.product.productStock && !widget.product.isInStock) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Out of stock", style: TextStyle(fontSize: 16)), backgroundColor: Theme.of(context).errorColor));
        } else {
          item.quantity = item.quantity + widget._quantity;
          print(item.toMap());
          Preferences.saveCartItems(cart);
          return ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Item updated in cart", style: TextStyle(fontSize: 16)), backgroundColor: Color(0xff0644e3)));
        }
      } else {
        print('item null');
        double price = double.parse(widget.product.offerPrice != null ? widget.product.offerPrice : widget.product.productPrice);
        CartItemModel cartItem = CartItemModel.fromMap({
          'price': price,
          'image': widget.product.productImageRef,
          'productID': widget.product.productDocId,
          'momOption': widget.product.momOption,
          'name': widget.product.productName,
          'quantity': widget._quantity,
          'catID': widget.product.cat,
          'storeId': widget.product.storeID,
          'subcatID': widget.product.subCat,
          'subtotal': widget._quantity * price,
          'description': widget.product.description,
          'productStock': widget.product.productStock,
          'isInStock': widget.product.isInStock
        });
        cart.items.add(cartItem);
        Preferences.saveCartItems(cart);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Item added to cart", style: TextStyle(fontSize: 16)), backgroundColor: Color(0xff0644e3)));
      }
    }
  }

  updateUserCart(UserModel userProfile) async {
    if (!await DataConnectionChecker().hasConnection) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
    } else {
      if (widget._quantity > widget.product.productStock && !widget.product.isInStock) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: kSnackBarDuration,
          content: Text(
            "Out of stock",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Theme.of(context).errorColor,
        ));
      } else {
        final QuerySnapshot queryCheck = await FirebaseFirestore.instance.collection(users_collection).doc(userProfile.userId).collection('cart').where('productID', isEqualTo: widget.product.productDocId).limit(1).get();
        print(queryCheck.docs.length);
        if (queryCheck.docs.length != 0) {
          if ((queryCheck.docs[0].data() as Map)['quantity'] + widget._quantity > widget.product.productStock && !widget.product.isInStock) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: kSnackBarDuration,
              content: Text(
                "Out of stock",
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Theme.of(context).errorColor,
            ));
          } else {
            return queryCheck.docs[0].reference.update({
              'quantity': ((queryCheck.docs[0].data() as Map)['quantity'] + widget._quantity),
            }).then((value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: kSnackBarDuration,
                content: Text(
                  "Item updated in cart",
                  style: TextStyle(fontSize: 16),
                ),
                backgroundColor: Color(0xff0644e3),
              ));
            }).catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: kSnackBarDuration,
                content: Text(
                  "Please Check your internet connection.",
                  style: TextStyle(fontSize: 16),
                ),
                backgroundColor: Theme.of(context).errorColor,
              ));
            });
          }
        } else {
          double price = double.parse(widget.product.offerPrice != null ? widget.product.offerPrice : widget.product.productPrice);
          FirebaseFirestore.instance.collection(users_collection).doc(userProfile.userId).collection('cart').add({
            'price': price,
            'image': widget.product.productImageRef,
            'productID': widget.product.productDocId,
            'momOption': widget.product.momOption,
            'name': widget.product.productName,
            'quantity': widget._quantity,
            'catID': widget.product.cat,
            'storeId': widget.product.storeID,
            'subcatID': widget.product.subCat,
            'subtotal': widget._quantity * price,
            'description': widget.product.description,
            'productStock': widget.product.productStock,
            'isInStock': widget.product.isInStock,
          }).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: kSnackBarDuration,
              content: Text(
                "Item added to cart",
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Color(0xff0644e3),
            ));
          }).catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: kSnackBarDuration,
              content: Text(
                "Please Check your internet connection.",
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Theme.of(context).errorColor,
            ));
          });
        }
      }
    }
  }
}

// ignore: must_be_immutable
class PriceContainer2 extends StatefulWidget {
  PriceContainer2(this.product, this.storeDocId);

  final String storeDocId;
  final ProductModel product;
  int _quantity = 1;

  @override
  _PriceContainer2State createState() => _PriceContainer2State();
}

class _PriceContainer2State extends State<PriceContainer2> {
  @override
  Widget build(BuildContext context) {
    UserModel userProfile = Provider.of<AppUser>(context).userProfile;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "${double.parse(widget.product.offerPrice != null ? widget.product.offerPrice : widget.product.productPrice).toStringAsFixed(2)}  SEK",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (widget._quantity > 1) {
                  setState(() {
                    widget._quantity -= 1;
                  });
                }
              },
              child: Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(border: Border.all(color: Color(0xff0644e3)), borderRadius: BorderRadius.circular(4), color: Colors.white),
                child: Icon(
                  Icons.remove,
                  color: Color(0xff0644e3),
                  size: 22,
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              widget._quantity.toString(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.black45,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: widget.product.isInStock || widget.product.productStock > widget._quantity
                  ? () {
                      print(widget.product.productStock > widget._quantity);
                      setState(() {
                        widget._quantity += 1;
                      });
                    }
                  : null,
              child: Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Color(0xff0644e3)),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 5.0),
              child: CustomButton(
                text: 'Buy',
                textColor: Colors.black,
                borderColor: Color(0xff0644e3),
                bgColor: Colors.white,
                onPress: () async {
                  if (userProfile == null) {
                    updateGuestCart();
                  } else {
                    updateUserCart(userProfile);
                  }
                },
              ),
            ))
      ],
    );
  }

  updateGuestCart() async {
    print('updating guest cart2');
    if (widget._quantity >= widget.product.productStock && !widget.product.isInStock) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Out of stock", style: TextStyle(fontSize: 16)), backgroundColor: Theme.of(context).errorColor));
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
        item = cart.items.singleWhere((element) => element.productID == widget.product.productDocId);
      } catch (e) {
        print(e);
        print('did not find cart item');
      }
      if (item != null) {
        print('item != null');
        print(item.toMap());
        if (item.quantity + widget._quantity > widget.product.productStock && !widget.product.isInStock) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Out of stock", style: TextStyle(fontSize: 16)), backgroundColor: Theme.of(context).errorColor));
        } else {
          item.quantity = item.quantity + widget._quantity;
          print(item.toMap());
          Preferences.saveCartItems(cart);
          return ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Item updated in cart", style: TextStyle(fontSize: 16)), backgroundColor: Color(0xff0644e3)));
        }
      } else {
        print('item null');
        double price = double.parse(widget.product.offerPrice != null ? widget.product.offerPrice : widget.product.productPrice);
        CartItemModel cartItem = CartItemModel.fromMap({
          'price': price,
          'image': widget.product.productImageRef,
          'productID': widget.product.productDocId,
          'momOption': widget.product.momOption,
          'name': widget.product.productName,
          'quantity': widget._quantity,
          'catID': widget.product.cat,
          'storeId': widget.product.storeID,
          'subcatID': widget.product.subCat,
          'subtotal': widget._quantity * price,
          'description': widget.product.description,
          'productStock': widget.product.productStock,
          'isInStock': widget.product.isInStock
        });
        cart.items.add(cartItem);
        Preferences.saveCartItems(cart);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text("Item added to cart", style: TextStyle(fontSize: 16)), backgroundColor: Color(0xff0644e3)));
      }
    }
  }

  updateUserCart(UserModel userProfile) async {
    if (!await DataConnectionChecker().hasConnection) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
    } else {
      if (widget._quantity >= widget.product.productStock && !widget.product.isInStock) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: kSnackBarDuration,
          content: Text(
            "Out of stock",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Theme.of(context).errorColor,
        ));
      } else {
        final QuerySnapshot queryCheck = await FirebaseFirestore.instance.collection(users_collection).doc(userProfile.userId).collection('cart').where('productID', isEqualTo: widget.product.productDocId).limit(1).get();
        print(queryCheck.docs.length);
        if (queryCheck.docs.length != 0) {
          if ((queryCheck.docs[0].data() as Map)['quantity'] + widget._quantity > widget.product.productStock && !widget.product.isInStock) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: kSnackBarDuration,
              content: Text(
                "Out of stock",
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Theme.of(context).errorColor,
            ));
          } else {
            return queryCheck.docs[0].reference.update({
              'quantity': ((queryCheck.docs[0].data() as Map)['quantity'] + widget._quantity),
            }).then((value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: kSnackBarDuration,
                content: Text(
                  "Item updated in cart",
                  style: TextStyle(fontSize: 16),
                ),
                backgroundColor: Color(0xff0644e3),
              ));
            }).catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: kSnackBarDuration,
                content: Text(
                  "Please Check your internet connection.",
                  style: TextStyle(fontSize: 16),
                ),
                backgroundColor: Theme.of(context).errorColor,
              ));
            });
          }
        } else {
          double price = double.parse(widget.product.offerPrice != null ? widget.product.offerPrice : widget.product.productPrice);
          FirebaseFirestore.instance.collection(users_collection).doc(userProfile.userId).collection('cart').add({
            'price': price,
            'image': widget.product.productImageRef,
            'productID': widget.product.productDocId,
            'momOption': widget.product.momOption,
            'name': widget.product.productName,
            'quantity': widget._quantity,
            'catID': widget.product.cat,
            'storeId': widget.product.storeID,
            'subcatID': widget.product.subCat,
            'subtotal': widget._quantity * price,
            'description': widget.product.description,
            'productStock': widget.product.productStock,
            'isInStock': widget.product.isInStock,
          }).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: kSnackBarDuration,
              content: Text(
                "Item added to cart",
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Color(0xff0644e3),
            ));
          }).catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: kSnackBarDuration,
              content: Text(
                "Please Check your internet connection.",
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Theme.of(context).errorColor,
            ));
          });
        }
      }
    }
  }
}
