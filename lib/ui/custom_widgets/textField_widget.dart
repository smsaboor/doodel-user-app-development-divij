import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  final String label;
  final String hint;
  final bool pass;
  final ValueChanged<String> onChange;
  final TextInputType inputType;
  IconButton icon;

  TextFieldWidget({this.hint, this.label, this.onChange, this.pass, this.icon, this.inputType = TextInputType.text});

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  TextEditingController controller = TextEditingController(text: '+');
  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    return Card(
      elevation: 10,
      child: TextFormField(
          obscureText: widget.pass ?? false,
          onChanged: widget.onChange,
          validator: (v) {
            if (widget.label == 'E-Mail') {
              if (!v.contains('@')) return 'Please Enter Valid Email';
            }
            if (v.length == 0) {
              return 'Please Fill This Field';
            }
            if (widget.label == 'Password') {
              if (v.length < 6) {
                return 'Password must be atleast 6 character long';
              }
            }
            return null;
          },
          onEditingComplete: () => node.nextFocus(),
          controller: 'code' == widget.label ? controller : null,
          keyboardType: 'Mobile Number' == widget.label || 'code' == widget.label ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(suffixIcon: widget.icon, hintText: widget.hint, fillColor: Colors.white, labelText: widget.label, border: OutlineInputBorder())),
    );
  }
}
