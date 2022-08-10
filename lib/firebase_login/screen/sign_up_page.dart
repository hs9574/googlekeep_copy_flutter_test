import 'package:fastapi_project/api.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:fastapi_project/widget/textfield_widget.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _gradeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFieldWidget(
              controller: _emailController,
              hintText: 'Email',
              showBorder: true,
            ),
            const SizedBox(height: 10),
            TextFieldWidget(
              controller: _passwordController,
              hintText: 'Password',
              showBorder: true,
            ),
            const SizedBox(height: 10),
            TextFieldWidget(
              controller: _nameController,
              hintText: 'Name',
              showBorder: true,
            ),
            const SizedBox(height: 10),
            TextFieldWidget(
              controller: _gradeController,
              hintText: 'Grade',
              showBorder: true,
            ),
            ElevatedButton(
              child: const Text('회원가입'),
              style: ElevatedButton.styleFrom(
                  primary: Colors.cyan
              ),
              onPressed: () async{
                if(_emailController.text == ''){
                  Util.toastMessage('이메일을 입력하세요.');
                  return;
                }
                if(_passwordController.text == ''){
                  Util.toastMessage('비밀번호를 입력하세요.');
                  return;
                }
                if(_nameController.text == ''){
                  Util.toastMessage('이름을 입력하세요.');
                  return;
                }
                if(_gradeController.text == ''){
                  Util.toastMessage('직책을 입력하세요.');
                  return;
                }
                Map<String, String> user = {
                  "email" : _emailController.text,
                  "password" : _passwordController.text,
                  "username" : _nameController.text,
                  "usergrade" : _gradeController.text
                };
                await Api().createUser(user).then((value) {
                  if(value != null){
                    Util.toastMessage('회원가입이 완료되었습니다.');
                    Navigator.pop(context);
                  }else{
                    Util.toastMessage('존재하는 이메일입니다.');
                  }
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
