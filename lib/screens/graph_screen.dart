import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../screens/most_common_data_screen.dart';
import '../enums/book_states.dart';
import '../values/values.dart';
import '../model/models.dart';
import '../widgets/spaces.dart';
import '../viewmodels/user_model.dart';

class GraphData {
  final String id;
  final int value;

  const GraphData(this.id, this.value);
}

class GraphScreen extends StatefulWidget {
  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  Map lastSevenDayData = {};
  List<GraphData> bookStates = [];
  List<GraphData> topAuthors = [];
  List<GraphData> topGenres = [];
  List<BarChartGroupData> bookRatings = [];
  List<BarChartGroupData> monthlyReadData = [];
  List<BarChartGroupData> pageCounts = [];

  Map topAuthorsMap = {};
  Map topGenresMap = {};

  var sortedAuthors;
  var sortedGenres;

  @override
  void initState() {
    super.initState();
    var model = Provider.of<UserModel>(context, listen: false);

    // Pages read last 7 days
    List<Book> booksWithGraphData = model.user.books.where((book) => book.graphData != null && book.graphData.isNotEmpty).toList();
    Map readingData = {};

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

    if (!readingData.containsKey(DateFormat('yyyy-MM-dd').format(DateTime.now()))) {
      readingData[DateFormat('yyyy-MM-dd').format(DateTime.now())] = {
        'pagesRead': 0,
      };
    }

    var sortedKeys = readingData.keys.toList()..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

    for (var i = 0; i < sortedKeys.length - 1; i++) {
      var date = DateTime.parse(sortedKeys[i]);
      var nextDate = DateTime.parse(sortedKeys[i + 1]);
      if (nextDate.difference(date).inDays > 1) {
        for (var j = 0; j < nextDate.difference(date).inDays - 1; j++) {
          readingData[DateFormat('yyyy-MM-dd').format(date.add(Duration(days: j + 1)))] = {'pagesRead': 0};
        }
      }
    }

    sortedKeys = readingData.keys.toList()..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

    if (sortedKeys.length >= 7) {
      for (var i = 0; i < 7; i++) {
        lastSevenDayData[i + 1] = readingData[sortedKeys[sortedKeys.length - 7 + i]]['pagesRead'];
      }
    }

    // Book states
    if (model.user.books.length != 0) {
      bookStates.add(GraphData(StringConst.reading.tr, model.user.books.where((book) => book.state == BookState.Reading).toList().length));
      bookStates.add(GraphData((StringConst.finished.tr), model.user.books.where((book) => book.state == BookState.Finished).toList().length));
      bookStates.add(GraphData(StringConst.toRead.tr, model.user.books.where((book) => book.state == BookState.ToRead).toList().length));
      bookStates.add(GraphData(StringConst.dropped.tr, model.user.books.where((book) => book.state == BookState.Dropped).toList().length));
    }

    // Top 5 Author
    // Top 5 Genre
    // Ratings
    Map ratings = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    Map monthlyReadMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0, 11: 0, 12: 0};
    Map pageCountMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0};

    var thisYear = DateTime.now().year;

    model.user.books.forEach((book) {
      if (topAuthorsMap.containsKey(book.author)) {
        topAuthorsMap[book.author] += 1;
      } else {
        topAuthorsMap[book.author] = 1;
      }

      if (topGenresMap.containsKey(book.genre)) {
        topGenresMap[book.genre] += 1;
      } else {
        topGenresMap[book.genre] = 1;
      }

      if (book.rating != 0) {
        ratings[book.rating.round()] += 1;
      }

      if (book.dateFinished != null && book.dateFinished.year == thisYear) {
        monthlyReadMap[book.dateFinished.month] += 1;
      }

      //<100, 101-200, 201-300, 301-400, 401-500, 501,600, 600,700, >700,
      if (book.totalPages != null) {
        if (book.totalPages > 0 && book.totalPages < 101) {
          pageCountMap[1] += 1;
        } else if (book.totalPages >= 101 && book.totalPages <= 200) {
          pageCountMap[2] += 1;
        } else if (book.totalPages >= 201 && book.totalPages <= 300) {
          pageCountMap[3] += 1;
        } else if (book.totalPages >= 301 && book.totalPages <= 400) {
          pageCountMap[4] += 1;
        } else if (book.totalPages >= 401 && book.totalPages <= 500) {
          pageCountMap[5] += 1;
        } else if (book.totalPages >= 501 && book.totalPages <= 600) {
          pageCountMap[6] += 1;
        } else if (book.totalPages >= 601 && book.totalPages <= 700) {
          pageCountMap[7] += 1;
        } else if (book.totalPages >= 701) {
          pageCountMap[8] += 1;
        }
      }
    });

    sortedAuthors = topAuthorsMap.keys.toList()..sort((a, b) => (topAuthorsMap[b] as int).compareTo(topAuthorsMap[a] as int));
    sortedGenres = topGenresMap.keys.toList()..sort((a, b) => (topGenresMap[b] as int).compareTo(topGenresMap[a] as int));

    for (var i = 1; i <= 12; i++) {
      monthlyReadData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              y: (monthlyReadMap[i] as int).toDouble(),
              colors: [
                Colors.cyan[400],
                Colors.deepPurple[300],
                Colors.pink[300],
              ],
              width: 10,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    for (var i = 1; i <= 8; i++) {
      pageCounts.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              y: (pageCountMap[i] as int).toDouble(),
              colors: [
                Colors.cyan[400],
                Colors.deepPurple[300],
                Colors.pink[300],
              ],
              width: 10,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    if (sortedAuthors.length >= 5) {
      for (var i = 0; i < 5; i++) {
        topAuthors.add(GraphData(sortedAuthors[i], topAuthorsMap[sortedAuthors[i]]));
      }
    }

    if (sortedGenres.length >= 5) {
      for (var i = 0; i < 5; i++) {
        topGenres.add(GraphData(getGenre(model.user.genres, sortedGenres[i]), topGenresMap[sortedGenres[i]]));
      }
    }

    ratings.keys.forEach((rating) {
      bookRatings.add(
        BarChartGroupData(
          x: rating,
          barRods: [
            BarChartRodData(
              y: (ratings[rating] as int).toDouble(),
              colors: [Colors.lightBlueAccent, Colors.greenAccent],
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    });
  }

  Widget lineChart() {
    final spots = <FlSpot>[
      for (final entry in lastSevenDayData.entries)
        FlSpot(
          (entry.key as int).toDouble(),
          (entry.value as int).toDouble(),
        ),
    ];

    if (spots.length > 0) {
      final lineChartData = LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            colors: [Colors.blue],
            barWidth: 4,
            isCurved: false,
            dotData: FlDotData(show: true),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  '${barSpot.y.toInt()}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          touchCallback: (LineTouchResponse touchResponse) {},
          handleBuiltInTouches: true,
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: const BorderSide(color: Colors.greenAccent, width: 4),
            left: const BorderSide(color: Colors.transparent),
            right: const BorderSide(color: Colors.transparent),
            top: const BorderSide(color: Colors.transparent),
          ),
        ),
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: SideTitles(
            showTitles: true,
            getTitles: (double val) {
              if (val.toInt() % 5 != 0) return '';
              return '${val.toInt()}';
            },
          ),
        ),
      );
      return Container(
        child: Expanded(
          child: LineChart(lineChartData),
        ),
      );
    }
    return Container(
      child: Expanded(
        child: Center(child: Text(StringConst.notEnoughDataToDisplay.tr)),
      ),
    );
  }

  Widget pieChart({String id, List<GraphData> data}) {
    if (data.length > 0) {
      final _colorPalettes = charts.MaterialPalette.getOrderedPalettes(data.length);
      return Expanded(
        child: charts.PieChart(
          [
            charts.Series<GraphData, String>(
              id: id,
              colorFn: (_, idx) => _colorPalettes[idx].shadeDefault,
              domainFn: (GraphData _data, _) => truncateWithEllipsis(10, '${_data.id}'),
              measureFn: (GraphData _data, _) => _data.value,
              data: data,
              labelAccessorFn: (GraphData row, _) => '${row.value}',
            ),
          ],
          animate: true,
          defaultRenderer: charts.ArcRendererConfig(
            arcRatio: 0.8,
            arcRendererDecorators: [
              charts.ArcLabelDecorator(
                labelPosition: charts.ArcLabelPosition.auto,
              )
            ],
          ),
          behaviors: [
            charts.DatumLegend(
              position: charts.BehaviorPosition.end,
              desiredMaxRows: 5,
            ),
          ],
        ),
      );
    }

    return Container(
      child: Expanded(
        child: Center(child: Text(StringConst.notEnoughDataToDisplay.tr)),
      ),
    );
  }

  Widget barChart({Function(double) titles, List<BarChartGroupData> data, double fontSize = 12}) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: const Color(0xff2c4260),
        child: Column(
          children: [
            SpaceH24(),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.transparent,
                      tooltipPadding: const EdgeInsets.all(0),
                      tooltipMargin: 0,
                      getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
                        String value = '';
                        if (rod.y.round() != 0) {
                          value = rod.y.round().toString();
                        }
                        return BarTooltipItem(
                          value,
                          const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (value, _) => TextStyle(
                        color: Color(0xff7589a2),
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      ),
                      margin: 10,
                      getTitles: titles,
                    ),
                    leftTitles: SideTitles(showTitles: false),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: data,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget graphCard({Widget graph, String title, bool showIcon = false, VoidCallback onPressed}) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: 300,
      width: width,
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
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SpaceH4(),
                  Container(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SpaceH18(),
                  graph,
                ],
              ),
            ),
            showIcon
                ? Positioned(
                    right: 10,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_right,
                      ),
                      onPressed: onPressed,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  String truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff) ? myString : '${myString.substring(0, cutoff)}...';
  }

  String getGenre(List<Genre> genres, String selectedGenre) {
    String genre;
    try {
      genre = genres.firstWhere((item) => item.id == selectedGenre).title;
    } catch (e) {
      genre = '';
    }
    return genre;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          StringConst.graphs.tr,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Container(
        width: width,
        height: height,
        child: ListView(
          children: [
            SpaceH10(),
            graphCard(
              title: StringConst.pagesReadLastSevenDays.tr,
              graph: lineChart(),
            ),
            graphCard(
              title: StringConst.bookStates.tr,
              graph: pieChart(
                id: 'book-states',
                data: bookStates,
              ),
            ),
            graphCard(
              title: StringConst.mostCommonAuthors.tr,
              showIcon: true,
              onPressed: () {
                Get.to(
                  () => MostCommonDataScreen(
                    title: StringConst.mostCommonAuthors.tr,
                    data: topAuthorsMap,
                    sortedKeys: sortedAuthors,
                    liteTileIcon: const Icon(Icons.person),
                  ),
                );
              },
              graph: pieChart(
                id: 'top-authors',
                data: topAuthors,
              ),
            ),
            graphCard(
              title: StringConst.mostCommonGenres.tr,
              showIcon: true,
              onPressed: () {
                Get.to(
                  () => MostCommonDataScreen(
                    title: StringConst.mostCommonGenres.tr,
                    data: topGenresMap,
                    sortedKeys: sortedGenres,
                    liteTileIcon: const Icon(Icons.category),
                    allGenres: Provider.of<UserModel>(context, listen: false).user.genres,
                    isGenre: true,
                  ),
                );
              },
              graph: pieChart(
                id: 'top-genres',
                data: topGenres,
              ),
            ),
            graphCard(
              title: StringConst.numberOfBooksByRatings.tr,
              graph: barChart(
                data: bookRatings,
                titles: (double value) {
                  switch (value.toInt()) {
                    case 1:
                      return '1 ${StringConst.star.tr}';
                    case 2:
                      return '2 ${StringConst.star.tr}';
                    case 3:
                      return '3 ${StringConst.star.tr}';
                    case 4:
                      return '4 ${StringConst.star.tr}';
                    case 5:
                      return '5 ${StringConst.star.tr}';
                    default:
                      return '';
                  }
                },
              ),
            ),
            graphCard(
              title: StringConst.booksReadByMonth.tr,
              graph: barChart(
                data: monthlyReadData,
                titles: (double value) {
                  return value.toInt().toString();
                },
              ),
            ),
            graphCard(
              title: StringConst.numberOfBooksByPageCount.tr,
              graph: barChart(
                data: pageCounts,
                fontSize: 8,
                titles: (double value) {
                  switch (value.toInt()) {
                    case 1:
                      return '<100';
                    case 2:
                      return '101-200';
                    case 3:
                      return '201-300';
                    case 4:
                      return '301-400';
                    case 5:
                      return '401-500';
                    case 6:
                      return '501-600';
                    case 7:
                      return '600-700';
                    case 8:
                      return '>700';
                    default:
                      return '';
                  }
                },
              ),
            ),
            SpaceH10(),
          ],
        ),
      ),
    );
  }
}
