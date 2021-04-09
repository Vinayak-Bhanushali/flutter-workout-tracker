import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:workout_tracker/datasources/remote/api_exception.dart';

const String key_content_type = "Content-Type";
const String key_authorization = "Authorization";
const String key_content_type_application_json = "application/json";
const String key_content_type_multi_part_form_data = "multipart/form-data";
const String key_content_type_text_xml = "text/xml";
const Duration timeout = const Duration(milliseconds: 90000);

class ApiBaseHelper {
  Future<dynamic> get(String url, {bool enableJsonDecoding = true}) async {
    // print('Api Get, url $url');

    Map<String, String> headers = {
      key_content_type: key_content_type_application_json,
    };

    var responseJson;
    try {
      final response = await http.get(url, headers: headers).timeout(timeout);
      responseJson = await _returnResponse(
        response,
        enableJsonDecoding: enableJsonDecoding,
      );
    } on SocketException {
      // print('No net');
      throw FetchDataException('No Internet connection');
    }
    // print('api get recieved!');
    return responseJson;
  }

  Future<dynamic> post(String url, dynamic body,
      {bool enableJsonDecoding = true}) async {
    // print('Api Post, url $url');

    Map<String, String> headers = {
      key_content_type: key_content_type_application_json,
    };

    body = jsonEncode(body);
    // debugPrint("Request Body: " + body);
    var responseJson;
    try {
      final response =
          await http.post(url, body: body, headers: headers).timeout(timeout);
      // debugPrint("Response Body: " + response.body.toString());
      responseJson = await _returnResponse(
        response,
        enableJsonDecoding: enableJsonDecoding,
      );
    } on SocketException {
      // print('No net');
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw ServerTimeoutException('No Internet connection');
    }
    // print('api post.');
    return responseJson;
  }

  Future<dynamic> put(String url, dynamic body,
      {bool enableJsonDecoding = true}) async {
    // print('Api Put, url $url');
    var responseJson;
    try {
      final response = await http.put(url, body: body);
      responseJson = _returnResponse(
        response,
        enableJsonDecoding: enableJsonDecoding,
      );
    } on SocketException {
      // print('No net');
      throw FetchDataException('No Internet connection');
    }
    // print('api put.');
    // print(responseJson.toString());
    return responseJson;
  }

  Future<dynamic> delete(String url, {bool enableJsonDecoding = true}) async {
    // print('Api delete, url $url');
    var apiResponse;
    try {
      final response = await http.delete(url);
      apiResponse = _returnResponse(
        response,
        enableJsonDecoding: enableJsonDecoding,
      );
    } on SocketException {
      // print('No net');
      throw FetchDataException('No Internet connection');
    }
    // print('api delete.');
    return apiResponse;
  }

  dynamic _returnResponse(
    http.Response response, {
    bool enableJsonDecoding = true,
  }) async {
    switch (response.statusCode) {
      case 200:
        var responseObject = enableJsonDecoding
            ? json.decode(
                response.body.replaceAll(r"\'", "'"),
              )
            : response.body;
        return responseObject;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
        throw UnauthorisedException(response.body.toString());
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
