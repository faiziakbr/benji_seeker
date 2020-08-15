import 'package:benji_seeker/My_Widgets/CustomProgressDialog.dart';
import 'package:flutter/material.dart';

class MyLoadingDialog {
  MyLoadingDialog(BuildContext context, String text) {
    showDialog(
        context: context,
        barrierDismissible: bool.fromEnvironment("dismiss dialog"),
        builder: (BuildContext context) {
          return CustomProgressDialog("$text");
        });
  }
}
