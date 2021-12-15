import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import 'custom_progress_indicator.dart';

class CustomNetworkImage extends StatelessWidget {
  final String url;
  CustomNetworkImage({this.url});
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Center(
          child: CustomProgressIndicator(),
        ),
        Container(
          child: FadeInImage.memoryNetwork(
            fadeInDuration: const Duration(milliseconds: 400),
            fit: BoxFit.fill,
            placeholder: kTransparentImage,
            image: url,
          ),
        ),
      ],
    );
  }
}
