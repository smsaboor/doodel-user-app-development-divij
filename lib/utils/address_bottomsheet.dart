import 'package:flutter/material.dart';

import '../ui/custom_widgets/textField_widget.dart';

Future<String> showAddressBottomSheet(BuildContext _, String pAddress) async {
  return await showModalBottomSheet(
      context: _,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0))),
      builder: (context) {
        return AddressSheet(pAddress: pAddress);
      });
}

class AddressSheet extends StatefulWidget {
  const AddressSheet({this.pAddress, Key key}) : super(key: key);
  final String pAddress;

  @override
  _AddressSheetState createState() => _AddressSheetState();
}

class _AddressSheetState extends State<AddressSheet> {
  String doorNo = '';
  String doorErr = '';
  // String xtraInfo = '';
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 20, bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'Add additional information',
                style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                // getCompleteAddress(doorNo, widget.pAddress, xtraInfo),
                getCompleteAddress(doorNo, widget.pAddress),
                style: TextStyle(color: Color(0xff0644e3), fontSize: 15),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextFieldWidget(
                label: "Door/Apt No.",
                hint: "Door/Apt No.",
                onChange: (v) {
                  setState(() {
                    doorNo = v.trim();
                    if (doorErr.isNotEmpty) {
                      doorErr = '';
                    }
                  });
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 20,
              child: Text(
                doorErr,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.only(left: 10, right: 10),
            //   child: TextFieldWidget(
            //     label: "Extra information like portkod etc.",
            //     hint: "Extra information like portkod etc.",
            //     onChange: (v) {
            //       setState(() {
            //         xtraInfo = v.trim();
            //       });
            //     },
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 25, bottom: 5),
              child: Container(
                width: double.infinity,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(30),
                ),
                // ignore: deprecated_member_use
                child: FlatButton(
                  onPressed: () {
                    // doorErr = doorNo.isNotEmpty ? '' : 'Door no is required field';
                    // setState(() {});
                    // if (doorErr.isEmpty) {
                    // Navigator.of(context).pop(getCompleteAddress(doorNo, widget.pAddress, xtraInfo));
                    Navigator.of(context).pop(getCompleteAddress(doorNo, widget.pAddress));
                    // }
                  },
                  child: Center(
                      child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // String getCompleteAddress(String door, String address, String extra) {
  String getCompleteAddress(String door, String address) {
    // if (extra.isNotEmpty) {
    //   extra = ', ' + extra;
    // }
    String d = door;
    if (door.isNotEmpty) {
      d = door + ', ';
    }
    // return d + address + extra;
    return d + address;
  }
}
