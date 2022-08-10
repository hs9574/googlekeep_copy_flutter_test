import 'package:http/http.dart' as http;

class FirebaseAuthRemoteDataSource {
  final String kakaoUrl = 'https://wary-plausible-stock.glitch.me/callbacks/kakao/token';
  final String naverUrl = 'https://wary-plausible-stock.glitch.me/callbacks/naver/token';

  Future<String> createCustomToken(Map<String, dynamic> token, String loginType) async{
    if(loginType == 'kakao'){
      final customTokenResponse = await http.post(Uri.parse(kakaoUrl), body: token);
      return customTokenResponse.body;
    }else if(loginType == 'naver'){
      final customTokenResponse = await http.post(Uri.parse(naverUrl), body: token);
      return customTokenResponse.body;
    }
    return '';
  }
}