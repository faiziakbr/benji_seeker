import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/PackageModel.dart';
import 'package:benji_seeker/pages/CreateJobPages/EnterJobDetailPage.dart';
import 'package:flutter/material.dart';

class ItemPackagePage extends StatefulWidget {
  final MediaQueryData mediaQueryData;
  final int index;
  final int size;
  final double wage;
  final List<ItemPackage> _list;
  final CreateJobModel createJobModel;

  ItemPackagePage(this.mediaQueryData, this.index, this.size, this.wage,
      this._list, this.createJobModel);

  @override
  _ItemPackagePageState createState() => _ItemPackagePageState();
}

class _ItemPackagePageState extends State<ItemPackagePage>
    with SingleTickerProviderStateMixin {
  bool _showDetails = false;
  int _customHours = 0;
  FocusNode _focus = new FocusNode();

  var _controller = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.index == widget.size - 1
        ? _lastCustomPackage(widget.mediaQueryData)
        : Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MontserratText("${widget._list[widget.index].name}", 18,
                      separatorColor, FontWeight.bold),
                  MontserratText(
                      "Around ${widget._list[widget.index].hours.toStringAsFixed(1)} hrs",
                      14,
                      orangeColor,
                      FontWeight.normal),
                  MontserratText(
                    "${widget._list[widget.index].description}",
                    14,
                    separatorColor,
                    FontWeight.normal,
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  MyDarkButton(
                    _showDetails ? "Viewing" : "View Pricing",
                    () {
                      setState(() {
                        _showDetails = !_showDetails;
                      });
                    },
                    color: _showDetails ? lightSeparatorColor : separatorColor,
                  ),
                  AnimatedSize(
                      vsync: this,
                      duration: Duration(milliseconds: 200),
                      child: _showDetails
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    MontserratText(
                                      "\$${(widget._list[widget.index].hours * widget.wage).toStringAsFixed(2)}",
                                      52,
                                      separatorColor,
                                      FontWeight.bold,
                                      textAlign: TextAlign.start,
                                      top: 16.0,
                                    ),
                                    MontserratText(
                                      "approx.",
                                      16,
                                      separatorColor,
                                      FontWeight.normal,
                                      left: 8.0,
                                      bottom: 16.0,
                                    )
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                ),
                                MontserratText(
                                  "Price is exclusive of 2.9% and 30 cents for payment processing fee.",
                                  14,
                                  separatorColor,
                                  FontWeight.w600,
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                                Container(
                                    width:
                                        widget.mediaQueryData.size.width * 0.35,
                                    child: MyDarkButton(
                                      "CONFIRM",
                                      () {
                                        widget.createJobModel.taskId = widget._list[widget.index].id;
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EnterJobDetailPage(widget.createJobModel, widget._list[widget.index].name, )));
                                      },
                                    ))
                              ],
                            )
                          : Container())
                ],
              ),
            ),
          );
  }

  Widget _lastCustomPackage(MediaQueryData mediaQueryData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MontserratText(
              "Manual Estimate Job Hours",
              18,
              separatorColor,
              FontWeight.bold,
              bottom: 16.0,
            ),
            _showDetails
                ? TextField(
                    style: TextStyle(fontSize: 18),
                    cursorColor: accentColor,
                    focusNode: _focus,
                    keyboardType: TextInputType.number,
                    controller: _controller,
                    onChanged: (value) {
                      setState(() {
                        if (value.isNotEmpty)
                          _customHours = int.parse(value);
                        else
                          _customHours = 0;
                      });
                    },
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(8.0),
                        hintText: "Enter number of hours 1-10",
                        errorText:
                            _isValid ? "Estimate must be lesser than 11" : null,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50))),
                  )
                : MyDarkButton(
                    "View Pricing",
                    () {
                      print("INDEX: ${widget.index}");
                      setState(() {
                        _showDetails = !_showDetails;
                      });
                    },
                    color: separatorColor,
                  ),
            AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 200),
                child: _showDetails
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MontserratText(
                            "\$${(_customHours * widget.wage).toStringAsFixed(0)}",
                            52,
                            separatorColor,
                            FontWeight.bold,
                            textAlign: TextAlign.start,
                            top: 16.0,
                          ),
                          MontserratText(
                            "Price is exclusive of 2.9% and 30 cents for payment processing fee.",
                            14,
                            separatorColor,
                            FontWeight.w600,
                            top: 8.0,
                            bottom: 8.0,
                          ),
                          Container(
                            width: widget.mediaQueryData.size.width * 0.35,
                            child: MyDarkButton(
                              "CONFIRM",
                              () {
                                String text = _controller.text.toString();
                                if (text.isNotEmpty &&
                                    int.parse(text) > 0 &&
                                    int.parse(text) < 11) {
                                  setState(() {
                                    _isValid = false;
                                  });
                                  widget.createJobModel.estimatedTime = int.parse(_controller.text.toString());
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EnterJobDetailPage(widget.createJobModel, "job")));
                                } else {
                                  setState(() {
                                    _isValid = true;
                                  });

                                }
                              },
                            ),
                          ),
                          Container(
                            height: _focus.hasFocus
                                ? mediaQueryData.size.height * 0.15
                                : 0,
                          )
                        ],
                      )
                    : Container())
          ],
        ),
      ),
    );
  }
}
