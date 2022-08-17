import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastapi_project/custom_scroll_behavior.dart';
import 'package:fastapi_project/firebase_database/bloc/project_bloc.dart';
import 'package:fastapi_project/firebase_login/bloc/auth_bloc.dart';
import 'package:fastapi_project/firebase_login/screen/login_page.dart';
import 'package:hive/hive.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:path_provider/path_provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  var appDir = await getApplicationDocumentsDirectory();
  await Hive..init(appDir.path);
  await Hive.openBox('token');
  KakaoSdk.init(nativeAppKey: '1181d61886d85a77f2fd778c15c422d8');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => ProjectBloc())
      ],
      child: Listener(
        onPointerDown: (_){
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
            FocusManager.instance.primaryFocus!.unfocus();
          }
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          scrollBehavior: CustomScrollBehavior(),
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xfff3f6fc),
              titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
              iconTheme: IconThemeData(color: Colors.black),
            )
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark
          ),
          themeMode: ThemeMode.system,
          home: const LoginPage(),
        ),
      ),
    );
  }
}