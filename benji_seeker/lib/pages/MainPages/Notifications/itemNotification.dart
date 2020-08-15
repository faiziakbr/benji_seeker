import 'package:benji_seeker/My_Widgets/Separator.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class ItemNotification extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final String image;

  ItemNotification(this.title, this.message, this.time, this.image);

  @override
  Widget build(BuildContext context) {
    String pic = "";
    if (image != null) pic = BASE_PROFILE_URL + image;
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    DateTime dateTime = DateTime.parse(time);
    String timeAgo = timeago.format(dateTime, locale: "en_short");
    String formattedTimeAgo = timeAgo.replaceAll(' ', '');
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Container(
              margin: EdgeInsets.only(
                  top: 16.0,
                  left: mediaQueryData.size.width * 0.05,
                  right: mediaQueryData.size.width * 0.05),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FadeInImage(
                              fit: BoxFit.cover,
                              width: 55,
                              height: 55,
                              placeholder: AssetImage("assets/placeholder.png"),
                              image: NetworkImage("$pic"),
                              imageErrorBuilder: (x, y, z) {
                                return Container(
                                    width: 55,
                                    height: 55,
                                    child:
                                    Image.asset("assets/placeholder.png"));
                              },
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              QuicksandText(
                                "$title",
                                16,
                                accentColor,
                                FontWeight.bold,
                                left: 8.0,
                              ),
                              Container(
                                width: mediaQueryData.size.width * 0.57,
                                child: MontserratText(
                                  "$message",
                                  14,
                                  lightTextColor,
                                  FontWeight.normal,
                                  left: 8.0,
                                  top: 4.0,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      DateTime.now().difference(dateTime).inDays < 1
                          ? Flexible(
                        child: MontserratText(
                          formattedTimeAgo != 'now'
                              ? "$formattedTimeAgo ago"
                              : "$formattedTimeAgo",
                          14,
                          lightTextColor,
                          FontWeight.normal,
                          textAlign: TextAlign.end,
                        ),
                      )
                          : Flexible(
                        child: MontserratText(
                          "${DateFormat.d().add_MMM().add_Hm().format(dateTime.toLocal())}",
                          14,
                          lightTextColor,
                          FontWeight.normal,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                  Separator(topMargin: 16.0)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

