import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dialogs/custom_yes_no_dialog.dart';
import '../enums/viewstate.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../widgets/custom_book_card_vertical.dart';
import '../widgets/custom_empty_book_card.dart';
import '../widgets/custom_progress_indicator.dart';
import '../model/models.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/spaces.dart';

import 'error_screen.dart';
import 'book_detail_screen.dart';

class CollectionScreen extends StatefulWidget {
  final Collection collection;
  CollectionScreen({this.collection});
  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<Widget> _bookCards;
  List<String> _booksToDelete = [];

  bool _isInit = true;
  bool _isLoading = false;

  Collection collection;

  @override
  void initState() {
    super.initState();
    collection = Collection.fromJson(
      id: widget.collection.id,
      json: widget.collection.toJson(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Utils.showCollectionTip == null) {
        Flushbar flush;
        flush = Flushbar<bool>(
          title: StringConst.tip.tr,
          message: StringConst.youCanReOrder.tr,
          icon: const Icon(
            Icons.info_outline,
            color: Colors.blue,
          ),
          mainButton: TextButton(
            onPressed: () {
              flush.dismiss(true);
            },
            child: Text(
              StringConst.close.tr,
              style: const TextStyle(color: Colors.amber),
            ),
          ),
        )..show(context).then((result) async {
            if (result) {
              var prefs = await SharedPreferences.getInstance();
              await prefs.setBool('showCollectionTip', false);
              Utils.showCollectionTip = false;
            }
          });
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      Widget _card = _bookCards.removeAt(oldIndex);
      _bookCards.insert(newIndex, _card);

      String _id = collection.books.removeAt(oldIndex);
      collection.books.insert(newIndex, _id);
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
    if (collection == widget.collection) {
      return Future.value(true);
    } else {
      var result = await _exitWithoutSaving();
      if (result != null && result) {
        return Future.value(true);
      }

      return Future.value(false);
    }
  }

  Widget buildBody(UserModel model) {
    Widget screen;
    if (model.user.getBooksViewState == ViewState.Busy) {
      screen = CustomProgressIndicator();
    } else if (model.user.getBooksViewState == ViewState.Ready) {
      if (collection.books.length == 0) {
        screen = screen = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150,
                height: 100,
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    StringConst.bookCollectionHighRes,
                    color: AppColors.nord0,
                  ),
                ),
              ),
              SpaceH24(),
              Text(
                StringConst.thisCollectionIsEmpty.tr,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      } else {
        if (_isInit) {
          _isInit = false;

          List<Book> books = widget.collection.books.map((bookId) => model.user.books.firstWhere((book) => book.id == bookId)).toList();

          _bookCards = books
              .map(
                (book) => Container(
                  key: Key(book.id),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  height: 130,
                  child: GestureDetector(
                    onTap: () async {
                      var data = await Get.to(
                        () => BookDetailScreen(
                          book: book,
                        ),
                      );
                      if (data != null && data['result']) {
                        if (data['action'] == 'update') {
                          Utils.showCustomInfoToast(
                            context,
                            StringConst.customTranslation(
                              key: StringConst.bookUpdate,
                              data: data['book'],
                            ),
                          );
                        } else if (data['action'] == 'delete') {
                          Utils.showCustomInfoToast(
                            context,
                            StringConst.customTranslation(
                              key: StringConst.bookDelete,
                              data: data['book'],
                            ),
                          );
                        }
                        setState(() {
                          _isInit = true;
                        });
                      } else if (data != null && !data['result']) {
                        Utils.showCustomErrorToast(context, StringConst.anErrorOccured.tr);
                      }
                    },
                    child: Card(
                      elevation: 8,
                      margin: const EdgeInsets.all(0),
                      color: Colors.white,
                      child: Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SpaceW10(),
                            Container(
                              height: 100,
                              width: 70,
                              child: book.imgUrl == ''
                                  ? CustomEmptyBookCard(
                                      showTitle: false,
                                      showSmallIcon: true,
                                    )
                                  : CustomBookCardVertical(
                                      book: book,
                                      shrinkBottom: true,
                                      showSmallIcon: true,
                                      borderRadius: 4,
                                      customOnTap: () async {
                                        var data = await Get.to(
                                          () => BookDetailScreen(
                                            book: book,
                                          ),
                                        );
                                        if (data != null && data['result']) {
                                          if (data['action'] == 'update') {
                                            Utils.showCustomInfoToast(
                                              context,
                                              StringConst.customTranslation(
                                                key: StringConst.bookUpdate,
                                                data: data['book'],
                                              ),
                                            );
                                          } else if (data['action'] == 'delete') {
                                            Utils.showCustomInfoToast(
                                              context,
                                              StringConst.customTranslation(
                                                key: StringConst.bookDelete,
                                                data: data['book'],
                                              ),
                                            );
                                          }
                                          setState(() {
                                            _isInit = true;
                                          });
                                        } else if (data != null && !data['result']) {
                                          Utils.showCustomErrorToast(context, StringConst.anErrorOccured.tr);
                                        }
                                      },
                                    ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SpaceH12(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    alignment: Alignment.topLeft,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        book.title,
                                        style: const TextStyle(fontSize: 14),
                                        textAlign: TextAlign.left,
                                        maxLines: 5,
                                      ),
                                    ),
                                  ),
                                  SpaceH6(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    alignment: Alignment.centerLeft,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        book.author,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.left,
                                        maxLines: 5,
                                      ),
                                    ),
                                  ),
                                  SpaceH12(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    alignment: Alignment.centerLeft,
                                    child: RatingBarIndicator(
                                      unratedColor: Colors.grey[300],
                                      rating: book.rating,
                                      itemCount: 5,
                                      itemSize: 18,
                                      itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                  SpaceH12(),
                                ],
                              ),
                            ),
                            StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                              return Checkbox(
                                  value: _booksToDelete.contains(book.id),
                                  onChanged: (value) {
                                    if (value) {
                                      setState(() {
                                        _booksToDelete.add(book.id);
                                      });
                                    } else {
                                      setState(() {
                                        _booksToDelete.remove(book.id);
                                      });
                                    }
                                  });
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList();
        }

        screen = LoadingOverlay(
          isLoading: _isLoading,
          color: Colors.white,
          opacity: 0.65,
          progressIndicator: const SpinKitCircle(
            color: AppColors.nord1,
            size: 60,
          ),
          child: ReorderableColumn(
            padding: const EdgeInsets.symmetric(vertical: 10),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _bookCards,
            onReorder: _onReorder,
          ),
        );
      }
    } else if (model.user.getBooksViewState == ViewState.Error) {
      screen = ErrorScreen(
        function: model.getBookList,
      );
    }

    return screen;
  }

  @override
  Widget build(BuildContext context) {
    UserModel model = Provider.of<UserModel>(context, listen: true);
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: collection.title,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.white,
              onPressed: () async {
                if (_booksToDelete.length != 0) {
                  var result = await showDialog(
                    builder: (context) => CustomYesNoDialog(
                      buttonTitleLeft: StringConst.yes.tr,
                      buttonTitleRight: StringConst.no.tr,
                      message: StringConst.confirmDeletingSelectedBooks.tr,
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
                      Utils.showCustomErrorToast(
                        context,
                        StringConst.makeSureYouAreOnline.tr,
                      );
                      return;
                    }

                    var result = await model.updateCollection(
                      id: widget.collection.id,
                      collection: collection,
                    );

                    if (result) {
                      collection.books.removeWhere((id) => _booksToDelete.contains(id));
                      _bookCards.removeWhere((widget) {
                        String k = widget.key.toString().replaceAll("[<'", "").replaceAll("'>]", "");
                        return _booksToDelete.contains(k);
                      });
                      _booksToDelete.clear();
                      setState(() {});
                      Utils.showCustomInfoToast(context, StringConst.bookSDeleteSuccess.tr);
                    } else {
                      Utils.showCustomErrorToast(context, StringConst.bookSDeleteFail.tr);
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  }
                } else {
                  Utils.showCustomErrorToast(context, StringConst.selectBooksToDelete.tr);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.save),
              color: Colors.white,
              onPressed: () async {
                if (collection == widget.collection) {
                  Get.back();
                } else {
                  setState(() {
                    _isLoading = true;
                  });

                  if (!(await Utils.isOnline())) {
                    setState(() {
                      _isLoading = false;
                    });
                    Utils.showCustomErrorToast(
                      context,
                      StringConst.makeSureYouAreOnline.tr,
                    );
                    return;
                  }

                  var result = await model.updateCollection(
                    id: collection.id,
                    collection: collection,
                  );

                  setState(() {
                    _isLoading = false;
                  });

                  if (result) {
                    collection = Collection.fromJson(
                      id: widget.collection.id,
                      json: widget.collection.toJson(),
                    );
                    Utils.showCustomInfoToast(context, StringConst.collectionUpdateSuccess.tr);
                  } else {
                    Utils.showCustomErrorToast(context, StringConst.collectionUpdateFail.tr);
                  }
                }
              },
            ),
          ],
        ),
        body: buildBody(model),
      ),
    );
  }
}
