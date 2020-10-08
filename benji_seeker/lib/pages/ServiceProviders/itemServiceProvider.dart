import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/BiddersModel.dart';
import 'package:benji_seeker/pages/ServiceProviders/ServiceProviderDetail.dart';
import 'package:flutter/material.dart';

class ItemServiceProvider extends StatelessWidget {
  final Bidder bidder;
  final String jobId;

  ItemServiceProvider(this.bidder, this.jobId);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
           Navigator.push(context,
              MaterialPageRoute(builder: (context) => ServiceProviderDetail(bidder.providerId, jobId)));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FadeInImage(
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70,
                  placeholder: AssetImage("assets/placeholder.png"),
                  image: NetworkImage("$BASE_PROFILE_URL${bidder.profilePicture}"),
                  imageErrorBuilder: (x, y, z) {
                    return Container(
                        width: 55,
                        height: 55,
                        child: Image.asset("assets/placeholder.png"));
                  },
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          MontserratText(
                            "${bidder.name}",
                            16,
                            Colors.black,
                            FontWeight.bold,
                            top: 8.0,
                            bottom: 8.0,
                            left: 8.0,
                          ),
                          MontserratText(
                              "", 14, lightTextColor, FontWeight.w200,
                              bottom: 8.0, left: 8.0),
                          Container(
                            margin: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                            child: Row(
                              children: [
                                bidder.rating != null ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    MontserratText(
                                      "${bidder.rating.toStringAsFixed(1)}",
                                      10.0,
                                      Colors.black,
                                      FontWeight.bold,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: starColor,
                                      size: 15,
                                    )
                                  ],
                                ) : Container(),
                                _separator(),
                                MontserratText("${bidder.totalJobs} Jobs Done", 10, accentColor,
                                    FontWeight.w600,
                                    left: 8.0),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
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

  Widget _separator() {
    return SizedBox(
      height: 20,
      width: 2.0,
      child: Container(
        color: Colors.black12,
      ),
    );
  }
}
