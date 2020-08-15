import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/PackageModel.dart';
import 'package:flutter/material.dart';

class RecurringOptionsPage extends StatefulWidget {

  final CreateJobModel createJobModel;

  RecurringOptionsPage(this.createJobModel);

  @override
  _RecurringOptionsPageState createState() => _RecurringOptionsPageState();
}

class _RecurringOptionsPageState extends State<RecurringOptionsPage> {
  RecurringOptions _selectedOption;

  @override
  void initState() {
//    if(widget.recurringOptions != null && widget.recurringOptions.length > 0) {
      _selectedOption = widget.createJobModel.setRecurringOptions[0];
//    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
            onPressed: null),
        title: MontserratText(
            "Set recurring", 20, Colors.black, FontWeight.w500),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(
              top: 8.0,
              left: mediaQueryData.size.width * 0.05,
              right: mediaQueryData.size.width * 0.05),
          child: Column(
            children: createRadioListUsers(),
          ),
        ),
      ),
    );
  }

  _setSelectedOption(RecurringOptions recurringOptions) {
    setState(() {
      _selectedOption = recurringOptions;
    });
  }

  List<Widget> createRadioListUsers() {
    List<Widget> widgets = [];
    for (RecurringOptions option in widget.createJobModel.setRecurringOptions) {
      widgets.add(
        Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: accentColor, width: 1)
          ),
          child: RadioListTile(
            value: option,
            groupValue: _selectedOption,
            title: Text(option.name),
            onChanged: (option) {
              print("Option ${option.name}");
              _setSelectedOption(option);
            },
            selected: _selectedOption == option,
            activeColor: Colors.green,
          ),
        ),
      );
    }
    return widgets;
  }
}
