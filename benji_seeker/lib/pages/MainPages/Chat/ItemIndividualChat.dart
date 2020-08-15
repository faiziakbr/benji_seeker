import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class ItemIndividualChat extends StatelessWidget {
  final String processId;
  final String image;
  final String title;
  final String subTitle;
  final String time;
  final bool isSeen;
  final String messageBody;
  final String createdAt;

  ItemIndividualChat(this.processId, this.image, this.title, this.subTitle,
      this.time, this.isSeen, this.messageBody, this.createdAt);

  @override
  Widget build(BuildContext context) {
    String pic = "";
    if (image != null) pic = BASE_PROFILE_URL + image;
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    DateTime dateTime = DateTime.parse(time);
    DateTime dateTimeCreated = DateTime.parse(createdAt);

    return Card(
      color: !isSeen ? Colors.green[100] : Colors.white,
      child: Container(
        height: 110,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FadeInImage(
                      fit: BoxFit.cover,
                      width: 70,
                      height: 70,
                      placeholder: AssetImage("assets/placeholder.png"),
                      image: NetworkImage("$pic"),
                      imageErrorBuilder: (x,y,z){
                        return Container(
                            width: 70,
                            height: 70,
                            child: Image.asset("assets/placeholder.png")
                        );
                      },
                    ),
                  ),
                  Flexible(
                    child: Container(
                      width: 60,
                      child: MontserratText(
                        "$title",
                        16,
                        accentColor,
                        FontWeight.w600,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        top: 8.0,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: MontserratText(
                            "$subTitle",
                            16,
                            Colors.black,
                            FontWeight.bold,
                            left: 8.0,
                            bottom: 4.0,
                          ),
                        ),
                        DateTime.now().difference(dateTimeCreated).inDays < 1
                            ? MontserratText(
                          "${timeago.format(dateTimeCreated, locale: "en_short")}",
                          14,
                          lightTextColor,
                          FontWeight.normal,
                          textAlign: TextAlign.end,
                          bottom: 4.0,
                        )
                            : MontserratText(
                          "${DateFormat.d().add_MMM().add_Hm().format(dateTimeCreated.toLocal())}",
                          14,
                          lightTextColor,
                          FontWeight.normal,
                          textAlign: TextAlign.end,
                          bottom: 4.0,
                        ),
                      ],
                    ),
                    Flexible(
                      child: Container(
                        height: mediaQueryData.size.height * 0.2,
                        child: MontserratText("$messageBody", 16,
                            lightTextColor, FontWeight.normal,
                            maxLines: 2,
                            textOverflow: TextOverflow.ellipsis,
                            left: 8.0),
                      ),
                    ),
                    MontserratText(
                      "Job Date: ${DateFormat.yMMMMd().format(dateTime.toLocal())}",
                      16,
                      Colors.black.withOpacity(0.8),
                      FontWeight.w600,
                      top: 4.0,
                      left: 8.0,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
