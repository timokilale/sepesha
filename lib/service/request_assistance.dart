import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class RequestAssistance {
  RequestAssistance._();

  static Future<dynamic> receiveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));
    try {
      if (httpResponse.statusCode == 200) {
        String responseData = httpResponse.body;
        print(responseData);
        var decodeResponseData = json.decode(responseData);
        print("receiveRequest......$decodeResponseData");
        return decodeResponseData;
      } else {
        return 'Error occured. Failed to receive request.';
      }
    } catch (e) {
      debugPrint(e.toString());
      return 'Error occured. Failed to receive request.';
    }
  }
}
