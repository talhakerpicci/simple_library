import 'dart:io';
import 'dart:math';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_edge_detection/cropping_preview.dart';
import 'package:simple_edge_detection/edge_detection.dart';
import 'package:simple_edge_detection/edge_detector.dart';
import 'package:validators/validators.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/models.dart';
import '../values/values.dart';
import '../widgets/custom_entry_field.dart';
import '../widgets/custom_cached_network_image.dart';
import '../widgets/spaces.dart';
import '../utils/utils.dart';
import '../enums/book_states.dart';
import '../widgets/custom_book_property_tile.dart';
import '../enums/modal_option.dart';
import '../enums/online_search_option.dart';
import '../locator.dart';
import '../services/api.dart';
import '../viewmodels/user_model.dart';
import '../viewmodels/db_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_empty_book_card.dart';
import '../dialogs/custom_genre_picker_dialog.dart';
import '../dialogs/custom_image_picker_dialog.dart';
import '../dialogs/custom_book_state_dialog.dart';
import '../widgets/custom_network_image.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/custom_floating_action_button.dart';
import '../widgets/sliverbar_with_card.dart';
import '../dialogs/custom_yes_no_dialog.dart';

import 'reminders_screen.dart';
import 'book_highlights_screen.dart';
import 'book_reading_chart_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  BookDetailScreen({this.book});
  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Api _api = locator<Api>();

  final _form = GlobalKey<FormState>();
  final _manualImageForm = GlobalKey<FormState>();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _authorFocusNode = FocusNode();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _controllerNotes = TextEditingController();

  Book book;
  bool _isLoading = false;

  File _imageFile;
  String _tempImgUrl = '';

  DateFormat _dateFormatter;

  List<String> allAuthors = [];

  EdgeDetectionResult edgeDetectionResult;

  @override
  void initState() {
    super.initState();
    book = Book(
      id: widget.book.id,
      author: widget.book.author,
      genre: widget.book.genre,
      dateCreated: widget.book.dateCreated,
      dateFinished: widget.book.dateFinished,
      dateStarted: widget.book.dateStarted,
      graphData: widget.book.graphData,
      imgUrl: widget.book.imgUrl,
      siteImgUrl: widget.book.siteImgUrl,
      notes: widget.book.notes,
      pagesRead: widget.book.pagesRead,
      rating: widget.book.rating,
      state: widget.book.state,
      title: widget.book.title,
      totalPages: widget.book.totalPages,
      highlights: widget.book.highlights,
    );

    _titleController.value = TextEditingValue(text: book.title, selection: _titleController.selection);
    _authorController.value = TextEditingValue(text: book.author, selection: _authorController.selection);
    _controllerNotes.value = TextEditingValue(text: book.notes, selection: _controllerNotes.selection);

    var model = Provider.of<UserModel>(context, listen: false);
    allAuthors = model.getAllAuthors();
  }

  bool isBookUpdated() {
    return !(widget.book == book) || _imageFile != null;
  }

  Color _getProgressColor() {
    Color color;
    if ((book.pagesRead * (1 / book.totalPages) * 100) >= 0 && (book.pagesRead * (1 / book.totalPages) * 100) < 33.3) {
      color = Colors.red[400];
    } else if ((book.pagesRead * (1 / book.totalPages) * 100) >= 33.3 && (book.pagesRead * (1 / book.totalPages) * 100) < 66.6) {
      color = Colors.yellow[400];
    } else if ((book.pagesRead * (1 / book.totalPages) * 100) >= 66.6 && (book.pagesRead * (1 / book.totalPages) * 100) <= 100) {
      color = Colors.green[400];
    } else {
      color = Colors.red;
    }
    return color;
  }

  double _getProgress() {
    return book.pagesRead * (1 / book.totalPages);
  }

  DateTime _getMinTime() {
    return book.dateStarted != null ? book.dateStarted : DateTime(1900);
  }

  DateTime _getMaxTime() {
    return book.dateFinished != null ? book.dateFinished : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  }

  String _getGenre(List<Genre> genres) {
    String genre;
    try {
      genre = genres.firstWhere((item) => item.id == book.genre).title;
    } catch (e) {
      genre = '';
    }
    return genre;
  }

  Future<String> _getDateStartedValue() async {
    String date = '';
    if (book.dateStarted != null) {
      if (_dateFormatter != null) {
        date = _dateFormatter.format(book.dateStarted);
      } else {
        var formatter = Utils.getCustomDateFormatter();
        _dateFormatter = formatter;
        date = _dateFormatter.format(book.dateStarted);
      }
    }

    return date;
  }

  Future<String> _getDateFinishedValue() async {
    String date = '';
    if (book.dateFinished != null) {
      if (_dateFormatter != null) {
        date = _dateFormatter.format(book.dateFinished);
      } else {
        var formatter = Utils.getCustomDateFormatter();
        _dateFormatter = formatter;
        date = _dateFormatter.format(book.dateFinished);
      }
    }

    return date;
  }

  LocaleType _getLocale() {
    LocaleType localeType = LocaleType.en;
    String _locale = Utils.currentLocale.languageCode;
    LocaleType.values.forEach((locale) {
      if (locale.toString().split('.')[1] == _locale) {
        localeType = locale;
        return;
      }
    });

    return localeType;
  }

  void _setUrlsToEmpty() {
    book.imgUrl = '';
    book.siteImgUrl = '';
    _tempImgUrl = '';
  }

  void editCurrentPosition() async {
    int currentPosition = book.pagesRead;

    var width = MediaQuery.of(context).size.width;

    var result = await showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0.0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            Utils.unFocus();
          },
          child: Container(
            height: 210,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: 210,
                  width: width,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        StringConst.currentPosition.tr,
                        style: const TextStyle(
                          fontSize: 24,
                          color: AppColors.nord0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SpaceH40(),
                      Form(
                        key: _form,
                        child: CustomTextFormField(
                          textAlign: TextAlign.center,
                          width: width * 0.5,
                          contentPadding: const EdgeInsets.only(bottom: 5),
                          keyboardType: TextInputType.number,
                          digitsOnly: true,
                          hintText: currentPosition.toString(),
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                          ),
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 40,
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged: (value) {
                            if (value == '') {
                              setState(() {
                                currentPosition = 0;
                              });
                            } else {
                              setState(() {
                                currentPosition = int.parse(value);
                              });
                            }
                          },
                          validator: (value) {
                            if (value.toString().isEmpty) {
                              return StringConst.enterAValidPosition.tr;
                            }
                            if (book.totalPages == 0) {
                              return StringConst.enterTotalPagesFirst.tr;
                            }
                            if (int.parse(value) > book.totalPages) {
                              return StringConst.customTranslation(
                                key: StringConst.enterPageLowerThan,
                                data: '${book.totalPages}',
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 4,
                  child: Row(
                    children: [
                      TextButton(
                        child: Text(
                          StringConst.cancel.tr,
                          style: const TextStyle(color: Colors.red, fontSize: 14.0),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      TextButton(
                        child: Text(
                          StringConst.done.tr,
                          style: const TextStyle(color: AppColors.nord1, fontSize: 14.0),
                        ),
                        onPressed: () {
                          final isValid = _form.currentState.validate();
                          if (!isValid) {
                            return;
                          }
                          Utils.unFocus();
                          Get.back(result: currentPosition);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      if (book.state != BookState.Finished && currentPosition == book.totalPages) {
        setState(() {
          book.state = BookState.Finished;
          book.pagesRead = currentPosition;
        });
      } else {
        setState(() {
          book.pagesRead = currentPosition;
        });
      }
    }
  }

  Widget _showImage() {
    Widget widget;
    if (_tempImgUrl != '') {
      widget = Container(
        width: 60 * 1.67,
        height: 60 * 2.4,
        child: CustomNetworkImage(
          url: _tempImgUrl,
        ),
      );
    } else if (book.imgUrl != '') {
      widget = Container(
        width: 60 * 1.67,
        height: 60 * 2.4,
        child: Hero(
          tag: book.id,
          child: CustomCachedNetworkImage(
            url: book.imgUrl,
            boxFit: BoxFit.fill,
          ),
        ),
      );
    } else if (_imageFile != null) {
      widget = Container(
        width: 60 * 1.67,
        height: 60 * 2.4,
        child: Image.file(
          _imageFile,
          fit: BoxFit.fill,
        ),
      );
    } else {
      widget = CustomEmptyBookCard(
        width: 60 * 1.67,
        height: 60 * 2.4,
        stackWidget: const Positioned(
          bottom: 5,
          right: 5,
          child: const Icon(Icons.add),
        ),
      );
    }
    return widget;
  }

  Future _detectEdges(File imgFile) async {
    if (!mounted || imgFile == null) {
      return;
    }

    EdgeDetectionResult result = await EdgeDetector().detectEdges(imgFile.path);

    setState(() {
      edgeDetectionResult = result;
    });
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
    if (book == widget.book) {
      return Future.value(true);
    } else {
      var result = await _exitWithoutSaving();
      if (result != null && result) {
        return Future.value(true);
      }

      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var model = Provider.of<UserModel>(context, listen: true);
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        floatingActionButton: isBookUpdated()
            ? CustomFloationgActionButton(
                icon: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                onPressed: () async {
                  Utils.unFocus();

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

                  if (widget.book.imgUrl != '' && book.imgUrl == '' && _imageFile == null) {
                    await _api.deleteCoverImage(id: book.id, imgUrl: widget.book.imgUrl);
                  } else if (widget.book.siteImgUrl != _tempImgUrl && _tempImgUrl != '') {
                    _imageFile = await Utils.urlToFile(imageUrl: _tempImgUrl, id: book.id);
                  }

                  if (_imageFile != null) {
                    var result = await _api.uploadCoverImage(bookCover: _imageFile, bookId: book.id);
                    if (!result.success) {
                      Utils.showFlushError(context, StringConst.couldNotUploadCover.tr);
                    } else {
                      book.imgUrl = result.downloadUrl;
                      book.siteImgUrl = _tempImgUrl;
                    }
                  }

                  if (widget.book.pagesRead != book.pagesRead) {
                    if (book.graphData == null) {
                      book.graphData = {};
                    }

                    if (book.pagesRead == 0) {
                      book.graphData = {};
                    } else {
                      if (book.pagesRead > widget.book.pagesRead) {
                        int toAdd = 0;
                        if (book.graphData[Utils.formatter.format(DateTime.now())] != null) {
                          toAdd = book.graphData[Utils.formatter.format(DateTime.now())]['pagesRead'];
                        }
                        book.graphData[Utils.formatter.format(DateTime.now())] = {
                          'pagesRead': book.pagesRead - widget.book.pagesRead + toAdd,
                          'id': book.id,
                        };
                      } else if (book.pagesRead < widget.book.pagesRead) {
                        int difference = widget.book.pagesRead - book.pagesRead;
                        var keys = book.graphData.keys.toList();
                        for (var i = keys.length - 1; i >= 0; i--) {
                          if (difference > book.graphData[keys[i]]['pagesRead']) {
                            difference = difference - book.graphData[keys[i]]['pagesRead'];

                            book.graphData.remove(keys[i]);
                          } else {
                            book.graphData[keys[i]]['pagesRead'] = book.graphData[keys[i]]['pagesRead'] - difference;

                            if (book.graphData[keys[i]]['pagesRead'] == 0) {
                              book.graphData.remove(keys[i]);
                            }

                            break;
                          }
                        }
                      }
                    }
                  }

                  if (book.highlights == null) {
                    book.highlights = [];
                  }

                  if (widget.book.state != book.state && book.state != BookState.Reading) {
                    var dbModel = Provider.of<DbModel>(context, listen: false);
                    await dbModel.canceAllNotificationsForBook(bookId: book.id);
                  }

                  var result = await model.updateBook(id: book.id, book: book);

                  setState(() {
                    _isLoading = false;
                  });

                  Get.back(result: {
                    'result': result.success,
                    'book': book.title,
                    'action': 'update',
                  });
                },
              )
            : Container(),
        body: LoadingOverlay(
          isLoading: _isLoading,
          color: Colors.white,
          opacity: 0.65,
          progressIndicator: const SpinKitCircle(
            color: AppColors.nord1,
            size: 60,
          ),
          child: CardSliverAppBar(
            height: 300,
            background: Image.asset(StringConst.libraryPath, fit: BoxFit.cover),
            title: Text(
              book.title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            titleDescription: Text(
              book.author,
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
              ),
            ),
            onWillPop: () async {
              if (book == widget.book) {
                Get.back();
              } else {
                var result = await _exitWithoutSaving();
                if (result != null && result) {
                  Get.back();
                }
              }
            },
            card: GestureDetector(
              onTap: () async {
                var result = await Utils.showBottomSheet(context);
                if (result == ModalOption.SearchOnline) {
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

                  var prefs = await SharedPreferences.getInstance();
                  String value = prefs.getString('searchEngine');
                  OnlineSearchOption initialOption;

                  if (value != null) {
                    initialOption = Utils.getSearchOptionAsEnum(value);
                  } else {
                    initialOption = OnlineSearchOption.Bookdepository;
                  }

                  var imgLinks = await Utils.getCoversOnline(title: book.title, author: book.author, option: initialOption);

                  setState(() {
                    _isLoading = false;
                  });

                  if (imgLinks is List) {
                    if (imgLinks.length == 0) {
                      Utils.showCustomErrorToast(context, StringConst.couldNotFindImages.tr);
                    } else {
                      var result2 = await showDialog(
                        context: context,
                        builder: (BuildContext context) => CustomImagePickerDialog(
                          imgLinks: imgLinks,
                        ),
                      );

                      if (result2 != null) {
                        if (widget.book.siteImgUrl != result2) {
                          setState(() {
                            _tempImgUrl = result2;
                            book.siteImgUrl = result2;
                          });
                        } else {
                          setState(() {
                            _tempImgUrl = '';
                          });
                        }
                      }
                    }
                  }
                } else if (result == ModalOption.ManualUrl) {
                  String url = '';
                  bool _loading = false;

                  var result = await showDialog(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0.0,
                      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
                      backgroundColor: Colors.white,
                      child: StatefulBuilder(
                        builder: (context, setState) => GestureDetector(
                          onTap: () {
                            Utils.unFocus();
                          },
                          child: Container(
                            height: 190,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: LoadingOverlay(
                                isLoading: _loading,
                                color: Colors.white,
                                opacity: 0.65,
                                progressIndicator: const SpinKitCircle(
                                  color: AppColors.nord1,
                                  size: 60,
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Container(
                                      height: 190,
                                      width: width,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Text(
                                            StringConst.coverImgUrl.tr,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              color: AppColors.nord0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SpaceH50(),
                                          Form(
                                            key: _manualImageForm,
                                            child: CustomTextFormField(
                                              textAlign: TextAlign.center,
                                              width: width * 0.7,
                                              contentPadding: const EdgeInsets.only(bottom: 5),
                                              keyboardType: TextInputType.text,
                                              textStyle: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                              textCapitalization: TextCapitalization.none,
                                              onChanged: (value) {
                                                setState(() {
                                                  url = value;
                                                });
                                              },
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return StringConst.urlCanNotBeNull.tr;
                                                }
                                                if (!isURL(value)) {
                                                  return StringConst.enterAValidUrl.tr;
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      bottom: 4,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Text(
                                              StringConst.cancel.tr,
                                              style: const TextStyle(color: Colors.red, fontSize: 14.0),
                                            ),
                                            onPressed: () {
                                              Get.back();
                                            },
                                          ),
                                          TextButton(
                                            child: Text(
                                              StringConst.done.tr,
                                              style: const TextStyle(color: AppColors.nord1, fontSize: 14.0),
                                            ),
                                            onPressed: () async {
                                              final isValid = _manualImageForm.currentState.validate();
                                              if (!isValid) {
                                                return;
                                              }
                                              setState(() {
                                                _loading = true;
                                              });

                                              if (!(await Utils.isOnline())) {
                                                setState(() {
                                                  _loading = false;
                                                });
                                                Get.back();
                                                Utils.showFlushError(context, StringConst.makeSureYouAreOnline.tr);
                                                return;
                                              }

                                              Utils.unFocus();

                                              var validateUrl = await Utils.checkIfImage(url);

                                              if (!validateUrl['isImage']) {
                                                url = '';
                                              }

                                              setState(() {
                                                _loading = false;
                                              });

                                              Get.back(result: {'url': url, 'size': validateUrl['size']});
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );

                  if (result != null) {
                    if (result['url'] == '') {
                      Utils.showFlushError(context, StringConst.urlWasNotValid.tr);
                    } else if (widget.book.siteImgUrl != result) {
                      if (result['size'] > Utils.maxImgSize) {
                        Utils.showFlushError(
                          context,
                          StringConst.customTranslation(
                            key: StringConst.imgSizeMustBeLowerThan,
                            data: '${Utils.maxImgSize}',
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _tempImgUrl = result['url'];
                        book.siteImgUrl = result['url'];
                      });
                    } else {
                      setState(() {
                        _tempImgUrl = '';
                      });
                    }
                  }
                } else if (result == ModalOption.Gallery) {
                  if (await Permission.storage.request().isGranted) {
                    File _tempImgFile = await Utils.captureImage(ImageSource.gallery);

                    if (_tempImgFile != null) {
                      setState(() {
                        _isLoading = true;
                      });
                      await _detectEdges(_tempImgFile);
                      var result = await Get.to(() => ImagePreview(
                            image: _tempImgFile,
                            edgeDetectionResult: edgeDetectionResult,
                          ));

                      if (result != null) {
                        File compressedFile = await FlutterNativeImage.compressImage(
                          result['croppedImage'].path,
                          quality: 90,
                          percentage: 90,
                          targetHeight: 600,
                          targetWidth: 400,
                        );

                        if ((compressedFile.lengthSync() * pow(10, -6)) > Utils.maxImgSize) {
                          Utils.showFlushError(
                            context,
                            StringConst.customTranslation(
                              key: StringConst.imgSizeMustBeLowerThan,
                              data: '${Utils.maxImgSize}',
                            ),
                          );
                          return;
                        }

                        setState(() {
                          book.imgUrl = '';
                          _imageFile = compressedFile;
                        });
                      }

                      setState(() {
                        _isLoading = false;
                      });

                      await _tempImgFile.delete();
                    }
                  } else if (await Permission.storage.isPermanentlyDenied) {
                    var state = await Utils.showAlertDialog(context, description: StringConst.toSelectImageGivePermission.tr);
                    if (state) {
                      openAppSettings();
                    }
                  }
                } else if (result == ModalOption.Camera) {
                  if (await Permission.camera.request().isGranted) {
                    setState(() {
                      _isLoading = true;
                    });
                    File _tempImgFile = await Utils.captureImage(ImageSource.camera);

                    if (_tempImgFile != null) {
                      await _detectEdges(_tempImgFile);
                      var result = await Get.to(() => ImagePreview(
                            image: _tempImgFile,
                            edgeDetectionResult: edgeDetectionResult,
                          ));

                      if (result != null) {
                        File compressedFile = await FlutterNativeImage.compressImage(
                          result['croppedImage'].path,
                          quality: 90,
                          percentage: 90,
                          targetHeight: 600,
                          targetWidth: 400,
                        );

                        if ((compressedFile.lengthSync() * pow(10, -6)) > Utils.maxImgSize) {
                          Utils.showFlushError(
                            context,
                            StringConst.customTranslation(
                              key: StringConst.imgSizeMustBeLowerThan,
                              data: '${Utils.maxImgSize}',
                            ),
                          );
                          return;
                        }

                        setState(() {
                          book.imgUrl = '';
                          _imageFile = compressedFile;
                        });
                      }

                      setState(() {
                        _isLoading = false;
                      });

                      await _tempImgFile.delete();
                    }

                    setState(() {
                      _isLoading = false;
                    });
                  } else if (await Permission.camera.isPermanentlyDenied) {
                    var state = await Utils.showAlertDialog(context, description: StringConst.toUseCameraGivePermission.tr);
                    if (state) {
                      openAppSettings();
                    }
                  }
                } else if (result == ModalOption.Delete) {
                  setState(() {
                    _imageFile = null;
                    _setUrlsToEmpty();
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: _showImage(),
                ),
              ),
            ),
            backButton: true,
            backButtonColors: [Colors.white, Colors.black],
            action: IconButton(
              onPressed: () async {
                String title = book.title;
                String author = book.author;

                _titleController.value = TextEditingValue(text: book.title, selection: _titleController.selection);
                _authorController.value = TextEditingValue(text: book.author, selection: _authorController.selection);

                var result = await showDialog(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0.0,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        Utils.unFocus();
                      },
                      child: Container(
                        height: 300,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              height: 300,
                              width: width,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text(
                                    StringConst.titleAndAuthor.tr,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: AppColors.nord0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SpaceH40(),
                                  Form(
                                    key: _form,
                                    child: Column(
                                      children: [
                                        EntryField(
                                          hintText: StringConst.title.tr,
                                          icon: const Icon(Icons.title),
                                          controller: _titleController,
                                          focusNode: _titleFocusNode,
                                          textCapitalization: TextCapitalization.words,
                                          textInputAction: TextInputAction.next,
                                          onSubmit: (_) {
                                            FocusScope.of(context).requestFocus(_authorFocusNode);
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              title = value;
                                            });
                                          },
                                          validator: (value) {
                                            if (title.trim().isEmpty) {
                                              return StringConst.titleIsRequired.tr;
                                            }
                                            if (title.length > 200) {
                                              return StringConst.bookTitleLengthMustBeLowerThan.tr;
                                            }
                                            if (widget.book.title != title && model.isBookAlreadyExists(title)) {
                                              return StringConst.thisBookAlreadyExists.tr;
                                            }
                                            return null;
                                          },
                                        ),
                                        SpaceH10(),
                                        FormField(
                                          validator: (value) {
                                            if (author.trim().isEmpty) {
                                              return StringConst.authorNameIsRequired.tr;
                                            }
                                            if (author.length > 200) {
                                              return StringConst.authorLengthMustBeLowerThan.tr;
                                            }

                                            return null;
                                          },
                                          builder: (state) => Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: TypeAheadFormField(
                                                  textFieldConfiguration: TextFieldConfiguration(
                                                    controller: _authorController,
                                                    focusNode: _authorFocusNode,
                                                    textCapitalization: TextCapitalization.words,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        author = value;
                                                      });
                                                    },
                                                    decoration: InputDecoration(
                                                      prefixIcon: const Icon(Icons.person),
                                                      border: InputBorder.none,
                                                      fillColor: AppColors.grey4,
                                                      filled: true,
                                                      labelText: StringConst.author.tr,
                                                    ),
                                                  ),
                                                  suggestionsCallback: (pattern) {
                                                    return allAuthors.where((author) => author.toLowerCase().contains(pattern.toLowerCase()));
                                                  },
                                                  itemBuilder: (context, suggestion) {
                                                    return ListTile(
                                                      title: Text(suggestion),
                                                    );
                                                  },
                                                  transitionBuilder: (context, suggestionsBox, controller) {
                                                    return suggestionsBox;
                                                  },
                                                  onSuggestionSelected: (suggestion) {
                                                    setState(() {
                                                      author = suggestion;
                                                      _authorController.value = TextEditingValue(text: author, selection: _authorController.selection);
                                                    });
                                                  },
                                                  hideOnEmpty: true,
                                                  onSaved: (value) => author = value,
                                                ),
                                              ),
                                              state.errorText != null
                                                  ? Container(
                                                      padding: const EdgeInsets.only(left: 10, top: 5),
                                                      child: Text(
                                                        state.errorText,
                                                        style: const TextStyle(color: Colors.red, fontSize: 12),
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 10,
                              bottom: 4,
                              child: Row(
                                children: [
                                  TextButton(
                                    child: Text(
                                      StringConst.cancel.tr,
                                      style: const TextStyle(color: Colors.red, fontSize: 14.0),
                                    ),
                                    onPressed: () {
                                      Get.back();
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                      StringConst.done.tr,
                                      style: const TextStyle(color: AppColors.nord1, fontSize: 14.0),
                                    ),
                                    onPressed: () {
                                      final isValid = _form.currentState.validate();
                                      if (!isValid) {
                                        return;
                                      }

                                      Utils.unFocus();

                                      Get.back(result: {'title': title, 'author': author});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    book.title = title;
                    book.author = author;
                  });
                }
              },
              icon: Icon(Icons.edit),
              color: AppColors.nord1,
              iconSize: 30.0,
            ),
            ratingBar: Container(
              child: RatingBar.builder(
                unratedColor: Colors.grey[300],
                initialRating: book.rating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 20,
                itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    book.rating = rating;
                  });
                },
              ),
            ),
            body: Container(
              alignment: Alignment.topLeft,
              color: Colors.white,
              child: GestureDetector(
                onTap: () {
                  Utils.unFocus();
                },
                child: Column(
                  children: <Widget>[
                    book.state == BookState.ToRead ? SpaceH30() : Container(),
                    SpaceH40(),
                    book.state == BookState.ToRead
                        ? CustomButton(
                            title: StringConst.startReading.tr,
                            width: width * 0.5,
                            height: 40,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: StringConst.trtRegular,
                            ),
                            onPressed: () {
                              setState(() {
                                book.state = BookState.Reading;
                                if (book.dateStarted == null) {
                                  book.dateStarted = DateTime.now();
                                }
                              });
                            },
                          )
                        : Container(),
                    book.state != BookState.ToRead ? SpaceH20() : Container(),
                    book.state == BookState.ToRead
                        ? Container()
                        : Container(
                            child: ListTile(
                              title: RichText(
                                text: TextSpan(
                                  text: '${book.pagesRead} ',
                                  style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 24),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '/${book.totalPages}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[500], fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: book.state == BookState.Finished || book.state == BookState.Dropped
                                  ? Container(
                                      width: 0,
                                    )
                                  : Icon(Icons.edit),
                              onTap: () {
                                editCurrentPosition();
                              },
                            ),
                          ),
                    book.state == BookState.ToRead
                        ? Container()
                        : Container(
                            width: width,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: LinearPercentIndicator(
                              animation: true,
                              lineHeight: 14.0,
                              animationDuration: 1500,
                              percent: book.totalPages == 0 ? 0 : _getProgress(),
                              center: Text(
                                book.totalPages == 0 ? '0%' : '${(_getProgress() * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 8),
                              ),
                              linearStrokeCap: LinearStrokeCap.roundAll,
                              progressColor: _getProgressColor(),
                            ),
                          ),
                    SpaceH4(),
                    book.state != BookState.Reading
                        ? Container()
                        : Text(
                            '${book.totalPages - book.pagesRead} ${StringConst.pagesLeft.tr}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: StringConst.trtRegular,
                            ),
                          ),
                    SpaceH24(),
                    FutureBuilder(
                      future: _getDateStartedValue(),
                      builder: (context, AsyncSnapshot<String> value) => CustomBookPropertyTile(
                        title: StringConst.dateStarted.tr,
                        titleTextStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        value: value.data,
                        trailingIcon: book.dateStarted == null
                            ? Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[700],
                                size: 18,
                              )
                            : Icon(
                                Icons.clear,
                                color: Colors.grey[700],
                                size: 20,
                              ),
                        showTrailingIcon: true,
                        bottomBorderColor: Colors.grey[500],
                        bottomPadding: 6,
                        topPadding: 6,
                        onTrailingIconTap: () {
                          setState(() {
                            book.dateStarted = null;
                          });
                        },
                        onPressed: () {
                          DatePicker.showDatePicker(
                            context,
                            showTitleActions: true,
                            locale: _getLocale(),
                            minTime: DateTime(1900),
                            maxTime: _getMaxTime(),
                            currentTime: DateTime.now(),
                            onConfirm: (date) {
                              setState(() {
                                book.dateStarted = date;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    FutureBuilder(
                      future: _getDateFinishedValue(),
                      builder: (context, AsyncSnapshot<String> value) => CustomBookPropertyTile(
                        titleTextStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        title: book.state == BookState.Dropped ? StringConst.dateDropped.tr : StringConst.dateFinished.tr,
                        value: value.data,
                        trailingIcon: book.dateFinished == null
                            ? Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[700],
                                size: 18,
                              )
                            : Icon(
                                Icons.clear,
                                color: Colors.grey[700],
                                size: 20,
                              ),
                        showTrailingIcon: true,
                        showBottomBorder: false,
                        bottomPadding: 6,
                        topPadding: 6,
                        onTrailingIconTap: () {
                          setState(() {
                            book.dateFinished = null;
                          });
                        },
                        onPressed: () {
                          DatePicker.showDatePicker(
                            context,
                            showTitleActions: true,
                            locale: _getLocale(),
                            minTime: _getMinTime(),
                            maxTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                            onConfirm: (date) {
                              setState(() {
                                book.dateFinished = date;
                              });
                            },
                            currentTime: DateTime.now(),
                          );
                        },
                      ),
                    ),
                    Container(
                      height: 12,
                      color: Colors.grey[300],
                    ),
                    CustomBookPropertyTile(
                      titleTextStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      title: StringConst.totalPagess.tr,
                      value: book.totalPages.toString(),
                      trailingIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[700],
                        size: 18,
                      ),
                      showTrailingIcon: true,
                      bottomBorderColor: Colors.grey[500],
                      topPadding: 6,
                      bottomPadding: 6,
                      onPressed: () async {
                        int totalPages = book.totalPages;
                        var result = await showDialog(
                          context: context,
                          builder: (BuildContext context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0.0,
                            insetPadding: const EdgeInsets.symmetric(horizontal: 30),
                            backgroundColor: Colors.transparent,
                            child: GestureDetector(
                              onTap: () {
                                Utils.unFocus();
                              },
                              child: Container(
                                height: 210,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Container(
                                      height: 210,
                                      width: width,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Text(
                                            StringConst.totalPages.tr,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              color: AppColors.nord0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SpaceH40(),
                                          Form(
                                            key: _form,
                                            child: CustomTextFormField(
                                              textAlign: TextAlign.center,
                                              width: width * 0.5,
                                              contentPadding: const EdgeInsets.only(bottom: 5),
                                              keyboardType: TextInputType.number,
                                              digitsOnly: true,
                                              initialValue: totalPages == 0 ? '' : totalPages.toString(),
                                              textStyle: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 40,
                                              ),
                                              hintStyle: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 40,
                                              ),
                                              textCapitalization: TextCapitalization.words,
                                              onChanged: (value) {
                                                if (value == '') {
                                                  setState(() {
                                                    totalPages = 0;
                                                  });
                                                } else {
                                                  setState(() {
                                                    totalPages = int.parse(value);
                                                  });
                                                }
                                              },
                                              validator: (value) {
                                                if (value.toString().isEmpty) {
                                                  return StringConst.enterValidNumber.tr;
                                                }

                                                if (int.parse(value) > 10000) {
                                                  return StringConst.totalPagesCantBeMoreThan.tr;
                                                }

                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      bottom: 4,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Text(
                                              StringConst.cancel.tr,
                                              style: const TextStyle(color: Colors.red, fontSize: 14.0),
                                            ),
                                            onPressed: () {
                                              Get.back();
                                            },
                                          ),
                                          TextButton(
                                            child: Text(
                                              StringConst.done.tr,
                                              style: const TextStyle(color: AppColors.nord1, fontSize: 14.0),
                                            ),
                                            onPressed: () {
                                              final isValid = _form.currentState.validate();
                                              if (!isValid) {
                                                return;
                                              }
                                              Utils.unFocus();
                                              Get.back(result: totalPages);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                        if (result != null) {
                          if (totalPages < book.pagesRead) {
                            setState(() {
                              book.totalPages = totalPages;
                              book.pagesRead = totalPages;
                            });
                          } else {
                            setState(() {
                              book.totalPages = totalPages;
                            });
                          }
                        }
                      },
                    ),
                    CustomBookPropertyTile(
                      titleTextStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      title: book.state == BookState.Finished ? StringConst.pagesRead.tr : StringConst.currentPosition.tr,
                      value: book.pagesRead.toString(),
                      trailingIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[700],
                        size: 18,
                      ),
                      showTrailingIcon: true,
                      showBottomBorder: false,
                      topPadding: 6,
                      bottomPadding: 6,
                      onPressed: () {
                        editCurrentPosition();
                      },
                    ),
                    Container(
                      height: 12,
                      color: Colors.grey[300],
                    ),
                    CustomBookPropertyTile(
                      titleTextStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      title: StringConst.genre.tr,
                      value: _getGenre(model.user.genres),
                      trailingIcon: book.genre == ''
                          ? Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey[700],
                              size: 18,
                            )
                          : Icon(
                              Icons.clear,
                              color: Colors.grey[700],
                              size: 20,
                            ),
                      showTrailingIcon: true,
                      bottomBorderColor: Colors.grey[500],
                      topPadding: 6,
                      bottomPadding: 6,
                      onTrailingIconTap: () {
                        setState(() {
                          book.genre = '';
                        });
                      },
                      onPressed: () async {
                        var result = await showDialog(
                          context: context,
                          builder: (BuildContext context) => CustomGenrePickerDialog(
                            selectedId: _getGenre(model.user.genres) == '' ? '' : book.genre,
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            book.genre = result;
                          });
                        }
                      },
                    ),
                    CustomBookPropertyTile(
                      titleTextStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      title: StringConst.state.tr,
                      value: Utils.getBookState(book.state),
                      trailingIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[700],
                        size: 18,
                      ),
                      showTrailingIcon: true,
                      showBottomBorder: false,
                      topPadding: 6,
                      bottomPadding: 6,
                      onPressed: () async {
                        var result = await showDialog(
                          context: context,
                          builder: (BuildContext context) => BookStateDialog(
                            bookState: book.state,
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            book.state = result;

                            if (book.state == BookState.Finished) {
                              book.pagesRead = book.totalPages;
                            }

                            if (book.state == BookState.Finished && book.dateFinished == null) {
                              book.dateFinished = DateTime.now();
                            }

                            if (book.state == BookState.Reading && book.dateStarted == null) {
                              book.dateStarted = DateTime.now();
                            }
                          });
                        }
                      },
                    ),
                    Container(
                      height: 12,
                      color: Colors.grey[300],
                    ),
                    SpaceH16(),
                    Container(
                      width: width - 32,
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.2,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: false,
                        maxLength: 1000,
                        controller: _controllerNotes,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: StringConst.youCanTakeNotesHere.tr,
                          border: const OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.grey2, width: 2.0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(5),
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.grey2, width: 2.0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(5),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.nord4, width: 2.0),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                        ),
                        cursorColor: AppColors.nord0,
                        onChanged: (String value) {
                          setState(() {
                            book.notes = value;
                          });
                        },
                      ),
                    ),
                    SpaceH16(),
                    Container(
                      height: 12,
                      color: Colors.grey[300],
                    ),
                    CustomBookPropertyTile(
                      leadingIcon: const Icon(
                        FontAwesomeIcons.highlighter,
                      ),
                      paddingBetweenIconAndText: SpaceW12(),
                      title: StringConst.highlights.tr,
                      trailingIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[700],
                        size: 15,
                      ),
                      showTrailingIcon: true,
                      bottomBorderColor: Colors.grey[500],
                      topPadding: 8,
                      bottomPadding: 8,
                      onPressed: () {
                        Get.to(() => BookHighlightsScreen(
                              bookId: book.id,
                            ));
                      },
                    ),
                    CustomBookPropertyTile(
                      leadingIcon: const Icon(
                        Icons.insert_chart,
                      ),
                      paddingBetweenIconAndText: SpaceW12(),
                      title: StringConst.readingStats.tr,
                      trailingIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[700],
                        size: 15,
                      ),
                      showTrailingIcon: true,
                      bottomBorderColor: Colors.grey[500],
                      topPadding: 8,
                      bottomPadding: 8,
                      onPressed: () {
                        Get.to(() => BookReadingChartScreen(book: book));
                      },
                    ),
                    book.state == BookState.Reading
                        ? CustomBookPropertyTile(
                            leadingIcon: const Icon(
                              Icons.notifications,
                            ),
                            paddingBetweenIconAndText: SpaceW12(),
                            title: StringConst.readingReminders.tr,
                            trailingIcon: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey[700],
                              size: 15,
                            ),
                            showTrailingIcon: true,
                            bottomBorderColor: Colors.grey[500],
                            topPadding: 8,
                            bottomPadding: 8,
                            onPressed: () {
                              Get.to(() => RemindersScreen(book: book));
                            },
                          )
                        : Container(),
                    CustomBookPropertyTile(
                      leadingIcon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      paddingBetweenIconAndText: SpaceW12(),
                      title: StringConst.delete.tr,
                      titleTextStyle: const TextStyle(
                        color: Colors.red,
                      ),
                      topPadding: 8,
                      bottomPadding: 8,
                      showTrailingIcon: false,
                      onPressed: () async {
                        var result = await showDialog(
                          builder: (context) => CustomYesNoDialog(
                            message: '${StringConst.confirmDeletingBook.tr}: ${book.title}',
                            buttonTitleLeft: StringConst.delete.tr,
                            buttonTitleRight: StringConst.cancel.tr,
                            leftButtonReturn: true,
                            rightButtonReturn: false,
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

                          await model.deleteBook(id: book.id, imgUrl: book.imgUrl);

                          model.user.collections.forEach((Collection collection) async {
                            collection.books.remove(book.id);
                            await model.updateCollection(id: collection.id, collection: collection);
                          });

                          var dbModel = Provider.of<DbModel>(context, listen: false);

                          if (dbModel.reminders.containsKey(book.id)) {
                            await dbModel.canceAllNotificationsForBook(bookId: book.id);
                          }

                          setState(() {
                            _isLoading = false;
                          });
                          Get.back(result: {
                            'result': true,
                            'book': book.title,
                            'action': 'delete',
                          });
                        }
                      },
                    ),
                    Container(
                      height: 80,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
