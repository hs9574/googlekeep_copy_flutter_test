import 'dart:async';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:fastapi_project/firebase_database/models/general_model.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:fastapi_project/utils/util.dart';

class Api {
  var apiUrl = 'https://aaespa.shop';
  // var apiUrl = 'http://192.168.0.169:8090';

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
    String url = '$apiUrl/users/login/naver';

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
    String url = '$apiUrl/users/login/kakao';

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
    String url = '$apiUrl/users/login/google';

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
    String url = '$apiUrl/users/login/email';
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
    String url = '$apiUrl/users/me';

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
    String url = '$apiUrl/users';

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

    String url = '$apiUrl/project/$uid';

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
    String url = '$apiUrl/project';

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
    String url = '$apiUrl/project/$projectId';

    final response = await delete(Uri.parse(url));

    if(response.statusCode != 200){
      throw Exception('프로젝트 삭제 실패');
    }
  }

  Future getGeneralData(int project_id) async {
    String url = '$apiUrl/general/$project_id';
    final response = await get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('일반 리스트 가져오기 실패');
    }
  }

  Future createGeneralData(Map<String, dynamic> data) async{
    String url = '$apiUrl/general/';

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

  Future updateGeneralData(Map<String, dynamic> data, int id) async{
    String url = '$apiUrl/general/$id';

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
    String url = '$apiUrl/general/$generalId';

    final response = await delete(Uri.parse(url));

    if(response.statusCode != 200){
      throw Exception('일반데이터 삭제 실패');
    }
  }

  Future getGeneralMedia(int general_id) async{
    String url = '$apiUrl/general/media/$general_id';

    final response = await get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('미디어 리스트 가져오기 실패');
    }
  }

  Future uploadGeneralMedia(Media file) async{
    String url = '$apiUrl/general/media';
    var request = MultipartRequest('POST', Uri.parse(url));
    request.files.add(await MultipartFile.fromBytes('file', file.bytes!,
      contentType: MediaType('application', 'octet-stream'),
      filename: file.name
    ));
    request.fields['parent_id'] = file.parentId.toString();
    request.fields['lat'] = file.lat.toString();
    request.fields['lon'] = file.lon.toString();

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);

    if(response.statusCode == 200){
      return jsonDecode(responseString);
    }else{
      throw Exception('uploadGeneralMedia 에러');
    }
  }

  Future deleteGeneralMedia(int media_id) async{
    String url = '$apiUrl/general/media/$media_id';

    var response = await delete(Uri.parse(url));

    if(response.statusCode != 200){
      throw Exception('미디어 삭제 실패');
    }
  }
}