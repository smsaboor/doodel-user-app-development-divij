import 'package:flutter/cupertino.dart';

class HeadingWidget extends StatelessWidget {
  final String heading;
  final bool underline;

  HeadingWidget({this.heading, this.underline});

  @override
  Widget build(BuildContext context) {
    return Text(
      heading,
      style: TextStyle(
          decoration: underline ?? false ? TextDecoration.underline : TextDecoration.none,
          fontWeight: FontWeight.bold,
          fontSize: 16),
    );
  }
}
