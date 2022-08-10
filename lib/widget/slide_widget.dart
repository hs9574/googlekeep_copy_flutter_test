import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fastapi_project/firebase_database/models/general_model.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:fastapi_project/widget/drag_bottom_sheet_widget.dart';
import 'package:fastapi_project/widget/image_view_widget.dart';
import 'package:fastapi_project/widget/video_player_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';

class SlideWidget extends StatefulWidget {
  final List<Media> mediaList;
  final int selectedIndex;
  final Function? remove;
  const SlideWidget({Key? key, required this.mediaList, this.selectedIndex = 0, this.remove}) : super(key: key);

  @override
  State<SlideWidget> createState() => _SlideWidgetState();
}

class _SlideWidgetState extends State<SlideWidget> {
  int page = 0;
  List<Media> medias = [];

  double minHeight = 0;
  double maxHeight = 400;
  double onPanHeight = 0;
  bool isDragSheet = false;

  final PopupController popupLayerController = PopupController();

  Widget fileTypeWidget(Media media) {
    String extension = Util.checkMediaTypeToUpperCase(media.name);
    Widget widget = Container();
    switch(extension){
      case 'PNG':
      case 'JPG':
      case 'JPEG':
        widget = ImageFullViewWidget(media: media);
        break;
      case 'MP4':
      case 'WEBM':
        widget = VideoPlayerWidget(media: media);
        break;
    }
    return widget;
  }

  Widget bottomSheet(){
    return DragBottomSheetWidget(
      maxHeight: 400,
      minHeight: 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('날짜 : ${medias[page].dateCreated}', style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 5),
          medias[page].lat != 0 ? SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                  center: LatLng(medias[page].lat, medias[page].lon),
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
                        markers: [Util.defaultMarker(medias[page].lat, medias[page].lon)],
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
                                Text('날짜 : ${medias[page].dateCreated}', style: const TextStyle(fontSize: 12)),
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
    );
  }

  @override
  void initState() {
    super.initState();
    page = widget.selectedIndex;
    medias = widget.mediaList.where((element) => element.isRemoved == false).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${page + 1}/${medias.length}'),
        toolbarHeight: 65,
        titleSpacing: 0,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: (){
              int mediaId = widget.mediaList.singleWhere((element) => element.id == medias[page].id).id;
              widget.remove!(mediaId);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.remove_circle_outline)
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: Center(
                child: CarouselSlider.builder(
                  itemCount: medias.length,
                  itemBuilder: (context, index, pageIndex) {
                    return fileTypeWidget(medias[index]);
                  },
                  options: CarouselOptions(
                    initialPage: page,
                    enableInfiniteScroll: false,
                    viewportFraction: 1,
                    height: MediaQuery.of(context).size.height,
                    onPageChanged: (index ,item){
                      setState((){
                        page = index;
                      });
                    }
                  ),
                ),
              ),
            ),
          ),
          bottomSheet()
        ],
      ),
    );
  }
}
