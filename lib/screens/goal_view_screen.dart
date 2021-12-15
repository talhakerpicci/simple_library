import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../model/models.dart';
import '../picker/show_scroll_picker.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_book_card_vertical.dart';
import '../widgets/spaces.dart';

class GoalViewScreen extends StatefulWidget {
  final String type;
  GoalViewScreen({this.type});
  @override
  _GoalViewScreenState createState() => _GoalViewScreenState();
}

class _GoalViewScreenState extends State<GoalViewScreen> {
  DateTime selectedDate;
  String selectedDateAsString;
  int numberOfBooksGoal;
  List<Goal> goals = [];
  List<String> goalsAsString = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    UserModel model = Provider.of<UserModel>(context, listen: false);
    if (widget.type == 'monthly') {
      goals = model.user.monthlyGoals;
      selectedDateAsString = Utils.getGoalViewDateFormatter().format(DateTime.now());
      numberOfBooksGoal = model.getMonthlyGoal(DateTime.now());

      try {
        var lastGoal = goals.last;

        if (lastGoal.date != '${DateTime.now().month}-${DateTime.now().year}') {
          goals.add(Goal(date: '${DateTime.now().month}-${DateTime.now().year}', numberOfBooks: 0));
        }
      } catch (e) {
        goals.add(Goal(date: '${DateTime.now().month}-${DateTime.now().year}', numberOfBooks: 0));
      }

      for (var i = 0; i < goals.length - 1; i++) {
        var goal = goals[i];
        var nextGoal = goals[i + 1];

        var date = DateTime(
          int.parse(
            goal.date.split('-')[1],
          ),
          int.parse(
            goal.date.split('-')[0],
          ),
        );

        date = date.add(Duration(days: 35));

        var formattedDate = '${date.month}-${date.year}';

        if (formattedDate != nextGoal.date) {
          i++;
          goals.insert(i, Goal(date: formattedDate, numberOfBooks: 0));
          i--;
        }
      }

      goalsAsString = goals
          .map((goal) => '${Utils.getGoalDateFormatter().format(
                DateTime(
                  int.parse(
                    goal.date.split('-')[1],
                  ),
                  int.parse(
                    goal.date.split('-')[0],
                  ),
                ),
              ).toString()} ${goal.date.split('-')[1]}')
          .toList();
    } else if (widget.type == 'yearly') {
      selectedDateAsString = DateFormat('y').format(DateTime.now());
      goals = model.user.yearlyGoals;
      numberOfBooksGoal = model.getYearlyGoal(DateTime.now());

      try {
        var lastGoal = goals.last;

        if (lastGoal.date != '${DateTime.now().year}') {
          goals.add(Goal(date: '${DateTime.now().year}', numberOfBooks: 0));
        }
      } catch (e) {
        goals.add(Goal(date: '${DateTime.now().year}', numberOfBooks: 0));
      }

      for (var i = 0; i < goals.length - 1; i++) {
        var goal = goals[i];
        var nextGoal = goals[i + 1];

        var date = DateTime(
          int.parse(goal.date),
        );

        date = date.add(const Duration(days: 370));

        var formattedDate = '${date.year}';

        if (formattedDate != nextGoal.date) {
          i++;
          goals.insert(i, Goal(date: formattedDate, numberOfBooks: 0));
          i--;
        }
      }

      goalsAsString = goals.map((goal) => '${goal.date}').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<UserModel>(context, listen: false);
    List<Book> booksRead;

    if (widget.type == 'monthly') {
      booksRead = model.getBooksReadThisMonth(selectedDate);
    } else if (widget.type == 'yearly') {
      booksRead = model.getBooksReadThisYear(selectedDate);
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.grey.withOpacity(0.1), BlendMode.dstOut),
          image: AssetImage(
            StringConst.backroundWallpaper,
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              selectedDateAsString,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            shadowColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: () {
                  showMaterialScrollPicker(
                    context: context,
                    maxLongSide: 400,
                    headerColor: AppColors.nord1,
                    showDivider: false,
                    title: StringConst.pickDate.tr,
                    cancelText: StringConst.cancel.tr,
                    confirmText: StringConst.ok.tr,
                    items: goalsAsString,
                    selectedItem: selectedDateAsString,
                    onConfirmed: (value) {
                      setState(() {
                        selectedDateAsString = value;
                      });

                      if (widget.type == 'monthly') {
                        setState(() {
                          selectedDate = DateFormat('MMMM y', Utils.currentLocale.languageCode).parse(selectedDateAsString);
                          numberOfBooksGoal = model.getMonthlyGoal(selectedDate);
                        });
                      } else if (widget.type == 'yearly') {
                        setState(() {
                          selectedDate = DateFormat('y').parse(selectedDateAsString);
                          numberOfBooksGoal = model.getYearlyGoal(selectedDate);
                        });
                      }
                    },
                  );
                },
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpaceH12(),
              Container(
                child: Text(
                  '${booksRead.length} / $numberOfBooksGoal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              SpaceH12(),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  addAutomaticKeepAlives: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1 / 1.55,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: booksRead.length > numberOfBooksGoal ? booksRead.length : numberOfBooksGoal,
                  itemBuilder: (context, index) {
                    if (index < booksRead.length) {
                      return CustomBookCardVertical(
                        book: booksRead[index],
                        showSmallIcon: true,
                        shrinkBottom: true,
                        customOnTap: () {},
                      );
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(.7),
                            blurRadius: 1.0,
                            spreadRadius: 2.5,
                            offset: const Offset(
                              0.0,
                              0.0,
                            ),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
