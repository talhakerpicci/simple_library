import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../values/values.dart';
import '../enums/viewstate.dart';
import '../model/models.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_book_card_vertical.dart';
import '../widgets/custom_floating_action_button.dart';
import '../widgets/custom_progress_indicator.dart';
import '../widgets/spaces.dart';

import 'empty_screen.dart';
import 'error_screen.dart';
import 'select_book_screen.dart';
import 'book_highlights_screen.dart';

class HighlightsScreen extends StatefulWidget {
  @override
  _HighlightsScreenState createState() => _HighlightsScreenState();
}

class _HighlightsScreenState extends State<HighlightsScreen> {
  Widget buildBody(UserModel model) {
    List<Book> booksWithHighlight = model.getBooksWithHighlight();
    Widget screen;

    if (model.user.getBooksViewState == ViewState.Busy) {
      screen = Center(
        child: CustomProgressIndicator(),
      );
    } else if (model.user.getBooksViewState == ViewState.Ready) {
      if (model.user.books.length != 0) {
        if (booksWithHighlight.length == 0) {
          screen = EmptyScreen(
            icon: FontAwesomeIcons.highlighter,
            description: StringConst.yourHiglihtsWillBeListedHere.tr,
          );
        } else {
          screen = Container(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              addAutomaticKeepAlives: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1 / 1.65,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              itemCount: booksWithHighlight.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Expanded(
                      child: CustomBookCardVertical(
                        book: booksWithHighlight[index],
                        showSmallIcon: true,
                        shrinkBottom: true,
                        customOnTap: () {
                          Get.to(() => BookHighlightsScreen(
                                bookId: booksWithHighlight[index].id,
                              ));
                        },
                      ),
                    ),
                    SpaceH8(),
                    Container(
                      height: 14,
                      child: Text(
                        '${booksWithHighlight[index].highlights.length} ${StringConst.bookHighlights.tr}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                );
              },
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
    var model = Provider.of<UserModel>(context, listen: true);
    return Scaffold(
      appBar: CustomAppBar(title: StringConst.highlights.tr),
      floatingActionButton: CustomFloationgActionButton(
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Get.to(() => SelectBookScreen());
        },
      ),
      body: Container(
        width: width,
        height: height,
        child: buildBody(model),
      ),
    );
  }
}
