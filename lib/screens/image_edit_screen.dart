import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'dart:io';

import '../utils/utils.dart';
import '../widgets/custom_app_bar.dart';
import '../values/values.dart';

class ImageEditScreen extends StatefulWidget {
  final File imageFile;
  final String type;
  final String source;
  final String title;

  ImageEditScreen({
    this.imageFile,
    this.type,
    this.source,
    this.title,
  });
  @override
  _ImageEditScreenScreenState createState() => new _ImageEditScreenScreenState();
}

class _ImageEditScreenScreenState extends State<ImageEditScreen> {
  bool isLoading = false;
  bool _isLodingPicture = false;
  File _imageFile;

  CropStyle getCropStyle() {
    CropStyle cropStyle;
    if (widget.source == 'book') {
      cropStyle = CropStyle.rectangle;
    } else if (widget.source == 'avatar') {
      cropStyle = CropStyle.circle;
    } else if (widget.source == 'highlight') {
      cropStyle = CropStyle.rectangle;
    }
    return cropStyle;
  }

  CropAspectRatio getAspectRatio() {
    CropAspectRatio aspecRatio;
    if (widget.source == 'book') {
      aspecRatio = CropAspectRatio(ratioX: 1, ratioY: 1.5);
    } else if (widget.source == 'avatar') {
      aspecRatio = CropAspectRatio(ratioX: 1, ratioY: 1);
    } else if (widget.source == 'highlight') {
      return null;
    }
    return aspecRatio;
  }

  Future<Null> captureImage(ImageSource captureMode) async {
    final _picker = ImagePicker();
    try {
      var imageFile = await _picker.getImage(source: captureMode);
      if (imageFile == null) {
        setState(() {
          _imageFile = null;
        });
      } else {
        setState(() {
          _imageFile = File(imageFile.path);
        });
      }
    } catch (e) {
      Get.back(result: null);
    }
  }

  Widget _buildImage() {
    Widget img;
    if (_imageFile == null) {
      img = Center(
        child: Text(StringConst.couldNotLoadPicture.tr),
      );
    } else {
      img = Image.file(_imageFile);
    }

    return img;
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: StringConst.editPicture.tr,
        lockAspectRatio: widget.source == 'highlight' ? false : true,
        showCropGrid: widget.source == 'highlight' ? false : true,
      ),
      aspectRatio: getAspectRatio(),
      sourcePath: _imageFile.path,
      cropStyle: getCropStyle(),
      aspectRatioPresets: const [
        CropAspectRatioPreset.original,
      ],
      compressQuality: widget.source == 'highlight' ? 100 : 90,
      maxWidth: widget.source == 'highlight' || widget.source == 'avatar' ? 600 : 400,
      maxHeight: 600,
    );
    setState(() {
      if (croppedFile == null) {
        _imageFile = null;
      } else {
        _imageFile = croppedFile;
      }
    });
  }

  @override
  void initState() {
    _imageFile = widget.imageFile;
    _cropImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var widthOfScreen = MediaQuery.of(context).size.width;
    var heightOfScreen = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        if (_isLodingPicture) {
          return false;
        }
        Get.back(result: null);
        return true;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: widget.title,
          actions: <Widget>[
            widget.type == 'Galery'
                ? IconButton(
                    icon: Icon(Icons.photo_size_select_actual),
                    onPressed: () async {
                      if (await Permission.storage.request().isGranted) {
                        setState(() {
                          _isLodingPicture = true;
                        });
                        await captureImage(ImageSource.gallery);
                        setState(() {
                          _isLodingPicture = false;
                        });
                        if (_imageFile != null) {
                          _cropImage();
                        }
                      } else {
                        Utils.showFlushError(context, StringConst.accessBlocked.tr);
                      }
                    },
                  )
                : IconButton(
                    icon: Stack(
                      children: <Widget>[
                        Icon(Icons.camera),
                      ],
                    ),
                    onPressed: () async {
                      if (await Permission.camera.request().isGranted) {
                        setState(() {
                          _isLodingPicture = true;
                        });
                        await captureImage(ImageSource.camera);
                        setState(() {
                          _isLodingPicture = false;
                        });
                        if (_imageFile != null) {
                          _cropImage();
                        }
                      } else {
                        Utils.showFlushError(context, StringConst.accessBlocked.tr);
                      }
                    },
                  ),
            IconButton(
              icon: Icon(
                widget.source == 'highlight' ? Icons.check : Icons.save,
              ),
              onPressed: () {
                Get.back(result: _imageFile);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: LoadingOverlay(
            isLoading: _isLodingPicture,
            color: Colors.white,
            opacity: 0.65,
            progressIndicator: const SpinKitCircle(
              color: AppColors.nord1,
              size: 60,
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: widthOfScreen * 0.75,
                    height: heightOfScreen * 0.8,
                    child: Center(child: _buildImage()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
