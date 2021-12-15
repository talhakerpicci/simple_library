import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../widgets/custom_book_card_horizontal.dart';
import '../widgets/custom_skeleton_horizontal_book_card.dart';
import '../enums/default_view.dart';
import '../values/values.dart';
import '../widgets/custom_skeleton_book_card.dart';
import '../enums/book_states.dart';
import '../enums/viewstate.dart';
import '../model/models.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_book_card_vertical.dart';

import 'empty_screen.dart';
import 'error_screen.dart';

class BookGridScreen extends StatefulWidget {
  final BookState state;
  final bool scrollToBottom;
  BookGridScreen({this.state, this.scrollToBottom = false});
  @override
  _BookGridScreenState createState() => _BookGridScreenState();
}

class _BookGridScreenState extends State<BookGridScreen> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );
  }

  @override
  void didUpdateWidget(BookGridScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollToBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    try {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.ease,
      );
    } catch (e) {}
  }

  int getLength(List<Book> model) {
    int length;
    if (widget.state == BookState.All) {
      length = model.length;
    } else if (widget.state == BookState.Reading) {
      length = model.where((book) => book.state == BookState.Reading).toList().length;
    } else if (widget.state == BookState.Finished) {
      length = model.where((book) => book.state == BookState.Finished).toList().length;
    } else if (widget.state == BookState.ToRead) {
      length = model.where((book) => book.state == BookState.ToRead).toList().length;
    } else if (widget.state == BookState.Dropped) {
      length = model.where((book) => book.state == BookState.Dropped).toList().length;
    }
    return length;
  }

  String getDescription() {
    String description;

    switch (widget.state) {
      case BookState.All:
        description = StringConst.yourBooksWillBeListedHere.tr;
        break;
      case BookState.Reading:
        description = StringConst.booksYouReadWillBeListedHere.tr;
        break;
      case BookState.Finished:
        description = StringConst.booksYouFinishedWillBeListedHere.tr;
        break;
      case BookState.ToRead:
        description = StringConst.booksYouPlanToReadWillBeListedHere.tr;
        break;
      case BookState.Dropped:
        description = StringConst.booksYouDroppedWillBeListedHere.tr;
        break;
    }

    return description;
  }

  IconData getIcon() {
    IconData icon;
    if (widget.state == BookState.All) {
      icon = FontAwesomeIcons.book;
    } else if (widget.state == BookState.Reading) {
      icon = Icons.auto_stories;
    } else if (widget.state == BookState.Finished) {
      icon = Icons.cake;
    } else if (widget.state == BookState.ToRead) {
      icon = Icons.watch_later;
    } else if (widget.state == BookState.Dropped) {
      icon = Icons.thumb_down;
    }
    return icon;
  }

  Widget buildBody() {
    var model = Provider.of<UserModel>(context, listen: true);
    Widget screen;

    if (model.user.getBooksViewState == ViewState.Busy) {
      screen = model.user.defaultView == DefaultView.GRID
          ? GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1 / 1.5,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return CustomSkeletonBookCardVertical();
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: 4,
              itemBuilder: (context, index) {
                return CustomSkeletonBookCardHorizontal();
              },
            );
    } else if (model.user.getBooksViewState == ViewState.Ready) {
      if (getLength(model.user.books) == 0) {
        screen = EmptyScreen(
          icon: getIcon(),
          description: getDescription(),
        );
      } else {
        List<Book> items;
        if (widget.state == BookState.All) {
          items = model.user.books;
        } else if (widget.state == BookState.Reading) {
          items = model.user.books.where((book) => book.state == BookState.Reading).toList();
          items.sort((book1, book2) {
            if (book1.dateStarted == null && book2.dateStarted == null) {
              return 0;
            } else if (book1.dateStarted == null) {
              return 1;
            } else if (book2.dateStarted == null) {
              return -1;
            } else {
              return book2.dateStarted.compareTo(book1.dateStarted);
            }
          });
        } else if (widget.state == BookState.Finished) {
          items = model.user.books.where((book) => book.state == BookState.Finished).toList();
          items.sort((book1, book2) {
            if (book1.dateFinished == null && book2.dateFinished == null) {
              return 0;
            } else if (book1.dateFinished == null) {
              return 1;
            } else if (book2.dateFinished == null) {
              return -1;
            } else {
              return book2.dateFinished.compareTo(book1.dateFinished);
            }
          });
        } else if (widget.state == BookState.ToRead) {
          items = model.user.books.where((book) => book.state == BookState.ToRead).toList();
        } else if (widget.state == BookState.Dropped) {
          items = model.user.books.where((book) => book.state == BookState.Dropped).toList();
        }
        screen = RefreshIndicator(
          onRefresh: () => model.getBookList(),
          child: model.user.defaultView == DefaultView.GRID
              ? GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1 / 1.5,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                  ),
                  itemCount: getLength(model.user.books),
                  itemBuilder: (context, index) {
                    return CustomBookCardVertical(
                      book: items[index],
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: getLength(model.user.books),
                  itemBuilder: (context, index) {
                    return CustomBookCardHorizontal(
                      book: items[index],
                    );
                  },
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
    return buildBody();
  }
}
