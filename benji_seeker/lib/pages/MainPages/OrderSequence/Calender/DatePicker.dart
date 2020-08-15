import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart' show CalendarCarousel;

class DatePicker extends StatefulWidget {
  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  var _currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: null),
        title: MontserratText(
            "Select future date", 20, Colors.black, FontWeight.w500),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () {},
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CalendarCarousel<Event>(
                weekFormat: false,
                height: 420.0,
                selectedDateTime: _currentDate,
                onDayPressed: (DateTime date, List<Event> events){
                  setState(() {
                    _currentDate = date;
                  });
                },
                todayButtonColor: Colors.transparent,
                todayBorderColor: Colors.black,
                daysHaveCircularBorder: null,
                iconColor: separatorColor,
                showOnlyCurrentMonthDate: true,
                showHeaderButton: false,
                minSelectedDate: DateTime.now(),
                daysTextStyle: TextStyle(
                    color: Colors.black, fontFamily: "Montserrat", fontSize: 16),
                headerTextStyle: TextStyle(
                    color: Colors.black,
                    fontFamily: "Quicksand",
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
                isScrollable: true,
                weekendTextStyle: TextStyle(
                    color: Colors.black, fontFamily: "Montserrat", fontSize: 16),
                selectedDayTextStyle: TextStyle(
                    color: Colors.white,
                    fontFamily: "Montserrat",
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                weekdayTextStyle: TextStyle(
                    color: Colors.black,
                    fontFamily: "Montserrat",
                    fontSize: 14,
                    fontWeight: FontWeight.w300),
                todayTextStyle: TextStyle(
                    color: Colors.black, fontFamily: "Montserrat", fontSize: 16),
                inactiveWeekendTextStyle: TextStyle(
                    color: Colors.grey, fontFamily: "Montserrat", fontSize: 16),
                inactiveDaysTextStyle: TextStyle(
                    color: Colors.grey, fontFamily: "Montserrat", fontSize: 16),
              ),
              Container(
                width: mediaQueryData.size.width,
                height: 60,
                margin: EdgeInsets.only(
                    left: mediaQueryData.size.height * 0.05,
                    right: mediaQueryData.size.height * 0.05,
                    bottom: mediaQueryData.size.height * 0.01),
                child: RaisedButton(
                    color: accentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DatePicker()));
                    },
                    child: MontserratText(
                        "SAVE & CONTINUE", 14, Colors.white, FontWeight.w300)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
