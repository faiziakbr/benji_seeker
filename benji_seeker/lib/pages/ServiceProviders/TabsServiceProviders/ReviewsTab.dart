import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/ProviderDetail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rating_bar/rating_bar.dart';

class ReviewsTab extends StatefulWidget {

  final Provider provider;

  ReviewsTab(this.provider);

  @override
  _ReviewsTabState createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: QuicksandText(widget.provider.rating != null ? "${widget.provider.rating.toStringAsFixed(1)}" : "0.0", 40, Colors.black, FontWeight.bold),
            title: Row(
              children: <Widget>[
                RatingBar.readOnly(
                  maxRating: 5,
                  filledIcon: Icons.star,
                  emptyIcon: Icons.star,
                  halfFilledIcon: Icons.star_half,
                  isHalfAllowed: true,
                  filledColor: starColor,
                  emptyColor: Colors.grey,
                  halfFilledColor: accentColor,
                  initialRating: widget.provider.rating != null ? widget.provider.rating : 0.0,
                  size: 20,
                ),
              ],
            ),
            subtitle: MontserratText("${widget.provider.totalRating.toStringAsFixed(0)} rating, ${widget.provider.totalReviews} review", 14,
                lightTextColor, FontWeight.normal,
                textAlign: TextAlign.start),
          ),
          rating(mediaQueryData, "Excellent", widget.provider.ratingStandard.ratingStandard5 / widget.provider.totalRating),
          rating(mediaQueryData, "Good", widget.provider.ratingStandard.ratingStandard4 / widget.provider.totalRating),
          rating(mediaQueryData, "Average", widget.provider.ratingStandard.ratingStandard3 / widget.provider.totalRating ),
          rating(mediaQueryData, "Bad", widget.provider.ratingStandard.ratingStandard2 / widget.provider.totalRating),
          rating(mediaQueryData, "Very Bad", widget.provider.ratingStandard.ratingStandard1 / widget.provider.totalRating),
          widget.provider.reviews.length > 0 ? MontserratText(
            "Customer Reviews:",
            20.0,
            Colors.black,
            FontWeight.w500,
            top: 16.0,
            left: mediaQueryData.size.width * 0.04,
            bottom: 8.0,
          ) : Container(),
          Expanded(
            child: MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: ListView.builder(
                  itemCount: widget.provider.reviews.length,
                  itemBuilder: (context, index) {
                    var review = widget.provider.reviews[index];
                    return itemReview(
                        mediaQueryData,
                        "${review.seekerName}",
                        "${DateFormat.yMMMMd().format(DateTime.parse(review.reviewedAt))}",
                        "${review.jobAddress}",
                        review.comment != null ? "${review.comment}" : "",
                        review.rating.toDouble());
                  }),
            ),
          )
        ],
      ),
    );
  }

  Widget rating(MediaQueryData mediaQueryData, String text, double fill) {
    if (fill.isNaN){
      fill = 0.0;
    }
    return Container(
      margin: EdgeInsets.only(
          left: mediaQueryData.size.width * 0.04,
          right: mediaQueryData.size.width * 0.04,
          top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          MontserratText(
            "$text",
            14,
            Colors.black,
            FontWeight.normal,
          ),
          Container(
            width: mediaQueryData.size.width * 0.4,
            margin: const EdgeInsets.only(left: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: LinearProgressIndicator(
                  value: fill,
                  backgroundColor: unfilledProgressColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    lightTextColor,
                  )),
            ),
          )
        ],
      ),
    );
  }

  Widget itemReview(MediaQueryData mediaQueryData, String name, String date,
      String address, String review, double rating) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: mediaQueryData.size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              MontserratText("$name", 16, accentColor, FontWeight.bold),
              MontserratText("$date", 14, lightTextColor, FontWeight.normal),
            ],
          ),
          Row(
            children: <Widget>[
              RatingBar.readOnly(
                maxRating: 5,
                filledIcon: Icons.star,
                emptyIcon: Icons.star,
                halfFilledIcon: Icons.star_half,
                isHalfAllowed: true,
                filledColor: starColor,
                emptyColor: Colors.grey,
                halfFilledColor: accentColor,
                initialRating: rating,
                size: 20,
              ),
            ],
          ),
          MontserratText("$address", 16, lightTextColor, FontWeight.normal, top: 4.0, bottom: 16.0,),
          MontserratText("$review", 16, lightTextColor, FontWeight.normal),
          Container(
            margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: unfilledProgressColor),
            height: 2.0,
          )
        ],
      ),
    );
  }
}
