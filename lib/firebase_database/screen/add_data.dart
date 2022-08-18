import 'dart:async';

import 'package:fastapi_project/api.dart';
import 'package:fastapi_project/firebase_database/models/general_model.dart';
import 'package:fastapi_project/firebase_database/screen/project_page.dart';
import 'package:fastapi_project/widget/image_view_widget.dart';
import 'package:fastapi_project/widget/slide_widget.dart';
import 'package:fastapi_project/widget/video_player_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:fastapi_project/widget/textfield_widget.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AddDataWidget extends StatefulWidget {
  final int projectId;
  General? item;
  List<General>? itemList;
  List<Media> fileList;
  Function? refresh;

  AddDataWidget({
    required this.projectId,
    this.item,
    this.itemList,
    this.fileList = const [],
    this.refresh
  });

  @override
  _AddDataWidgetState createState() => _AddDataWidgetState();
}

class _AddDataWidgetState extends State<AddDataWidget> {
  bool check = false;
  Map<String, TextEditingController> _textControllerMap = {};
  List<String> _defaultInfoList = ['제목','메모'];
  List<Media> mediaList = [];
  bool loading = false;

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
      int mediaIndex = mediaList.isEmpty ? 0 : (mediaList.last.id + 1);
      for(XFile element in files){
        Media media = Media(
          id: mediaIndex,
          url: element.path,
          bytes: await element.readAsBytes(),
          dateCreated: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          name: element.name,
          isSaved: false,
        );
        mediaList.add(media);
        mediaIndex++;
      }
      setState((){});
    }
  }

  Future uploadData() async{
    bool noSave = _validCheck();
    if(noSave){
      Navigator.pop(context);
      Util.toastMessage('빈 메모가 삭제되었습니다.');
    }else{
      setState((){
        loading = true;
      });
      General item = General.getInstance();
      if(widget.item == null){
        item = General(
          userId: dbUser.uid,
          projectId: widget.projectId,
          dateCreated: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          title: _textControllerMap['제목']!.text,
          memo: _textControllerMap['메모']!.text,
          mediaList: mediaList.where((element) => element.isRemoved == false).toList()
        );
        await Api().createGeneralData(item.toJson()).then((value) async{
          await uploadStorage(value['cnt']);
        });
      }else{
        await uploadStorage(widget.item!.id);
        item = General(
          id: widget.item!.id,
          userId: dbUser.uid,
          projectId: widget.projectId,
          dateCreated: widget.item!.dateCreated,
          title: _textControllerMap['제목']!.text,
          memo: _textControllerMap['메모']!.text,
          mediaList: mediaList.where((element) => element.isRemoved == false).toList()
        );
        await Api().updateGeneralData(item.toJson(), item.id);
      }
      setState((){
        loading = false;
      });
      if(mounted){
        widget.refresh!(item.projectId);
        Navigator.pop(context);
      }
    }
  }

  Future uploadStorage(int itemId) async{
    for(Media file in mediaList){
      file.parentId = itemId;
      if(!file.isSaved && !file.isRemoved){
        await Api().uploadGeneralMedia(file).then((value) {
          file.url = value['url'];
        });
      }else if(file.isSaved && file.isRemoved){
        await Api().deleteGeneralMedia(file.id);
      }
    }
  }

  bool _validCheck(){
    bool isNone = false;
    if(_textControllerMap['제목']!.text.toString().trim() == '' && _textControllerMap['메모']!.text.toString().trim() == '' && mediaList.isEmpty){
      isNone = true;
    }
    return isNone;
  }

  Widget fileTypeWidget(Media media, bool isThumbNail) {
    String extension = Util.checkMediaTypeToUpperCase(media.url);
    Widget widget = Container();
    switch(extension){
      case 'PNG':
      case 'JPG':
      case 'JPEG':
        if(isThumbNail){
          widget = ImageThumbNailWidget(media: media);
        }else{
          widget = ImageFullViewWidget(mediaList: mediaList, media: media);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.item == null){
      _defaultInfoList.forEach((element) {
        TextEditingController controller = TextEditingController();
        _textControllerMap[element] = controller;
      });
      mediaList = List.from(widget.fileList);
    }else{
      _defaultInfoList.forEach((element) {
        TextEditingController controller = TextEditingController();
        controller.text = (widget.item!.getParameter(element)).toString();
        _textControllerMap[element] = controller;
      });

      mediaList = List.from(widget.item!.mediaList);
      mediaList.sort((a,b) => a.id.compareTo(b.id));
    }
  }

  void removeMedia(int mediaId) {
    setState((){
      mediaList.singleWhere((element) => element.id == mediaId).isRemoved = true;
    });
  }

  Widget _body(){
    List<Media> medias = mediaList.where((element) => element.isRemoved == false).toList();
    return Column(
      children: [
        if(medias.isNotEmpty) Column(
          children: List.generate(medias.length~/3 + 1, (i) {
            int rowIndex = i == medias.length~/3 ? medias.length%3 : 3;
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: FittedBox(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1, minHeight: 1),
                  child: Row(
                    children: List.generate(rowIndex, (j) {
                      int index = (i*3)+j;
                      Media media = medias[index];
                      return Padding(
                        padding: j != rowIndex - 1 ? EdgeInsets.only(right: rowIndex == 2 ? 20 : 50) : EdgeInsets.zero,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: InkWell(
                            onTap:(){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SlideWidget(
                                mediaList: medias,
                                selectedIndex: index,
                                remove: removeMedia,
                              )));
                            },
                            child: Hero(
                              tag: media.id,
                              child: fileTypeWidget(media, true)
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            );
          }),
        ),
        TextFieldWidget(
          controller: _textControllerMap['제목']!,
          hintText: '제목',
          textStyle: const TextStyle(fontSize: 23),
        ),
        TextFieldWidget(
          controller: _textControllerMap['메모']!,
          hintText: '내용',
          textStyle: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _bottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        children: [
          IconButton(
            iconSize: 24,
            tooltip: '이미지 업로드',
            onPressed: () async{
              mediaPick(isImage: true);
            },
            icon: Icon(Icons.add_photo_alternate_outlined)
          ),
          const SizedBox(width: 5),
          IconButton(
            iconSize: 28,
            padding: EdgeInsets.only(top: 3),
            tooltip: '동영상 업로드',
            onPressed: () async{
              mediaPick(isImage: false);
            },
            icon: Icon(Icons.video_call_outlined)
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leadingWidth: 45,
            leading: InkWell(
              onTap: () async{
                await uploadData();
              },
              child: const Icon(Icons.arrow_back, color: Colors.black54,)
            ),
          ),
          body: Column(
            children: [
              Expanded(child: SingleChildScrollView(
                child: _body(),
              )),
              _bottomBar()
            ],
          ),
        ),
        if(loading) AbsorbPointer(
          child: Container(
            color: Colors.white.withOpacity(0.7),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        )
      ],
    );
  }
}