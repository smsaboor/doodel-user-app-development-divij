import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../grocerry_kit/product_grid_view_page.dart';
import '../grocerry_kit/sub_pages/cartPage.dart';
import '../providers/collection_names.dart';
import '../providers/subCategory.dart';
import '../providers/user.dart';
import 'sub_pages/guest_cart_page.dart';

class SubcategoryGridView extends StatefulWidget {
  final String storeDocId;
  final String categoryDocid;
  final String categoryName;

  SubcategoryGridView({@required this.storeDocId, @required this.categoryDocid, @required this.categoryName});

  @override
  _SubcategoryGridViewState createState() => _SubcategoryGridViewState();
}

class _SubcategoryGridViewState extends State<SubcategoryGridView> {
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
                    child: Text('${widget.categoryName}', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18)),
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
                  return Provider.of<AppUser>(context, listen: false).
                  userProfile == null ? GuestCartPage(true, widget.storeDocId) : CartPage(true, widget.storeDocId);
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
      body: Container(
        child: categoryItems(),
      ),
    );
  }

  Widget categoryItems() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection(stores_collection).doc(widget.storeDocId).collection(category_collection).doc(widget.categoryDocid).collection('subCategory').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final snapShotData = snapshot.data.docs;
            if (snapShotData.length == 0) {
              return Center(
                child: Text("No subcategories."),
              );
            }
            return GridView.builder(
                itemCount: snapShotData.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (context, index) {
                  var data = snapshot.data.docs[index];
                  SubCategory subCategory = SubCategory.fromDocument(data);
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ProductGridView(
                              catName: '',
                              categoryDocid: subCategory.catID,
                              storeID: subCategory.storeID,
                              subcatName: subCategory.name,
                              subcatID: subCategory.id,
                              hasSubcatID: true,
                            );
                          }));
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
                              imageUrl: subCategory.imageURL,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Container(
                          width: 110,
                          alignment: Alignment.topCenter,
                          child: Text(
                            subCategory.name,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0644e3),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  );
                });
          }),
    );
  }
}
