import 'dart:async';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:dio/dio.dart';

class DioHelper {
  DioHelper._privateConstructor();

  static final DioHelper instance = DioHelper._privateConstructor();

  Dio _dio;

  void _getInstance() {
    //Couldn't create its singlton cause it will just append my responses from other requests WEIRD
    if (_dio != null) _dio.clear();

    BaseOptions baseOptions = new BaseOptions(
      connectTimeout: 15000,
      receiveTimeout: 15000,
    );
    _dio = Dio(baseOptions);
  }

  Future<Response> getRequest(String path, Map<String, dynamic> headers) {
    _getInstance();

    Options options = Options(headers: headers);

    _addInterceptors(_dio);

    var response = _dio.get(path, options: options);

    return response;
  }

  Future<Response> postRequest(
      String path, Map<String, dynamic> headers, Map<String, dynamic> data) {
    _getInstance();

    Options options = Options(headers: headers);

    _addInterceptors(_dio);

    var response = _dio.post(path, options: options, data: data);

    return response;
  }

  Future<Response> postFormRequest(
      String path, Map<String, dynamic> headers, FormData data) {
    _getInstance();

    data.fields.forEach((element) {
      print("FIELD: ${element.key} VALue: ${element.value}");
    });
    data.files.forEach((element) {
      print("FILES: ${element.key} VALUE: ${element.value.filename}");
    });

    Options options = Options(headers: headers);

    _addInterceptors(_dio);

    var response = _dio.post(path, options: options, data: data);

    return response;
  }

  Dio _addInterceptors(Dio dio) {
    return dio
      ..interceptors.add(InterceptorsWrapper(
          onRequest: (RequestOptions options) => _requestInterceptor(options),
          onResponse: (Response response) => _responseInterceptor(response),
          onError: (DioError dioError) => _errorInterceptor(dioError)));
  }

  dynamic _requestInterceptor(RequestOptions options) async {
    if (options.headers.containsKey("token")) {
      SavedData savedData = SavedData();
      String token = await savedData.getValue(TOKEN);
      print("TOKEN: $token");
      if (token == null || token.isEmpty) {
        return DioError(type: DioErrorType.RESPONSE, error: "Token was empty");
      }
      options.headers.addAll({"token": "$token"});

      return options;
    }
  }

  dynamic _responseInterceptor(Response options) async {
    return options;
  }

  dynamic _errorInterceptor(DioError dioError) {
    print("REQUEST: ${dioError.request.uri}, \nError Response: ${dioError.response} Status code: ${dioError.message}");
    switch (dioError.type) {
      case DioErrorType.DEFAULT:

        return DioError(response: dioError.response,type: dioError.type, error: "Not Connected to Internet");
        break;
      case DioErrorType.CONNECT_TIMEOUT:
      case DioErrorType.RECEIVE_TIMEOUT:
      case DioErrorType.SEND_TIMEOUT:
        return DioError(response: dioError.response,type: dioError.type, error: "Request Timed out!");
        break;
      case DioErrorType.RESPONSE:
        return DioError(response: dioError.response, type: dioError.type, error: "Server Error!");
        break;
      default:
        return DioError(response: dioError.response,type: dioError.type, error: "Unexpected Error!");
    }
  }
}
