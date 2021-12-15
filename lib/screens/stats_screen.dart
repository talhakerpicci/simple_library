import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:feature_discovery/feature_discovery.dart';

import '../enums/viewstate.dart';
import '../widgets/custom_progress_indicator.dart';
import '../screens/graph_screen.dart';
import '../values/values.dart';
import '../model/models.dart';
import '../widgets/custom_stat_card.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/spaces.dart';

import 'error_screen.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  double dailyAvg = 0;
  int currentStreak = 0;
  int maxStreak = 0;
  int maxPages = 0;

  String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2)}${StringConst.hour.tr} ${parts[1].padLeft(2)}${StringConst.minute.tr}';
  }

  @override
  void initState() {
    super.initState();
    var model = Provider.of<UserModel>(context, listen: false);

    List<Book> booksWithGraphData = model.user.books.where((book) => book.graphData != null && book.graphData.isNotEmpty).toList();
    Map readingData = {};
    DateTime tempDate;

    int tempMaxStreak = 0;

    booksWithGraphData.forEach((book) {
      book.graphData.forEach((key, value) {
        if (readingData.containsKey(key)) {
          readingData[key] = {
            'pagesRead': value['pagesRead'] + readingData[key]['pagesRead'],
          };
        } else {
          readingData[key] = {
            'pagesRead': value['pagesRead'],
          };
        }
      });
    });

    var sortedKeys = readingData.keys.toList()..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

    sortedKeys.forEach((key) {
      DateTime date = DateTime.parse(key);

      // Calculates daily average
      if (-date.difference(DateTime.now()).inDays < 30) {
        dailyAvg += readingData[key]['pagesRead'];
      }

      // Calculates max pages read in one day
      if (readingData[key]['pagesRead'] > maxPages) {
        maxPages = readingData[key]['pagesRead'];
      }

      // Calculates max streak
      if (tempDate != null) {
        if (date.difference(tempDate).inDays == 1) {
          tempMaxStreak++;
          currentStreak++;

          if (tempMaxStreak >= maxStreak) {
            maxStreak = tempMaxStreak;
          }
        } else {
          tempMaxStreak = 1;
          currentStreak = 1;
        }

        tempDate = date;
      } else {
        tempDate = date;
        tempMaxStreak = 1;
        maxStreak = 1;
      }
    });

    // Calculates current streak,
    if (tempDate == null || -tempDate.difference(DateTime.now()).inDays > 1) {
      currentStreak = 0;
    }

    if (tempDate != null && currentStreak == 0 && -tempDate.difference(DateTime.now()).inDays == 0) {
      currentStreak = 1;
    }

    dailyAvg /= 30;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FeatureDiscovery.discoverFeatures(
        context,
        const <String>{
          'graph_feature',
        },
      );
    });
  }

  Widget buildBody() {
    Widget screen;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var model = Provider.of<UserModel>(context, listen: true);

    if (model.user.getBooksViewState == ViewState.Busy || model.user.getUserDataViewState == ViewState.Busy) {
      screen = Center(
        child: CustomProgressIndicator(),
      );
    } else if (model.user.getBooksViewState == ViewState.Ready && model.user.getUserDataViewState == ViewState.Ready) {
      screen = Container(
        width: width,
        height: height,
        child: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SpaceH44(),
                Center(
                  child: Text(
                    model.getNumberOfBooks().toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                SpaceH4(),
                Center(
                  child: Text(
                    StringConst.totalBooks.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                SpaceH30(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            model.getNumberOfReading().toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SpaceH5(),
                          Text(
                            StringConst.reading.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 60,
                      child: const VerticalDivider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            model.getNumberOfToRead().toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SpaceH5(),
                          Text(
                            StringConst.toRead.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 60,
                      child: const VerticalDivider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            model.getNumberOfFinished().toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SpaceH5(),
                          Text(
                            StringConst.finished.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 60,
                      child: const VerticalDivider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            model.getNumberOfDropped().toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SpaceH5(),
                          Text(
                            StringConst.dropped.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SpaceH30(),
                Container(
                  width: width,
                  height: 150,
                  color: Colors.grey[300],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SpaceH20(),
                      Container(
                        child: Text(
                          StringConst.pagesReading.tr,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  model.getNumberOfPagesRead().toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SpaceH5(),
                                Text(
                                  StringConst.totalPagesN.tr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  durationToString(model.getNumberOfPagesRead() * int.parse(model.user.readingSpeed.split('-')[1]) ~/ int.parse(model.user.readingSpeed.split('-')[0])),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SpaceH5(),
                                Text(
                                  StringConst.totalTimeAprox.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  dailyAvg.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SpaceH5(),
                                Text(
                                  StringConst.pagesDailyAvg.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                SpaceH20(),
                StatCard(
                  firstData: currentStreak,
                  firstDataType: StringConst.days.tr,
                  firstExplanation: StringConst.currentReadingStreak.tr,
                  secondData: maxStreak,
                  secondDataType: StringConst.days.tr,
                  secondExplanation: StringConst.maxStreak.tr,
                  colors: const [
                    const Color(0xff6a83f1),
                    const Color(0xff09c7dc),
                  ],
                ),
                SpaceH20(),
                StatCard(
                  firstData: maxPages,
                  firstDataType: StringConst.pagesS.tr,
                  firstExplanation: StringConst.maxPagesReadInOneDay.tr,
                  colors: const [
                    const Color(0xfff57b31),
                    const Color(0xfffcc02c),
                  ],
                ),
                SpaceH20(),
                StatCard(
                  firstData: maxPages *
                      int.parse(
                        model.user.readingSpeed.split('-')[1],
                      ) ~/
                      int.parse(
                        model.user.readingSpeed.split('-')[0],
                      ),
                  firstDataType: StringConst.minutes.tr,
                  firstExplanation: StringConst.maxMinutesReadInOneDay.tr,
                  colors: const [
                    const Color(0xffe36e66),
                    const Color(0xfffeb389),
                  ],
                ),
                SpaceH20(),
              ],
            ),
          ],
        ),
      );
    } else if (model.user.getBooksViewState == ViewState.Error) {
      screen = ErrorScreen(function: model.getBookList);
    }
    return screen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: StringConst.statsAppBarTitle.tr,
        actions: [
          DescribedFeatureOverlay(
            featureId: 'graph_feature',
            tapTarget: const Icon(
              Icons.insert_chart_outlined_outlined,
            ),
            title: Text(StringConst.viewYourGraphs.tr),
            description: Text(StringConst.tapHereToViewYourGraphs.tr),
            backgroundColor: AppColors.nord2,
            targetColor: Colors.white,
            textColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.insert_chart_outlined_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Get.to(() => GraphScreen());
              },
            ),
          )
        ],
      ),
      body: buildBody(),
    );
  }
}
