import 'package:auto_size_text/auto_size_text.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:flutter/material.dart';

class ItemEstimate extends StatelessWidget {
  final String radioGroup;
  final MediaQueryData mediaQueryData;
  final String mainText;
  final String subText;
  final String time;
  final bool isClientEstimate;
  List<int> hours = List();
  bool selected = true;

  ItemEstimate(this.radioGroup, this.mediaQueryData, this.mainText,
      this.subText, this.time,
      {this.isClientEstimate = false});

  @override
  Widget build(BuildContext context) {
    for (int i = 1; i <= 24; i++) {
      hours.add(i);
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: InkWell(
        onTap: (){
          //TODO not working radio button check it later
          selected = true;
        },
        child: Card(
          elevation: 4.0,
          child: Container(
            margin: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Radio(
                  value: selected,
                  groupValue: radioGroup,
                  onChanged: (value){
                    selected = value;
                  },
                ),
                isClientEstimate
                    ? Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AutoSizeText(
                      mainText,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0 * mediaQueryData.textScaleFactor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                    Container(
                      width: mediaQueryData.size.width * 0.65,
                      child: DropdownButton(
                        items:
                        hours.map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          );
                        }).toList(),
                        isExpanded: true,
                        onChanged: (value) {}, hint: Text("Select hours"),),
                    )
                  ],
                ),)
                    : Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: AutoSizeText(
                              mainText,
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0 *
                                      mediaQueryData.textScaleFactor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ),
                            flex: 2,
                          ),
                          Expanded(
                            child: AutoSizeText(
                              time,
                              style: TextStyle(
                                  color: orangeColor,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0 *
                                      mediaQueryData.textScaleFactor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                            flex: 1,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      AutoSizeText(
                        subText,
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize:
                            12.0 * mediaQueryData.textScaleFactor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


