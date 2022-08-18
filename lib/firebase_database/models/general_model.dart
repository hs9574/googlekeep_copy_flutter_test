import 'package:intl/intl.dart';
import 'dart:typed_data';

class General {
  int id;
  String userId;
  int projectId;
  String dateCreated;
  String title;
  String memo;
  List<Media> mediaList;

  General({
    this.id = 0,
    this.userId = '',
    this.projectId = 0,
    this.dateCreated = '',
    this.title = '',
    this.memo = '',
    this.mediaList = const []
  });

  factory General.fromJson(Map<String, dynamic> json){
    DateTime dateTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(json['date_created']);
    return General(
      id: json["cnt"],
      userId: json["uid"],
      projectId: json["project_id"],
      dateCreated: DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime),
      title: json["title"]??'',
      memo: json['memo']??'',
      mediaList: []
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "date_created": dateCreated,
      "title": title,
      "memo": memo,
      "project_id" : projectId,
      "uid": userId,
    };
  }

  dynamic setParameter(String param, dynamic value){
    switch(param.toUpperCase()){
      case '지점명':
      case '제목':
        title = value;
        break;
      case '조사일시':
      case '날짜':
        dateCreated = value;
        break;
      case '메모':
        memo = value;
        break;
    }
  }

  dynamic getParameter(String param){
    switch(param.toUpperCase()){
      case '코드':
        return id;
      case '지점명':
      case '제목':
        return title=='' ? '-' : title;
      case '조사일시':
      case '날짜':
        return dateCreated;
      case '메모':
        return memo=='' ? '-' : memo;
      default:
        return '-';
    }
  }

  static General getInstance(){
    return General(id: 0, userId: '', projectId: 0, dateCreated: '', title: '', memo: '', mediaList: []);
  }
}

class Media {
  int id;
  int parentId;
  String name;
  String url;
  String thumbnail;
  String dateCreated;
  double lat;
  double lon;
  Uint8List? bytes;
  bool isSaved;
  bool isRemoved;

  Media({
    this.id = 0,
    this.parentId = 0,
    this.name = '',
    this.url = '',
    this.thumbnail = '',
    this.dateCreated = '',
    this.lat = 0,
    this.lon = 0,
    this.bytes,
    this.isSaved = true,
    this.isRemoved = false
  });

  factory Media.fromJson(Map<String, dynamic> json){
    DateTime dateTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(json['date_created']);
    return Media(
      id: json['id'],
      parentId: json['parent_id'],
      url: json['url'],
      dateCreated: DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime),
      lat: (json['lat']??0).toDouble(),
      lon: (json['lon']??0).toDouble(),
    );
  }
}