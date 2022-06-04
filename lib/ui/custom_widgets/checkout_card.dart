import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CheckoutCard extends StatelessWidget {
  double height;
  double width ;
  String hint;
  String label;
  int maxLine;
  TextEditingController controller;
  ValueChanged<String> onChange;
  final String email;
  CheckoutCard(
      {this.email,
      this.controller,
      this.hint,
      this.label,
      this.maxLine,
      this.onChange});
  @override
  Widget build(BuildContext context) {
    height=MediaQuery.of(context).size.height;
    width=MediaQuery.of(context).size.width;
    final node = FocusScope.of(context);
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 10,
            child: TextField(
              onChanged: onChange,
              maxLines: maxLine,
              controller: controller,
              onEditingComplete: () => node.nextFocus(),
              decoration: InputDecoration(
                hintText: hint,
                fillColor: Colors.white,
                labelText: label,
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // TextFieldWidget(
          //   hint: "Name",
          //   label: "Name",
          // ),
          // SizedBox(
          //   height: 10,
          // ),
          // TextFieldWidget(
          //   hint: "Number",
          //   label: "Number",
          // ),
          // SizedBox(
          //   height: 10,
          // ),
          // Text("E-Mail: " + email),
          // SizedBox(
          //   height: 10,
          // ),
          // TextFieldWidget(
          //   hint: "Email",
          //   label: "Email",
          // ),
        ],
      ),
    );
  }
}
