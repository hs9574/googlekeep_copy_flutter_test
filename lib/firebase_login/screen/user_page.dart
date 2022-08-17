import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastapi_project/firebase_database/screen/project_page.dart';
import 'package:fastapi_project/firebase_login/bloc/auth_bloc.dart';
import 'package:fastapi_project/firebase_login/model/user_model.dart';
import 'package:fastapi_project/widget/alert_dialog_widget.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialogWidget(
      title: '회원 정보',
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_circle, size: 100, color: Colors.grey[300]),
            // : SizedBox(
            //   width: 100,
            //   height: 100,
            //   child: ClipRRect(
            //       borderRadius: BorderRadius.circular(30),
            //       child: Image.network(user.photoURL??'', fit: BoxFit.cover)
            //   ),
            // ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('이름'),
                    SizedBox(height: 5),
                    Text('이메일'),
                    SizedBox(height: 5),
                    Text('소속'),
                    SizedBox(height: 5),
                    Text('직급'),
                    SizedBox(height: 5),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dbUser.username),
                    const SizedBox(height: 5),
                    Text(dbUser.email),
                    const SizedBox(height: 5),
                    Text(dbUser.userdept),
                    const SizedBox(height: 5),
                    Text(dbUser.usergrade),
                    const SizedBox(height: 5),
                  ],
                )
              ],
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.cloud_outlined),
                    SizedBox(width: 10),
                    Text('저장용량')
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[200]!
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: dbUser.usage,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.blue
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 10,
                          color: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('1GB 중 ${dbUser.usage}MB 사용', style: TextStyle(fontSize: 12))
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                context.read<AuthBloc>().add(SignOutRequested());
                dbUser = DBUser();
                Navigator.pop(context);
              },
              child: Text('로그아웃', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).buttonTheme.colorScheme!.primary))
            )
          ],
        ),
      ),
    );
  }
}
