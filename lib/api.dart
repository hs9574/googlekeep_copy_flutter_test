import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fastapi_project/firebase_database/models/general_model.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Api {
  final db = Util.db;
  final storage = Util.storage;
  final user = Util.auth.currentUser;

  /// 카카오 주소 -> 좌표 변환
  Future<Map<String,dynamic>> getCoordinate(String address) async {
    String url = "https://dapi.kakao.com/v2/local/search/address.json?query=$address";

    final response = await get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'KakaoAK $KAKAO_RESTAPI_KEY'
    });

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('주소 -> 좌표 변환 실패');
    }
  }

  /// 카카오 좌표 -> 주소 변환
  Future<Map<String,dynamic>> getAddress(double lat, double lon) async {
    String url = "https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$lon&y=$lat";

    final response = await get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'KakaoAK $KAKAO_RESTAPI_KEY'
    });

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('좌표 -> 주소 변환 실패');
    }
  }

  Future naverLogin(String accessToken) async{
    String url = 'http://192.168.0.169:8090/users/login/naver';

    var data = {
      "access_token" : accessToken
    };
    final response = await post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(data)
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('네이버 로그인 실패');
    }
  }

  Future kakaoLogin(String accessToken) async{
    String url = 'http://192.168.0.169:8090/users/login/kakao';

    var data = {
      "access_token" : accessToken
    };
    final response = await post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(data)
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('카카오 로그인 실패');
    }
  }

  Future googleLogin(String idToken, String accessToken) async{
    String url = 'http://192.168.0.169:8090/users/login/google';

    var data = {
      "id_token" : idToken,
      "access_token" : accessToken
    };
    final response = await post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(data)
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('구글 로그인 실패');
    }
  }

  Future userLogin(String email, String password) async{
    String url = 'http://192.168.0.169:8090/users/login/email';
    var data = {
      "email" : email,
      "password" : password
    };
    final response = await post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(data)
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }else if(response.statusCode == 401){
      var errorMap = jsonDecode(utf8.decode(response.bodyBytes));
      if(errorMap['detail'] == 'Email UnAuthentication'){
        Util.toastMessage('이메일 인증이 완료되지 않았습니다.');
        throw Exception('유저 로그인 실패');
      }
    } else {
      throw Exception('유저 로그인 실패');
    }
  }

  Future getUser() async{
    var box = await Hive.box('token');
    String token = box.get('access_token')??'';
    String url = 'http://192.168.0.169:8090/users/me';

    if(token != ''){
      final response = await get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          }
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }else if(response.statusCode == 403){
        return 'refresh';
      } else{
        throw Exception('유저 정보 가져오기 실패');
      }
    }
  }

  Future createUser(Map<String, String> user) async{
    String url = 'http://192.168.0.169:8090/user';

    String uid = Util.getRandomString(25);
    user['uid'] = uid;
    user['userdept'] = '휴먼플래닛';

    final response = await post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(user)
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('유저 생성 실패');
    }
  }

  Future getProjects(String uid) async{
    var box = await Hive.box('token');
    String token = box.get('access_token')??'';

    String url = 'http://192.168.0.169:8090/project/$uid';

    final response = await get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('프로젝트 리스트 가져오기 실패');
    }
  }

  Future createProject(Map<String, dynamic> project) async{
    String url = 'http://192.168.0.169:8090/project';

    final response = await post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(project)
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('프로젝트 생성 실패');
    }
  }

  Future deleteProject(int projectId) async{
    String url = 'http://192.168.0.169:8090/project/$projectId';

    final response = await delete(Uri.parse(url));

    if(response.statusCode != 200){
      throw Exception('프로젝트 삭제 실패');
    }
  }

  Future getGeneralData(int project_id) async {
    String url = 'http://192.168.0.169:8090/general/$project_id';
    final response = await get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('일반 리스트 가져오기 실패');
    }
  }

  Future createGeneralData(Map<String, dynamic> data) async{
    String url = 'http://192.168.0.169:8090/general';

    final response = await post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(data)
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('일반데이터 생성 실패');
    }
  }

  Future updateGeneralData(Map<String, dynamic> data) async{
    String url = 'http://192.168.0.169:8090/general/${data['cnt']}';

    final response = await put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(data)
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('일반데이터 수정 실패');
    }
  }

  Future deleteGeneralData(int generalId) async {
    String url = 'http://192.168.0.169:8090/project/general/$generalId';

    final response = await delete(Uri.parse(url));

    if(response.statusCode != 200){
      throw Exception('일반데이터 삭제 실패');
    }
  }

  Future<String> uploadGeneralMedia(int projectId, Media file) async{
    var ref = storage.ref().child(user!.uid).child('$projectId');
    String url = '';
    String thumbUrl = '';
    await ref.child(file.name).putData(file.bytes!).then((task) async{
      url = await task.ref.getDownloadURL();
      if(file.thumbNailUrl != ''){
        var thumbNailFile = await VideoThumbnail.thumbnailData(
            video: url,
            quality: 50,
            maxWidth: 512,
            imageFormat: ImageFormat.PNG
        );
        await ref.child('${file.name}atThumbNail.png').putData(thumbNailFile!).then((thumbTask) async{
          thumbUrl = await thumbTask.ref.getDownloadURL();
        });
      }
    });
    return '$url#$thumbUrl';
  }

  Future deleteGeneralMedia(int projectId, String fileName) async{
    var ref = storage.ref().child(user!.uid).child('$projectId');
    await ref.child(fileName).delete();
    try{
      await ref.child('${fileName}atThumbNail.png').delete();
    }on FirebaseException catch (e){
      e.code;
    }
  }

  Future deleteGeneralMediaAll(int projectId) async{
    var storageRef = storage.ref().child(user!.uid).child('$projectId');
    await storageRef.listAll().then((medias) async{
      for(var media in medias.items){
        await media.delete();
      }
    });
  }

  Future<double> getUserMediaSize() async{
    var ref = storage.ref().child(user!.uid);
    double mediasSize = 0;
    await ref.listAll().then((projects) async{
      List<String> projectList = projects.prefixes.map((e) => e.name).toList();
      for(String projectId in projectList){
        await ref.child(projectId).listAll().then((medias) async{
          for(var media in medias.items){
            await media.getMetadata().then((data) {
              mediasSize += data.size!;
            });
          }
        });
      }
    });
    return mediasSize;
  }
}