import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:provider/provider.dart';

import '../dialogs/custom_yes_no_dialog.dart';
import '../model/models.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_app_bar.dart';
import '../dialogs/custom_await_dialog.dart';
import '../dialogs/custom_error_dialog.dart';
import '../widgets/custom_entry_field.dart';
import '../widgets/custom_floating_action_button.dart';
import '../widgets/spaces.dart';

import 'image_edit_screen.dart';

class CreateHighlightScreen extends StatefulWidget {
  final Book book;
  final int highlightIndex;

  CreateHighlightScreen({
    this.book,
    this.highlightIndex,
  });
  @override
  _CreateHighlightScreenState createState() => _CreateHighlightScreenState();
}

class _CreateHighlightScreenState extends State<CreateHighlightScreen> {
  final _form = GlobalKey<FormState>();

  File _imageFile;

  Highlight highlight = Highlight();

  bool _isLoading = false;

  final FocusNode _chapterFocusNode = FocusNode();
  final FocusNode _pageNoFocusNode = FocusNode();
  final FocusNode _highlightFocusNode = FocusNode();

  final TextEditingController _chapterController = TextEditingController();
  final TextEditingController _pageNoController = TextEditingController();
  final TextEditingController _highlightController = TextEditingController();

  final List<String> existingChapters = [];

  @override
  void initState() {
    super.initState();
    if (widget.highlightIndex != null) {
      highlight = Highlight.fromJson2(json: widget.book.highlights[widget.highlightIndex].toJson());
    } else {
      highlight = Highlight();
    }

    widget.book.highlights.forEach((highlight) {
      if (!existingChapters.contains(highlight.chapter)) {
        existingChapters.add(highlight.chapter);
      }
    });

    _chapterController.value = TextEditingValue(text: highlight.chapter, selection: _chapterController.selection);
    _pageNoController.value = TextEditingValue(text: highlight.pageNo, selection: _pageNoController.selection);
    _highlightController.value = TextEditingValue(text: highlight.highlight, selection: _highlightController.selection);
  }

  void _surroundTextSelection(String left, String right) {
    final currentTextValue = _highlightController.value.text;
    final selection = _highlightController.selection;
    final middle = selection.textInside(currentTextValue);
    final newTextValue = selection.textBefore(currentTextValue) +
        '$left$middle$right' +
        selection.textAfter(
          currentTextValue,
        );

    _highlightController.value = _highlightController.value.copyWith(
      text: newTextValue,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset + left.length + middle.length,
      ),
    );

    highlight.highlight = newTextValue;
  }

  void _settingModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: const Radius.circular(20.0)),
      ),
      backgroundColor: AppColors.grey2,
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SpaceH15(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        StringConst.highlightScan.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  SpaceH14(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 90,
                        child: Column(
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(
                                Icons.photo_size_select_actual,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                Get.back();
                                if (await Permission.storage.request().isGranted) {
                                  _imageFile = await Utils.captureImage(ImageSource.gallery);
                                  if (_imageFile != null) {
                                    var newImage = await Get.to(
                                      () => ImageEditScreen(
                                        imageFile: _imageFile,
                                        type: 'Galery',
                                        source: 'highlight',
                                        title: StringConst.higlightPicture.tr,
                                      ),
                                    );

                                    if (newImage != null) {
                                      showAwaitDialog();

                                      final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(newImage);
                                      final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
                                      final VisionText visionText = await textRecognizer.processImage(visionImage);

                                      await Future.delayed(const Duration(milliseconds: 2000));

                                      Get.back();

                                      String text = visionText.text.replaceAll('\n', ' ').replaceAll('- ', '');

                                      if (text == '' || text == null) {
                                        showErrorDialog(StringConst.couldNotExtractText.tr);
                                      } else {
                                        setState(() {
                                          highlight.highlight += text;
                                          _highlightController.clear();
                                          _highlightController.value = TextEditingValue(text: highlight.highlight, selection: _highlightController.selection);
                                        });
                                      }
                                    }
                                  }
                                } else if (await Permission.storage.isPermanentlyDenied) {
                                  var state = await Utils.showAlertDialog(context, description: StringConst.toSelectImageGivePermission.tr);
                                  if (state) {
                                    openAppSettings();
                                  }
                                }
                              },
                            ),
                            Text(
                              StringConst.takePhotoFromGallery.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SpaceW10(),
                      Container(
                        width: 90,
                        child: Column(
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(
                                Icons.camera,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                Get.back();
                                if (await Permission.camera.request().isGranted) {
                                  _imageFile = await Utils.captureImage(ImageSource.camera);
                                  if (_imageFile != null) {
                                    var newImage = await Get.to(
                                      () => ImageEditScreen(
                                        imageFile: _imageFile,
                                        type: 'Camera',
                                        source: 'highlight',
                                        title: StringConst.higlightPicture.tr,
                                      ),
                                    );
                                    if (newImage != null) {
                                      showAwaitDialog();

                                      final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(newImage);
                                      final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
                                      final VisionText visionText = await textRecognizer.processImage(visionImage);

                                      await Future.delayed(const Duration(milliseconds: 2000));

                                      Get.back();

                                      String text = visionText.text.replaceAll('\n', ' ').replaceAll('- ', '');

                                      if (text == '' || text == null) {
                                        showErrorDialog(StringConst.couldNotExtractText.tr);
                                      } else {
                                        setState(() {
                                          highlight.highlight += text;
                                          _highlightController.clear();
                                          _highlightController.value = TextEditingValue(text: highlight.highlight, selection: _highlightController.selection);
                                        });
                                      }
                                    }
                                  }
                                } else if (await Permission.camera.isPermanentlyDenied) {
                                  var state = await Utils.showAlertDialog(context, description: StringConst.toUseCameraGivePermission.tr);
                                  if (state) {
                                    openAppSettings();
                                  }
                                }
                              },
                            ),
                            Text(
                              StringConst.takePhoto.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SpaceH15(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showAwaitDialog() {
    showDialog(
      builder: (context) => AwaitDialog(),
      context: context,
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      builder: (context) => ErrorDialog(message),
      context: context,
    );
  }

  bool isDataUpdated() {
    Highlight oldHighlight = widget.book.highlights[widget.highlightIndex];
    if (highlight.chapter != oldHighlight.chapter || highlight.pageNo != oldHighlight.pageNo || highlight.highlight != oldHighlight.highlight || highlight.textAlign != oldHighlight.textAlign) {
      return true;
    }
    return false;
  }

  TextAlign getTextAlign() {
    TextAlign align = TextAlign.left;
    switch (highlight.textAlign) {
      case 'left':
        align = TextAlign.left;
        break;
      case 'center':
        align = TextAlign.center;
        break;
      case 'right':
        align = TextAlign.right;
        break;
      default:
    }

    return align;
  }

  Widget _settingButton({
    bool isActive,
    IconData icon,
    Function onTap,
  }) {
    return Container(
      width: 34,
      height: 34,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(
                  width: isActive ? 1.5 : 0.5,
                  color: isActive ? Colors.grey[800] : Colors.grey[400],
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isActive ? Colors.grey[800] : Colors.grey[400],
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _exitWithoutAdding() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) => CustomYesNoDialog(
        message: StringConst.someChangesHaveBeenMade.tr,
        buttonTitleLeft: StringConst.yes.tr,
        buttonTitleRight: StringConst.no.tr,
        leftButtonReturn: true,
        rightButtonReturn: false,
      ),
    );
  }

  Future<bool> _exitWithoutSaving() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) => CustomYesNoDialog(
        message: StringConst.someChangesHaveBeenMade.tr,
        buttonTitleLeft: StringConst.yes.tr,
        buttonTitleRight: StringConst.no.tr,
        leftButtonReturn: true,
        rightButtonReturn: false,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (widget.highlightIndex == null) {
      Highlight _highlight = Highlight();
      if (highlight == _highlight) {
        return Future.value(true);
      } else {
        var result = await _exitWithoutAdding();
        if (result != null && result) {
          return Future.value(true);
        }

        return Future.value(false);
      }
    } else {
      Highlight _highlight = Highlight.fromJson2(json: widget.book.highlights[widget.highlightIndex].toJson());
      if (highlight == _highlight) {
        return Future.value(true);
      } else {
        var result = await _exitWithoutSaving();
        if (result != null && result) {
          return Future.value(true);
        }

        return Future.value(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var model = Provider.of<UserModel>(context, listen: false);
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(
          title: widget.highlightIndex != null ? StringConst.updateHighlight.tr : StringConst.createHighlight.tr,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                final isValid = _form.currentState.validate();
                if (!isValid) {
                  return;
                }

                Utils.unFocus();

                if (!(await Utils.isOnline())) {
                  setState(() {
                    _isLoading = false;
                  });
                  Utils.showFlushError(context, StringConst.makeSureYouAreOnline.tr);
                  return;
                }

                if (highlight.highlight == '') {
                  Utils.showCustomErrorToast(context, StringConst.highlightCanNotBeEmpty.tr);
                  return;
                }

                String method;
                if (widget.highlightIndex != null) {
                  if (isDataUpdated()) {
                    widget.book.highlights[widget.highlightIndex] = highlight;
                    method = 'updated';
                  } else {
                    Get.back();
                    return;
                  }
                } else {
                  highlight.dateCreated = DateTime.now();
                  widget.book.highlights.insert(0, highlight);
                  method = 'added';
                }

                setState(() {
                  _isLoading = true;
                });

                var result = await model.updateBook(id: widget.book.id, book: widget.book);

                if (result.success) {
                  Get.back(result: {'success': true, 'method': method});
                } else {
                  Get.back(result: {'success': false});
                }

                setState(() {
                  _isLoading = false;
                });
              },
            ),
            widget.highlightIndex != null
                ? IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      Utils.unFocus();

                      var result = await showDialog(
                        builder: (context) => CustomYesNoDialog(
                          buttonTitleLeft: StringConst.yes.tr,
                          buttonTitleRight: StringConst.no.tr,
                          message: StringConst.areYouSureYouWantToDeleteHighlight.tr,
                        ),
                        context: context,
                      );
                      if (result != null && result) {
                        setState(() {
                          _isLoading = true;
                        });

                        if (!(await Utils.isOnline())) {
                          setState(() {
                            _isLoading = false;
                          });
                          Utils.showFlushError(context, StringConst.makeSureYouAreOnline.tr);
                          return;
                        }

                        widget.book.highlights.removeAt(widget.highlightIndex);

                        var result = await model.updateBook(id: widget.book.id, book: widget.book);

                        if (result.success) {
                          Get.back(result: {'success': true, 'method': 'deleted'});
                        } else {
                          Get.back(result: {'success': false});
                        }

                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                  )
                : Container(),
          ],
        ),
        floatingActionButton: Container(
          padding: const EdgeInsets.only(bottom: 45),
          child: CustomFloationgActionButton(
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
            onPressed: () {
              Utils.unFocus();
              _settingModalBottomSheet(context);
            },
          ),
        ),
        body: GestureDetector(
          onTap: () {
            Utils.unFocus();
          },
          child: LoadingOverlay(
            isLoading: _isLoading,
            color: Colors.white,
            opacity: 0.65,
            progressIndicator: const SpinKitCircle(
              color: AppColors.nord1,
              size: 60,
            ),
            child: Container(
              width: width,
              height: height,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Form(
                            key: _form,
                            child: Column(
                              children: [
                                SpaceH30(),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: FormField(
                                    builder: (state) => TypeAheadFormField(
                                      textFieldConfiguration: TextFieldConfiguration(
                                        controller: _chapterController,
                                        focusNode: _chapterFocusNode,
                                        textCapitalization: TextCapitalization.words,
                                        onChanged: (value) {
                                          setState(() {
                                            highlight.chapter = value;
                                          });
                                        },
                                        textInputAction: TextInputAction.next,
                                        onSubmitted: (_) {
                                          FocusScope.of(context).requestFocus(_pageNoFocusNode);
                                        },
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          labelStyle: const TextStyle(
                                            fontSize: 14,
                                          ),
                                          labelText: StringConst.sectionChapter.tr,
                                          border: Borders.border,
                                          enabledBorder: Borders.enabledBorder,
                                          focusedBorder: Borders.focusedBorder,
                                        ),
                                      ),
                                      suggestionsCallback: (pattern) {
                                        return existingChapters.where((chapter) => chapter.toLowerCase().contains(pattern.toLowerCase()));
                                      },
                                      itemBuilder: (context, suggestion) {
                                        return ListTile(
                                          title: Text(
                                            suggestion,
                                            style: TextStyle(
                                              fontFamily: StringConst.trtRegular,
                                            ),
                                          ),
                                        );
                                      },
                                      transitionBuilder: (context, suggestionsBox, controller) {
                                        return suggestionsBox;
                                      },
                                      onSuggestionSelected: (suggestion) {
                                        setState(() {
                                          highlight.chapter = suggestion;
                                          _chapterController.value = TextEditingValue(text: highlight.chapter, selection: _chapterController.selection);
                                        });
                                      },
                                      hideOnEmpty: true,
                                      onSaved: (value) => highlight.chapter = value,
                                    ),
                                  ),
                                ),
                                SpaceH18(),
                                CustomTextField(
                                  labelText: StringConst.pageNo.tr,
                                  focusNode: _pageNoFocusNode,
                                  controller: _pageNoController,
                                  textInputAction: TextInputAction.next,
                                  digitsOnly: true,
                                  textFieldTextStyle: const TextStyle(
                                    fontSize: 14,
                                  ),
                                  labelStyle: const TextStyle(
                                    fontSize: 14,
                                  ),
                                  onChanged: (String value) {
                                    setState(() {
                                      highlight.pageNo = value;
                                    });
                                  },
                                  onSubmit: (_) {
                                    FocusScope.of(context).requestFocus(_highlightFocusNode);
                                  },
                                  validator: (value) {
                                    if (highlight.pageNo.length > 10) {
                                      return StringConst.pageNoLengthCanNotBeMore.tr;
                                    }
                                  },
                                ),
                                SpaceH18(),
                                CustomTextField(
                                  labelText: StringConst.enterHighlight.tr,
                                  focusNode: _highlightFocusNode,
                                  textInputAction: TextInputAction.newline,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  textAlign: getTextAlign(),
                                  controller: _highlightController,
                                  textFieldTextStyle: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: StringConst.trtRegular,
                                    height: 1.4,
                                  ),
                                  labelStyle: const TextStyle(
                                    fontSize: 14,
                                  ),
                                  onChanged: (String value) {
                                    setState(() {
                                      highlight.highlight = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (highlight.highlight.trim().isEmpty) {
                                      return StringConst.thisFieldIsRequired.tr;
                                    }
                                  },
                                ),
                                SpaceH12(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  Container(
                    height: 50,
                    child: Row(
                      children: [
                        SpaceW12(),
                        _settingButton(
                          icon: Icons.format_align_left,
                          isActive: highlight.textAlign == 'left' ? true : false,
                          onTap: () {
                            setState(() {
                              highlight.textAlign = 'left';
                            });
                          },
                        ),
                        SpaceW8(),
                        _settingButton(
                          icon: Icons.format_align_center,
                          isActive: highlight.textAlign == 'center' ? true : false,
                          onTap: () {
                            setState(() {
                              highlight.textAlign = 'center';
                            });
                          },
                        ),
                        SpaceW8(),
                        _settingButton(
                          icon: Icons.format_align_right,
                          isActive: highlight.textAlign == 'right' ? true : false,
                          onTap: () {
                            setState(() {
                              highlight.textAlign = 'right';
                            });
                          },
                        ),
                        const Spacer(),
                        _settingButton(
                          icon: Icons.format_bold,
                          isActive: true,
                          onTap: () => _surroundTextSelection('**', '**'),
                        ),
                        SpaceW8(),
                        _settingButton(
                          icon: Icons.format_italic,
                          isActive: true,
                          onTap: () => _surroundTextSelection('*', '*'),
                        ),
                        SpaceW8(),
                        _settingButton(
                          icon: Icons.format_quote,
                          isActive: true,
                          onTap: () => _surroundTextSelection('```', '```'),
                        ),
                        SpaceW12(),
                      ],
                    ),
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
