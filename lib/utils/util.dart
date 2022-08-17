import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

const Color DEFAULT_BUTTON_COLOR = Color(0xff366cf6);

const String KAKAO_RESTAPI_KEY = '6688bfc92ad09373c11642605c453bb8'; // 회사키
const String VWORD_MAP_KEY = 'B4CD2B4A-39A2-32C6-8439-F5D3E26FCE6D';

List<String> GENERAL_COLUMN = [
  "코드",
  "제목",
  "메모",
  "조사일시",
];
const List<String> GENERAL_TYPE = ["하천", "호소", "시설물", "경작지", "오염원", "기타"];

class Util {
  static String getRandomString(int length) {
    var chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    var randomChar = String.fromCharCodes(Iterable.generate(length, (index) {
      return chars.codeUnitAt(rnd.nextInt(chars.length));
    }));

    return randomChar;
  }

  /// 숫자 형식 확인
  static bool checkRegNumber(String text, {bool isNatural = false, bool isPositive = false}) {
    String pattern = r'^(0(\.\d+)?|(-?[1-9]\d*(\.\d+)?)|(-0\.\d*[1-9]+\d*))$';
    if(isNatural){
      pattern = r'(^[1-9][0-9]*$)';
    }else if(isPositive){
      pattern = r'(^0|[1-9][0-9]*$)';
    }
    return RegExp(pattern).hasMatch(text);
  }

  /// 날짜 형식 확인
  static bool checkRegDateTime(String text) {
    String pattern = r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]) ([01][0-9]|2[0-4]):[0-5][0-9]:[0-5][0-9]$';
    return RegExp(pattern).hasMatch(text);
  }

  static GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'https://www.googleapis.com/auth/userinfo.email',
    ],
  );

  /// 미디어 파일 형식 확인
  static String checkMediaTypeToUpperCase(String url){
    return url.toString().substring(url.toString().lastIndexOf('.')+1).toUpperCase();
  }

  /// 미디어 파일 정보
  static Future<ImageInfo> getImageInfo(Image img) async {
    final c = Completer<ImageInfo>();
    img.image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((ImageInfo i, bool _) {
      c.complete(i);
    }));
    return c.future;
  }

  ///플러터 맵 기본 마커
  static Marker defaultMarker(double lat, double lon, {String key = ''}){
    return Marker(
      point: LatLng(lat, lon),
      key: ValueKey(key),
      builder: (context){
        return const Icon(Icons.location_on, color: Colors.red, size: 20);
      },
      anchorPos: AnchorPos.exactly(Anchor(15, 8))
    );
  }

  /// 토스트 메세지
  static void toastMessage(String str, {int showTime = 3}) {
    Fluttertoast.showToast(
      msg: str,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: showTime,
      textColor: Colors.white,
      fontSize: 16.0,
      webPosition: 'center',
      webBgColor: '#009aff',
    );
  }

  ///카메라 촬영 및 갤러리 선택으로 동영상 가져오기
  static Future<List<XFile>> getVideo(ImageSource imageSource) async{
    List<XFile> videos = [];
    await ImagePicker().pickVideo(source: imageSource).then((file) {
      if(file != null){
        videos.add(file);
      }
    });
    return videos;
  }

  ///카메라 촬영 및 갤러리 선택으로 이미지 가져오기
  static Future<List<XFile>> getImage(ImageSource imageSource) async{
    List<XFile> images = [];
    if(imageSource == ImageSource.camera){
      await ImagePicker().pickImage(source: imageSource).then((file) {
        if(file != null){
          images.add(file);
        }
      });
    }else{
      await ImagePicker().pickMultiImage().then((files) {
        if(files != null){
          images = files;
        }
      });
    }
    return images;
  }
}