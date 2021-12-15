import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_edge_detection/cropping_preview.dart';
import 'package:simple_edge_detection/edge_detection.dart';
import 'package:simple_edge_detection/edge_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../dialogs/custom_yes_no_dialog.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_entry_field.dart';
import '../model/models.dart';
import '../values/values.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/utils.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/spaces.dart';
import '../enums/modal_option.dart';
import '../enums/online_search_option.dart';
import '../locator.dart';
import '../services/api.dart';
import '../widgets/custom_empty_book_card.dart';
import '../dialogs/custom_genre_picker_dialog.dart';
import '../dialogs/custom_image_picker_dialog.dart';
import '../widgets/custom_network_image.dart';
import '../dialogs/custom_book_state_dialog.dart';

class AddBookScreen extends StatefulWidget {
  final GoogleBook googleBook;
  const AddBookScreen({this.googleBook});
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  String croppedImagePath;
  EdgeDetectionResult edgeDetectionResult;
  String imagePath;

  DateFormat _dateFormatter;

  bool _isStateCleared = false;
  bool _isGenreCleared = false;
  bool _isDateStartedCleared = false;
  bool _isDateFinishedCleared = false;

  bool _isLoading = false;
  Book book = Book();
  File _imageFile;
  Api _api = locator<Api>();

  List<String> allAuthors = [];

  final _form = GlobalKey<FormState>();
  final _manualImageForm = GlobalKey<FormState>();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _authorFocusNode = FocusNode();
  final FocusNode _totalPagesFocusNode = FocusNode();
  final FocusNode _pagesReadFocusNode = FocusNode();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.googleBook != null) {
      book = Book(
        title: widget.googleBook.title,
        author: widget.googleBook.authors,
        imgUrl: widget.googleBook.thumbnail,
        totalPages: widget.googleBook.pageCount,
      );
    }

    _titleController.value = TextEditingValue(text: book.title, selection: _titleController.selection);
    _authorController.value = TextEditingValue(text: book.author, selection: _authorController.selection);

    var model = Provider.of<UserModel>(context, listen: false);

    model.user.books.forEach((book) {
      if (!allAuthors.contains(book.author)) {
        allAuthors.add(book.author);
      }
    });
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

  Widget _showImage() {
    Widget widget;
    if (book.imgUrl != '') {
      widget = Container(
        width: 125,
        height: 180,
        child: CustomNetworkImage(
          url: book.imgUrl,
        ),
      );
    } else if (_imageFile != null) {
      widget = Container(
        width: 125,
        height: 180,
        child: Image.file(
          _imageFile,
          fit: BoxFit.fill,
        ),
      );
    } else {
      widget = CustomEmptyBookCard(
        width: 125,
        height: 180,
        stackWidget: Positioned(
          top: 150,
          left: 95,
          child: const Icon(Icons.add),
        ),
        showTitle: false,
      );
    }
    return widget;
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

  DateTime _getMinTime() {
    return book.dateStarted != null ? book.dateStarted : DateTime(1900);
  }

  DateTime _getMaxTime() {
    return book.dateFinished != null ? book.dateFinished : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
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

  Future<bool> _onWillPop() async {
    Book _book = Book();

    if (book == _book) {
      return Future.value(true);
    } else {
      var result = await _exitWithoutAdding();
      if (result != null && result) {
        return Future.value(true);
      }

      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var widthOfScreen = MediaQuery.of(context).size.width;
    var model = Provider.of<UserModel>(context, listen: false);
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: StringConst.addNewBook.tr,
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                final isValid = _form.currentState.validate();
                if (!isValid) {
                  return;
                }

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

                if (model.user.books.length >= Utils.maxBookCapacity) {
                  setState(() {
                    _isLoading = false;
                  });
                  Utils.showFlushInfo(
                    context,
                    '${StringConst.reachedMaxBookCapacity.tr}: ${Utils.maxBookCapacity}. ${StringConst.upgradeToProToSeeWhy.tr}',
                  );
                  return;
                }

                book.dateCreated = DateTime.now();
                book.highlights = [];
                book.graphData = {};

                AddBookResult addBookResult = await model.addBook(
                  book: book,
                );

                if (book.imgUrl != '') {
                  _imageFile = await Utils.urlToFile(imageUrl: book.imgUrl, id: addBookResult.model.id);
                }

                if (_imageFile != null) {
                  var result = await _api.uploadCoverImage(bookCover: _imageFile, bookId: addBookResult.model.id);
                  if (!result.success) {
                    Utils.showFlushError(context, StringConst.couldNotUploadCover.tr);
                  } else {
                    book.imgUrl = result.downloadUrl;
                    await model.updateBook(id: addBookResult.model.id, book: book);
                  }
                }

                if (book.dateStarted != null && Utils.formatter.format(book.dateStarted) == Utils.formatter.format(DateTime.now()) && book.pagesRead != 0) {
                  book.graphData[Utils.formatter.format(DateTime.now())] = {
                    'pagesRead': book.pagesRead,
                    'id': addBookResult.model.id,
                  };
                  await model.updateBook(id: addBookResult.model.id, book: book);
                }

                setState(() {
                  _isLoading = false;
                });

                Get.back(result: {
                  'result': true,
                  'book': book.title,
                  'action': 'insert',
                  'state': book.state,
                });
              },
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            Utils.unFocus();
          },
          child: SafeArea(
            child: LoadingOverlay(
              isLoading: _isLoading,
              color: Colors.white,
              opacity: 0.65,
              progressIndicator: const SpinKitCircle(
                color: AppColors.nord1,
                size: 60,
              ),
              child: ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SpaceH12(),
                      GestureDetector(
                        onTap: () async {
                          Utils.unFocus();
                          var result = await Utils.showBottomSheet(context);
                          if (result == ModalOption.SearchOnline) {
                            if (book.title.isEmpty) {
                              Utils.showFlushError(context, StringConst.pleaseEnterBookTitle.tr);
                              return;
                            }

                            if (!(await Utils.isOnline())) {
                              setState(() {
                                _isLoading = false;
                              });
                              Utils.showFlushError(context, StringConst.makeSureYouAreOnline.tr);
                              return;
                            }

                            setState(() {
                              _isLoading = true;
                            });

                            var prefs = await SharedPreferences.getInstance();
                            String value = prefs.getString('searchEngine');
                            OnlineSearchOption initialOption;

                            if (value != null) {
                              initialOption = Utils.getSearchOptionAsEnum(value);
                            } else {
                              initialOption = OnlineSearchOption.Bookdepository;
                            }

                            var imgLinks = await Utils.getCoversOnline(
                              title: book.title,
                              author: book.author,
                              option: initialOption,
                            );

                            setState(() {
                              _isLoading = false;
                            });

                            if (imgLinks is String) {
                              Utils.showFlushError(context, imgLinks);
                            } else if (imgLinks is List) {
                              if (imgLinks.length == 0) {
                                Utils.showFlushInfo(context, StringConst.couldNotFindImages.tr);
                              } else {
                                var result2 = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) => CustomImagePickerDialog(
                                    imgLinks: imgLinks,
                                  ),
                                );

                                if (result2 != null) {
                                  setState(() {
                                    book.imgUrl = result2;
                                    book.siteImgUrl = result2;
                                  });
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
                                                width: widthOfScreen,
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
                                                        width: widthOfScreen * 0.7,
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

                                                        Utils.unFocus();

                                                        if (!(await Utils.isOnline())) {
                                                          setState(() {
                                                            _loading = false;
                                                          });
                                                          Get.back();
                                                          Utils.showFlushError(context, StringConst.makeSureYouAreOnline.tr);
                                                          return;
                                                        }

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
                              if (url == '') {
                                Utils.showFlushError(context, StringConst.urlWasNotValid.tr);
                              } else {
                                File img = await Utils.urlToFile(imageUrl: url);

                                File compressedFile = await FlutterNativeImage.compressImage(
                                  img.path,
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
                                  _imageFile = compressedFile;
                                  book.siteImgUrl = result['url'];
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
                              setState(() {
                                _isLoading = false;
                              });
                              var state = await Utils.showAlertDialog(context, description: StringConst.toUseCameraGivePermission.tr);
                              if (state) {
                                openAppSettings();
                              }
                            }
                          } else if (result == ModalOption.Delete) {
                            setState(() {
                              book.imgUrl = '';
                              book.siteImgUrl = '';
                              _imageFile = null;
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
                      SpaceH18(),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          key: _form,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SpaceH10(),
                              EntryField(
                                hintText: StringConst.title.tr,
                                icon: const Icon(Icons.title),
                                textEditingValue: book.title,
                                focusNode: _titleFocusNode,
                                controller: _titleController,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                onSubmit: (_) {
                                  FocusScope.of(context).requestFocus(_authorFocusNode);
                                },
                                onChanged: (value) {
                                  setState(() {
                                    book.title = value;
                                  });
                                },
                                validator: (value) {
                                  if (book.title.trim().isEmpty) {
                                    return StringConst.titleIsRequired.tr;
                                  }
                                  if (book.title.length > 200) {
                                    return StringConst.bookTitleLengthMustBeLowerThan.tr;
                                  }
                                  if (model.isBookAlreadyExists(book.title)) {
                                    return StringConst.thisBookAlreadyExists.tr;
                                  }
                                },
                              ),
                              SpaceH10(),
                              FormField(
                                validator: (value) {
                                  if (book.author.trim().isEmpty) {
                                    return StringConst.authorNameIsRequired.tr;
                                  }
                                  if (book.author.length > 200) {
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
                                              book.author = value;
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
                                            book.author = suggestion;
                                            _authorController.value = TextEditingValue(text: book.author, selection: _authorController.selection);
                                          });
                                        },
                                        hideOnEmpty: true,
                                        onSaved: (value) => book.author = value,
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
                              SpaceH10(),
                              EntryField(
                                hintText: StringConst.state.tr,
                                icon: const Icon(Icons.auto_stories),
                                readOnly: true,
                                textEditingValue: book.state != null ? Utils.getBookState(book.state) : '',
                                showSuffixIcon: book.state != null ? true : false,
                                onSuffixIconTap: () {
                                  Utils.unFocus();
                                  setState(() {
                                    _isStateCleared = true;
                                    book.state = null;
                                  });
                                },
                                validator: (value) {
                                  if (book.state == null) {
                                    return StringConst.bookStateIsRequired.tr;
                                  }
                                },
                                onTap: () async {
                                  if (!_isStateCleared) {
                                    var result = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) => BookStateDialog(
                                        bookState: book.state,
                                      ),
                                    );
                                    if (result != null) {
                                      setState(() {
                                        book.state = result;
                                      });
                                    }
                                  }
                                  _isStateCleared = false;
                                  Utils.unFocus();
                                },
                              ),
                              SpaceH10(),
                              EntryField(
                                hintText: StringConst.genre.tr,
                                icon: const Icon(Icons.category),
                                textEditingValue: book.genre != '' ? _getGenre(model.user.genres) : '',
                                showSuffixIcon: book.genre != '' ? true : false,
                                onSuffixIconTap: () {
                                  Utils.unFocus();
                                  setState(() {
                                    _isGenreCleared = true;
                                    book.genre = '';
                                  });
                                },
                                readOnly: true,
                                onTap: () async {
                                  if (!_isGenreCleared) {
                                    var result = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) => CustomGenrePickerDialog(
                                        selectedId: _getGenre(model.user.genres) == '' ? '' : book.genre,
                                        showClearButton: false,
                                      ),
                                    );

                                    if (result != null) {
                                      setState(() {
                                        book.genre = result;
                                      });
                                    }
                                  }
                                  _isGenreCleared = false;
                                  Utils.unFocus();
                                },
                              ),
                              SpaceH10(),
                              EntryField(
                                  hintText: StringConst.totalPages.tr,
                                  digitsOnly: true,
                                  inputType: TextInputType.number,
                                  focusNode: _totalPagesFocusNode,
                                  textInputAction: TextInputAction.next,
                                  onSubmit: (_) {
                                    FocusScope.of(context).requestFocus(_pagesReadFocusNode);
                                  },
                                  textEditingValue: book.totalPages != null ? book.totalPages.toString() : '',
                                  onChanged: (value) {
                                    if (value.toString().trim().isEmpty) {
                                      setState(() {
                                        book.totalPages = 0;
                                      });
                                    } else {
                                      setState(() {
                                        book.totalPages = int.parse(value);
                                      });
                                    }
                                  }),
                              SpaceH10(),
                              EntryField(
                                hintText: StringConst.pagesRead.tr,
                                digitsOnly: true,
                                focusNode: _pagesReadFocusNode,
                                textEditingValue: book.pagesRead != null ? book.pagesRead.toString() : '',
                                inputType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.toString().trim().isEmpty) {
                                    setState(() {
                                      book.pagesRead = 0;
                                    });
                                  } else {
                                    setState(() {
                                      book.pagesRead = int.parse(value);
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (book.pagesRead > book.totalPages) {
                                    return StringConst.pagesReadCantBeMoreThanTotalPages.tr;
                                  }
                                },
                              ),
                              SpaceH10(),
                              FutureBuilder(
                                future: _getDateStartedValue(),
                                builder: (context, AsyncSnapshot<String> value) => EntryField(
                                  hintText: StringConst.dateStarted.tr,
                                  icon: const Icon(Icons.today),
                                  textEditingValue: value.data != null ? value.data : '',
                                  readOnly: true,
                                  showSuffixIcon: book.dateStarted != null ? true : false,
                                  onSuffixIconTap: () {
                                    Utils.unFocus();
                                    setState(() {
                                      _isDateStartedCleared = true;
                                      book.dateStarted = null;
                                    });
                                  },
                                  onTap: () {
                                    if (!_isDateStartedCleared) {
                                      DatePicker.showDatePicker(
                                        context,
                                        showTitleActions: true,
                                        minTime: DateTime(1900),
                                        maxTime: _getMaxTime(),
                                        currentTime: DateTime.now(),
                                        locale: _getLocale(),
                                        onConfirm: (date) {
                                          setState(() {
                                            book.dateStarted = date;
                                          });
                                        },
                                        onCancel: () {
                                          Utils.unFocus();
                                        },
                                      );
                                    }
                                    _isDateStartedCleared = false;
                                    Utils.unFocus();
                                  },
                                ),
                              ),
                              SpaceH10(),
                              FutureBuilder(
                                future: _getDateFinishedValue(),
                                builder: (context, AsyncSnapshot<String> value) => EntryField(
                                  hintText: StringConst.dateFinished.tr,
                                  icon: const Icon(Icons.date_range),
                                  textEditingValue: value.data != null ? value.data : '',
                                  readOnly: true,
                                  showSuffixIcon: book.dateFinished != null ? true : false,
                                  onSuffixIconTap: () {
                                    Utils.unFocus();
                                    setState(() {
                                      _isDateFinishedCleared = true;
                                      book.dateFinished = null;
                                    });
                                  },
                                  onTap: () {
                                    if (!_isDateFinishedCleared) {
                                      DatePicker.showDatePicker(
                                        context,
                                        showTitleActions: true,
                                        minTime: _getMinTime(),
                                        maxTime: DateTime.now(),
                                        currentTime: DateTime.now(),
                                        locale: _getLocale(),
                                        onConfirm: (date) {
                                          setState(() {
                                            book.dateFinished = date;
                                          });
                                        },
                                        onCancel: () {
                                          Utils.unFocus();
                                        },
                                      );
                                    }
                                    _isDateFinishedCleared = false;
                                    Utils.unFocus();
                                  },
                                ),
                              ),
                              SpaceH18(),
                            ],
                          ),
                        ),
                      ),
                      SpaceH30(),
                    ],
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
