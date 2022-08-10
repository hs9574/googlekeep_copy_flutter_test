import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fastapi_project/firebase_login/firebase_auth_remote_data_source.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart' as naver;

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _firebaseAuthDataSource = FirebaseAuthRemoteDataSource();

  void socialLogIn(String social) async{
    print(Util.auth.currentUser!.email);
    if(social == 'kakao'){
      final kakao.OAuthToken kakaoToken;
      try {
        if(await kakao.isKakaoTalkInstalled()){
          kakaoToken = await kakao.UserApi.instance.loginWithKakaoTalk();
        }else{
          kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
        final token = await _firebaseAuthDataSource.createCustomToken({
          "accessToken" : kakaoToken.accessToken
        }, 'kakao');

        await Util.auth.signInWithCustomToken(token);
        print(Util.auth.currentUser!.displayName);
        print(Util.auth.currentUser!.email);
        print(Util.auth.currentUser!.uid);
      } on kakao.KakaoAuthException catch (error) {
        print('카카오톡으로 로그인 실패 ${error.message}');

      }
    }else if(social == 'naver'){
      await naver.FlutterNaverLogin.isLoggedIn.then((value) async{
        if(value){
          await naver.FlutterNaverLogin.logOutAndDeleteToken();
        }else {
          naver.NaverLoginResult res = await naver.FlutterNaverLogin.logIn();
          print(res.account.nickname);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: (){
                socialLogIn('naver');
              },
              child: Container(
                width: 300,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: Colors.grey),
                ),
                child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text('네이버 로그인', style: TextStyle(height: 1),),
                      Positioned(
                        left: 8,
                        child: Container(
                          width: 30,
                          height: 30,
                          child: const Image(image: AssetImage('assets/images/login_naver.png'), fit: BoxFit.fill, height: 30, width: 30,),
                        ),
                      ),
                    ]
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: (){
                socialLogIn('kakao');
              },
              child: Container(
                width: 300,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: Colors.grey),
                ),
                child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text('카카오 로그인', style: TextStyle(height: 1),),
                      Positioned(
                        left: 8,
                        child: Container(
                          width: 30,
                          height: 30,
                          child: const Image(image: AssetImage('assets/images/login_kakao.png'), fit: BoxFit.fill, height: 30, width: 30,),
                        ),
                      ),
                    ]
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
