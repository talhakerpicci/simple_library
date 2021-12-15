import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../enums/viewstate.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_cached_network_image.dart';
import '../widgets/custom_empty_book_card.dart';
import '../widgets/custom_progress_indicator.dart';
import '../widgets/selectable_item.dart';
import '../widgets/spaces.dart';

import 'empty_screen.dart';
import 'error_screen.dart';
import 'filter_screen.dart';

class SelectBooksScreen extends StatefulWidget {
  final List<String> selectedBooks;
  SelectBooksScreen({this.selectedBooks});
  @override
  _SelectBooksScreenState createState() => _SelectBooksScreenState();
}

class _SelectBooksScreenState extends State<SelectBooksScreen> {
  List searchList = [];
  List<String> selectedBooks;

  bool showSelectedOnly = false;

  final duration = Duration(milliseconds: 500);
  final defaultColor = Colors.transparent;
  final selectedColor = AppColors.frost4;

  @override
  void initState() {
    super.initState();
    if (widget.selectedBooks != null) {
      selectedBooks = List.from(widget.selectedBooks);
    } else {
      selectedBooks = [];
    }
  }

  Widget buildBody() {
    Widget screen;
    var model = Provider.of<UserModel>(context, listen: true);

    if (model.user.getBooksViewState == ViewState.Busy) {
      screen = Center(
        child: CustomProgressIndicator(),
      );
    } else if (model.user.getBooksViewState == ViewState.Ready) {
      if (model.user.books.length != 0) {
        if (showSelectedOnly) {
          searchList = model.getBooksWithIds(selectedBooks);
        } else {
          searchList = model.filterBooks();
        }

        if (Utils.sort.values.contains(true)) {
          searchList = model.sortBooks(books: searchList);
        }
        if (searchList.length == 0 && !showSelectedOnly) {
          screen = Center(
            child: Text(StringConst.couldNotFindBook.tr),
          );
        } else {
          screen = Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    searchList.length != model.user.books.length && !showSelectedOnly
                        ? Container(
                            padding: const EdgeInsets.only(
                              left: 15,
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
                    Container(
                      child: Row(
                        children: [
                          Text(
                            StringConst.showSelectedOnly.tr,
                            style: const TextStyle(
                              fontFamily: StringConst.trtRegular,
                            ),
                          ),
                          Checkbox(
                            value: showSelectedOnly,
                            onChanged: (value) {
                              Utils.clearAllFilters(Utils.filter);
                              setState(() {
                                showSelectedOnly = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    addAutomaticKeepAlives: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1 / 1.45,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: searchList.length,
                    itemBuilder: (context, index) {
                      String selectedBookId = searchList[index].id;
                      bool isSelected = selectedBooks.contains(selectedBookId);
                      return GestureDetector(
                        onTap: () {
                          if (!selectedBooks.contains(selectedBookId)) {
                            setState(() {
                              selectedBooks.add(
                                selectedBookId,
                              );
                            });
                          } else {
                            setState(() {
                              selectedBooks.removeWhere((id) => id == selectedBookId);
                            });
                          }
                        },
                        child: SelectableItem(
                          index: index,
                          color: Colors.blue,
                          selected: isSelected,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              margin: EdgeInsets.all(0),
                              duration: duration,
                              color: isSelected ? selectedColor : defaultColor,
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(.7),
                                      blurRadius: 1.0,
                                      spreadRadius: 2.5,
                                      offset: const Offset(
                                        0.0,
                                        0.0,
                                      ),
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: buildBook(
                                    index: index,
                                    selected: selectedBooks.contains(selectedBookId),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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

  Widget buildBook({int index, bool selected}) {
    Widget book;

    if (searchList[index].imgUrl != '') {
      book = Container(
        child: Hero(
          tag: searchList[index].id,
          child: CustomCachedNetworkImage(
            url: searchList[index].imgUrl,
            boxFit: BoxFit.fill,
          ),
        ),
      );
    } else {
      book = CustomEmptyBookCard(
        bookTitle: searchList[index].title,
        showTitle: true,
        showSmallIcon: true,
        shrinkBottom: true,
      );
    }
    return book;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Utils.setALLSortValuesToFlase();
        Utils.clearAllFilters(Utils.filter);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: '${selectedBooks.length} ${StringConst.bookSSelected.tr}',
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Utils.setALLSortValuesToFlase();
                Utils.clearAllFilters(Utils.filter);
                Get.back(
                  result: selectedBooks,
                );
              },
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            Utils.unFocus();
          },
          child: Column(
            children: [
              SpaceH12(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
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
                child: Container(child: buildBody()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
