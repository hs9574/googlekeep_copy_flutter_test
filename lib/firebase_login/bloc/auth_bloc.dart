import 'package:bloc/bloc.dart';
import 'package:fastapi_project/api.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart' as naver;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(UnAuthenticated()) {
    on<tokenSignInRequested>((event, emit){
      emit(Authenticated());
    });

    on<SignInRequested>((event, emit) async{
      emit(Loading());
      try{
        await Api().userLogin(event.email, event.password).then((value) async{
          var box = await Hive.box('token');
          box.put('access_token', value['access_token']);
          emit(Authenticated());
        });
      } catch (e) {
        String errorMsg = e.toString();
        emit(UnAuthenticated(error: errorMsg));
      }
    });

    on<GoogleSignInRequested>((event, emit) async{
      try {
        await Util.googleSignIn.signIn().then((GoogleSignInAccount? acc) async{
          emit(Loading());
          await acc!.authentication.then((auth) async{
            if (auth.idToken == '' || auth.accessToken == '') {
              print('GoogleSignInAuthentication Error. Retry...');
              await Util.googleSignIn.disconnect();
            }else{
              await Api().googleLogin(auth.idToken!, auth.accessToken!).then((value) async{
                var box = await Hive.box('token');
                box.put('access_token', value['access_token']);
                emit(Authenticated());
              });
            }
          });
        });
      } catch (e) {
        emit(UnAuthenticated());
      }
    });

    on<KakaoSignInRequested>((event, emit) async{
      emit(Loading());
      final kakao.OAuthToken kakaoToken;
      try {
        if(await kakao.isKakaoTalkInstalled()){
          kakaoToken = await kakao.UserApi.instance.loginWithKakaoTalk();
        }else{
          kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
        await Api().kakaoLogin(kakaoToken.accessToken).then((value) async{
          var box = await Hive.box('token');
          box.put('access_token', value['access_token']);
          emit(Authenticated());
        });
      } catch (error) {
        if (error is PlatformException && error.code == 'CANCELED') {
          emit(UnAuthenticated());
          return;
        }
        emit(UnAuthenticated());
      }
    });

    on<NaverSignInRequested>((event, emit) async{
      emit(Loading());
      try{
        await naver.FlutterNaverLogin.logIn().then((value) async{
          naver.NaverAccessToken naverToken = await naver.FlutterNaverLogin.currentAccessToken;
          await Api().naverLogin(naverToken.accessToken).then((value) async{
            var box = await Hive.box('token');
            box.put('access_token', value['access_token']);
            emit(Authenticated());
          });
        });
      } catch (e){
        print('네이버 로그인 실패 $e');
        emit(UnAuthenticated());
      }
    });

    on<SignOutRequested>((event, emit) async{
      emit(Loading());
      await Util.googleSignIn.isSignedIn().then((isSign) async{
        if(isSign){
          await Util.googleSignIn.disconnect();
        }
      });
      bool kakaoHasToken = await kakao.AuthApi.instance.hasToken();
      if(kakaoHasToken){
        await kakao.UserApi.instance.logout();
      }
      bool isNaverLogin = await naver.FlutterNaverLogin.isLoggedIn;
      if(isNaverLogin){
        await naver.FlutterNaverLogin.logOutAndDeleteToken();
      }
      var box = Hive.box('token');
      await box.delete('access_token');
      emit(UnAuthenticated());
    });
  }
}
