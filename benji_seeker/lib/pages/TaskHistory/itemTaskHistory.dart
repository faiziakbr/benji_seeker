import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/CompleteJobModel.dart';
import 'package:benji_seeker/pages/JobDetailPage/JobDetailPage.dart';
import 'package:benji_seeker/pages/JobDetailPage/NewJobDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class ItemWorkHistory extends StatelessWidget {
  final ItemCompletedModel itemCompletedModel;

  ItemWorkHistory(this.itemCompletedModel);

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(itemCompletedModel.when);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          shape: BoxShape.rectangle,
          border: Border.all(color: accentColor, width: 1)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NewJobDetailPage(itemCompletedModel.processId)));
        },
        child: ListTile(
          leading: Container(
            width: mediaQueryData.size.width * 0.13,
            height: mediaQueryData.size.width * 0.1,
            child: SvgPicture.network(
              "$BASE_URL_CATEGORY${itemCompletedModel.logo}",
              color: accentColor,
              fit: BoxFit.contain,
            ),
            margin: EdgeInsets.all(5.0),
          ),
          title: MontserratText("${itemCompletedModel.category}", 16,
              Colors.black, FontWeight.bold),
          subtitle: MontserratText(
              "${DateFormat.yMMMd().add_jm().format(dateTime.toLocal())}",
              14,
              lightTextColor,
              FontWeight.normal),
        ),
      ),
    );
  }
}
