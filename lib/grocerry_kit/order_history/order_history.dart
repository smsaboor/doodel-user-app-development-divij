import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user.dart';
import 'completed_orders_tab.dart';
import 'ongoing_orders_tab.dart';

class OrderHistory extends StatefulWidget {
  static const routeName = "/orderHistory";

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> with TickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, initialIndex: 0, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    UserModel userProfile = Provider.of<AppUser>(context).userProfile;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xff0644e3),
        title: Text(
          'Order History',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TabBar(controller: tabController, onTap: (v) {}, tabs: [
            const Tab(
                child: Text(
              'Ongoing Orders',
              style: TextStyle(color: Colors.black),
            )),
            const Tab(
                child: Text(
              'Completed Orders',
              style: TextStyle(color: Colors.black),
            )),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                OngoingOrdersTab(userProfile.userId),
                CompletedOrdersTab(userProfile.userId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
