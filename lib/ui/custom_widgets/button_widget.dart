import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  final Function onPress;
  final String text;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  CustomButton({this.onPress, this.text, this.bgColor, this.borderColor, this.textColor});
  double height;
  double width ;
  @override
  Widget build(BuildContext context) {
    height=MediaQuery.of(context).size.height;
    width=MediaQuery.of(context).size.width;
    return Container(
      height: height * 0.050,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: MaterialButton(
        height: height * 0.050,
        // height: 58,
        // minWidth: 340,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5)),
        onPressed: onPress,
        child: Text(
          text,
          textScaleFactor: 1,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        color: bgColor,
      ),
    );
  }
}
