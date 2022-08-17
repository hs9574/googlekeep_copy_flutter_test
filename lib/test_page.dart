import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  void socialLogIn(String social) async{

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
