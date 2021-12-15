import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../dialogs/custom_yes_no_dialog.dart';
import '../viewmodels/user_model.dart';
import '../widgets/spaces.dart';
import '../utils/utils.dart';
import '../enums/book_states.dart';
import '../model/models.dart';
import '../values/values.dart';
import '../widgets/custom_app_bar.dart';

class BookReadingChartScreen extends StatefulWidget {
  final Book book;

  BookReadingChartScreen({this.book});

  @override
  _BookReadingChartScreenState createState() => _BookReadingChartScreenState();
}

class _BookReadingChartScreenState extends State<BookReadingChartScreen> {
  int daysItTookToFinish;
  int maxPagesReadInADay = 0;
  double avg = 0;
  bool showAvg = false;
  bool isBookFinished;
  DateTime fromDate;
  DateTime toDate;
  List<DataPoint<dynamic>> graphData = [];

  bool isLoading = false;

  List<BezierLine> getSeries() {
    List<BezierLine> list = [
      BezierLine(
        lineColor: AppColors.snowStorm0,
        dataPointFillColor: AppColors.aurora0,
        lineStrokeWidth: 2,
        label: StringConst.pagesReadd.tr,
        onMissingValue: (dateTime) {
          return 0;
        },
        data: graphData,
      ),
    ];
    if (showAvg) {
      list.add(
        BezierLine(
          lineColor: AppColors.aurora0,
          dataPointFillColor: Color.fromRGBO(3, 4, 2, 1),
          lineStrokeWidth: 2,
          label: StringConst.pagesAvg.tr,
          onMissingValue: (dateTime) {
            return avg;
          },
          data: [],
        ),
      );
    }
    return list;
  }

  @override
  void initState() {
    super.initState();

    List keys = widget.book.graphData.keys.toList();
    keys.sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

    fromDate = widget.book.graphData.length > 0 ? DateTime.parse(keys.first) : null;
    toDate = widget.book.graphData.length > 0 ? DateTime.parse(keys.last) : null;

    if (fromDate == toDate) {
      fromDate = null;
      toDate = null;
    }

    isBookFinished = widget.book.state == BookState.Finished;

    widget.book.graphData.forEach((key, value) {
      graphData.add(
        DataPoint<DateTime>(
          value: (value['pagesRead'] as int).toDouble(),
          xAxis: DateTime.parse(key),
        ),
      );
      avg += (value['pagesRead'] as int).toDouble();

      if ((value['pagesRead'] as int) > maxPagesReadInADay) {
        maxPagesReadInADay = (value['pagesRead'] as int);
      }
    });

    avg /= fromDate != null && toDate != null ? toDate.difference(fromDate).inDays + 1 : 1;
    avg = double.parse((avg).toStringAsFixed(1));

    if (isBookFinished && fromDate != null && toDate != null) {
      daysItTookToFinish = toDate.difference(fromDate).inDays + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var model = Provider.of<UserModel>(context, listen: true);
    return Scaffold(
      appBar: CustomAppBar(
        title: StringConst.dailyGraph.tr,
        actions: [
          widget.book.graphData.length > 0
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    var result = await showDialog(
                      builder: (context) => CustomYesNoDialog(
                        message: StringConst.customTranslation(
                          key: StringConst.thisActionWillResetAllProgress,
                          data: widget.book.title,
                        ),
                        buttonTitleLeft: StringConst.reset.tr,
                        buttonTitleRight: StringConst.cancel.tr,
                        leftButtonReturn: true,
                        rightButtonReturn: false,
                      ),
                      context: context,
                    );
                    if (result != null && result) {
                      setState(() {
                        isLoading = true;
                      });

                      if (!(await Utils.isOnline())) {
                        setState(() {
                          isLoading = false;
                        });
                        Utils.showFlushError(context, StringConst.makeSureYouAreOnline.tr);
                        return;
                      }

                      var oldGraphData = widget.book.graphData;
                      widget.book.graphData = {};

                      var result = await model.updateBook(id: widget.book.id, book: widget.book);

                      setState(() {
                        isLoading = false;
                      });

                      if (result.success) {
                        Utils.showCustomInfoToast(context, StringConst.progressResetSuccess.tr);
                        setState(() {
                          graphData = [];
                          fromDate = null;
                          toDate = null;
                        });
                      } else {
                        Utils.showCustomErrorToast(context, StringConst.progressResetFail.tr);
                        widget.book.graphData = oldGraphData;
                      }
                    }
                  },
                )
              : Container(),
          widget.book.graphData.length >= 1 || isBookFinished || widget.book.pagesRead != 0
              ? IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => SimpleDialog(
                      title: Center(
                        child: Text(
                          StringConst.statistics.tr,
                          style: const TextStyle(
                            fontFamily: StringConst.trtRegular,
                          ),
                        ),
                      ),
                      children: <Widget>[
                        isBookFinished && daysItTookToFinish != null
                            ? ListTile(
                                title: Row(
                                  children: <Widget>[
                                    Text(
                                      StringConst.finishedIn.tr,
                                      style: const TextStyle(
                                        fontFamily: StringConst.trtRegular,
                                      ),
                                    ),
                                    Text(
                                      '$daysItTookToFinish ${StringConst.days.tr}',
                                      style: const TextStyle(
                                        fontFamily: StringConst.trtRegular,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        ListTile(
                          title: Row(
                            children: <Widget>[
                              Text(
                                StringConst.pagesReadWithSpace.tr,
                                style: const TextStyle(
                                  fontFamily: StringConst.trtRegular,
                                ),
                              ),
                              Text(
                                '${widget.book.pagesRead} ${StringConst.pagesS.tr}',
                                style: const TextStyle(
                                  fontFamily: StringConst.trtRegular,
                                ),
                              ),
                            ],
                          ),
                        ),
                        avg != 0.0
                            ? ListTile(
                                title: Row(
                                  children: <Widget>[
                                    Text(
                                      StringConst.dailyAvg.tr,
                                      style: const TextStyle(
                                        fontFamily: StringConst.trtRegular,
                                      ),
                                    ),
                                    Text(
                                      '$avg ${StringConst.pagesS.tr}',
                                      style: const TextStyle(
                                        fontFamily: StringConst.trtRegular,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        maxPagesReadInADay != 0
                            ? ListTile(
                                title: Row(
                                  children: <Widget>[
                                    Text(
                                      '${StringConst.maxPagesInADay.tr} $maxPagesReadInADay',
                                      style: const TextStyle(
                                        fontFamily: StringConst.trtRegular,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                )
              : Container(),
          fromDate == null || toDate == null
              ? Container()
              : PopupMenuButton(
                  onSelected: (value) {
                    setState(() {
                      showAvg = !showAvg;
                    });
                  },
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Row(
                        children: <Widget>[
                          SpaceW10(),
                          showAvg
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              : Container(),
                          showAvg
                              ? const Padding(
                                  padding: const EdgeInsets.only(right: 30),
                                )
                              : Container(),
                          Text(
                            StringConst.showAvg.tr,
                            style: const TextStyle(
                              fontFamily: StringConst.trtRegular,
                            ),
                          ),
                        ],
                      ),
                      value: 'sohwAvg',
                    ),
                  ],
                )
        ],
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
        color: Colors.white,
        opacity: 0.65,
        progressIndicator: const SpinKitCircle(
          color: AppColors.nord1,
          size: 60,
        ),
        child: fromDate == null && toDate == null
            ? Container(
                height: height,
                width: width,
                color: AppColors.nord0,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Center(
                  child: Text(
                    StringConst.noDataAvailable.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
            : Container(
                height: height,
                width: width,
                child: BezierChart(
                  fromDate: fromDate,
                  toDate: toDate,
                  bezierChartScale: BezierChartScale.WEEKLY,
                  selectedDate: toDate,
                  footerDateTimeBuilder: (DateTime value, BezierChartScale scaleType) {
                    final newFormat = intl.DateFormat('dd MMM', Utils.currentLocale.toString());
                    return newFormat.format(value);
                  },
                  bubbleLabelDateTimeBuilder: (DateTime value, BezierChartScale scaleType) {
                    final newFormat = intl.DateFormat('EEE d', Utils.currentLocale.toString());
                    return "${newFormat.format(value)}\n";
                  },
                  series: getSeries(),
                  config: BezierChartConfig(
                    displayDataPointWhenNoValue: true,
                    verticalIndicatorStrokeWidth: 3.0,
                    verticalIndicatorColor: AppColors.frost1,
                    verticalIndicatorFixedPosition: false,
                    pinchZoom: true,
                    snap: true,
                    backgroundColor: AppColors.nord0,
                    displayYAxis: true,
                    stepsYAxis: 5,
                  ),
                ),
              ),
      ),
    );
  }
}
