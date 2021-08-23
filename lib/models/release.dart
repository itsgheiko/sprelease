import 'package:flutter/material.dart';

class Release {
  final String id;
  final DateTime date;
  final String name;
  final String type;
  final String artists;
  final String imageUrl;
  final String openUrl;
  final String previewUrl;
  final bool isNew;

  Release({@required this.id, @required this.date, @required this.name, @required this.type, @required this.artists, @required this.imageUrl, @required this.openUrl, @required this.previewUrl, this.isNew = false});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map["id"] = id;
    map["date"] = date;
    map["name"] = name;
    map["type"] = type;
    map["artists"] = artists;
    map["imageUrl"] = imageUrl;
    map["openUrl"] = openUrl;
    map["previewUrl"] = previewUrl;
    map["isNew"] = isNew;
    return map;
  }
}
