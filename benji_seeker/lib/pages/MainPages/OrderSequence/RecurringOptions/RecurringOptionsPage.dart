import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/PackageModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecurringOptionsPage extends StatefulWidget {
  final CreateJobModel createJobModel;

  RecurringOptionsPage(this.createJobModel);

  @override
  _RecurringOptionsPageState createState() => _RecurringOptionsPageState();
}

class _RecurringOptionsPageState extends State<RecurringOptionsPage> {
  RecurringOptions _selectedOption;
  bool _showDatePickerSheet = false;
  bool _setDateComplete = false;

  @override
  void initState() {
//    if(widget.recurringOptions != null && widget.recurringOptions.length > 0) {
    _selectedOption = widget.createJobModel.setRecurringOptions[0];
    widget.createJobModel.isRecurringID = _selectedOption.id;
    widget.createJobModel.recurringText = _selectedOption.name;
//    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    DateTime endTime;
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
          actions: [
            IconButton(
              onPressed: () {
                widget.createJobModel.recurringText = "";
                widget.createJobModel.isRecurringID = "";
                widget.createJobModel.endTime = null;
                Navigator.pop(context, true);
              },
              icon: Icon(
                Icons.close,
                color: Colors.black,
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showDatePickerSheet = false;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                  top: 8.0,
                  left: mediaQueryData.size.width * 0.05,
                  right: mediaQueryData.size.width * 0.05),
              child: SingleChildScrollView(
                child: Column(
                  children: createRadioListUsers(mediaQueryData),
                ),
              ),
            ),
          ),
        ),
        bottomSheet: AnimatedContainer(
          duration: Duration(milliseconds: 1800),
          height: _showDatePickerSheet ? mediaQueryData.size.height * 0.35 : 0,
          width: mediaQueryData.size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.9),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              MontserratText(
                "Select end date",
                18,
                Colors.black,
                FontWeight.w600,
                top: 16.0,
                bottom: 16.0,
              ),
              Flexible(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  minimumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime value) {
                    endTime = DateTime(value.year, value.month, value.day);
                  },
                ),
              ),
              Container(
                  width: mediaQueryData.size.width * 0.35,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: MyDarkButton("Done", () {
                    setState(() {
                      _showDatePickerSheet = false;
                      _setDateComplete = true;
                    });
                    widget.createJobModel.endTime = endTime;
                  }))
            ],
          ),
        ));
  }

  _setSelectedOption(RecurringOptions recurringOptions) {
    setState(() {
      _selectedOption = recurringOptions;
      widget.createJobModel.isRecurringID = _selectedOption.id;
      widget.createJobModel.recurringText = _selectedOption.name;
    });
  }

  List<Widget> createRadioListUsers(MediaQueryData mediaQueryData) {
    List<Widget> widgets = [];
    for (RecurringOptions option in widget.createJobModel.setRecurringOptions) {
      widgets.add(
        Card(
          shape: RoundedRectangleBorder(
              side: BorderSide(color: accentColor, width: 1)),
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

    widgets.add(_customCard(
        mediaQueryData,
        context,
        "assets/recursive_icon.png",
        "END TIME",
        _setDateComplete
            ? "${DateFormat.yMd().format(widget.createJobModel.endTime)}"
            : "Set end time"));

    widgets.add(_confirmButton(mediaQueryData));
    return widgets;
  }

  Widget _customCard(MediaQueryData mediaQueryData, BuildContext context,
      String image, String title, String subTitle) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showDatePickerSheet = true;
        });
      },
      child: Card(
        margin: EdgeInsets.only(top: mediaQueryData.size.height * 0.05),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: accentColor, width: 1.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.only(top: 8.0),
              leading: Image.asset(
                image,
                width: mediaQueryData.size.width * 0.2,
                height: mediaQueryData.size.height * 0.15,
              ),
              title: MontserratText(title, 16, Colors.black, FontWeight.bold),
              subtitle:
                  MontserratText(subTitle, 16, separatorColor, FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmButton(MediaQueryData mediaQueryData) {
    return Container(
        width: mediaQueryData.size.width * 0.9,
        margin: EdgeInsets.only(top: mediaQueryData.size.height * 0.05),
        height: 50,
        child: MyDarkButton("Continue", () {
          print("ID: ${widget.createJobModel.isRecurringID}");
          if (widget.createJobModel.endTime != null)
            Navigator.pop(context, true);
          else
            MyToast("Set end time", context, position: 1);
        }));
  }
}
