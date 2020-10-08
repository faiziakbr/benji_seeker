import 'package:benji_seeker/constants/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SortingDialog extends StatefulWidget {
  @override
  _SortingDialogState createState() => _SortingDialogState();
}

class _SortingDialogState extends State<SortingDialog> {
  int groupValue = -1;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                    onTap: () {
                      Get.back(result: -1);
                    },
                    child: Icon(Icons.close)),
              ),
              RadioListTile(
                onChanged: (value) {
                  setState(() {
                    groupValue = value;
                  });
                  Get.back(result: 0);
                },
                value: 0,
                groupValue: groupValue,
                title: RichText(
                  text: TextSpan(text: "Rating -", style: TextStyle(fontSize: 16, fontFamily: "Montserrat", color: separatorColor), children: [
                    TextSpan(text: " Low to High", style: TextStyle(fontSize: 12, fontFamily: "Montserrat", color: separatorColor))
                  ]),
                ),
              ),
              RadioListTile(
                onChanged: (value) {
                  setState(() {
                    groupValue = value;
                  });
                  Get.back(result: 1);
                },
                value: 1,
                groupValue: groupValue,
                title: RichText(
                  text: TextSpan(text: "Rating -", style: TextStyle(fontSize: 16, fontFamily: "Montserrat", color: separatorColor), children: [
                    TextSpan(text: " High to Low", style: TextStyle(fontSize: 12, fontFamily: "Montserrat", color: separatorColor))
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
