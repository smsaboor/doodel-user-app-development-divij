import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doodeluser/grocerry_kit/sub_pages/guest_cart_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../grocerry_kit/sub_category_grid_view.dart';
import '../grocerry_kit/sub_pages/cartPage.dart';
import '../main.dart';
import '../providers/category.dart';
import '../providers/collection_names.dart';
import '../providers/user.dart';
import '../ui/search_page.dart';

class CategoryGridView extends StatefulWidget {
  final String storeDocId;
  CategoryGridView(this.storeDocId);
  @override
  _CategoryGridViewState createState() => _CategoryGridViewState();
}

class _CategoryGridViewState extends State<CategoryGridView> {
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
          actions: <Widget>[
            GestureDetector(
                onTap: () {
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
          title: Text('All Categories', style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        body: categoryItems(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue[800],
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchScreen(storeID: widget.storeDocId))),
          child: Icon(Icons.search, size: 30, color: Colors.white),
        ));
  }

  Widget categoryItems() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection(stores_collection).doc(widget.storeDocId).collection(category_collection).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final snapShotData = snapshot.data.docs;
            if (snapShotData.length == 0) {
              return Center(
                child: Text("No categories added"),
              );
            }
            return GridView.builder(
                itemCount: snapShotData.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (context, index) {
                  var data = snapShotData[index];
                  var category = Provider.of<Category>(context).convertToCategoryModel(data);
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return SubcategoryGridView(
                              categoryName: category.categoryName,
                              storeDocId: widget.storeDocId,
                              categoryDocid: category.categoryDocId,
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
                              imageUrl: category.categoryImageRef,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: devWidth * 0.35,
                            child: Text(
                              category.categoryName,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0644e3),
                              ),
                            ),
                          ),
                        ],
                      )
                    ]),
                  );
                });
          }),
    );
  }
}
