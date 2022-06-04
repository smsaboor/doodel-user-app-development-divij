import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as latLng;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../const.dart';
import '../../grocerry_kit/model/address_model.dart';
import '../../main.dart';
import '../../packages/gmap_place_picker/gmap_place_picker.dart';
import '../../providers/collection_names.dart';
import '../../providers/store.dart';
import '../../providers/user.dart';
import '../../services/preferences.dart';
import '../../services/push_notification_service.dart';
import '../../utils/address_bottomsheet.dart';
import '../../utils/custom_drawer.dart';
import '../home_page.dart';

class StoresListPage extends StatefulWidget {
  static const routeName = "/StoresList";

  final int isGuest;

  StoresListPage({this.isGuest});

  @override
  _StoresListPageState createState() => _StoresListPageState();
}

class _StoresListPageState extends State<StoresListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Address guestAddress;
  bool hasNotified = false;

  @override
  void initState() {
    super.initState();
    guestAddress = Preferences.getGuestAddress();
    PushNotificationService.initialise(context);
  }

  Future<bool> _onWillPop() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Text('Do you want to exit the app?'),
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser>(context).userProfile;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: CustomDrawer(widget.isGuest),
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                  child: Icon(Icons.dehaze, color: Colors.white, size: 32)),
              Padding(
                padding: const EdgeInsets.only(left: 98.0),
                child: Text("Stores", style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ],
          ),
          backgroundColor: Color(0xff0644e3),
        ),
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: InkWell(
                    onTap: () async {
                      var customPin;
                      latLng.BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)), 'assets/images/store-pin.png').then((d) {
                        customPin = d;
                      });
                      final query = await FirebaseFirestore.instance.collection(stores_collection).get();
                      Set<latLng.Marker> markers = {};
                      Set<latLng.Circle> circles = {};
                      if (query.size > 0) {
                        query.docs.forEach((doc) {
                          Map docData = doc.data();
                          if (docData.containsKey('lat') && docData.containsKey('lng')) {
                            markers.add(latLng.Marker(
                              icon: customPin,
                              markerId: latLng.MarkerId(doc.id),
                              position: latLng.LatLng(docData['lat'], docData['lng']),
                              infoWindow: latLng.InfoWindow(title: docData['storeName']),
                            ));
                            if (docData['showRadius'] != false) {
                              circles.add(latLng.Circle(
                                strokeColor: Color(0xff0644e3),
                                fillColor: Color(0xff0644e3).withOpacity(0.15),
                                strokeWidth: 0,
                                circleId: latLng.CircleId(doc.id),
                                center: latLng.LatLng(docData['lat'], docData['lng']),
                                radius: (docData['deliveryRadius'] * 1000) / 1,
                              ));
                            }
                          }
                        });
                      }
                      PlaceInfo result = await openPlacePicker(
                        context,
                        mapsKey,
                        initialCenter: latLng.LatLng(user?.address?.lat ?? 59.85882, user?.address?.lng ?? 17.63889),
                        myLocationButtonEnabled: true,
                        layersButtonEnabled: true,
                        markers: markers,
                        circles: circles,
                        desiredAccuracy: LocationAccuracy.high,
                        countries: ['SE'],
                      );
                      if (result != null && result.address != null) {
                        String fAddress = await showAddressBottomSheet(context, result.address);
                        if (fAddress != null) {
                          if (widget.isGuest != 1) {
                            result.address = fAddress;
                            Provider.of<AppUser>(context, listen: false).updateUserAddress(result, user.userId);
                          } else {
                            guestAddress = Address(address: fAddress, lat: result.latLng.latitude, lng: result.latLng.longitude);
                            await Preferences.saveGuestAddress(guestAddress);
                          }
                          await Preferences.deleteUserStoreData();
                          setState(() => hasNotified = false);
                        }
                      }
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.isGuest != 1
                                ? (user?.address?.address == '' || user?.address?.address == null) ?? true
                                    ? 'Please select your delivery address to see the store near you'
                                    : '${user.address.address}'
                                : guestAddress == null
                                    ? 'Please select your delivery address to see the store near you'
                                    : '${guestAddress.address}',
                            style: TextStyle(color: Color(0xff0644e3), fontSize: 15),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Color(0xff0644e3)),
                          ),
                          child: Icon(
                            Icons.add_location,
                            size: 20,
                            color: Color(0xff0644e3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                widget.isGuest == 1 && guestAddress == null ? allStoresList() : NearbyStoresWidget(hasNotified: hasNotified, user: user, address: widget.isGuest == 1 ? guestAddress : user.address, isGuest: widget.isGuest),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget allStoresList() {
    return Expanded(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16, top: 4),
            child: Text(
              "Choose your favourite grocery store",
              maxLines: 4,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection(stores_collection).snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                      break;
                    default:
                      print(stores_collection);
                      if (snapshot.hasData) {
                        if (snapshot.data.docs.length > 0) {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              var data = snapshot.data.docs[index];
                              return _vehicleCard(data);
                            },
                            // itemCount: snapshot.data.documents.length > 5 ? 5 : snapshot.data.documents.length,
                            itemCount: snapshot.data.docs.length,
                          );
                        }
                      }
                      return Center(
                        child: Text("No Stores Added"),
                      );
                  }
                }),
          ),
        ],
      ),
    );
  }

  Widget _vehicleCard(DocumentSnapshot storeSnapshot) {
    StoreModel store = Provider.of<Store>(context).convertToStoreModel(storeSnapshot);
    UserModel userProfile = Provider.of<AppUser>(context).userProfile;
    return GestureDetector(
      onTap: () async {
        if (!await DataConnectionChecker().hasConnection) {
          ScaffoldMessenger.of(_scaffoldKey.currentContext).hideCurrentSnackBar();
          ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
          return;
        } else {
          if (widget.isGuest != 1) {
            try {
              await FirebaseFirestore.instance.collection(users_collection).doc(userProfile.userId).collection('cart').get().then((QuerySnapshot snapshot) {
                for (DocumentSnapshot doc in snapshot.docs) {
                  doc.reference.delete();
                }
              }).catchError((e) {
                print(e);
              });
            } catch (error) {
              print(error);
            }
          } else {
            await Preferences.deleteCartItems();
          }
          Provider.of<AppUser>(context, listen: false)
              .setUserStoreId(
            isGuest: widget.isGuest,
            storeDocId: store.storeDocId,
            storeName: store.storeName,
            storeId: store.storeId,
          )
              .then((value) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(storeName: store.storeName, storeDocId: store.storeDocId, isGuest: widget.isGuest)),
            );
          });
        }
      },
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: LayoutBuilder(builder: (ctx, cnst) {
          return Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: cnst.maxHeight,
                    width: cnst.maxWidth * 0.6,
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          store.storeName,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Color(0xffe6020a), fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              'Open from : ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                (store.startingTime == 0 && store.endingTime == 0) ? 'Closed' : '${store.startingTime}:00 - ${store.endingTime}:00',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${store.storeAddress}",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: cnst.maxWidth * 0.4,
                    height: cnst.maxWidth * 0.4,
                    child: store.storeImageRef != null
                        ? ClipRRect(
                            borderRadius: new BorderRadius.circular(24.0),
                            child: FadeInImage.assetNetwork(
                              fadeInDuration: const Duration(milliseconds: 100),
                              fadeOutDuration: const Duration(milliseconds: 100),
                              placeholder: 'assets/images/image_loading.gif',
                              fit: BoxFit.contain,
                              width: cnst.maxWidth * 0.4,
                              height: cnst.maxWidth * 0.4,
                              alignment: Alignment.topRight,
                              image: store.storeImageRef,
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.only(right: 25),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.navigate_next,
                              size: 50,
                            ),
                          ),
                  ),
                ],
              ));
        }),
      ),
    );
  }
}

// ignore: must_be_immutable
class NearbyStoresWidget extends StatefulWidget {
  NearbyStoresWidget({this.address, this.hasNotified, this.user, this.isGuest, Key key}) : super(key: key);
  final Address address;
  final UserModel user;
  final int isGuest;
  bool hasNotified;

  @override
  _NearbyStoresWidgetState createState() => _NearbyStoresWidgetState();
}

class _NearbyStoresWidgetState extends State<NearbyStoresWidget> {
  bool _isLoading = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> storeDocs = [];
  @override
  void initState() {
    super.initState();
    getAllStores();
  }

  @override
  void didUpdateWidget(NearbyStoresWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    getAllStores();
  }

  getAllStores() async {
    final query = await FirebaseFirestore.instance.collection(stores_collection).get();
    storeDocs.clear();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> temp = [];
    List<Map> maps = [];
    if (query.size > 0) {
      query.docs.forEach((doc) {
        Map docData = doc.data();
        if (docData.containsKey('lat') && docData.containsKey('lng') && docData.containsKey('deliveryRadius')) {
          final distance = new Distance();
          // final double km = distance.as(LengthUnit.Kilometer, LatLng(docData['lat'], docData['lng']), LatLng(widget.address.lat, widget.address.lng));
          final double meter = distance(LatLng(docData['lat'], docData['lng']), LatLng(widget.address.lat, widget.address.lng));
          final double storeRadius = (docData['deliveryRadius'] * 1000) / 1;
          if (storeRadius >= meter) {
            maps.add({
              'id': doc.id,
              'name': docData['storeName'],
              'distance': meter,
            });
            temp.add(doc);
          }
        }
      });
    }
    if (maps.length > 1) {
      maps.removeWhere((e) {
        bool desc = false;
        maps.forEach((x) {
          if (x['id'] != e['id']) {
            if (x['name'].toLowerCase().split(' ')[0] == e['name'].toLowerCase().split(' ')[0]) {
              if (x['distance'] < e['distance']) {
                desc = true;
              }
            }
          }
        });
        return desc;
      });
      maps.forEach((element) {
        storeDocs.add(temp.singleWhere((e) => element['id'] == e.id));
      });
    } else {
      storeDocs = temp.toList();
    }
    setState(() => _isLoading = false);
  }

  Widget storesList() {
    if (storeDocs.length > 0) {
      return ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          var data = storeDocs[index];
          return _vehicleCard(data);
        },
        itemCount: storeDocs.length,
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: widget.hasNotified
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Your request has been received. And we will try to add stores to your location as soon as possible. Thank you!", textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontSize: 17)),
                    SizedBox(height: 10),
                    Text("Try another location", textAlign: TextAlign.center, style: TextStyle(fontSize: 17)),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("No stores found near you. Try using a different location or notify us so that we can bring stores to your doorstep!", textAlign: TextAlign.center, style: TextStyle(fontSize: 17)),
                    //ignore: deprecated_member_use
                    RaisedButton(
                      child: Text('Notify'),
                      onPressed: () async {
                        if (widget.isGuest == 1) {
                          final userModel = UserModel(address: widget.address, email: '', name: 'Guest', userId: '', phoneNumber: '', phoneCode: '');
                          await FirebaseFirestore.instance.collection('locationRequests').doc().set(userModel.toMap());
                        } else {
                          await FirebaseFirestore.instance.collection('locationRequests').doc().set(widget.user.toMap());
                        }
                        setState(() => widget.hasNotified = true);
                      },
                    ),
                  ],
                ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16, top: 4),
            child: Text(
              "Choose your favourite grocery store",
              maxLines: 4,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          Expanded(child: _isLoading ? Center(child: CircularProgressIndicator()) : storesList()),
        ],
      ),
    );
  }

  Widget _vehicleCard(DocumentSnapshot storeSnapshot) {
    StoreModel store = Provider.of<Store>(context).convertToStoreModel(storeSnapshot);
    UserModel userProfile = Provider.of<AppUser>(context).userProfile;
    return GestureDetector(
      onTap: () async {
        if (!await DataConnectionChecker().hasConnection) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
          return;
        } else {
          if (widget.isGuest != 1) {
            try {
              await FirebaseFirestore.instance.collection(users_collection).doc(userProfile.userId).collection('cart').get().then((QuerySnapshot snapshot) {
                for (DocumentSnapshot doc in snapshot.docs) {
                  doc.reference.delete();
                }
              }).catchError((e) {
                print(e);
              });
            } catch (error) {
              print(error);
            }
          } else {
            await Preferences.deleteCartItems();
          }

          Provider.of<AppUser>(context, listen: false)
              .setUserStoreId(
            isGuest: widget.isGuest,
            storeDocId: store.storeDocId,
            storeName: store.storeName,
            storeId: store.storeId,
          )
              .then((value) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(storeName: store.storeName, storeDocId: store.storeDocId, isGuest: widget.isGuest)),
            );
          });
        }
      },
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: LayoutBuilder(builder: (ctx, cnst) {
          return Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: cnst.maxHeight,
                    width: cnst.maxWidth * 0.6,
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          store.storeName,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Color(0xffe6020a), fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              'Open from : ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                (store.startingTime == 0 && store.endingTime == 0) ? 'Closed' : '${store.startingTime}:00 - ${store.endingTime}:00',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${store.storeAddress}",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: cnst.maxWidth * 0.4,
                    height: cnst.maxWidth * 0.4,
                    child: store.storeImageRef != null
                        ? ClipRRect(
                            borderRadius: new BorderRadius.circular(24.0),
                            child: FadeInImage.assetNetwork(
                              fadeInDuration: const Duration(milliseconds: 100),
                              fadeOutDuration: const Duration(milliseconds: 100),
                              placeholder: 'assets/images/image_loading.gif',
                              fit: BoxFit.contain,
                              width: cnst.maxWidth * 0.4,
                              height: cnst.maxWidth * 0.4,
                              alignment: Alignment.topRight,
                              image: store.storeImageRef,
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.only(right: 25),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.navigate_next,
                              size: 50,
                            ),
                          ),
                  ),
                ],
              ));
        }),
      ),
    );
  }
}
