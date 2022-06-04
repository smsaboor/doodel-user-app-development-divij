import 'package:doodeluser/providers/search_results.dart';
import 'package:flutter/material.dart';

import '../grocerry_kit/sub_pages/guest_cart_page.dart';
import '../services/push_notification_service.dart';
import 'sub_pages/cartPage.dart';
import 'sub_pages/home_list.dart';

String storeID;
String nameStore;

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  static const routeName = "/storeHomepage";
  int isGuest;

  HomePage({this.storeDocId, this.storeName, this.isGuest});
  String storeDocId;
  String storeName;
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  SearchResults searchResultsProvider;
  @override
  void initState() {
    storeID = widget.storeDocId;
    nameStore = widget.storeName;
    PushNotificationService.initialise(context);
    // Future.delayed(Duration(milliseconds: 1500), () {
    //   // searchResultsProvider = Provider.of<SearchResults>(context, listen: false);
    //   // searchResultsProvider.getSearchResults(storeID);
    //   searchResultsProvider = context.read<SearchResults>()
    //     ..startListeningToProductsStream(widget.storeDocId);
    // });
    super.initState();
  }

  // @override
  // void dispose() {
  //   searchResultsProvider.stopListening();
  //   super.dispose();
  // }

  final PageController controller =
      PageController(initialPage: 0, keepPage: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        children: <Widget>[
          HomeList(widget.storeDocId, widget.isGuest),
          widget.isGuest != 1
              ? CartPage(
                  true,
                  widget.storeDocId,
                  isPagePushed: true,
                  controller: controller,
                )
              : GuestCartPage(
                  true,
                  widget.storeDocId,
                  isPagePushed: true,
                  controller: controller,
                ),
        ],
      ),
    );
  }
}
