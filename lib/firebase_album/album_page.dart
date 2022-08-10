import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastapi_project/firebase_database/bloc/project_bloc.dart';
import 'package:fastapi_project/firebase_database/models/project_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fastapi_project/firebase_album/album_model.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class AlbumPage extends StatefulWidget {
  bool removeMode;
  AlbumPage({Key? key, this.removeMode = false}) : super(key: key);

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  List<XFile> fileList = [];
  Project project = Project.getInstance();
  ValueNotifier checkList = ValueNotifier<List<bool>>([]);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget fileTypeWidget(Album album, bool isThumbNail) {
    String extension = Util.checkMediaTypeToUpperCase(album.name);
    Widget widget = Container();
    // switch(extension){
    //   case 'PNG':
    //   case 'JPG':
    //   case 'JPEG':
    //     widget = ImageViewWidget(album: album, isThumbNail: isThumbNail);
    //     break;
    //   case 'MP4':
    //   case 'WEBM':
    //     widget = VideoPlayerWidget(album: album, isThumbNail: isThumbNail);
    //     break;
    // }
    return widget;
  }

  printExifOf(XFile file) async {
    final fileBytes = await file.readAsBytes();
    final data = await readExifFromBytes(fileBytes);

    if (data.isEmpty) {
      print("No EXIF information found");
      return;
    }

    if (data.containsKey('JPEGThumbnail')) {
      print('File has JPEG thumbnail');
      data.remove('JPEGThumbnail');
    }
    if (data.containsKey('TIFFThumbnail')) {
      print('File has TIFF thumbnail');
      data.remove('TIFFThumbnail');
    }

    for (final entry in data.entries) {
      print("${entry.key}: ${entry.value}");
    }
  }

  void storageUpload(List<XFile> files) async{
    Reference storageRef = Util.storage.ref().child('project_album').child('${project.projectId}');
    final DBRef = Util.db.collection('album').doc('${project.projectId}');
    for(XFile file in fileList){
      printExifOf(file);
      String storageUrl = '';
      try{
        await storageRef.child(file.name).putData(await file.readAsBytes()).then((task) async{
          storageUrl = await task.ref.getDownloadURL();
        });

        int newId = 0;
        await DBRef.get().then((media) async{
          List items = media.exists ? media.get('items') : [];
          items.sort((a,b) => a['id'].compareTo(b['id']));
          newId = items.isNotEmpty ? items.last['id'] + 1 : 0;
        });
        Album album = Album(
          name: file.name,
          etc: '',
          dateCreated: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          url: storageUrl,
          id: newId
        );
        await DBRef.get().then((value) async{
          if(value.exists){
            await DBRef.update({
              "items" : FieldValue.arrayUnion([album.toFirestore()])
            });
          }else{
            await DBRef.set({
              'items' : FieldValue.arrayUnion([album.toFirestore()])
            });
          }
        });
      } on FirebaseException catch (e){
        print(e.code);
      }
    }
  }

  void showBottomSheet(Album album){
    final PopupController popupLayerController = PopupController();
    showModalBottomSheet(
      enableDrag: false,
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(5),
          height: MediaQuery.of(context).size.height * 0.5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('날짜 : ${album.dateCreated}', style: const TextStyle(fontSize: 15)),
                if(album.etc != '') Text('메모 : ${album.etc}', style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 5),
                album.lat != 0 ? SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(album.lat, album.lon),
                      zoom: 11,
                      maxZoom: 18,
                      minZoom: 6,
                      interactiveFlags: InteractiveFlag.drag | InteractiveFlag.doubleTapZoom | InteractiveFlag.pinchZoom | InteractiveFlag.pinchMove,
                      onTap: (position, latlng){
                        popupLayerController.hideAllPopups();
                      }
                    ),
                    nonRotatedChildren: [
                      TileLayerWidget(
                        options: TileLayerOptions(
                          urlTemplate: 'http://api.vworld.kr/req/wmts/1.0.0/$VWORD_MAP_KEY/Base/{z}/{y}/{x}.png',
                          subdomains: ['a', 'b', 'c'],
                        )
                      ),
                      PopupMarkerLayerWidget(
                        options: PopupMarkerLayerOptions(
                          popupController: popupLayerController,
                          markerCenterAnimation: const MarkerCenterAnimation(),
                          markers: [Util.defaultMarker(album.lat, album.lon)],
                          popupBuilder: (context, marker) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black87.withOpacity(0.3),
                                    spreadRadius: 0,
                                    blurRadius: 2,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('날짜 : ${album.dateCreated}', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            );
                          }
                        )
                      )
                    ],
                  ),
                ): const SizedBox(
                  height: 200,
                  child: Center(child: Text('위치가 없습니다.')),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state){
          if(state is ProjectInitial){
            return Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 100, color: Colors.grey[300]!,),
                    const SizedBox(height: 8),
                    Text('프로젝트를 선택하세요.', style: TextStyle(color: Colors.grey[400]!,),),
                  ],
                ),
              ),
            );
          }else if(state is Selected){
            project = state.project;
            return GestureDetector(
              onTap: widget.removeMode == true ? (){
                setState((){
                  widget.removeMode = false;
                });
              } : null,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: Util.db.collection('album').doc('${project.projectId}').snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      List imageList = snapshot.data!.exists ? (snapshot.data!.data() as Map<String, dynamic>)['items'] : [];
                      checkList.value = List.filled(imageList.length, false);
                      return imageList.isNotEmpty ? Stack(
                        alignment: Alignment.center,
                        children: [
                          GridView.count(
                            crossAxisCount: kIsWeb ? 10 : 3,
                            mainAxisSpacing: 5,
                            children: List.generate(imageList.length, (index) {
                              Album item = Album.fromFireStore(imageList[index]);
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: (){
                                      // Navigator.push(context, MaterialPageRoute(builder: (context) => fileTypeWidget(item, false)));
                                      showBottomSheet(item);
                                    },
                                    onLongPress: (){
                                      setState((){
                                        widget.removeMode = true;
                                      });
                                    },
                                    child: ValueListenableBuilder(
                                      valueListenable: checkList,
                                      builder: (_, checks, __){
                                        checks as List<bool>;
                                        return Stack(
                                          children: [
                                            SizedBox(
                                              height: 110,
                                              width: 110,
                                              child: fileTypeWidget(item, true),
                                            ),
                                            if(widget.removeMode == true) Positioned(
                                              top: kIsWeb ? 0 : -10,
                                              left: kIsWeb ? 0 : -10,
                                              child: Checkbox(
                                                value: checks[index],
                                                onChanged: (val){
                                                  checks[index] = val!;
                                                  checkList.notifyListeners();
                                                }
                                              )
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  Text(item.dateCreated, style: TextStyle(fontSize: 12))
                                ],
                              );
                            }),
                          ),
                          ValueListenableBuilder(
                            valueListenable: checkList,
                            builder: (context, list, _){
                              list as List;
                              if(list.any((element) => element == true)){
                                return Positioned(
                                  top: 0,
                                  child: Container(
                                    height: 30,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Center(child: Text('삭제', style: TextStyle(fontSize: 12, color: Colors.white))),
                                  )
                                );
                              }else{
                                return Container();
                              }
                            }
                          )
                        ],
                      ) : Container(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, size: 100, color: Colors.grey[300]!,),
                              const SizedBox(height: 8),
                              Text('이미지가 없습니다.', style: TextStyle(color: Colors.grey[400]!,),),
                            ],
                          ),
                        ),
                      );
                    }else{
                      return CircularProgressIndicator();
                    }
                  }
                ),
              ),
            );
          }
          return Container();
        }
      ),
      floatingActionButton: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          if(state is Selected){
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  iconSize: 50,
                  color: Colors.blue,
                  onPressed: () async{
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
                                    Navigator.pop(context);
                                    fileList = await Util.getImage(ImageSource.camera);
                                    storageUpload(fileList);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                    child: const Text('사진 촬영하여 업로드', style: TextStyle(fontSize: 13)),
                                  ),
                                ),
                                Container(color: Colors.black26, height: 1),
                                InkWell(
                                  onTap: () async{
                                    Navigator.pop(context);
                                    fileList = await Util.getImage(ImageSource.gallery);
                                    storageUpload(fileList);
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
                  },
                  icon: Icon(Icons.image)
                ),
                IconButton(
                    iconSize: 50,
                    color: Colors.blue,
                    onPressed: () async{
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
                                      Navigator.pop(context);
                                      fileList = await Util.getVideo(ImageSource.camera);
                                      storageUpload(fileList);
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                      child: const Text('동영상 촬영하여 업로드', style: TextStyle(fontSize: 13)),
                                    ),
                                  ),
                                  Container(color: Colors.black26, height: 1),
                                  InkWell(
                                    onTap: () async{
                                      Navigator.pop(context);
                                      fileList = await Util.getVideo(ImageSource.gallery);
                                      storageUpload(fileList);
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
                    },
                    icon: Icon(Icons.video_call)
                )
              ],
            );
          }else{
            return Container();
          }
        }
      ),
    );
  }
}
