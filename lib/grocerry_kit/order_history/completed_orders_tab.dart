import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../grocerry_kit/sub_pages/order_Page.dart';
import '../../providers/collection_names.dart';

class CompletedOrdersTab extends StatelessWidget {
  const CompletedOrdersTab(this.userID, {Key key}) : super(key: key);
  final String userID;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(completed_orders_Collection).where('userUid', isEqualTo: userID).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            final List<QueryDocumentSnapshot> orders = List.from(snapshot.data.docs);
            if (orders.length > 1) {
              orders.sort((QueryDocumentSnapshot a, QueryDocumentSnapshot b) {
                DateTime aDateTime, bDateTime;
                aDateTime = DateTime.parse('${(a.data() as Map)['dateTime'].split('T')[0]} ${(a.data() as Map)['dateTime'].split('T')[1]}');
                bDateTime = DateTime.parse('${(b.data() as Map)['dateTime'].split('T')[0]} ${(b.data() as Map)['dateTime'].split('T')[1]}');
                return bDateTime.compareTo(aDateTime);
              });
            }
            if (snapshot.data.docs.isEmpty) {
              return Center(child: Text('No Completed Order found'));
            }
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                DocumentSnapshot orderData = orders[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return OrderPage(orderData);
                    }));
                  },
                  child: Container(
                    height: 130,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 2), shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8), color: Colors.white70),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            (orderData.data() as Map)['storeName'] == null ? "" : (orderData.data() as Map)['storeName'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            (orderData.data() as Map)['dateTime'] == null ? "" : "Date: " + (orderData.data() as Map)['dateTime'].split('T').first + "    Time: " + (orderData.data() as Map)['dateTime'].split('T').last.split('.').first,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Order Id: ${(orderData.data() as Map)['orderID']}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        });
  }
}
