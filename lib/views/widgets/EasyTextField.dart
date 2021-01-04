import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// @see https://qiita.com/mont_blanc/items/dc011a9935ccaf3db42e
class EasyTextField extends StatefulWidget {
  final String initialText; // 初期入力値

  EasyTextField({
    Key key,
    this.initialText,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EasyTextFieldState();
  }
}

class EasyTextFieldState extends State<EasyTextField> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(30),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
        ),
        child: TextFormField(
          controller: controller,
          decoration: new InputDecoration(
            hintText: "暗証番号4桁",
          ),
        ));
  }
}
