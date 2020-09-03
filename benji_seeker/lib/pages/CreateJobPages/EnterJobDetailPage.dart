import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:benji_seeker/My_Widgets/DialogInfo.dart';
import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyLoadingDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/My_Widgets/Separator.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/JustStatusModel.dart';
import 'package:benji_seeker/pages/MainPages/OrderSequence/Calender/When.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

import '../BotNav.dart';
import 'AddLocationPage.dart';

class EnterJobDetailPage extends StatefulWidget {
  final CreateJobModel createJobModel;
  final String title;

  EnterJobDetailPage(this.createJobModel, this.title);

  @override
  _EnterJobDetailPageState createState() => _EnterJobDetailPageState();
}

class _EnterJobDetailPageState extends State<EnterJobDetailPage> {
  bool _isKeyboardVisible = false;
  DioHelper _dioHelper;
  bool _showInfo = true;

  bool _isAddLocationComplete = false;
  bool _whenToComplete = false;
  bool _showSomePicsComplete = false;
  bool _jobSpecificsComplete = false;

  List<CameraDescription> cameras;
  TextEditingController _controller = TextEditingController();
  List<File> _images;

  CreateJobModel _createJobModel;

  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    _createJobModel = widget.createJobModel;
    _initializeCamera();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          _isKeyboardVisible = visible;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: mediaQueryData.size.height,
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Visibility(
                      visible: _showInfo,
                      child: Container(
                        width: mediaQueryData.size.width,
                        height: mediaQueryData.size.height * 0.1,
                        padding: EdgeInsets.only(
                            left: mediaQueryData.size.width * 0.05,
                            right: mediaQueryData.size.width * 0.03),
                        color: separatorColor,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: QuicksandText(
                                "Lets find you someone to take care of your ${widget.title}.",
                                18,
                                Colors.white,
                                FontWeight.bold,
                                maxLines: 3,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                while (Navigator.canPop(context))
                                  Navigator.pop(context);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BotNavPage()));
                              },
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    _item(
                        mediaQueryData,
                        1,
                        true,
                        _isAddLocationComplete,
                        "Where?",
                        "Tell us where your lawn is located.",
                        "${widget.createJobModel.address}",
                        "ADD ADDRESS",
                        _btnClick),
                    _item(
                        mediaQueryData,
                        2,
                        _isAddLocationComplete,
                        _whenToComplete,
                        "When?",
                        "Tell us when you want your lawn mowed",
                        "${DateFormat.yMd().add_jm().format(widget.createJobModel.jobTime)} ${widget.createJobModel.endTime != null ? "Repeats ${widget.createJobModel.recurringText} till ${DateFormat.yMd().format(widget.createJobModel.endTime)}" : ""}",
                        "SET DATE & TIME",
                        _btnClick),
                    _item(
                        mediaQueryData,
                        3,
                        _whenToComplete,
                        _showSomePicsComplete,
                        "Show us some pictures",
                        "Upload at least three pictures of your lawn.",
                        "",
                        "UPLOAD PHOTOS",
                        _btnClick,
                        images: _images),
                    _item(
                        mediaQueryData,
                        4,
                        _showSomePicsComplete,
                        _jobSpecificsComplete,
                        "Tell us about this job",
                        "Tell us details & specifics about this job.",
                        "",
                        "ADD DESCRIPTION",
                        _btnClick)
                  ],
                ),
              ),
              Positioned(
                bottom: mediaQueryData.size.height * 0.02,
                child: Container(
                    height: 50,
                    width: mediaQueryData.size.width * 0.9,
                    margin: EdgeInsets.symmetric(
                        horizontal: mediaQueryData.size.width * 0.05),
                    child: _isKeyboardVisible
                        ? Container()
                        : MyDarkButton("SUBMIT", _btnSubmit)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _initializeCamera() async {
    cameras = await availableCameras();
  }

  void _btnSubmit() async {
    if (_images == null || _images.length < 3) {
      MyToast("Please select 3 images.", context, position: 1);
//      Navigator.pop(context);
      return;
    }
    if (_controller.text.isEmpty) {
      MyToast("Description is required.", context, position: 1);
//      Navigator.pop(context);
      return;
    }
    if (_isAddLocationComplete == false) {
      MyToast("Location is required.", context, position: 1);
//      Navigator.pop(context);
      return;
    }

    MyLoadingDialog(context, "Posting job...");

    FormData formData;
    if (widget.createJobModel.recurringDays != null &&
        widget.createJobModel.endTime != null) {
      if (widget.createJobModel.isRecurringSet) {
        if (!widget.createJobModel.jobTime
            .isBefore(widget.createJobModel.endTime)) {
          MyToast("Job end date can't be before the start", context);
          Navigator.pop(context);
          return;
        }
      }

      _createJobModel.emailDateLabel =
          "${DateFormat.EEEE().format(_createJobModel.jobTime)}, ${DateFormat.MMMM().add_d().format(_createJobModel.jobTime)}, ${DateFormat.y().add_jm().format(_createJobModel.jobTime)} (Local)";

      print("EMAIL DATE LABEL ${_createJobModel.emailDateLabel}");
      formData = FormData.fromMap({
        "sub_category_id": _createJobModel.categoryId,
        _createJobModel.estimatedTime != null ? "estimated_time" : "task_id":
            _createJobModel.estimatedTime != null
                ? _createJobModel.estimatedTime
                : _createJobModel.taskId,
        "time": "${DateFormat("E MMM d y hh:mm:ss", Locale(Intl.getCurrentLocale()).languageCode).format(_createJobModel.jobTime)} GMT${DateTime.now().timeZoneOffset.inHours}00",
        "latitude": _createJobModel.latitude,
        "longitude": _createJobModel.longitude,
        "full_address": _createJobModel.address,
        "description": _controller.text.toString(),
        "email_date_label": _createJobModel.emailDateLabel,
        "recurring": widget.createJobModel.recurringDays,
        "end_date": "${DateFormat("E MMM d y hh:mm:ss", Locale(Intl.getCurrentLocale()).languageCode).format(_createJobModel.endTime)} GMT${DateTime.now().timeZoneOffset.inHours}00",
        "place_id": _createJobModel.placeId
      });
    } else {
      _createJobModel.emailDateLabel =
      "${DateFormat.EEEE().format(_createJobModel.jobTime)}, ${DateFormat.MMMM().add_d().format(_createJobModel.jobTime)}, ${DateFormat.y().add_jm().format(_createJobModel.jobTime)} (Local)";
      formData = FormData.fromMap({
        "sub_category_id": _createJobModel.categoryId,
        _createJobModel.estimatedTime != null ? "estimated_time" : "task_id":
            _createJobModel.estimatedTime != null
                ? _createJobModel.estimatedTime
                : _createJobModel.taskId,
        "time": "${DateFormat("E MMM d y hh:mm:ss", Locale(Intl.getCurrentLocale()).languageCode).format(_createJobModel.jobTime)} GMT${DateTime.now().timeZoneOffset.inHours}00",
        "latitude": _createJobModel.latitude,
        "longitude": _createJobModel.longitude,
        "full_address": _createJobModel.address,
        "description": _controller.text.toString(),
        "email_date_label": _createJobModel.emailDateLabel,
        "place_id": _createJobModel.placeId
      });
    }

    var list = formData.files;

    _images.forEach((element) {
      list.add(MapEntry(
          "pictures", MultipartFile.fromFileSync(element.absolute.path)));
    });

    _dioHelper
        .postFormRequest(BASE_URL + URL_CREATE_JOB, {"token": ""}, formData)
        .then((value) {
      Navigator.pop(context);
      print("UPCOMING JOBS: ${value.data}");
      JustStatusModel justStatusModel =
          justStatusResponseFromJson(json.encode(value.data));

      if (justStatusModel.status) {
//        MyToast("Job created successfully", context, position: 1);
//        while (Navigator.canPop(context)) {
//          Navigator.pop(context);
//        }
//        Navigator.pushReplacement(
//            context, MaterialPageRoute(builder: (context) => BotNavPage()));
        showDialog(
          context: context,
          builder: (_) => DialogInfo(
            "assets/start_job.png",
            "Congratulation",
            "Task added to your Task Calendar.",
          ),
        );

        Timer(const Duration(seconds: 3), () {
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => BotNavPage()));
        });
      } else {
        MyToast("${justStatusModel.errors[0]}", context, position: 1);
      }
    }).catchError((error) {
      Navigator.pop(context);
      try {
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          JustStatusModel justModel =
              justStatusResponseFromJson(json.encode(err.response.data));
          MyToast("${justModel.errors[0]}", context, position: 1);
        } else {
          MyToast("${err.message}", context, position: 1);
        }
      } catch (e) {
        MyToast("Unexpected Error!", context, position: 1);
      }
    });
  }

  void _btnClick(int index) async {
    if (index == 1) {
      _showPlacePicker();
    }

    if (index == 2) {
      var result = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => When(widget.createJobModel)));
      if (result != null && result) {
        setState(() {
          _whenToComplete = true;
        });
      }
    }

    if (index == 3) {
      _getImages();
    }
  }

  void _showPlacePicker() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddLocationPage(widget.createJobModel)));
    if (result) {
      print("ADDRESS IS: ${widget.createJobModel.address}");
      setState(() {
        _isAddLocationComplete = true;
      });
    }
  }

  Future _getImages() async {
    FocusScope.of(context).requestFocus(FocusNode());
    List<File> files = await FilePicker.getMultiFile(
        type: FileType.custom,
        allowCompression: true,
        allowedExtensions: ["jpg", "jpeg", "png"]);

    if (files.length > 2 && files != null)
      setState(() {
        _images = files;
        _showSomePicsComplete = true;
      });
    else {
      MyToast("You need to select more than 3 images.", context, position: 1);
    }
  }

  Widget _item(
      MediaQueryData mediaQueryData,
      int index,
      bool itemActive,
      bool itemDone,
      String title,
      String description,
      String completedText,
      String btnText,
      Function btnClick,
      {List<File> images}) {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: mediaQueryData.size.width * 0.05),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(
                          top: mediaQueryData.size.height * 0.03),
                      child: QuicksandText(
                          "$title",
                          22,
                          itemActive ? Colors.black : disableTextColor,
                          FontWeight.bold)),
                  index == 3 && itemDone
                      ? Stack(
                          overflow: Overflow.visible,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Image.file(
                                  _images[0],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                Image.file(
                                  _images[1],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                Image.file(
                                  _images[2],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                            images != null && images.length > 3
                                ? Positioned(
                                    right: -35,
                                    bottom: 10,
                                    top: 10,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      child: CircleAvatar(
                                        child: MontserratText(
                                            "+${images.length - 3}",
                                            16,
                                            orangeColor,
                                            FontWeight.bold),
                                        backgroundColor: Colors.black,
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        )
                      : index == 4
                          ? Container(
                              width: mediaQueryData.size.width * 0.9,
                              child: TextField(
                                enabled: _showSomePicsComplete,
                                controller: _controller,
                                decoration:
                                    InputDecoration(hintText: description),
                              ))
                          : Container(
                              width: mediaQueryData.size.width * 0.8,
                              margin: EdgeInsets.only(
                                  top: mediaQueryData.size.height * 0.005),
                              child: MontserratText(
                                itemDone ? "$completedText" : "$description",
                                16,
                                itemActive ? lightTextColor : disableTextColor,
                                FontWeight.w400,
                              ),
                            ),
                  !itemDone && itemActive && index != 4
                      ? Container(
                          margin: EdgeInsets.only(
                              top: mediaQueryData.size.height * 0.005),
                          child: RaisedButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            color: accentColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            onPressed: () => btnClick(index),
                            child: MontserratText(
                                "$btnText", 14, Colors.white, FontWeight.w500),
                          ),
                        )
                      : Container(),
                ],
              ),
              itemDone && index != 4
                  ? Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => btnClick(index),
                          child: MontserratText(
                            "Edit",
                            16,
                            orangeColor,
                            FontWeight.bold,
                            underline: true,
                            top: 16.0,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8.0),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: accentColor, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white),
                          child: Icon(
                            Icons.check,
                            color: accentColor,
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
          index != 4 ? Separator() : Container()
        ],
      ),
    );
  }
}
