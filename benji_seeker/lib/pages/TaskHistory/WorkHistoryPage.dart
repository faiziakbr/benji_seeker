import 'dart:convert';
import 'dart:io';

import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/CompleteJobModel.dart';
import 'package:dio/dio.dart';
import "package:flutter/material.dart";

import 'itemTaskHistory.dart';

class WorkHistoryPage extends StatefulWidget {
  @override
  _WorkHistoryPageState createState() => _WorkHistoryPageState();
}

class _WorkHistoryPageState extends State<WorkHistoryPage> {
  bool _search = false;
  List<ItemCompletedModel> _originalList = [];
  List<ItemCompletedModel> _list = [];

  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    _getCompletedJobResponse().then((jobResponse) {
      setState(() {
        _isLoading = false;

        if (jobResponse.status) {
          _originalList = jobResponse.completedJobs;
          _list = _originalList;
        } else {
          _isError = true;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: _search ? _searchAppBar() : _mainAppBar(),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _isError
            ? Center(
            child: MontserratText("Error loading task history", 22,
                Colors.black, FontWeight.normal))
            : Container(
          margin: EdgeInsets.only(
              top: 16.0,
              left: mediaQueryData.size.width * 0.05,
              right: mediaQueryData.size.width * 0.05),
          child: _list.length == 0 ? Center(child: MontserratText("No task history.", 18, Colors.black.withOpacity(0.4), FontWeight.normal),) : ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: _list.length,
              itemBuilder: (context, index) {
                return ItemWorkHistory(_list[index]);
              }),
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
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: accentColor,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: QuicksandText("Task History", 22, accentColor, FontWeight.bold),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _search = true;
            });
          },
        )
      ],
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
        decoration: InputDecoration.collapsed(hintText: "Search by title"),
        onChanged: (text) {
          setState(() {
            _searchHistory(text);
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
              _search = false;
              _list = _originalList;
            });
          },
        )
      ],
    );
  }

  void _searchHistory(String text) {
    setState(() {
      List<ItemCompletedModel> temp = [];
      if (text.isNotEmpty) {
        for (int i = 0; i < _originalList.length; i++) {
          if (_originalList[i]
              .category
              .toLowerCase()
              .contains(text.toLowerCase())) {
            temp.add(_originalList[i]);
          }
        }
        _list = temp;
      } else {
        _list = _originalList;
      }
    });
  }

  Future<CompletedJobModel> _getCompletedJobResponse() async {
    try {
      SavedData savedData = new SavedData();
      String token = await savedData.getValue(TOKEN);
      Dio dio = new Dio();

      Options options = new Options(headers: {"token": token});

      final response =
      await dio.get(BASE_URL + URL_COMPLETED_JOBS, options: options);

      if (response.statusCode == HttpStatus.ok)
        return responseFromJson(json.encode(response.data));
      else
        return CompletedJobModel(status: false);
    } catch (e) {
      return CompletedJobModel(status: false);
    }
  }
}
