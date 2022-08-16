import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fastapi_project/firebase_database/models/general_model.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Media media;
  const VideoPlayerWidget({Key? key, required this.media}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.media.url);
    await _videoPlayerController.initialize().onError((error, stackTrace) {
      Util.toastMessage('해당 영상은 재생할 수 없습니다.');
      Navigator.pop(context);
      return;
    });
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
    );

    if(kIsWeb){
      _chewieController!.addListener(() async{  //전체화면에서 다시 돌아갈때 화면안나타는 현상 해결
        if(!_chewieController!.isFullScreen) {
          bool isPlaying = _chewieController!.isPlaying;
          await _chewieController!.videoPlayerController.position.then((value) async{
            _videoPlayerController = VideoPlayerController.network(widget.media.url);
            await Future.wait([_videoPlayerController.initialize()]);
            _createChewieController();
            await _videoPlayerController.seekTo(value!);
            isPlaying ? _chewieController!.play() : _chewieController!.pause();
            setState(() {});
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    if(_chewieController != null){
      _chewieController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.media.id,
      child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized ?
      Container(
        height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
        color: Colors.black,
        child: Chewie(controller: _chewieController!)
      ) : Stack(
        children: [
          Container(
            width: double.infinity,
            color: Colors.black,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.media.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 5),
                Text('Wait...', style: TextStyle(color: Colors.white, fontSize: 12))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class VideoThumbNailWidget extends StatelessWidget {
  final Media media;
  const VideoThumbNailWidget({Key? key, required this.media}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: media.url,
      fit: BoxFit.cover,
      placeholder: (context, url) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        );
      },
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}


