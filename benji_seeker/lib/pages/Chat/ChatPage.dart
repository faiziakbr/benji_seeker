import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';

import 'package:benji_seeker/My_Widgets/Separator.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/ChatModel.dart';
import 'package:benji_seeker/models/JobDetailModel.dart';
import 'package:benji_seeker/models/ProviderDetail.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:string_validator/string_validator.dart';

class ChatPage extends StatefulWidget {
  final String processId;
  final JobDetailModel jobDetailModel;
  final bool fromJobPage;
  final String providerName;

  ChatPage(this.processId, this.jobDetailModel, {this.fromJobPage = false, this.providerName = ""});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  ScrollController _scrollController = ScrollController();
  var platform = MethodChannel('samples.flutter.dev/battery');
  DioHelper _dioHelper;
  bool _isLoading = true;
  bool _isError = false;
  bool _showDate = true;
  var _previousDate;
  var _currentDate;
  List<ItemChatModel> _chat = [];

  AsyncMemoizer _memoizer = AsyncMemoizer<ChatModel>();

  TextEditingController _controller = TextEditingController();
  JobDetailModel _jobDetailModel;
  DateTime dateTime;
  bool _loadFullScreen = false;
  Provider _provider;

  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    _jobDetailModel = widget.jobDetailModel;
    _loadFullScreen = widget.fromJobPage;

    WidgetsBinding.instance.addObserver(this);

    if (widget.fromJobPage) {
      _dioHelper.getRequest(BASE_URL + URL_JOB_DETAIL(widget.processId),
          {"token": ""}).then((result) {
        print("JOB DETAIL: ${result.data}");
        _jobDetailModel = jobDetailResponseFromJson(json.encode(result.data));
        if (_jobDetailModel.status) {
          _fetchProviderDetail(_jobDetailModel.detail.providerId);
          dateTime = DateTime.parse(_jobDetailModel.detail.when);

        } else {
          _jobDetailModel = jobDetailResponseFromJson(json.encode(result.data));

        }
        if (_jobDetailModel.status) {
          _loadChat();
        }
      }).catchError((error) {
        try {
          var err = error as DioError;
          if (err.type == DioErrorType.RESPONSE) {
            var errorResponse =
                jobDetailResponseFromJson(json.encode(err.response.data));
            MyToast("${errorResponse.errors[0]}", context, position: 1);
          } else
            MyToast("${err.message}", context, position: 1);

          setState(() {
            _isError = true;
          });
        } catch (e) {
          setState(() {
            _isError = true;
          });
        }
      });
    } else {
      dateTime = DateTime.parse(_jobDetailModel.detail.when);
      _loadChat();
    }

    platform.setMethodCallHandler((call) async {
      if (call.method == "socketConnected") {
        await _addUser();
        await _startListeningForMessages();
      }
      if (call.method == "listenForMessages") {
        print("LISTEN TO MESSAGES");
        await _listenToMessages(widget.processId);
      }
      if (call.method == "receiveMessage") {
        var data = call.arguments;
//        [{"sender":"seeker","seen":false,"_id":"5e73b4d1379eeb1eb42bc4b4","created_at":"2020-03-19T18:07:13.295Z","process_id":"JB71029CX","message_body":"kilhhhbh"}]
        try {
          if (!isJson(data)) {
            MessagesArray messageArray =
                MessagesArray.fromJson(json.decode(json.encode(data)));

            ItemChatModel itemChatModel = ItemChatModel(
                sender: messageArray.messages[0].sender,
                id: messageArray.messages[0].id,
                createdAt: messageArray.messages[0].createdAt,
                processId: messageArray.messages[0].processId,
                messageBody: messageArray.messages[0].messageBody);

            setState(() {
              _chat.add(itemChatModel);
            });
            Timer(const Duration(milliseconds: 100), () {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
              _controller.clear();
            });
          } else {
            var array = json.decode(data.toString());
            print("MESSAGE ARRAY: $array");
            var object = array[0];
            print("MESSAGE OBJECT: $object");
            String sender = object['sender'];
            bool isSeen = object['seen'];
            String id = object['_id'];
            String createdAt = object['created_at'];
            String processId = object['process_id'];
            String messageBody = object['message_body'];

            ItemChatModel itemChatModel = ItemChatModel(
                sender: sender,
                id: id,
                createdAt: createdAt,
                processId: processId,
                messageBody: messageBody);

            setState(() {
              _chat.add(itemChatModel);
            });
            Timer(const Duration(milliseconds: 100), () {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
              _controller.clear();
            });
          }
        } catch (e) {
          print("ERROR: $e");
        }
      } else {
        print("METHOD CALLED: ${call.method}");
      }
      return;
    });

    Timer(const Duration(seconds: 2), () {
      _connectSocket();
      _isSocketConnected();
    });
    super.initState();
  }

  _fetchProviderDetail(String providerId) {
    _dioHelper.getRequest(BASE_URL + URL_PROVIDER_DETAIL(providerId),
        {"token": ""}).then((value) {
      ProviderDetail providerDetail =
      providerDetailResponseFromJson(json.encode(value.data));
      if (providerDetail.status) {
        _provider = providerDetail.provider;
        setState(() {
          _loadFullScreen = false;
        });
      } else {
        MyToast("${providerDetail.errors[0]}", context, position: 1);
        setState(() {
          _loadFullScreen = false;
          _isError = true;
        });
      }
    }).catchError((error) {
      try {
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          ProviderDetail providerDetail =
          providerDetailResponseFromJson(json.encode(err.response.data));
          MyToast("${providerDetail.errors[0]}", context, position: 1);
        } else {
          MyToast("${err.message}", context, position: 1);
        }
        setState(() {
          _isError = true;
        });
      } catch (e) {
        setState(() {
          _isError = true;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _leaveChatRoom();
      _closeSocket();
    } else if (state == AppLifecycleState.resumed) {
      Timer(const Duration(seconds: 1), () {
        _connectSocket();
        _isSocketConnected();
        _reloadChat();
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  void _loadChat() {
    _getChatResponse(widget.processId).then((model) {
      setState(() {
        _isLoading = false;
        if (model.status) {
          _chat = model.itemChatModel;
          if (_chat.length > 0) {
            Timer(const Duration(milliseconds: 100), () {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            });
          }
        } else {
          _isError = true;
        }
      });
    });
  }

  void _reloadChat() {
    DioHelper dioHelper = DioHelper.instance;

    dioHelper.getRequest(BASE_URL + URL_MESSAGES(widget.processId),
        {"token": ""}).then((result) {
      var model = responseFromChatJson(json.encode(result.data));
      if (model.status) {
        setState(() {
          _isError = false;
          _chat = model.itemChatModel;
        });
        print("GOT DATA IN CHAT: ${_chat.length}");
        if (_chat.length > 0) {
          Timer(const Duration(milliseconds: 100), () {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          });
        }
      } else {
        setState(() {
          _isError = true;
        });
      }
    }).catchError((error) {
      setState(() {
        _isError = true;
      });
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });

//    _getChatResponse(widget.processId).then((result) {
//      print("CHAAT PROCESS ID: ${widget.processId}");
//      setState(() {
//        print("CHAT RAN ***********");
//        if (result.status) {
//          _chat = result.itemChatModel;
//          print("GOT DATA IN CHAT: ${_chat.length}");
//          if (_chat.length > 0) {
//            Timer(const Duration(milliseconds: 100), () {
//              _scrollController
//                  .jumpTo(_scrollController.position.maxScrollExtent);
//            });
//          }
//        } else {
//          print("CHAT RAN BUT ERROR***********");
//          _isError = true;
//        }
//      });
//    });
  }

  Future<void> _connectSocket() async {
    try {
      await platform.invokeMethod('connectSocket');
    } on PlatformException catch (e) {
      print("Failed ${e.toString()}");
    }
  }

  Future<void> _addUser() async {
    try {
      SavedData savedData = SavedData();
      String token = await savedData.getValue(TOKEN);
      await platform.invokeMethod('addUserForSocket', {"token": token});
    } on PlatformException catch (e) {
      print("Failed ${e.toString()}");
    }
  }

  Future<void> _startListeningForMessages() async {
    try {
      await platform.invokeMethod('startListeningToMessages');
    } on PlatformException catch (e) {
      print("Failed ${e.toString()}");
    }
  }

  Future<void> _leaveChatRoom() async {
    try {
      await platform
          .invokeMethod('leaveChatRoom', {"processId": widget.processId});
    } on PlatformException catch (e) {
      print("Failed ${e.toString()}");
    }
  }

  Future<void> _closeSocket() async {
    try {
      await platform.invokeMethod('closeSocket');
    } on PlatformException catch (e) {
      print("Failed ${e.toString()}");
    }
  }

  Future<void> _isSocketConnected() async {
    try {
      await platform.invokeMethod('isSocketConnected');
    } on PlatformException catch (e) {
      print("Failed ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: _loadFullScreen && !_isError
          ? Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ))
          : _isError
              ? Container(
                  color: Colors.white,
                  child: Center(
                    child: MontserratText("${_jobDetailModel.errors[0]}", 18,
                        Colors.black.withOpacity(0.4), FontWeight.normal),
                  ),
                )
              : Scaffold(
                  appBar: AppBar(
                    backgroundColor: accentColor,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        QuicksandText(
                          _provider != null ? "${_provider.nickName}" : "${widget.providerName}",
                          18,
                          Colors.white,
                          FontWeight.bold,
                          bottom: 8.0,
                        ),
                        Row(
                          children: <Widget>[
                            Image.asset(
                              "assets/white_location_icon.png",
                              width: 12,
                              height: 12,
                            ),
                            Flexible(
                              child: MontserratText(
                                "${_jobDetailModel.detail.where}",
                                12,
                                Colors.white,
                                FontWeight.w500,
                                textOverflow: TextOverflow.ellipsis,
                                left: 8.0,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
//        actions: <Widget>[
//          IconButton(
//            icon: Icon(
//              Icons.call,
//              color: Colors.white,
//            ),
//            onPressed: () {},
//          ),
//          IconButton(
//            icon: Icon(
//              Icons.tune,
//              color: Colors.white,
//            ),
//            onPressed: () {},
//          ),
//        ],
                    bottom: PreferredSize(
                      preferredSize:
                          Size.fromHeight(mediaQueryData.size.height * 0.12),
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(
                            left: mediaQueryData.size.width * 0.07,
                            top: 8,
                            bottom: 8,
                            right: mediaQueryData.size.width * 0.04),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              "assets/lawn_moving.png",
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                            ),
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 24.0, top: 8.0, bottom: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    MontserratText(
                                      "${_jobDetailModel.detail.subCategory}",
                                      16,
                                      Colors.black,
                                      FontWeight.bold,
                                      textOverflow: TextOverflow.ellipsis,
                                    ),
                                    MontserratText(
                                        "${DateFormat.yMMMd().add_jm().format(dateTime.toLocal())}",
                                        14,
                                        lightTextColor,
                                        FontWeight.normal),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  body: SafeArea(
                    child: Container(
                      margin: EdgeInsets.only(
                          top: 16.0,
                          left: mediaQueryData.size.width * 0.02,
                          right: mediaQueryData.size.width * 0.02),
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : _isError
                              ? Center(
                                  child: MontserratText("Error loading Chat!",
                                      18, Colors.black, FontWeight.normal),
                                )
                              : Column(
                                  children: <Widget>[
                                    _chat.length > 0
                                        ? Expanded(
                                            child: ListView.builder(
                                                controller: _scrollController,
                                                physics:
                                                    BouncingScrollPhysics(),
                                                itemCount: _chat.length,
                                                itemBuilder: (context, index) {
                                                  var data = _chat[index];
                                                  if (data.sender ==
                                                      'provider') {
                                                    return _chatItem(
                                                        mediaQueryData,
                                                        data,
                                                        true,
                                                        index);
                                                  } else {
                                                    return _chatItem(
                                                        mediaQueryData,
                                                        data,
                                                        false,
                                                        index);
                                                  }
                                                }),
                                          )
                                        : Expanded(
                                            child: Center(
                                            child: Opacity(
                                              opacity: 0.8,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  SvgPicture.asset(
                                                      "assets/speech_bubble.svg",
                                                      width: 60,
                                                      height: 60),
                                                  MontserratText(
                                                      "Start Chat!",
                                                      22,
                                                      Colors.black
                                                          .withOpacity(0.8),
                                                      FontWeight.normal)
                                                ],
                                              ),
                                            ),
                                          )),
//              Expanded(
//                child: FutureBuilder<ChatModel>(
//                  future: _getChatResponse(widget.processId),
//                  builder: (context, snap) {
//                    switch (snap.connectionState) {
//                      case ConnectionState.none:
//                        return Center(child: Text("No Internet"));
//                      case ConnectionState.waiting:
//                        return Center(child: CircularProgressIndicator());
//                      case ConnectionState.active:
//                      case ConnectionState.done:
//                        if (snap.hasError) {
//                          print("ERROR: ${snap.error}");
//                          return Center(
//                              child: MontserratText("Error loading messages",
//                                  22, Colors.black, FontWeight.normal));
//                        }
//                        _chat = snap.data.itemChatModel;
//                        if (_chat != null && _chat.length > 0) {
//                          Timer(
//                              Duration(milliseconds: 1000),
//                              () => _scrollController.jumpTo(
//                                  _scrollController.position.maxScrollExtent));
//                          return ListView.builder(
//                              controller: _scrollController,
//                              physics: BouncingScrollPhysics(),
//                              itemCount: _chat.length,
//                              itemBuilder: (context, index) {
//                                var data = _chat[index];
//                                if (data.fromUserId == _myId) {
//                                  return _chatItem(mediaQueryData, data, false);
//                                } else {
//                                  return _chatItem(mediaQueryData, data, true);
//                                }
//                              });
//                        } else
//                          return Center(
//                            child: MontserratText("Start chat with client.", 22,
//                                Colors.black, FontWeight.normal),
//                          );
//                    }
//                    return Container();
//                  },
//                ),
//              ),
                                    _typeMessageUI(mediaQueryData)
                                  ],
                                ),
                    ),
                  ),
                ),
    );
  }

  Widget _chatItem(MediaQueryData mediaQueryData, ItemChatModel data,
      bool isReceived, int index) {
    DateTime dateTime = DateTime.parse(data.createdAt);
    _currentDate = DateFormat.yMMMd().format(dateTime.toLocal());

    if (index == 0) {
//      setState(() {
      _showDate = true;
      _previousDate = _currentDate;
//      });
    } else if (_previousDate != _currentDate) {
      print("prev Data: $_previousDate, _currentData: $_currentDate");
      _previousDate = _currentDate;
//      setState(() {
      _showDate = true;
//      });
    } else {
//      setState(() {
      _showDate = false;
//      });
    }

    return Column(
      children: <Widget>[
        _showDate
            ? Align(
                alignment: Alignment.center,
                child: Container(
                  child: MontserratText(
                      "$_currentDate", 8, Colors.white, FontWeight.normal),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: separatorColor),
                  padding: const EdgeInsets.all(8.0),
                ),
              )
            : Container(),
        Container(
          width: mediaQueryData.size.width,
          margin: isReceived
              ? EdgeInsets.only(
                  top: 8.0, bottom: 8.0, right: mediaQueryData.size.width * 0.2)
              : EdgeInsets.only(
                  top: 8.0, bottom: 8.0, left: mediaQueryData.size.width * 0.2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isReceived ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                child: MontserratText(
                    "${data.messageBody}", 16, navBarColor, FontWeight.normal),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: unfilledProgressColor),
                padding: const EdgeInsets.all(8.0),
              ),
              MontserratText(
                "${DateFormat.d().add_MMM().add_Hm().format(dateTime.toLocal())}",
                12,
                separatorColor,
                FontWeight.normal,
                top: 4.0,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _typeMessageUI(MediaQueryData mediaQueryData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Column(
        children: <Widget>[
          Separator(bottomMargin: 8.0),
          Row(
            children: <Widget>[
//              CircleAvatar(
//                backgroundColor: orangeColor,
//                child: Icon(
//                  Icons.add,
//                  color: whiteColor,
//                ),
//              ),
              Container(
                margin: EdgeInsets.only(left: 8.0),
                width: mediaQueryData.size.width * 0.92,
                padding: EdgeInsets.only(left: 16.0),
                decoration: BoxDecoration(
                  color: textFieldBackgroundColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: TextField(
                  enableInteractiveSelection: false,
                  controller: _controller,
                  cursorColor: accentColor,
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                        color: lightTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        fontFamily: "Montserrat"),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        if (_controller.text.isNotEmpty) {
                          Detail detailModel = _jobDetailModel.detail;

                          var now = new DateTime.now();
                          var dateFormatted =
                              DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
                                  .format(now);
                          ItemChatModel itemChatModel = ItemChatModel(
                              createdAt: dateFormatted,
                              messageBody: _controller.text.toString(),
                              sender: 'seeker');
                          _emitMessage(
                              widget.processId, _controller.text.toString());
                          setState(() {
                            _chat.add(itemChatModel);
//                            _controller.text = "";
                          });
                          Timer(const Duration(milliseconds: 100), () {
                            _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent);
                            _controller.clear();
                          });
                        }
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<ChatModel> _getChatResponse(String processId) async {
    SavedData savedData = new SavedData();
    String token = await savedData.getValue(TOKEN);
    Dio dio = new Dio();

    Options options = new Options(headers: {"token": token});

    return _memoizer.runOnce(() async {
      final response =
          await dio.get(BASE_URL + URL_MESSAGES(processId), options: options);

//      print("RESPONSE: ${response.data}");
      if (response.statusCode == HttpStatus.ok)
        return responseFromChatJson(json.encode(response.data));
      else
        return ChatModel();
    });
  }

  Future<void> _emitMessage(String processId, String messageBody) async {
    _postSendMessage(processId, messageBody).then((model) {
//      MyToast("MEssage Sent", context);
//      if (model.status) {
//        ItemChatModel itemChatModel = ItemChatModel(
//            "messageID${DateTime.now()}",
//            dateFormatted,
//            processId,
//            _jobDetailModel.detailModel.seeker.seekerId,
//            _myId,
//            messageBody);
//      }
    });
//    _isSocketConnected().then((value) async {
//      if (value) {
//        try {
//          bool messageEmitted = await platform.invokeMethod('emitMessage', {
//            "processId": processId,
//            "toUserId": toUserId,
//            "fromUserId": fromUserId,
//            "messageBody": messageBody
//          });
//          print("Message Emitted: $messageEmitted");
//        } on PlatformException catch (e) {
//          print("Failed ${e.toString()}");
//        }
//      }
//    });
  }

  Future<void> _listenToMessages(String processId) async {
    try {
      print("Message Ran: $processId");
      await platform.invokeMethod('listenToMessages', {"processId": processId});
    } on PlatformException catch (e) {
      print("Failed ${e.toString()}");
    }
  }

  Future<SendMessageModel> _postSendMessage(
      String processId, String message) async {
    try {
      SavedData savedData = SavedData();
      String token = await savedData.getValue(TOKEN);
      Dio dio = Dio();

      Map<String, dynamic> map = {
        'process_id': '$processId',
        'message_body': '$message'
      };

      Options options = new Options(
        headers: {"token": token, "Content-type": "application/json"},
      );

      final response = await dio.post(BASE_URL + URL_MESSAGE_SEND,
          options: options, data: json.encode(map));

      print("SEND MESSAGE RESPONSE: ${response.data}");
      if (response.statusCode == HttpStatus.ok)
        return _sendMessageResponseFromJson(json.encode(response.data));
      else
        return SendMessageModel(status: false);
    } on DioError catch (e) {
      if (e.response != null) {
        return SendMessageModel(status: false);
      } else
        return SendMessageModel(status: false);
    }
  }

  @override
  void dispose() {
    _leaveChatRoom();
    _closeSocket();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

SendMessageModel _sendMessageResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return SendMessageModel.fromJson(jsonData);
}

class SendMessageModel {
  bool status;

  SendMessageModel({this.status});

  SendMessageModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
  }
}

class MessagesArray {
  List<Message> messages = [];

  MessagesArray.fromJson(List<dynamic> parsedJson) {
//    for (int i = 0; i < parsedJson.length; i++) {
    messages.add(Message.fromJson(parsedJson[0]));
//    }
  }
}

class Message {
  bool seen;
  String processId;
  String sender;
  String id;
  String messageBody;
  String createdAt;

  Message.fromJson(Map<String, dynamic> json) {
    seen = json['seen'];
    processId = json['process_id'];
    sender = json['sender'];
    id = json['_id'];
    messageBody = json['message_body'];
    createdAt = json['created_at'];
  }
}
