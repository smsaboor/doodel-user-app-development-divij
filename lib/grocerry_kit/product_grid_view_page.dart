import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../grocerry_kit/detailedProductPage.dart';
import '../grocerry_kit/sub_pages/cartPage.dart';
import '../grocerry_kit/sub_pages/guest_cart_page.dart';
import '../grocerry_kit/sub_pages/home_list.dart';
import '../main.dart';
import '../providers/product.dart';
import '../providers/user.dart';
import '../ui/search_page.dart';

class ProductGridView extends StatefulWidget {
  final String categoryDocid;
  final String subcatID;
  final String subcatName;
  final String catName;
  final String storeID;
  final bool hasSubcatID;

  ProductGridView({this.categoryDocid, this.subcatID, this.subcatName, this.catName, this.storeID, @required this.hasSubcatID});
  @override
  _ProductGridViewState createState() => _ProductGridViewState();
}

class _ProductGridViewState extends State<ProductGridView> {
  ScrollController _scrollController = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          // ignore: deprecated_member_use
          brightness: Brightness.dark,
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
          title: Container(
            height: 50,
            // width: 220,
            width: MediaQuery.of(context).size.width / 1.7,
            child: Scrollbar(
              controller: _scrollController,
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: [
                    Center(
                      child: Text(widget.catName == "" ? widget.subcatName : widget.catName, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Provider.of<AppUser>(context, listen: false).userProfile == null ? GuestCartPage(true, widget.storeID) : CartPage(true, widget.storeID);
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
        body: Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: Container(
            child: categoryItems(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue[800],
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchScreen(storeID: widget.storeID, categoryDocid: widget.categoryDocid, subcatID: widget.subcatID, subcatName: widget.subcatName))),
          child: Icon(Icons.search, size: 30, color: Colors.white),
        ));
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

  Widget categoryItems() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: devWidth * 0.048),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: widget.hasSubcatID ? FirebaseFirestore.instance.collection('groceryShops').doc(widget.storeID).collection('categoryCollection').doc(widget.categoryDocid).collection('subCategory').doc(widget.subcatID).collection('products').where('subcatID', isEqualTo: widget.subcatID).snapshots() : FirebaseFirestore.instance.collection('groceryShops').doc(widget.storeID).collection('categoryCollection').doc(widget.categoryDocid).collection('subCategory').doc(widget.subcatID).collection('products').where('catID', isEqualTo: widget.categoryDocid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final snapShotData = snapshot.data.docs;
            if (snapShotData.length == 0) {
              return Center(
                child: Text("No products added"),
              );
            }
            return GridView.builder(
                itemCount: snapShotData.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.55,
                ),
                itemBuilder: (context, index) {
                  var data = snapshot.data.docs[index];
                  ProductModel product = Provider.of<Product>(context).convertToProductModel(data);
                  return Container(
                    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return DetailedProductPage(storeId: widget.storeID, catId: widget.categoryDocid, subcatName: widget.subcatID, id: product.productDocId);
                          }));
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.center,
                          width: 120,
                          height: 120,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: FadeInImage.assetNetwork(
                                  fadeInDuration: const Duration(milliseconds: 100),
                                  fadeOutDuration: const Duration(milliseconds: 100),
                                  width: 120,
                                  height: 120,
                                  placeholder: 'assets/images/image_loading.gif',
                                  fit: BoxFit.fill,
                                  image: product.productImageRef,
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
                                              child: Text('OUT OF STOCK', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(14, allowFontScalingSelf: true), fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        )
                                      : product.offerPrice != null
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
                                                height: ScreenUtil().setHeight(30),
                                                width: double.infinity,
                                                color: Colors.green,
                                                child: Center(
                                                  child: Text('LIMITED OFFER', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(14, allowFontScalingSelf: true), fontWeight: FontWeight.bold)),
                                                ),
                                              ),
                                            )
                                          : SizedBox()
                                  : product.offerPrice != null
                                      ? Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
                                            height: ScreenUtil().setHeight(30),
                                            width: double.infinity,
                                            color: Colors.green,
                                            child: Center(
                                              child: Text('LIMITED OFFER', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(14, allowFontScalingSelf: true), fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Container(
                        height: 45,
                        width: 110,
                        alignment: Alignment.topCenter,
                        child: Text(
                          product.productName,
                          softWrap: false,
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                          // minFontSize: 12,
                        ),
                      ),
                      if (product.productPrice != '') PriceContainer2(product, widget.storeID),
                    ]),
                  );
                });
          }),
    );
  }
}
