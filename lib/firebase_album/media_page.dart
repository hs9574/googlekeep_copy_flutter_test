import 'dart:async';

import 'package:intl/intl.dart';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastapi_project/api.dart';
import 'package:fastapi_project/firebase_database/bloc/project_bloc.dart';
import 'package:fastapi_project/firebase_database/models/general_model.dart';
import 'package:fastapi_project/firebase_database/models/project_model.dart';
import 'package:fastapi_project/firebase_database/screen/add_data.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:fastapi_project/widget/appbar_widget.dart';
import 'package:fastapi_project/widget/image_view_widget.dart';
import 'package:fastapi_project/widget/video_player_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaPage extends StatefulWidget {
  final String title;
  const MediaPage({Key? key, required this.title}) : super(key: key);

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  bool removeMode = false;
  bool isGridView = false;
  List<General> removeList = [];
  Project _selectedProject = Project.getInstance();
  int _bottomNavIndex = 0;

  List<String> conditionList = ['날짜순', '제목순'];
  String condition = '날짜순';
  TextEditingController searchController = TextEditingController();

  List<Media> selectFileList = [];

  StreamController<List<General>> _generalStream = StreamController();

  loadGeneral(int projectId) async{
    await Api().getGeneralData(projectId).then((value) {
      List<General> generalList = [];
      for(var item in value){
        generalList.add(General.fromJson(item));
      }
      _generalStream.add(generalList);
    });
  }
  
  void mediaPick({required bool isImage}) async{
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async{
                    getMedia(ImageSource.camera, isImage: isImage? true : false);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text(isImage ? '사진 촬영하여 업로드' : '동영상 촬영하여 업로드', style: TextStyle(fontSize: 13)),
                  ),
                ),
                Container(color: Colors.black26, height: 1),
                InkWell(
                  onTap: () async{
                    getMedia(ImageSource.gallery, isImage: isImage? true : false);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: const Text('파일에서 업로드', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void getMedia(ImageSource imageSource, {bool isImage = true}) async{
    List<XFile> files = [];
    if(isImage){
      files = await Util.getImage(imageSource);
    }else{
      files = await Util.getVideo(imageSource);
    }
    if(files.isNotEmpty){
      int mediaIndex = selectFileList.isEmpty ? 0 : (selectFileList.last.id + 1);
      for(XFile element in files){
        Media media = Media(
          id: mediaIndex,
          url: element.path,
          bytes: await element.readAsBytes(),
          dateCreated: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          name: element.name,
          isSaved: false,
        );
        selectFileList.add(media);
        mediaIndex++;
      }
      setState((){});
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddDataWidget(
      projectId: _selectedProject.projectId,
      fileList: selectFileList,
      refresh: loadGeneral,
    )));
  }

  Widget fileTypeWidget(Media media, bool isThumbNail) {
    String extension = Util.checkMediaTypeToUpperCase(media.name);
    Widget widget = Container();
    switch(extension){
      case 'PNG':
      case 'JPG':
      case 'JPEG':
        if(isThumbNail){
          widget = ImageThumbNailWidget(media: media);
        }else{
          widget = ImageFullViewWidget(media: media);
        }
        break;
      case 'MP4':
      case 'WEBM':
        if(isThumbNail){
          widget = VideoThumbNailWidget(media: media);
        }else{
          widget = VideoPlayerWidget(media: media);
        }
        break;
    }
    return widget;
  }

  List<General> conditionSetList(List<General> list){
    switch(condition){
      case '날짜순':
        list.sort((a, b) => -a.dateCreated.compareTo(b.dateCreated));
        break;
      case '제목순':
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return list;
  }

  Widget _mainView(){
    return GestureDetector(
      onTap: removeList.isNotEmpty ? (){
        setState(() {
          removeList.clear();
          removeMode =false;
        });
      } : null,
      child: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state){
          if(state is ProjectInitial){
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 100, color: Colors.grey[300]!,),
                  const SizedBox(height: 8),
                  Text('프로젝트를 선택하세요.', style: TextStyle(color: Colors.grey[400]!,),),
                ],
              ),
            );
          }else if(state is Selected){
            _selectedProject = state.project;
            loadGeneral(_selectedProject.projectId);
            return StreamBuilder<List<General>>(
              stream: _generalStream.stream,
              builder: (context, snapshot){
                if(snapshot.hasData){
                  List<General> itemList = snapshot.data!;
                  itemList = conditionSetList(itemList);
                  itemList = itemList.where((element) => element.title.contains(searchController.text)).toList();
                  return MasonryGridView.count(
                    crossAxisCount: isGridView ? 2 : 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 8,
                    itemCount: itemList.length,
                    itemBuilder: (context, index) {
                      var item = itemList[index];
                      return InkWell(
                        onTap: (){
                          if(removeMode){
                            setState((){
                              if(removeList.any((element) => element.id == item.id)){
                                removeList.removeWhere((element) => element.id == item.id);
                              }else{
                                removeList.add(item);
                              }
                              if(removeList.isEmpty){
                                removeMode =false;
                              }
                            });
                          }else{
                            List<General> list = [];
                            for(var it in itemList){
                              list.add(it);
                            }
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => AddDataWidget(
                                projectId: _selectedProject.projectId,
                                item: item,
                                itemList: list,
                                refresh: loadGeneral,
                              )
                            ));
                          }
                        },
                        onLongPress: (){
                          setState((){
                            removeMode = true;
                            removeList.add(item);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xffd5d7d6)
                            ),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          foregroundDecoration: removeList.any((element) => element.id == item.id) ? BoxDecoration(
                            border: Border.all(color: const Color(0xff0b57d0), width: 3),
                            borderRadius: BorderRadius.circular(10)
                          ) : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                child: Column(
                                  children: List.generate(item.mediaList.length~/3 + 1, (i) {
                                    int rowIndex = i == item.mediaList.length~/3 ? item.mediaList.length%3 : 3;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: FittedBox(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(minWidth: 1, minHeight: 1),
                                          child: Row(
                                            children: List.generate(rowIndex, (j) {
                                              int index = (i*3)+j;
                                              Media media = item.mediaList[index];
                                              return Padding(
                                                padding: j != rowIndex - 1 ? EdgeInsets.only(right: rowIndex == 2 ? 20 : 50) : EdgeInsets.zero,
                                                child: SizedBox(
                                                  height: MediaQuery.of(context).size.height,
                                                  child: fileTypeWidget(media, true)
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if(item.title != '') Text(item.title, style: const TextStyle(fontSize: 17)),
                                    if(item.memo != '') const SizedBox(height: 10),
                                    if(item.memo != '') Text(item.memo, style: TextStyle(color: Theme.of(context).brightness.name == 'light' ? Colors.black54 : null))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }else{
                  return const CircularProgressIndicator();
                }
              }
            );
          }
          return Container();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, isScroll){
           return [
             SliverAppBar(
               toolbarHeight: 70,
               flexibleSpace: Padding(
                 padding: const EdgeInsets.all(10),
                 child: TextFieldAppBarWidget(
                   controller: searchController,
                   prefixIcon: [
                     PopupMenuButton(
                         icon: const Icon(Icons.arrow_drop_down_outlined),
                         onSelected: (val){
                           setState((){
                             condition = val.toString();
                           });
                         },
                         position: PopupMenuPosition.under,
                         itemBuilder: (context) {
                           return conditionList.map((e) {
                             return PopupMenuItem(
                               value: e,
                               textStyle: const TextStyle(fontSize: 12, color: Colors.black),
                               height: 25,
                               child: Center(child: Text(e)),
                             );
                           }).toList();
                         }
                     ),
                     InkWell(
                       onTap: (){
                         setState((){
                           isGridView =!isGridView;
                         });
                       },
                       child: Icon(isGridView ? Icons.splitscreen : Icons.grid_view)
                     ),
                   ],
                   hintText: '메모 검색',
                   onSubmitted: (val){
                     setState((){
                       searchController.text = val.toString();
                     });
                   },
                   onTapTextField: (){
                     if(MediaQuery.of(context).viewInsets.bottom > 0){
                       FocusScope.of(context).unfocus();
                     }
                   },
                 ),
               ),
               leading: Container(),
               backgroundColor: Colors.transparent,
             )
           ];
        },
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _mainView(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xfff2f5fb),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        onPressed: () async{
          if(removeMode){
            for(General item in removeList){
              await Api().deleteGeneralData(item.id).whenComplete(() async{
                // for(Media media in item.mediaList){
                //   await Api().deleteGeneralMedia(_selectedProject.projectId, media.name);
                // }
              });
            }
            setState((){
              removeList.clear();
              removeMode =false;
            });
          }else{
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => AddDataWidget(
                projectId: _selectedProject.projectId,
                refresh: loadGeneral,
              )
            ));
          }
        },
        child: Icon(removeMode ? Icons.remove : Icons.add, size: 40, color: Colors.blue),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: const [Icons.photo_outlined, Icons.video_call_outlined],
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.end,
        backgroundColor: const Color(0xfff2f5fb),
        notchSmoothness: NotchSmoothness.defaultEdge,
        onTap: (index) {
          if(index == 0){
            mediaPick(isImage: true);
          }else if(index == 1){
            mediaPick(isImage: false);
          }
        },
        gapWidth: 300,
      ),
    );
  }
}
