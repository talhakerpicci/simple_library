import 'dart:convert';
import 'package:dio/dio.dart' as d;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../model/models.dart';
import '../widgets/google_book_card.dart';
import '../values/values.dart';
import '../utils/utils.dart';
import '../widgets/spaces.dart';

import 'isbn_scanner_screen.dart';

class SearchBookOnlineScreen extends StatefulWidget {
  @override
  _SearchBookOnlineScreenState createState() => _SearchBookOnlineScreenState();
}

class _SearchBookOnlineScreenState extends State<SearchBookOnlineScreen> {
  var dio = d.Dio();

  bool _isLoading = false;

  String query = '';
  String isbn = '';
  List searchList = [];

  final TextEditingController _qeryController = TextEditingController();

  Future<Map> _getBooksList({String query = '', String isbn = ''}) async {
    Map result = {'success': true, 'data': []};
    var url = query != '' ? 'https://www.googleapis.com/books/v1/volumes?q=$query' : 'https://www.googleapis.com/books/v1/volumes?q=?isbn=$isbn';
    try {
      var response = await dio.get(url);
      if (response.statusCode == 200) {
        if (json.decode(response.toString())['totalItems'] != 0) {
          result['data'] = GoogleBook.parseFromJsonStr(response.toString());
        }
      } else {
        result['success'] = false;
      }
    } catch (e) {
      result['success'] = false;
    }

    return result;
  }

  Future onSearchButtontap() async {
    if (query == '') {
      Utils.showCustomErrorToast(context, StringConst.queryCantBeEmpty.tr);
      return;
    }

    setState(() {
      _isLoading = true;
    });
    Utils.unFocus();

    var result = await _getBooksList(query: query);

    if (result['success']) {
      searchList = result['data'];

      if (searchList.length == 0) {
        Utils.showCustomErrorToast(context, StringConst.couldNotFindAnyBook.tr);
      }
    } else {
      Utils.showCustomErrorToast(context, StringConst.onlyAnErrorOccured.tr);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _scanCodeButton() {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 150,
            child: ElevatedButton(
              onPressed: () async {
                var isbn = await Get.to(() => IsbnScannerScreen());
                if (isbn != null) {
                  setState(() {
                    _isLoading = true;
                  });

                  _qeryController.clear();
                  query = '';

                  var result = await _getBooksList(isbn: isbn);

                  if (result['success']) {
                    searchList = result['data'];

                    if (searchList.length == 0) {
                      Utils.showCustomErrorToast(context, StringConst.couldNotFindAnyBook.tr);
                    }
                  } else {
                    Utils.showCustomErrorToast(context, StringConst.onlyAnErrorOccured.tr);
                  }

                  isbn = '';

                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: Text(StringConst.scanIsbn.tr),
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColors.nord1, width: 1, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    Widget screen = Container();
    if (searchList.length > 0) {
      screen = ListView.builder(
        itemCount: searchList.length,
        padding: EdgeInsets.symmetric(vertical: 10),
        itemBuilder: (context, index) {
          return GoogleBookCard(
            book: searchList[index],
          );
        },
      );
    } else {
      screen = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpaceH10(),
          Expanded(
              flex: 1,
              child: Text(
                StringConst.poweredByGoogle.tr,
                style: TextStyle(
                  fontFamily: StringConst.trtRegular,
                ),
              )),
          SpaceH20(),
          _scanCodeButton(),
        ],
      );
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
      child: Scaffold(
        body: SafeArea(
          child: LoadingOverlay(
            isLoading: _isLoading,
            color: Colors.white,
            opacity: 0.65,
            progressIndicator: const SpinKitCircle(
              color: AppColors.nord1,
              size: 60,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              width: width,
              height: height,
              child: Column(
                children: [
                  SpaceH20(),
                  Container(
                    height: 60,
                    child: Row(
                      children: [
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
                          child: Container(
                            width: width * 0.75,
                            child: Card(
                              child: ListTile(
                                leading: GestureDetector(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: const Icon(
                                    Icons.arrow_back,
                                  ),
                                ),
                                title: TextField(
                                  controller: _qeryController,
                                  decoration: InputDecoration.collapsed(hintText: StringConst.searchWithDots.tr),
                                  textInputAction: TextInputAction.search,
                                  onChanged: (value) {
                                    query = value;
                                  },
                                  onSubmitted: (_) => onSearchButtontap(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SpaceW10(),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10.0),
                            onTap: onSearchButtontap,
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.nord1,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: AppColors.grey2,
                                ),
                              ),
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SpaceW4(),
                      ],
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
