import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../const.dart';
import '../../main.dart';
import '../../packages/gmap_place_picker/gmap_place_picker.dart';
import '../../providers/collection_names.dart';
import '../../providers/user.dart';
import '../../services/preferences.dart';
import '../../utils/address_bottomsheet.dart';
import '../store_package/stores_list_screen.dart';

class EditProfilePage extends StatefulWidget {
  static const routeName = "signupPage";

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _scacffoldKey = GlobalKey<ScaffoldState>();
  String _name;
  String _address;
  String _phoneNumber;
  String _phoneCode;
  double _lat, _lng;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final userProfile = Provider.of<AppUser>(context, listen: false).userProfile;
      // _name = userProfile.name;
      // _phoneCode = userProfile.phoneCode;
      // _phoneNumber = userProfile.phoneNumber;
      _address = userProfile.address.address;
      _lat = userProfile.address.lat;
      _lng = userProfile.address.lng;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel userProfile = Provider.of<AppUser>(context).userProfile;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 24)),
      ),
      key: _scacffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
            child: Container(
          height: MediaQuery.of(context).size.height - 50,
          child: Align(
            //alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: devWidth * 0.0389, right: devWidth * 0.0389, top: 8, bottom: 8),
                        child: TextFormField(
                          validator: (val) {
                            if (val.trim().length > 36) {
                              return "Name cannot be 36+ characters";
                            }
                            return val.trim().isEmpty ? "Name cannot be empty." : null;
                          },
                          onSaved: (val) {
                            _name = val.trim();
                          },
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: 18),
                          initialValue: userProfile.name,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            hintText: 'Name',
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ),
                      //Country Code
                      Padding(
                        padding: EdgeInsets.only(left: devWidth * 0.0389, right: devWidth * 0.0389, top: 8, bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 10.0),
                              width: devWidth * 0.20,
                              child: TextFormField(
                                validator: (val) {
                                  if (val.trim().length > 4) {
                                    return "Code cannot be 4+ characters";
                                  }
                                  return val.trim().isEmpty ? "Code cannot be empty." : null;
                                },
                                onSaved: (val) {
                                  _phoneCode = val.trim();
                                },
                                keyboardType: TextInputType.phone,
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                                initialValue: userProfile.phoneCode,
                                decoration: InputDecoration(
                                  hintText: 'Country Code',
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey)),
                                ),
                              ),
                            ),
                            //Phone Number
                            Container(
                              width: devWidth * 0.69,
                              child: TextFormField(
                                validator: (val) {
                                  if (val.trim().length > 16) {
                                    return "Number cannot be 16+ characters";
                                  }
                                  return val.trim().isEmpty ? "Number cannot be empty." : null;
                                },
                                onSaved: (val) {
                                  _phoneNumber = val.trim();
                                },
                                keyboardType: TextInputType.phone,
                                style: TextStyle(fontSize: 18),
                                initialValue: userProfile.phoneNumber,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                  hintText: 'Phone Number',
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: InkWell(
                          onTap: () async {
                            PlaceInfo result = await openPlacePicker(
                              context,
                              mapsKey,
                              initialCenter: LatLng(_lat ?? 59.85882, _lng ?? 17.63889),
                              // initialCenter: LatLng(59.85882, 17.63889),
                              myLocationButtonEnabled: true,
                              layersButtonEnabled: true,
                              desiredAccuracy: LocationAccuracy.high,
                              countries: ['SE'],
                            );
                            if (result != null && result.address != null) {
                              String fAddress = await showAddressBottomSheet(context, result.address);
                              if (fAddress != null) {
                                _address = fAddress;
                                _lat = result.latLng.latitude;
                                _lng = result.latLng.longitude;
                                setState(() {});
                              }
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _address == '' || _address == null ? 'Please select your delivery address to see the store near you' : '$_address',
                                  style: TextStyle(fontSize: 18),
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
                    ],
                  ),
                ),

                SizedBox(
                  height: 12,
                ),
                if (_isLoading) CircularProgressIndicator(),
                if (!_isLoading)
                  Container(
                    margin: EdgeInsets.only(top: devHeight * 0.0234, bottom: devHeight * 0.0234),
                    decoration: BoxDecoration(
                      color: Color(0xff0644e3),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    width: devWidth * 0.60827,
                    child: FlatButton(
                      child: Text('Save Changes', style: TextStyle(fontSize: 20, color: Colors.white)),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          //Only gets here if the fields pass
                          _formKey.currentState.save();
                          if (!await DataConnectionChecker().hasConnection) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: kSnackBarDuration, content: Text('Please check your internet connection'), backgroundColor: Theme.of(context).errorColor));
                          }
                          _signUp(context);
                        }
                      },
                    ),
                  ),
//                    SizedBox(
//                      height: 20,
//                    )
              ],
            ),
          ),
        )),
      ),
    );
  }

  void _signUp(BuildContext ctx) async {
    var useruid = Provider.of<AppUser>(ctx, listen: false).userProfile;
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance.collection(users_collection).doc(useruid.userId).update({
        'address': _address,
        'name': _name,
        'lat': _lat,
        'lng': _lng,
        "phoneNumber": _phoneNumber,
        "phoneCode": _phoneCode,
      });

      await Provider.of<AppUser>(context, listen: false).getCurrentUser(useruid.userId);
      await Preferences.deleteUserStoreData();
      Navigator.of(ctx).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => StoresListPage()), (Route<dynamic> route) => false);
    } on PlatformException catch (err) {
      var message = "An error has occured, please check your credentials.";

      if (err.message != null) {
        message = err.message;
      }

      _scacffoldKey.currentState.showSnackBar(SnackBar(
        duration: kSnackBarDuration,
        content: Text(
          message,
        ),
        backgroundColor: Theme.of(ctx).errorColor,
      ));

      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }
}
