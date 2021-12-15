import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../values/values.dart';
import '../enums/viewstate.dart';
import '../utils/utils.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_book_card_vertical.dart';
import '../widgets/custom_progress_indicator.dart';
import '../widgets/spaces.dart';

import 'error_screen.dart';
import 'create_highlight_screen.dart';
import 'empty_screen.dart';
import 'filter_screen.dart';

class SelectBookScreen extends StatefulWidget {
  @override
  _SelectBookScreenState createState() => _SelectBookScreenState();
}

class _SelectBookScreenState extends State<SelectBookScreen> {
  List searchList = [];

  Widget buildBody() {
    Widget screen;
    var model = Provider.of<UserModel>(context, listen: true);

    if (model.user.getBooksViewState == ViewState.Busy) {
      screen = Center(
        child: CustomProgressIndicator(),
      );
    } else if (model.user.getBooksViewState == ViewState.Ready) {
      if (model.user.books.length != 0) {
        searchList = model.filterBooks();

        if (Utils.sort.values.contains(true)) {
          searchList = model.sortBooks(books: searchList);
        }
        if (searchList.length == 0) {
          screen = Center(
            child: Text(StringConst.couldNotFindBook.tr),
          );
        } else {
          screen = Container(
            child: Column(
              children: [
                searchList.length != model.user.books.length
                    ? Container(
                        padding: const EdgeInsets.only(
                          left: 4,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${searchList.length} ${StringConst.bookSFound.tr}',
                          style: const TextStyle(
                            fontFamily: StringConst.trtRegular,
                          ),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                    addAutomaticKeepAlives: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1 / 1.55,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: searchList.length,
                    itemBuilder: (context, index) {
                      return CustomBookCardVertical(
                        book: searchList[index],
                        showSmallIcon: true,
                        shrinkBottom: true,
                        customOnTap: () {
                          if (searchList[index].highlights.length >= Utils.maxHighlightCapacity) {
                            Utils.showFlushInfo(
                              context,
                              StringConst.customTranslation(
                                data: model.user.books[index].title,
                                key: StringConst.reachedMaxHighlightCapacity,
                              ),
                            );
                            return;
                          }
                          Utils.setALLSortValuesToFlase();
                          Utils.clearAllFilters(Utils.filter);

                          Get.off(() => CreateHighlightScreen(
                                book: searchList[index],
                              ));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        screen = EmptyScreen(
          icon: FontAwesomeIcons.book,
          description: StringConst.couldNotFindAnyBookTryAddingSome.tr,
        );
      }
    } else if (model.user.getBooksViewState == ViewState.Error) {
      screen = ErrorScreen(function: model.getBookList);
    }
    return screen;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        Utils.unFocus();
      },
      child: WillPopScope(
        onWillPop: () {
          Utils.setALLSortValuesToFlase();
          Utils.clearAllFilters(Utils.filter);
          return Future.value(true);
        },
        child: Scaffold(
          appBar: CustomAppBar(title: StringConst.selectABook.tr),
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              width: width,
              height: height,
              child: Column(
                children: [
                  SpaceH12(),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(.5),
                          blurRadius: 20.0,
                          spreadRadius: 0.0,
                          offset: const Offset(
                            5.0,
                            5.0,
                          ),
                        )
                      ],
                    ),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.search,
                        ),
                        trailing: Container(
                          width: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Utils.showSortSetting(
                                    context,
                                    setState: () {
                                      setState(() {
                                        searchList = [];
                                      });
                                    },
                                    onSortSelect: () {
                                      setState(() {});
                                    },
                                  );
                                },
                                child: Icon(Icons.sort_by_alpha),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await Get.to(() => FilterScreen());
                                  setState(() {});
                                },
                                child: Icon(Icons.filter_list),
                              ),
                            ],
                          ),
                        ),
                        title: TextField(
                            decoration: InputDecoration.collapsed(hintText: StringConst.searchWithDots.tr),
                            textInputAction: TextInputAction.done,
                            onChanged: (value) {
                              setState(() {
                                Utils.filter['title'] = value;
                              });
                            }),
                      ),
                    ),
                  ),
                  SpaceH12(),
                  Expanded(
                    child: Container(
                      width: width,
                      child: buildBody(),
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
