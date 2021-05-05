import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// @see https://qiita.com/mont_blanc/items/dc011a9935ccaf3db42e
class EasyTextField extends StatefulWidget {
  final String initialText; // 初期入力値
  final String hintText;
  EasyTextField({
    required Key key,
    required this.initialText,
    required this.hintText,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EasyTextFieldState(this.hintText);
  }
}

class EasyTextFieldState extends State<EasyTextField> {
  TextEditingController? controller;
  String hintText;

  EasyTextFieldState(this.hintText);

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    if(controller != null) {
      controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
        ),
        child: TextFormField(
          controller: controller,
          decoration: new InputDecoration(
            hintText: hintText,
          ),
        ));
  }
}
