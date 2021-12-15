import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:simple_edge_detection/edge_detection.dart';
import 'package:simple_edge_detection/edge_detection_shape.dart';

import './edge_detector.dart';

class ImagePreview extends StatefulWidget {
  ImagePreview({this.image, this.edgeDetectionResult});

  final File image;
  final EdgeDetectionResult edgeDetectionResult;

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  GlobalKey imageWidgetKey = GlobalKey();
  File coppedImage;

  Future _processImage(File img, EdgeDetectionResult edgeDetectionResult) async {
    if (!mounted || img == null) {
      return;
    }

    //File croppedImage = File(widget.image.path).copy();
    widget.image.copy(widget.image.path + '_img.jpg');
    File croppedImage = File(widget.image.path + '_img.jpg');

    bool result = await EdgeDetector().processImage(croppedImage.path, edgeDetectionResult);

    if (result == false) {
      return;
    }

    Navigator.pop(context, {'croppedImage': croppedImage});

    //GallerySaver.saveImage(widget.image.path);
    //print(widget.image.path);

    /* setState(() {
      /* imageCache.clearLiveImages();
      imageCache.clear(); */
      /* print(imageCache.liveImageCount); */
      /* img.delete(recursive: true); */

      /* coppedImage = widget.image; */
      /* widget.image.delete(); */
    }); */
  }

  @override
  Widget build(BuildContext mainContext) {
    final double safeAreaHeight = MediaQuery.of(context).padding.top;
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Center(child: Text('Loading ...')),
              Image.file(File(widget.image.path), fit: BoxFit.contain, key: imageWidgetKey),
              FutureBuilder<ui.Image>(
                  future: loadUiImage(widget.image.path),
                  builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
                    return _getEdgePaint(snapshot, context, safeAreaHeight);
                  }),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff434c5e),
          splashColor: Color(0xffd4d4d4),
          child: Icon(Icons.check, color: Colors.white),
          onPressed: () async {
            setState(() {});
            await _processImage(widget.image, widget.edgeDetectionResult);
          },
        ),
      ),
    );
    /* MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SafeArea(
        child: Scaffold(
          body: Center(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Center(child: Text('Loading ...')),
                Image.file(File(widget.image.path), fit: BoxFit.contain, key: imageWidgetKey),
                FutureBuilder<ui.Image>(
                    future: loadUiImage(widget.image.path),
                    builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
                      return _getEdgePaint(snapshot, context);
                    }),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xff707070),
            splashColor: Color(0xffd4d4d4),
            child: Icon(Icons.check, color: Colors.white),
            onPressed: () async {
              setState(() {});
              await _processImage(widget.image, widget.edgeDetectionResult);
            },
          ),
        ),
      ),
    ); */
  }

  Widget _getEdgePaint(AsyncSnapshot<ui.Image> imageSnapshot, BuildContext context, double safeAreaHeight) {
    if (imageSnapshot.connectionState == ConnectionState.waiting) return Container();

    if (imageSnapshot.hasError) return Text('Error: ${imageSnapshot.error}');

    if (widget.edgeDetectionResult == null) return Container();

    final keyContext = imageWidgetKey.currentContext;

    if (keyContext == null) {
      return Container();
    }

    final box = keyContext.findRenderObject() as RenderBox;

    return EdgeDetectionShape(
      originalImageSize: Size(imageSnapshot.data.width.toDouble(), imageSnapshot.data.height.toDouble()),
      renderedImageSize: Size(box.size.width, box.size.height),
      edgeDetectionResult: widget.edgeDetectionResult,
      safeAreaHeight: safeAreaHeight,
    );
  }

  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    final Uint8List data = await File(imageAssetPath).readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image image) {
      return completer.complete(image);
    });
    return completer.future;
  }
}
