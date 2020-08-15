import 'dart:convert';

import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/HelpModel.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class GetHelpPage extends StatefulWidget {
  @override
  _GetHelpPageState createState() => _GetHelpPageState();
}

class _GetHelpPageState extends State<GetHelpPage> {
  DioHelper _dioHelper;
  bool _isLoading = true;
  bool _isError = false;
  List<FAQItem> faqs = [];
  int selected = -1;
  @override
  void initState() {
    _dioHelper = DioHelper.instance;

    _dioHelper.getRequest(BASE_URL + URL_HELP, null).then((result) {
      HelpModel helpModel = helpModelresponseFromHelp(json.encode(result.data));
      faqs = [];
      if (helpModel.status) {
        for (FAQ faq in helpModel.faqs) {
          FAQItem faqItem = FAQItem(false, faq.question, faq.answer);
          faqs.add(faqItem);
        }
      } else {
        setState(() {
          _isError = true;
        });
      }
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      var err = error as DioError;
      if (err.type == DioErrorType.RESPONSE) {
        var errorResponse = helpModelresponseFromHelp(json.encode(err.response.data));
        MyToast("${errorResponse.error[0]}", context);
      } else
        MyToast("${err.message}", context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  stops: [0.4, 0.8],
                  colors: [Colors.white, Colors.green[100]],
                  begin: Alignment.topLeft,
                  end: Alignment.topRight),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: QuicksandText("Get Help", 22, Colors.black, FontWeight.bold),
//          actions: <Widget>[
//            IconButton(
//              icon: Icon(
//                Icons.search,
//                color: Colors.black,
//              ),
//              onPressed: () {},
//            )
//          ],
        ),
        body: SafeArea(
          child: Container(
              height: mediaQueryData.size.height,
              margin: EdgeInsets.only(
                  top: 8.0,
                  left: mediaQueryData.size.width * 0.02,
                  right: mediaQueryData.size.width * 0.02),
              child: _isLoading && !_isError
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : _isError
                  ? MontserratText("Error occurred.", 18,
                  Colors.black.withOpacity(0.4), FontWeight.normal)
                  : ListView.builder(
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    FAQItem faqItem = faqs[index];
                    return ExpansionTile(
                      title: MontserratText("${faqItem.header}", 16,
                          Colors.black, FontWeight.normal),
                      children: <Widget>[
                        MontserratText(
                          "${faqItem.body}",
                          16,
                          lightTextColor,
                          FontWeight.normal,
                          left: mediaQueryData.size.width * 0.05,
                          right: mediaQueryData.size.width * 0.05,
                          bottom: 16.0,
                        )
                      ],

                    );
                  })
//                    : SingleChildScrollView(
//                        child: ExpansionPanelList(
//                          expansionCallback: (int index, bool isExpanded) {
//                            setState(() {
//                              faqs[index].isExpanded = !faqs[index].isExpanded;
//                              for (int i = 0; i < faqs.length; i++) {
//                                if (index != i) faqs[i].isExpanded = false;
//                              }
//                            });
//                          },
//                          children: faqs.map((FAQItem faq) {
//                            return ExpansionPanel(
//                                canTapOnHeader: true,
//                                isExpanded: faq.isExpanded,
//                                headerBuilder:
//                                    (BuildContext context, bool isExpanded) {
//                                  return Container(
//                                      alignment: Alignment.centerLeft,
//                                      child: MontserratText("${faq.header}", 16,
//                                          Colors.black, FontWeight.normal, left: 8.0,));
//                                },
//                                body: Container(
//                                    child: MontserratText(
//                                  "${faq.body}",
//                                  16,
//                                  lightTextColor,
//                                  FontWeight.normal,
//                                  left: 8.0,
//                                  bottom: 8.0,
//                                  right: 16.0,
//                                )));
//                          }).toList(),
//                        ),
//                      ),

//          child: SingleChildScrollView(
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                MontserratText(
//                  "Browse help topics",
//                  20,
//                  Colors.black,
//                  FontWeight.w500,
//                  top: 8.0,
//                  bottom: 16.0,
//                ),
//                ItemGetHelp("Popular Questions"),
//                ItemGetHelp("Payment method"),
//                ItemGetHelp("Offers & Promotions"),
//                ItemGetHelp("Identification & vertification"),
//                ItemGetHelp("Cancellation"),
//                MontserratText(
//                  "All topics",
//                  20,
//                  Colors.black,
//                  FontWeight.w500,
//                  top: 8.0,
//                  bottom: 16.0,
//                ),
//                ItemGetHelp("Get started"),
//                ItemGetHelp("Booking"),
//                ItemGetHelp("Your plan"),
//                ItemGetHelp("Your account"),
//                ItemGetHelp("Become a service provider"),
//                ItemGetHelp("Community"),
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceAround,
//                  children: <Widget>[
//                    MontserratText(
//                        "Still need help?", 16, Colors.black, FontWeight.bold),
//                    MyDarkButton("Contact us", () {
//                      Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: (context) => ContactUsPage()));
//                    })
//                  ],
//                )
//              ],
//            ),
//          ),
          ),
        ));
  }
}

class FAQItem {
  bool isExpanded;
  final String header;
  final String body;

  FAQItem(this.isExpanded, this.header, this.body);
}
