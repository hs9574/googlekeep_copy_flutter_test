import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Album{
  int id;
  String dateCreated;
  String url;
  String name;
  String etc;
  double lat;
  double lon;

  Album({
    this.id = 0,
    this.dateCreated = '',
    this.url = '',
    this.name = '',
    this.etc = '',
    this.lat = 0,
    this.lon = 0
  });

  factory Album.fromFireStore(Map<String, dynamic> json){
    return Album(
      id: json['id']??0,
      dateCreated: json['date_created'] != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(json['date_created'].toDate()) : '',
      url: json['url']??'',
      name: json['name']??'',
      etc: json['etc']??'',
      lat: (json['lat']??0).toDouble(),
      lon: (json['lon']??0).toDouble()
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id" : id,
      "date_created" : Timestamp.fromDate(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateCreated)),
      "url" : url,
      "name" : name,
      "etc": etc,
      "lat" : lat,
      "lon" : lon
    };
  }
}