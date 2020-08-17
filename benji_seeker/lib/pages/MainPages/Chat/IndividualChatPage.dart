import 'dart:convert';

import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/pages/Chat/ChatPage.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import "package:flutter/material.dart";

import 'ItemIndividualChat.dart';

class IndividualChatPage extends StatefulWidget {
  final GlobalKey key;
  final Function updateChatCount;

  IndividualChatPage(this.key, {this.updateChatCount});

  @override
  IndividualChatPageState createState() => IndividualChatPageState();
}

class IndividualChatPageState extends State<IndividualChatPage> {
  DioHelper _dioHelper;
  List<Message> _originalList = [];
  List<Message> _filteredList = [];
  bool _isLoading = true;
  bool _isError = false;
  bool _isSearch = false;
  ChatModel _chatModel;

  @override
  void initState() {
    _chatModel = ChatModel(status: false);
    _dioHelper = DioHelper.instance;
    getMessages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.updateChatCount();
    });
    super.initState();
  }

  Future<ChatModel> getMessages() {
    return _dioHelper.getRequest(
        BASE_URL + URL_MESSAGES_UNREAD, {"token": ""}).then((result) {
      _chatModel = _responseFromChatJson(json.encode(result.data));
      if (_chatModel.status) {
        _originalList = _chatModel.unReadMessages.messages;
        _filteredList = _originalList;
      } else {
        setState(() {
          _isError = true;
        });
      }
    }).catchError((error) {
      var err = error as DioError;
      if (err.type == DioErrorType.RESPONSE) {
        var errorResponse =
            _responseFromChatJson(json.encode(err.response.data));
        MyToast("${errorResponse.errors[0]}", context);
      } else
        MyToast("${err.message}", context);

      setState(() {
        _isError = true;
      });
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: _isSearch ? _searchAppBar() : _mainAppBar(),
      body: SafeArea(
        child: Container(
          height: mediaQueryData.size.height,
          margin: EdgeInsets.only(
              top: 16.0,
              left: mediaQueryData.size.width * 0.02,
              right: mediaQueryData.size.width * 0.02),
          child: _isLoading && !_isError
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _isError
                  ? Center(
                      child: MontserratText("${_chatModel.errors[0]}", 18,
                          Colors.black.withOpacity(0.4), FontWeight.normal))
                  : _originalList.length <= 0
                      ? Center(
                          child: Opacity(
                            opacity: 0.8,
                            child: MontserratText(
                                "Nothing to show!",
                                18,
                                Colors.black.withOpacity(0.8),
                                FontWeight.normal),
//              child: Column(
//                mainAxisAlignment:
//                MainAxisAlignment.center,
//                children: <Widget>[
//                  SvgPicture.asset(
//                      "assets/speech_bubble.svg",
//                      width: 60,
//                      height: 60),
//                  MontserratText(
//                      "Start Chat!",
//                      22,
//                      Colors.black
//                          .withOpacity(0.8),
//                      FontWeight.normal)
//                ],
//              ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: getMessages,
                          child: ListView.builder(
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) {
                              Message message = _filteredList[index];
                              return GestureDetector(
                                onTap: () async {
                                  var result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                              message.processId, null, fromJobPage: true, providerName: message.senderName,)));
                                  if (result != null) {
                                    if (result) {
                                      getMessages();
                                      widget.updateChatCount();
                                    }
                                  }
                                },
                                child: ItemIndividualChat(
                                    message.processId,
                                    message.profilePicture,
                                    message.senderName,
                                    message.title,
                                    message.time,
                                    message.seen,
                                    message.messageBody,
                                    message.createdAt),
                              );
                            },
                          ),
                        ),
        ),
      ),
    );
  }

  Widget _mainAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              stops: [0.4, 0.8],
              colors: [Colors.white, Colors.green[100]],
              begin: Alignment.topLeft,
              end: Alignment.topRight),
        ),
      ),
      automaticallyImplyLeading: false,
      title: QuicksandText("Messages", 22, accentColor, FontWeight.bold),
      centerTitle: false,
      actions: _originalList.length > 0
          ? <Widget>[
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isSearch = true;
                  });
                },
              )
            ]
          : <Widget>[],
    );
  }

  Widget _searchAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              stops: [0.4, 0.8],
              colors: [Colors.white, Colors.green[100]],
              begin: Alignment.topLeft,
              end: Alignment.topRight),
        ),
      ),
      title: TextField(
        autofocus: true,
        cursorColor: accentColor,
        decoration: InputDecoration.collapsed(hintText: "Search by name."),
        onChanged: (text) {
          setState(() {
            _searchLeads(text);
          });
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _isSearch = false;
              _filteredList = _originalList;
            });
          },
        )
      ],
    );
  }

  void _searchLeads(String text) {
    setState(() {
      List<Message> temp = [];
      if (text.isNotEmpty) {
        for (int i = 0; i < _originalList.length; i++) {
          if (_originalList[i]
              .senderName
              .toLowerCase()
              .contains(text.toLowerCase())) {
            temp.add(_originalList[i]);
          }
        }
        _filteredList = temp;
      } else {
        _filteredList = _originalList;
      }
    });
  }
}

ChatModel _responseFromChatJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return ChatModel.fromJson(jsonData);
}

class ChatModel {
  bool status;
  UnReadMessages unReadMessages;
  List<dynamic> errors = ['Unexpected Error!'];

  ChatModel({this.status});

  ChatModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['unread_messages'] != null)
      unReadMessages = UnReadMessages.fromJson(json['unread_messages']);
    errors = json['errors'];
  }
}

class UnReadMessages {
  String id;
  int unreadCount;
  List<Message> messages = [];

  UnReadMessages.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    unreadCount = json['unread_count'];

    List<Message> _temp = [];

    var key = json['messages'];
    if (key != null && key.length > 0) {
      for (int i = 0; i < key.length; i++) {
        var messages = Message.fromJson(key[i]);
        _temp.add(messages);
      }
    }
    messages = _temp;
  }
}

class Message {
  String id;
  bool seen;
  String messageBody;
  String createdAt;
  String senderName;
  String profilePicture;
  String processId;
  String title;
  String time;

  Message.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    seen = json['seen'];
    messageBody = json['message_body'];
    createdAt = json['created_at'];
    senderName = json['sender_name'];
    profilePicture = json['sender_profile_picture'];
    processId = json['process_id'];
    title = json['title'];
    time = json['time'];
  }
}
