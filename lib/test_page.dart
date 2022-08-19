import 'package:chewie/chewie.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network('https://aaespa.shop/static/images/7/20220818141214_image_picker9035545767520228139.webm');
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
            _videoPlayerController = VideoPlayerController.network('https://aaespa.shop/static/images/7/20220818141214_image_picker9035545767520228139.webm');
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized ?
            Container(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
              color: Colors.black,
              child: Chewie(controller: _chewieController!)
            ) : Container()
          ],
        ),
      ),
    );
  }
}
