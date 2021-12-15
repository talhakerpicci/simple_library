import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:intl/intl.dart';

import '../enums/viewstate.dart';
import '../model/models.dart';
import '../utils/utils.dart';
import '../values/values.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/custom_app_bar.dart';
import '../dialogs/custom_await_dialog.dart';
import '../dialogs/custom_error_dialog.dart';
import '../widgets/custom_progress_indicator.dart';
import '../widgets/spaces.dart';

import 'goal_view_screen.dart';
import 'error_screen.dart';

class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    UserModel model = Provider.of<UserModel>(context, listen: false);

    if (model.user.getGoalsViewState != ViewState.Ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<UserModel>(context, listen: false).getGoals();
      });
    }
  }

  Color _getProgressColor({int pagesRead, int goal}) {
    Color color;
    if (pagesRead == null || pagesRead == 0) {
      return Colors.transparent;
    }

    if ((pagesRead * (1 / goal) * 100) >= 0 && (pagesRead * (1 / goal) * 100) < 33.3) {
      color = Colors.red[400];
    } else if ((pagesRead * (1 / goal) * 100) >= 33.3 && (pagesRead * (1 / goal) * 100) < 66.6) {
      color = Colors.yellow[400];
    } else if ((pagesRead * (1 / goal) * 100) >= 66.6 && (pagesRead * (1 / goal) * 100) <= 100) {
      color = Colors.green[400];
    } else {
      color = Colors.green[400];
    }
    return color;
  }

  double getMonthlyCircularSliderValue({int numOfBooksReadThisMonth, int monthlyGoal}) {
    double circularSliderValue;

    if (numOfBooksReadThisMonth == 0 || monthlyGoal == 0) {
      circularSliderValue = 0;
    } else if (numOfBooksReadThisMonth > monthlyGoal) {
      circularSliderValue = 100;
    } else {
      circularSliderValue = numOfBooksReadThisMonth / monthlyGoal * 100;
    }

    return circularSliderValue;
  }

  double getYearlyCircularSliderValue({int numOfBooksReadThisYear, int yearlyGoal}) {
    double circularSliderValue;

    if (numOfBooksReadThisYear == 0 || yearlyGoal == 0) {
      circularSliderValue = 0;
    } else if (numOfBooksReadThisYear > yearlyGoal) {
      circularSliderValue = 100;
    } else {
      circularSliderValue = numOfBooksReadThisYear / yearlyGoal * 100;
    }

    return circularSliderValue;
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        message,
        height: 150,
      ),
    );
  }

  Future<String> showGoalInputDialog({String title, String hintText, String currentGoal}) async {
    String newGoal = '';
    var width = MediaQuery.of(context).size.width;
    newGoal = await showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0.0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            Utils.unFocus();
          },
          child: Container(
            height: 215,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: 215,
                  width: width,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            color: AppColors.nord0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SpaceH4(),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          hintText,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SpaceH33(),
                      CustomTextFormField(
                        textAlign: TextAlign.center,
                        width: width * 0.5,
                        contentPadding: const EdgeInsets.only(bottom: 5),
                        keyboardType: TextInputType.number,
                        digitsOnly: true,
                        initialValue: currentGoal == '0' ? '' : currentGoal,
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 40,
                        ),
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) {
                          setState(() {
                            newGoal = value;
                          });
                        },
                        validator: (value) {
                          if (value.toString().isEmpty) {
                            return StringConst.enterValidNumber.tr;
                          }

                          if (int.parse(value) > 10000) {
                            return StringConst.totalPagesCantBeMoreThan.tr;
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 4,
                  child: Row(
                    children: [
                      TextButton(
                        child: Text(
                          StringConst.cancel.tr,
                          style: const TextStyle(color: Colors.red, fontSize: 14.0),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      TextButton(
                        child: Text(
                          StringConst.done.tr,
                          style: const TextStyle(color: AppColors.nord1, fontSize: 14.0),
                        ),
                        onPressed: () {
                          Utils.unFocus();
                          Get.back(result: newGoal);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (newGoal == currentGoal) {
      newGoal = '';
    }

    return newGoal;
  }

  void showAwaitDialog() {
    showDialog(
      context: context,
      builder: (context) => AwaitDialog(),
    );
  }

  Widget buildBody({UserModel model, double width, double height}) {
    Widget screen;

    int pagesReadToday = model.getNumberOfPagesReadToday();
    int numOfBooksReadThisMonth = model.getBooksReadThisMonth(DateTime.now()).length;
    int numOfBooksReadThisYear = model.getBooksReadThisYear(DateTime.now()).length;

    int dailyGoal = model.getDailyGoal();
    int monthlyGoal = model.getMonthlyGoal(DateTime.now());
    int yearlyGoal = model.getYearlyGoal(DateTime.now());

    if (model.user.getGoalsViewState == ViewState.Busy) {
      screen = Center(
        child: CustomProgressIndicator(),
      );
    } else if (model.user.getBooksViewState == ViewState.Ready) {
      screen = Container(
        width: width,
        height: height,
        child: Column(
          children: [
            SpaceH12(),
            const Icon(
              FontAwesomeIcons.medal,
              size: 70,
              color: AppColors.nord0,
            ),
            SpaceH10(),
            Text(
              StringConst.goalsCapital.tr,
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.nord1,
              ),
            ),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Text(
                        StringConst.dailyReadingGoal.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.nord0,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SpaceH10(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpaceW30(),
                        Container(
                          child: Text(
                            StringConst.customTranslation(
                              key: StringConst.dailyPagesGoal,
                              data: '$dailyGoal',
                            ),
                            style: const TextStyle(
                              color: AppColors.nord4,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SpaceW12(),
                        GestureDetector(
                          child: Icon(
                            Icons.edit,
                          ),
                          onTap: () async {
                            int currentGoal = model.user.dailyGoal;

                            var result = await showGoalInputDialog(
                              title: StringConst.dailyReadingGoal.tr,
                              hintText: '${StringConst.pages.tr}',
                              currentGoal: currentGoal != null ? currentGoal.toString() : '0',
                            );

                            if (result != null && result != '') {
                              if (!(await Utils.isOnline())) {
                                Utils.showFlushError(context, StringConst.makeSureYouAreOnline.tr);
                                return;
                              }

                              showAwaitDialog();
                              int numOfBooks;
                              try {
                                numOfBooks = int.parse(result);
                              } catch (e) {}

                              if (!(await Utils.isOnline())) {
                                Utils.showFlushError(context, StringConst.makeSureYouAreOnline.tr);
                              }

                              await model.setGoal(
                                type: 'daily',
                                pages: numOfBooks,
                              );

                              await Future.delayed(Duration(milliseconds: 2000));

                              Get.back();
                            }
                          },
                        ),
                      ],
                    ),
                    SpaceH8(),
                    Container(
                      alignment: Alignment.center,
                      width: width * 0.7,
                      child: LinearPercentIndicator(
                        lineHeight: 14.0,
                        percent: pagesReadToday != 0
                            ? pagesReadToday > dailyGoal
                                ? 1
                                : pagesReadToday / dailyGoal
                            : 0,
                        progressColor: _getProgressColor(pagesRead: pagesReadToday, goal: dailyGoal),
                        center: Text(
                          '$pagesReadToday / $dailyGoal',
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    SpaceH24(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SpaceH12(),
                              Text(
                                '${Utils.getGoalDateFormatter().format(DateTime.now()).toString()} ${StringConst.numberGoal.tr}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SpaceH4(),
                              Text(
                                '$monthlyGoal ${StringConst.numberBooks.tr}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                              SpaceH20(),
                              SleekCircularSlider(
                                appearance: CircularSliderAppearance(
                                  spinnerMode: false,
                                  customColors: CustomSliderColors(
                                    dotColor: Colors.transparent,
                                    progressBarColors: [
                                      Colors.cyan[400],
                                      Colors.deepPurple[300],
                                      Colors.pink[300],
                                    ],
                                    shadowColor: AppColors.nord5,
                                    trackColor: AppColors.snowStorm0,
                                  ),
                                ),
                                initialValue: getMonthlyCircularSliderValue(
                                  numOfBooksReadThisMonth: numOfBooksReadThisMonth,
                                  monthlyGoal: monthlyGoal,
                                ),
                                onChange: null,
                                onChangeEnd: null,
                                onChangeStart: null,
                                innerWidget: (value) {
                                  return Center(
                                    child: Text(
                                      '$numOfBooksReadThisMonth / $monthlyGoal',
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    child: TextButton(
                                      onPressed: () async {
                                        String date = DateFormat('M-y').format(DateTime.now());
                                        Goal currentGoal = model.user.monthlyGoals.firstWhere((goal) => goal.date == date, orElse: () => null);

                                        var result = await showGoalInputDialog(
                                          title: '${Utils.getGoalDateFormatter().format(DateTime.now())} ${StringConst.numberGoal.tr}',
                                          hintText: StringConst.numberOfBooks.tr,
                                          currentGoal: currentGoal != null ? currentGoal.numberOfBooks.toString() : '0',
                                        );

                                        if (result != null && result != '') {
                                          if (!(await Utils.isOnline())) {
                                            Utils.showFlushError(context, StringConst.makeSureYouAreOnline.tr);
                                            return;
                                          }
                                          showAwaitDialog();
                                          int numOfBooks;
                                          try {
                                            numOfBooks = int.parse(result);
                                          } catch (e) {
                                            Get.back();
                                            showErrorDialog(StringConst.anErrorOccuredOnlyEnterNumbers.tr);
                                            return;
                                          }

                                          await model.setGoal(
                                            type: 'monthly',
                                            newGoal: Goal(
                                              date: date,
                                              numberOfBooks: numOfBooks,
                                            ),
                                          );

                                          await Future.delayed(Duration(milliseconds: 2000));

                                          Get.back();
                                        }
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          const Icon(
                                            Icons.edit,
                                            color: AppColors.nord1,
                                          ),
                                          const Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                                          ),
                                          FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(
                                              StringConst.edit.tr,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.nord1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 80,
                                    child: TextButton(
                                      onPressed: () async {
                                        Get.to(() => GoalViewScreen(type: 'monthly'));
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          const Icon(
                                            Icons.open_in_browser,
                                            color: AppColors.nord1,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                                          ),
                                          FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(
                                              StringConst.view.tr,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.nord1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: height * 0.5 - 50,
                          child: const VerticalDivider(
                            color: AppColors.nord4,
                            thickness: 1,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SpaceH12(),
                              Text(
                                "${DateFormat('y').format(DateTime.now()).toString()}${StringConst.sGoal.tr}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SpaceH4(),
                              Text(
                                '$yearlyGoal ${StringConst.numberBooks.tr}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SpaceH20(),
                              SleekCircularSlider(
                                appearance: CircularSliderAppearance(
                                  spinnerMode: false,
                                  customColors: CustomSliderColors(
                                    dotColor: Colors.transparent,
                                    progressBarColors: [
                                      Colors.cyan[400],
                                      Colors.deepPurple[300],
                                      Colors.pink[300],
                                    ],
                                    shadowColor: AppColors.nord5,
                                    trackColor: AppColors.snowStorm0,
                                  ),
                                ),
                                initialValue: getYearlyCircularSliderValue(
                                  numOfBooksReadThisYear: numOfBooksReadThisYear,
                                  yearlyGoal: yearlyGoal,
                                ),
                                onChange: null,
                                onChangeEnd: null,
                                onChangeStart: null,
                                innerWidget: (_) => Center(
                                  child: Text(
                                    '$numOfBooksReadThisYear / $yearlyGoal',
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    child: TextButton(
                                      onPressed: () async {
                                        String date = DateFormat('y').format(DateTime.now());
                                        Goal currentGoal = model.user.yearlyGoals.firstWhere((goal) => goal.date == date, orElse: () => null);

                                        var result = await showGoalInputDialog(
                                          title: "$date${StringConst.sGoal.tr}",
                                          hintText: StringConst.numberOfBooks.tr,
                                          currentGoal: currentGoal != null ? currentGoal.numberOfBooks.toString() : '0',
                                        );

                                        if (result != null && result != '') {
                                          if (!(await Utils.isOnline())) {
                                            Utils.showFlushError(context, StringConst.makeSureYouAreOnline.tr);
                                            return;
                                          }

                                          showAwaitDialog();
                                          int numOfBooks;
                                          try {
                                            numOfBooks = int.parse(result);
                                          } catch (e) {
                                            Get.back();
                                            showErrorDialog(StringConst.anErrorOccuredOnlyEnterNumbers.tr);
                                            return;
                                          }

                                          await model.setGoal(
                                            type: 'yearly',
                                            newGoal: Goal(
                                              date: date,
                                              numberOfBooks: numOfBooks,
                                            ),
                                          );

                                          await Future.delayed(Duration(milliseconds: 2000));

                                          Get.back();
                                        }
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          const Icon(
                                            Icons.edit,
                                            color: AppColors.nord1,
                                          ),
                                          const Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                                          ),
                                          FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(
                                              StringConst.edit.tr,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.nord1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 80,
                                    child: TextButton(
                                      onPressed: () async {
                                        Get.to(() => GoalViewScreen(type: 'yearly'));
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          const Icon(
                                            Icons.open_in_browser,
                                            color: AppColors.nord1,
                                          ),
                                          const Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                                          ),
                                          FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(
                                              StringConst.view.tr,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.nord1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (model.user.getBooksViewState == ViewState.Error) {
      screen = ErrorScreen(
        function: model.getGoals,
      );
    }

    return screen;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    var model = Provider.of<UserModel>(context, listen: true);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: StringConst.readingGoals.tr,
      ),
      body: buildBody(
        model: model,
        width: width,
        height: height,
      ),
    );
  }
}
