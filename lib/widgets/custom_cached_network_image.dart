import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'custom_progress_indicator.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit boxFit;
  final double borderRadius;

  CustomCachedNetworkImage({
    this.url,
    this.width,
    this.height,
    this.boxFit = BoxFit.cover,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      width: width,
      height: height,
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.7),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
          image: DecorationImage(
            image: imageProvider,
            fit: boxFit,
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        color: Colors.white,
        child: Center(
          child: CustomProgressIndicator(
            size: 30,
          ),
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
