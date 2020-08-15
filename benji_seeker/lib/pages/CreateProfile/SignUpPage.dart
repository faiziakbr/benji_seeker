import 'package:basic_utils/basic_utils.dart';
import 'package:benji_seeker/My_Widgets/MyLoadingDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:flutter/material.dart';

import 'AddPaymentDetailsPage.dart';

class SignUpPage extends StatefulWidget {
  final String phoneNumber;
  final String accessCode;

  SignUpPage(this.phoneNumber, this.accessCode);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    "first_name": null,
    "last_name": null,
    "email": null,
    "password": null,
    "confirm_password": null
  };
  DioHelper _dioHelper;

  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.close,
            color: lightIconColor,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  if (_formData['password'] == _formData['confirm_password']) {
                    _btnCreateProfile(
                        _formData['first_name'],
                        _formData['last_name'],
                        _formData['email'],
                        _formData['password']);
                  } else {
                    MyToast("Password Mis-match", context);
                  }
                } else {
                  MyToast("Validation Error", context);
                }
              },
              child: CircleAvatar(
                backgroundColor: accentColor,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(
            top: 8.0,
            left: mediaQueryData.size.width * 0.05,
            right: mediaQueryData.size.width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MontserratText(
                "Welcome, \ntell us about yourself",
                16,
                accentColor,
                FontWeight.bold,
                top: 8.0,
                bottom: 8.0,
              ),
//              Container(
//                margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceAround,
//                  children: <Widget>[
//                    Container(
//                      child: MyDarkButton(
//                        "FACEBOOK",
//                        btnFbClick,
//                        color: fbColor,
//                        textSize: 14,
//                        fontWeight: FontWeight.w600,
//                      ),
//                      height: 40,
//                      width: mediaQueryData.size.width * 0.4,
//                    ),
//                    Container(
//                      child: MyDarkButton(
//                        "GOOGLE",
//                        btnFbClick,
//                        color: googleColor,
//                        textSize: 14,
//                        fontWeight: FontWeight.w600,
//                      ),
//                      height: 40,
//                      width: mediaQueryData.size.width * 0.4,
//                    )
//                  ],
//                ),
//              ),
//              MontserratText(
//                "tell us about yourself",
//                16,
//                accentColor,
//                FontWeight.bold,
//                bottom: 16.0,
//              ),
              Container(
                margin: const EdgeInsets.only(top: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        style: labelTextStyle(
                            fontWeight: FontWeight.w500, textSize: 20),
                        cursorColor: accentColor,
                        decoration: InputDecoration(
                            labelText: "Enter your first name",
                            labelStyle: labelTextStyle(letterSpacing: 0.06),
                            contentPadding: const EdgeInsets.only(top: -8.0)),
                        validator: (String value) {
                          if (value.isEmpty) return "First name is required";
                          return null;
                        },
                        onSaved: (value) {
                          _formData['first_name'] = value;
                        },
                      ),
                      SizedBox(
                        height: mediaQueryData.size.height * 0.035,
                      ),
                      TextFormField(
                        style: labelTextStyle(
                            fontWeight: FontWeight.w500, textSize: 20),
                        cursorColor: accentColor,
                        decoration: InputDecoration(
                            labelText: "Enter your last name",
                            labelStyle: labelTextStyle(letterSpacing: 0.06),
                            contentPadding: const EdgeInsets.only(top: -8.0)),
                        validator: (String value) {
                          if (value.isEmpty) return "Last name is required";
                          return null;
                        },
                        onSaved: (value) {
                          _formData['last_name'] = value;
                        },
                      ),
                      SizedBox(
                        height: mediaQueryData.size.height * 0.035,
                      ),
                      TextFormField(
                        style: labelTextStyle(
                            fontWeight: FontWeight.w500, textSize: 20),
                        cursorColor: accentColor,
                        decoration: InputDecoration(
                            labelText: "Enter your email",
                            labelStyle: labelTextStyle(),
                            contentPadding: const EdgeInsets.only(top: -8.0)),
                        validator: (String value) {
                          if (value.isEmpty) return "Email is required";
                          if (!RegExp(r'[\w-]+@([\w-]+\.)+[\w-]+')
                              .hasMatch(value)) return "Invalid Email";
                          return null;
                        },
                        onSaved: (value) {
                          _formData['email'] = value;
                        },
                      ),
                      SizedBox(
                        height: mediaQueryData.size.height * 0.035,
                      ),
                      TextFormField(
                        obscureText: true,
                        style: labelTextStyle(
                            fontWeight: FontWeight.w500, textSize: 20),
                        cursorColor: accentColor,
                        decoration: InputDecoration(
                            labelText: "Enter password",
                            labelStyle: labelTextStyle(),
                            contentPadding: const EdgeInsets.only(top: -8.0)),
                        validator: (String value) {
                          if (value.isEmpty) return "Password is required";
                          return null;
                        },
                        onSaved: (value) {
                          _formData['password'] = value;
                        },
                      ),
                      SizedBox(
                        height: mediaQueryData.size.height * 0.035,
                      ),
                      TextFormField(
                        obscureText: true,
                        style: labelTextStyle(
                            fontWeight: FontWeight.w500, textSize: 20),
                        cursorColor: accentColor,
                        decoration: InputDecoration(
                            labelText: "Confirm Password",
                            labelStyle: labelTextStyle(),
                            contentPadding: const EdgeInsets.only(top: -8.0)),
                        validator: (String value) {
                          if (value.isEmpty)
                            return "Confirm password is required";
                          return null;
                        },
                        onSaved: (value) {
                          _formData['confirm_password'] = value;
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  TextStyle labelTextStyle(
      {FontWeight fontWeight = FontWeight.normal,
      double textSize = 14,
      double,
      letterSpacing = 0.0}) {
    return TextStyle(
        color: lightTextColor,
        fontSize: textSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        fontFamily: "Montserrat");
  }

  void _btnCreateProfile(
      String firstName, String lastName, String email, String password) {
    firstName = StringUtils.capitalize(firstName.toLowerCase());
    lastName = StringUtils.capitalize(lastName.toLowerCase());


    Map<String, dynamic> map = {
      'access_code': widget.accessCode,
      "email": email,
      "first_name": firstName,
      "last_name": lastName,
      "password": password,
      "phone": widget.phoneNumber
    };

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddPaymentDetailsPage(map)));
  }
}
