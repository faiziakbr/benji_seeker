import 'dart:convert';
import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyLoadingDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/UpdateProfileModel.dart';
import 'package:benji_seeker/pages/GettingStarted/VerifyPINPage.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  var _firstNameController = TextEditingController();
  var _lastNameController = TextEditingController();
  var _emailController = TextEditingController();
  var _phoneController = TextEditingController();

  String _image;
  File _fileImage;
  String _address = "";
  double _lat = 0.0;
  double _lng = 0.0;
  String _briefInfo;

  @override
  void initState() {
    _getSavedUserData();
    super.initState();
  }

  void _getSavedUserData() async {
    SavedData savedData = SavedData();
    savedData.getValue(FIRST_NAME).then((name) {
      _firstNameController.text = name;
    });
    savedData.getValue(LAST_NAME).then((value) {
      _lastNameController.text = value;
    });
    savedData.getValue(PHONE).then((phone) {
      _phoneController.text = phone;
    });
    savedData.getValue(EMAIL).then((email) {
      _emailController.text = email;
    });
    savedData.getValue(IMAGE_URL).then((image) {
      print("GOT IMAGE: $image");
      setState(() {
        _image = BASE_PROFILE_URL + image;
      });
    });
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
        centerTitle: false,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: QuicksandText("Edit Profile", 22, Colors.black, FontWeight.bold),
      ),
      body: SafeArea(
        child: Container(
          height: mediaQueryData.size.height,
          width: mediaQueryData.size.width,
          margin: EdgeInsets.only(
              top: 16.0,
              left: mediaQueryData.size.width * 0.05,
              right: mediaQueryData.size.width * 0.05),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                MontserratText(
                  "Upload profile image",
                  14,
                  lightTextColor,
                  FontWeight.normal,
                  bottom: 8.0,
                ),
                GestureDetector(
                  onTap: _getImage,
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _fileImage == null
                              ? FadeInImage(
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  placeholder:
                                      AssetImage("assets/placeholder.png"),
                                  image: NetworkImage("$_image"),
                                )
                              : Image.file(
                                  _fileImage,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Image.asset(
                          "assets/edit_icon.png",
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                _textField(mediaQueryData, "First name", _firstNameController),
                _textField(mediaQueryData, "Last name", _lastNameController),
                _textField(mediaQueryData, "Email address", _emailController),
                _textField(mediaQueryData, "Phone number", _phoneController),
                Container(
                    width: mediaQueryData.size.width,
                    height: 50,
                    margin: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                    child: MyDarkButton("SAVE & UPDATE", _btnClick))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _getImage() async {
    FocusScope.of(context).requestFocus(FocusNode());
    File file = await FilePicker.getFile(type: FileType.image);

    setState(() {
      _fileImage = file;
    });
  }

  Widget _textField(MediaQueryData mediaQueryData, String label,
      TextEditingController controller,
      {int maxLines = 1, bool enabled = true, Function onTap}) {
    return Container(
      margin: EdgeInsets.only(top: mediaQueryData.size.height * 0.04),
      child: TextFormField(
        controller: controller,
        enableInteractiveSelection: enabled,
        onTap: onTap,
        cursorColor: accentColor,
        style: _labelTextStyle(fontWeight: FontWeight.w500, textSize: 20),
        decoration: InputDecoration(
            labelText: "$label",
            labelStyle: _labelTextStyle(),
            contentPadding: const EdgeInsets.only(top: -8.0)),
        maxLines: maxLines,
        minLines: 1,
      ),
    );
  }

  TextStyle _labelTextStyle(
      {FontWeight fontWeight = FontWeight.normal, double textSize = 16}) {
    return TextStyle(
        color: Colors.black,
        fontSize: textSize,
        fontWeight: fontWeight,
        fontFamily: "Montserrat");
  }

  void _btnClick() {
    if (_firstNameController.text.toString().isNotEmpty &&
        _lastNameController.text.toString().isNotEmpty &&
        _emailController.text.toString().isNotEmpty &&
        _phoneController.text.toString().isNotEmpty) {
      MyLoadingDialog(context, "Updating profile...");
      String firstName = _firstNameController.text.toString().toLowerCase();
      String lastName = _lastNameController.text.toString().toLowerCase();
      firstName = StringUtils.capitalize(firstName);
      lastName = StringUtils.capitalize(lastName);
      _updateProfile(firstName, lastName, _emailController.text.toString(),
          _phoneController.text.toString());
    } else {
      MyToast("Fill the form correctly!", context);
    }
  }

  void _updateProfile(
      String firstName, String lastName, String email, String phoneNumber) {
    DioHelper dioHelper = DioHelper.instance;

    if (_fileImage != null) {
      FormData formData = FormData.fromMap({
        "first_name": "$firstName",
        "last_name": "$lastName",
        "email": "$email",
        "phone": "$phoneNumber",
        "profile_picture": MultipartFile.fromFileSync(_fileImage.absolute.path)
      });

      dioHelper
          .postFormRequest(
              BASE_URL + URL_UPDATE_PROFILE, {"token": ""}, formData)
          .then((value) {
            print("UPDATE RESPONSE: $value");
        Navigator.pop(context);
        UpdateUserProfileModel userProfileModel =
            updateUserProfileModelResponseFromJson(json.encode(value.data));
        if (userProfileModel.status) {
          SavedData savedData = SavedData();
          savedData.setValue(FIRST_NAME, firstName);
          savedData.setValue(LAST_NAME, lastName);
          savedData.setValue(EMAIL, _emailController.text.toString());

          if (userProfileModel.imageUrl != null)
            savedData.setValue(IMAGE_URL, userProfileModel.imageUrl);

          if (userProfileModel.getOTP) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VerifyPINPage(
                          _phoneController.text.toString(),
                          updateProfileNumber: true,
                        )));
          } else {
            MyToast("Profile Updated", context);
            Navigator.pop(context, true);
          }
        }
      }).catchError((error) {
        try {
          print("RESPONSE ERRROR: $error");
          Navigator.pop(context);
          var err = error as DioError;
          if (err.type == DioErrorType.RESPONSE) {
            UpdateUserProfileModel userProfileModel =
                updateUserProfileModelResponseFromJson(
                    json.encode(err.response.data));
            MyToast("${userProfileModel.errors[0]}", context);
          } else
            MyToast("${err.message}", context);
        } catch (e) {
          MyToast("Unexpected error!", context);
        }
      });
    } else {
      Map<String, dynamic> data = {
        "first_name": "$firstName",
        "last_name": "$lastName",
        "email": "$email",
        "phone": "$phoneNumber",
      };
      print("REQUEST: $data");

      dioHelper
          .postRequest(BASE_URL + URL_UPDATE_PROFILE, {"token": ""}, data)
          .then((value) {
        Navigator.pop(context);
        UpdateUserProfileModel userProfileModel =
            updateUserProfileModelResponseFromJson(json.encode(value.data));
        if (userProfileModel.status) {
          SavedData savedData = SavedData();
          savedData.setValue(FIRST_NAME, firstName);
          savedData.setValue(LAST_NAME, lastName);
          savedData.setValue(EMAIL, _emailController.text.toString());

          if (userProfileModel.imageUrl != null)
            savedData.setValue(IMAGE_URL, userProfileModel.imageUrl);

          if (userProfileModel.getOTP) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VerifyPINPage(
                          _phoneController.text.toString(),
                          updateProfileNumber: true,
                        )));
          } else {
            MyToast("Profile Updated", context);
            Navigator.pop(context, true);
          }
        }
      }).catchError((error) {
        try {
          Navigator.pop(context);
          var err = error as DioError;
          if (err.type == DioErrorType.RESPONSE) {
            UpdateUserProfileModel userProfileModel =
                updateUserProfileModelResponseFromJson(
                    json.encode(err.response.data));
            MyToast("${userProfileModel.errors[0]}", context);
          } else
            MyToast("${err.message}", context);
        } catch (e) {
          MyToast("Unexpected error!", context);
        }
      });
    }
  }

//  Future<UpdateUserProfileModel> _updateProfile(
//    String firstName,
//    String lastName,
//    String email,
//    String phoneNumber,
//  ) async {
//    try {
//      Dio dio = new Dio();
//
//      SavedData savedData = SavedData();
//      String token = await savedData.getValue(TOKEN);
//
//      Map<String, dynamic> map;
//
//      FormData formData;
//      if (_lat != 0.0 && _lng != 0.0 && _fileImage != null) {
//        print("1rd called");
//        formData = FormData.fromMap({
//          'first_name': '$firstName',
//          'last_name': '$lastName',
//          "email": '$email',
//          "phone": phoneNumber,
//          "about_me": '$overview',
//          "latitude": _lat,
//          "longitude": _lng,
//          "address": _address,
//          "profile_picture": MultipartFile.fromFileSync(
//              _fileImage.absolute.path,
//              filename: "image"),
//        });
//      } else if (_fileImage != null) {
//        print("2rd called");
//        formData = FormData.fromMap({
//          'first_name': '$firstName',
//          'last_name': '$lastName',
//          "email": '$email',
//          "phone": phoneNumber,
//          "about_me": '$overview',
//          "profile_picture": MultipartFile.fromFileSync(
//              _fileImage.absolute.path,
//              filename: "image"),
//        });
//      } else if (_lat != 0.0 && _lng != 0.0) {
//        print("3rd called");
//        map = {
//          'first_name': '$firstName',
//          'last_name': '$lastName',
//          "email": '$email',
//          "phone": phoneNumber,
//          "about_me": '$overview',
//          "latitude": _lat,
//          "longitude": _lng,
//          "address": _address,
//        };
//      } else
//        map = {
//          'first_name': '$firstName',
//          'last_name': '$lastName',
//          "email": '$email',
//          "phone": phoneNumber,
//          "about_me": '$overview'
//        };
//
//      print("REQUEST: $map");
//
//      Map<String, dynamic> headers = {
//        'token': token,
//        'Content-type': 'application/json'
//      };
//
//      Options options = new Options(headers: headers);
//
//      var response;
//      if (_fileImage == null) {
//        response = await dio.post(BASE_URL + URL_UPDATE_PROFILE,
//            data: json.encode(map), options: options);
//      } else {
//        print("PIC RAN");
//        print("URL: $BASE_URL$URL_UPDATE_PROFILE");
//        response = await dio.post(BASE_URL + URL_UPDATE_PROFILE,
//            data: formData, options: options);
//      }
//
//      print("UPDATE PROFILE RESPONSE: ${response.data}");
//      if (response.statusCode == HttpStatus.ok) {
//        return _updateUserProfileModelResponseFromJson(
//            json.encode(response.data));
//      } else {
//        return UpdateUserProfileModel(status: false);
//      }
//    } on DioError catch (e) {
//      print("UPDATE PROFILE ERROR: ${e.response.data}");
//      if (e.response != null) {
//        return _updateUserProfileModelResponseFromJson(
//            json.encode(e.response.data));
//      } else {
//        return UpdateUserProfileModel(status: false);
//      }
//    }
//  }
}
