import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fastapi_project/firebase_database/models/general_model.dart';

class ImageThumbNailWidget extends StatelessWidget {
  final Media media;
  const ImageThumbNailWidget({Key? key, required this.media}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return media.url.contains('flutter_firebase/cache') ? Image.file(
      File(media.url),
      fit: BoxFit.cover,
    ) : CachedNetworkImage(
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

class ImageFullViewWidget extends StatelessWidget {
  final List<Media> mediaList;
  final Media media;
  const ImageFullViewWidget({Key? key, this.mediaList = const [], required this.media}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Hero(
        tag: media.id,
        child: media.url.contains('flutter_firebase/cache') ? Image.file(
          File(media.url),
          fit: BoxFit.cover,
        ) : CachedNetworkImage(
          imageUrl: media.url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Icon(Icons.error),
        )
      ),
    );
  }
}

