import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:intl/intl.dart';

class ApiGeneral {
  ApiGeneral({
    required this.id,
    required this.userIdId,
    required this.projectIdId,
    required this.dateCreated,
    required this.stdId,
    required this.title,
    required this.waterSystem,
    required this.address,
    required this.lat,
    required this.lon,
    required this.memo,
    required this.type,
    required this.url,
    required this.userdept,
    required this.usergrade,
    required this.username,
    required this.prjurl,
  });

  int id;
  int userIdId;
  int projectIdId;
  String dateCreated;
  dynamic stdId;
  String title;
  dynamic waterSystem;
  String address;
  double lat;
  double lon;
  String memo;
  int type;
  String url;
  String userdept;
  String usergrade;
  String username;
  String prjurl;

  factory ApiGeneral.fromJson(Map<String, dynamic> json) {
    DateTime dateTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(json["date_created"]);
    return ApiGeneral(
      id: json["id"],
      userIdId: json["user_id_id"],
      projectIdId: json["project_id_id"],
      dateCreated: DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime),
      stdId: json["std_id"]??'',
      title: json["title"]??'',
      waterSystem: json["water_system"]??'',
      address: json["address"]??'',
      lat: json["lat"] == null ? -999 : json["lat"].toDouble(),
      lon: json["lon"] == null ? -999 : json["lon"].toDouble(),
      memo: json['memo']??'',
      type: json['type']??'',
      url: json["url"]??'',
      userdept: json["userdept"]??'',
      usergrade: json["usergrade"]??'',
      username: json["username"]??'',
      prjurl: json["prjurl"]??'',
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": 'DGXVhhJj38SJAGqSaGTvoQ8zizn1',
    "project_id": 1,
    "date_created": Timestamp.fromDate(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateCreated)),
    "title": title,
    "address": address,
    "lat": lat,
    "lon": lon,
    "user_dept": '휴먼플래닛',
    "user_grade": '사원',
    "user_name": 'kwater',
    "memo": memo,
    "type": GENERAL_TYPE[type],
    "medias" : []
  };
}
