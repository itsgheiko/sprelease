// Packages
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class APIHelper {
  Future<Map<String, dynamic>> getRequest(Uri uri, Map<String, String> headers) async {
    try {
      var _response = await http.get(uri, headers: headers);
      if (_response.body != null) return Map<String, dynamic>.from(jsonDecode(_response.body));
    } catch (e) {
      return {
        "error": "$e",
      };
    }
  }
}
