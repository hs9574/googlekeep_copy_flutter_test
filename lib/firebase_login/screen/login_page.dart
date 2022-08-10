import 'package:fastapi_project/api.dart';
import 'package:fastapi_project/firebase_login/screen/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastapi_project/firebase_database/screen/project_page.dart';
import 'package:fastapi_project/firebase_login/bloc/auth_bloc.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:fastapi_project/widget/textfield_widget.dart';
import 'package:hive/hive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final user = Util.auth.currentUser;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  loadUser() async{
    print('object');
    await Api().getUser().then((value) async{
      if(value is Map && value.isNotEmpty){
        dbUser.email = value['email'];
        dbUser.userdept = value['userdept'];
        dbUser.usergrade = value['usergrade'];
        dbUser.username = value['username'];
        dbUser.usage = value['usage'].toDouble();
        dbUser.uid = value['uid'];
        context.read<AuthBloc>().add(tokenSignInRequested());
      }
      if(value is String && value == 'refresh'){
        var box = await Hive.box('token');
        await box.delete('access_token');
        context.read<AuthBloc>().add(SignOutRequested());
      }
    });
  }

  Widget loginView(UnAuthenticated state) {
    _emailController.text = '';
    _passwordController.text = '';
    return Container(
      height: 360,
      width: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[300],
      ),
      child: Column(children: [
        const Text('로그인 페이지'),
        const SizedBox(height: 10,),
        InkWell(
          onTap: (){
            context.read<AuthBloc>().add(GoogleSignInRequested());
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
                  const Text('구글 로그인', style: TextStyle(height: 1),),
                  Positioned(
                    left: 8,
                    child: Container(
                      width: 30,
                      height: 30,
                      child: const Image(image: AssetImage('assets/images/login_google.png'), fit: BoxFit.fill, height: 30, width: 30,),
                    ),
                  ),
                ]
            ),
          ),
        ),
        const SizedBox(height: 10,),
        InkWell(
          onTap: (){
            context.read<AuthBloc>().add(KakaoSignInRequested());
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
        ),
        const SizedBox(height: 10,),
        InkWell(
          onTap: (){
            context.read<AuthBloc>().add(NaverSignInRequested());
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
        const SizedBox(height: 10,),
        TextFieldWidget(
          controller: _emailController,
          hintText: 'Email',
          showBorder: true,
        ),
        const SizedBox(height: 5),
        TextFieldWidget(
          controller: _passwordController,
          hintText: 'Password',
          showBorder: true,
        ),
        if(state.error != '') const SizedBox(height: 5),
        if(state.error != '') Text(state.error, style: const TextStyle(color: Colors.red)),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                child: const Text('회원가입'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.cyan
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                },
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: ElevatedButton(
                child: const Text('로그인'),
                style: ElevatedButton.styleFrom(
                    primary: Colors.cyan
                ),
                onPressed: () {
                  context.read<AuthBloc>().add(SignInRequested(_emailController.text, _passwordController.text));
                },
              ),
            ),
          ],
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state){
            if(state is Loading){
              return const CircularProgressIndicator();
            }else if(state is UnAuthenticated){
              return loginView(state);
            }else if(state is Authenticated){
              return const ProjectPage();
            }else{
              return Container();
            }
          },
        ),
      ),
    );
  }
}
