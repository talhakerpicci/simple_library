import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_library/widgets/spaces.dart';

import '../utils/utils.dart';
import '../values/values.dart';
import '../enums/book_states.dart';

class BookStateDialog extends StatelessWidget {
  final BookState bookState;

  BookStateDialog({this.bookState});

  Widget dialogContent(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Utils.unFocus();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          height: 330,
          width: width - 50,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SpaceH20(),
              Container(
                height: 40,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Text(
                      StringConst.bookState.tr,
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.nord2,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              highlightColor: AppColors.grey4,
                              onTap: () {
                                Get.back(result: BookState.Reading);
                              },
                              child: Container(
                                child: ListTile(
                                  leading: const Icon(Icons.local_library),
                                  title: Text(StringConst.reading.tr),
                                  trailing: bookState == BookState.Reading
                                      ? Container(
                                          width: 34,
                                          height: 20,
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          ),
                                        )
                                      : Container(
                                          width: 34,
                                          height: 20,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              highlightColor: AppColors.grey4,
                              onTap: () {
                                Get.back(result: BookState.Finished);
                              },
                              child: Container(
                                child: ListTile(
                                  leading: const Icon(Icons.cake),
                                  title: Text(StringConst.finished.tr),
                                  trailing: bookState == BookState.Finished
                                      ? Container(
                                          width: 34,
                                          height: 20,
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          ),
                                        )
                                      : Container(
                                          width: 34,
                                          height: 20,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              highlightColor: AppColors.grey4,
                              onTap: () {
                                Get.back(result: BookState.ToRead);
                              },
                              child: Container(
                                child: ListTile(
                                  leading: const Icon(Icons.watch_later),
                                  title: Text(StringConst.toRead.tr),
                                  trailing: bookState == BookState.ToRead
                                      ? Container(
                                          width: 34,
                                          height: 20,
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          ),
                                        )
                                      : Container(
                                          width: 34,
                                          height: 20,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              highlightColor: AppColors.grey4,
                              onTap: () {
                                Get.back(result: BookState.Dropped);
                              },
                              child: Container(
                                child: ListTile(
                                  leading: const Icon(Icons.thumb_down),
                                  title: Text(StringConst.dropped.tr),
                                  trailing: bookState == BookState.Dropped
                                      ? Container(
                                          width: 34,
                                          height: 20,
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          ),
                                        )
                                      : Container(
                                          width: 34,
                                          height: 20,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}
