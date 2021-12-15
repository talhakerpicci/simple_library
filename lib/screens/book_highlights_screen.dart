import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../widgets/spaces.dart';
import '../values/values.dart';
import '../model/models.dart';
import '../utils/utils.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_highlight_card.dart';

import 'create_highlight_screen.dart';
import 'empty_screen.dart';

class BookHighlightsScreen extends StatefulWidget {
  final String bookId;
  BookHighlightsScreen({this.bookId});
  @override
  _BookHighlightsScreenState createState() => _BookHighlightsScreenState();
}

class _BookHighlightsScreenState extends State<BookHighlightsScreen> {
  bool isSearching = false;
  String searchText = '';
  List<Highlight> highlights = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Book book = Provider.of<UserModel>(context, listen: true).findBookById(widget.bookId);
    return Scaffold(
      appBar: CustomAppBar(
        title: book.title,
        actions: [
          IconButton(
            tooltip: StringConst.generatePdf.tr,
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(FontAwesomeIcons.filePdf),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    StringConst.pdf.tr,
                    style: const TextStyle(
                      fontSize: 6,
                    ),
                  ),
                )
              ],
            ),
            onPressed: () async {
              if (book.highlights.isEmpty) {
                Utils.showCustomErrorToast(context, StringConst.noHighlightFound.tr);
                return;
              }

              String markdown = '<h1>${book.title} ${StringConst.highlights.tr}</h1>\n';
              markdown += '<br>';
              markdown += '<br>';

              book.highlights.forEach((highlight) {
                markdown += '\n<h2>${highlight.chapter}</h2>\n';
                markdown += '\n${highlight.highlight}\n';
                markdown += '\n<br>\n';
                markdown += "<span style='float:right;'>${Utils.formatter.format(highlight.dateCreated)}</span>\n";
                markdown += "<span style='float:left;'>${StringConst.pageNo.tr} ${highlight.pageNo}</span>\n";
                markdown += '\n<br>\n';
                markdown += '<hr>\n';
                markdown += '\n<br>\n';
              });

              markdown += '\n<br>\n';
              markdown += '<p>${StringConst.dateCreated.tr}: ${Utils.formatter.format(DateTime.now())}</p>';

              await Utils.createPdf(
                markdown: markdown,
                fileName: '${book.title.replaceAll(" ", "-")}-${StringConst.bookHighlights.tr}-${Utils.formatter.format(DateTime.now())}',
              );
            },
          ),
          IconButton(
            tooltip: StringConst.searchWithoutDots.tr,
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                searchText = '';
                highlights.clear();
              });
            },
          ),
          IconButton(
            tooltip: StringConst.addNewHighlight.tr,
            icon: Icon(Icons.add),
            onPressed: () async {
              if (book.highlights.length >= Utils.maxHighlightCapacity) {
                Utils.showFlushInfo(
                  context,
                  StringConst.customTranslation(
                    data: book.title,
                    key: StringConst.reachedMaxHighlightCapacity,
                  ),
                );
                return;
              }

              if (isSearching) {
                Utils.unFocus();
              }

              var result = await Get.to(
                () => CreateHighlightScreen(
                  book: book,
                ),
              );

              if (result != null) {
                if (result['success']) {
                  setState(() {
                    highlights = book.highlights.where((highlight) => highlight.chapter.toLowerCase().contains(searchText) || highlight.highlight.toLowerCase().contains(searchText)).toList();
                  });
                  Utils.showCustomInfoToast(context, StringConst.highlightInsertSuccess.tr);
                } else {
                  Utils.showCustomErrorToast(context, StringConst.somethingWentWrong.tr);
                }
              }
            },
          ),
        ],
      ),
      body: Container(
        width: width,
        height: height,
        child: book.highlights.length == 0
            ? EmptyScreen(
                icon: FontAwesomeIcons.highlighter,
                description: StringConst.customTranslation(
                  key: StringConst.noHighlightsFoundForBook,
                  data: book.title,
                ),
              )
            : Column(
                children: [
                  isSearching
                      ? Container(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    SpaceH10(),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(left: 5),
                                              width: 20,
                                              height: 25,
                                              child: const Icon(
                                                Icons.search,
                                                color: Color(0xff717D8D),
                                                size: 30,
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: 40,
                                                padding: EdgeInsets.symmetric(horizontal: 20),
                                                child: TextFormField(
                                                  keyboardType: TextInputType.text,
                                                  onChanged: (value) {
                                                    searchText = value;
                                                    setState(() {
                                                      highlights = book.highlights.where((highlight) => highlight.chapter.toLowerCase().contains(searchText) || highlight.highlight.toLowerCase().contains(searchText)).toList();
                                                    });
                                                  },
                                                  textInputAction: TextInputAction.done,
                                                  style: TextStyle(
                                                    fontFamily: StringConst.trtRegular,
                                                  ),
                                                  decoration: InputDecoration(
                                                    contentPadding: EdgeInsets.all(10),
                                                    labelText: StringConst.searchHighlight.tr,
                                                    labelStyle: TextStyle(
                                                      fontFamily: StringConst.trtRegular,
                                                    ),
                                                    border: Borders.customBorder(borderRadius: 20),
                                                    enabledBorder: Borders.customBorder(borderRadius: 20),
                                                    focusedBorder: Borders.customFocusedBorder(borderRadius: 20),
                                                  ),
                                                  textCapitalization: TextCapitalization.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Divider(
                                      color: Colors.grey[600],
                                      height: 0,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      : Container(),
                  Expanded(
                    child: highlights.length == 0 && searchText != ''
                        ? Center(child: Text(StringConst.noHighlightFound.tr))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            separatorBuilder: (context, index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: const Divider(
                                thickness: 1,
                              ),
                            ),
                            itemCount: searchText == '' ? book.highlights.length : highlights.length,
                            itemBuilder: (context, index) => HighlightCard(
                              highlight: searchText == '' ? book.highlights[index] : highlights[index],
                              onTap: () async {
                                if (isSearching) {
                                  Utils.unFocus();
                                }

                                var result = await Get.to(() => CreateHighlightScreen(
                                      book: book,
                                      highlightIndex: searchText == '' ? index : book.highlights.indexWhere((highlight) => highlight.dateCreated == highlights[index].dateCreated),
                                    ));

                                if (result != null) {
                                  if (result['success']) {
                                    String message;
                                    switch (result['method']) {
                                      case 'deleted':
                                        message = StringConst.highlightDeleteSuccess.tr;
                                        break;
                                      case 'updated':
                                        message = StringConst.highlightUpdateSuccess.tr;
                                        break;
                                    }
                                    setState(() {
                                      highlights = book.highlights.where((highlight) => highlight.chapter.toLowerCase().contains(searchText) || highlight.highlight.toLowerCase().contains(searchText)).toList();
                                    });
                                    Utils.showCustomInfoToast(context, message);
                                  } else {
                                    Utils.showCustomErrorToast(context, StringConst.somethingWentWrong.tr);
                                  }
                                }
                              },
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
