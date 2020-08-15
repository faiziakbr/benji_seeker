import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class MyToast {
  String text;
  BuildContext context;
  int position;

  MyToast(this.text, this.context, {this.position = 0}) {
    if (position == 0)
      myToast(text, context);
    else
      bottomToast(text, context);
  }

  void myToast(String text, BuildContext context) {
    Fluttertoast.showToast(
        msg: "$text",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey.shade600,
        textColor: Colors.white,
        fontSize: 16.0
    );
//    Toast.show("$text", context,
//        duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
  }

  void bottomToast(String text, BuildContext context) {
    Fluttertoast.showToast(
        msg: "$text",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey.shade600,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}
