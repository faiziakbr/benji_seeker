import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:flutter/material.dart';

class InputDialog extends StatefulWidget {
  final String title;
  final String inputTextLabel;
  final String hintText;
  final String btnText;

  InputDialog(this.title, this.inputTextLabel, this.hintText, this.btnText);

  @override
  _InputDialogState createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {

  TextEditingController _textEditingController = TextEditingController();
  bool _validate = false;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: dialogBackgroundColor,
      child: Container(
        width: mediaQueryData.size.width * 0.8,
        height: 200,
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            QuicksandText(widget.title, 20.0, Colors.white, FontWeight.bold,
                textAlign: TextAlign.center),
            MontserratText(
                widget.inputTextLabel, 16, Colors.white, FontWeight.normal),
            Container(
              margin: EdgeInsets.only(
                  left: mediaQueryData.size.width * 0.2,
                  right: mediaQueryData.size.width * 0.2),
              child: TextField(
                controller: _textEditingController,
                textAlign: TextAlign.center,
                cursorColor: Colors.white,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: lightTextColor),
                  errorText: _validate ? "Enter the Tip." : null
                ),
              ),
            ),
            Container(
                width: mediaQueryData.size.width * 0.5,
                child: MyDarkButton(widget.btnText, _sendTip))
          ],
        ),
      ),
    );
  }

  _sendTip() {
    if(_textEditingController.text.isEmpty) {
      setState(() {
        _textEditingController.text.isEmpty ? _validate = true : _validate =
        false;
      });
    }else {
      Navigator.pop(context, _textEditingController.text.toString());
    }
  }
}
