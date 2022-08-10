import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastapi_project/firebase_album/media_page.dart';
import 'package:fastapi_project/firebase_login/bloc/auth_bloc.dart';

GlobalKey<ScaffoldState> mainPageKey = GlobalKey<ScaffoldState>();
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int tabIndex = 0;
  List<String> tabList = ['갤러리', '더보기'];
  List<IconData> tabIconList = [Icons.album_outlined, Icons.account_circle];

  Widget _mainContents(int index){
    List<Widget> mainContents = [
      MediaPage(title: tabList[index]),
      // Content for Feed tab
      Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TextButton(
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => ObjectDetectorView() ));
            //   },
            //   child: const Text('Object Detection', style: TextStyle(fontWeight: FontWeight.bold))
            // ),
            // const SizedBox(height: 5),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
              child: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.bold))
            )
          ],
        )
      ),
    ];
    return mainContents[index];
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: mainPageKey,
        body: Row(
          children: [
            // if(MediaQuery.of(context).size.width >= 640)
            //   NavigationRail(
            //     minWidth: 55,
            //     onDestinationSelected: (index) => setState(() => tabIndex = index),
            //     labelType: NavigationRailLabelType.all,
            //     selectedIndex: tabIndex,
            //     destinations: List.generate(tabList.length, (index) {
            //       return NavigationRailDestination(
            //           icon: Icon(tabIconList[index]), label: Text(tabList[index])
            //       );
            //     }),
            //   ),
            Expanded(child: _mainContents(tabIndex))
          ],
        ),
        // bottomNavigationBar: MediaQuery.of(context).size.width < 640 ? BottomNavigationBar(
        //   onTap: (index) => setState(() => tabIndex = index),
        //   currentIndex: tabIndex,
        //   items: List.generate(tabList.length, (index) {
        //     return BottomNavigationBarItem(
        //       icon: Icon(tabIconList[index]),
        //       label: tabList[index]
        //     );
        //   })
        // ) : null,
      ),
    );
  }
}
