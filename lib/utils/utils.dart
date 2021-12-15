import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:markdown/markdown.dart' as mk;
import 'package:path_provider/path_provider.dart';
import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:showcaseview/showcase.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

import '../enums/default_view.dart';
import '../enums/book_states.dart';
import '../enums/modal_option.dart';
import '../enums/online_search_option.dart';
import '../model/models.dart';
import '../values/values.dart';
import '../widgets/custom_cached_network_image.dart';
import '../dialogs/custom_online_search_option_picker_dialog.dart';
import '../widgets/spaces.dart';

class Utils {
  static MethodChannel platform = MethodChannel('simple_library');
  static var formatter = DateFormat('yyyy-MM-dd');

  static String languageCode;
  static String countryCode;
  static String defaultLocale;
  static String selectedLocale;
  static Locale currentLocale;

  static int maxBookCapacity;
  static int maxGenreCapacity;
  static int maxHighlightCapacity;
  static int maxCollectionCapacity;
  static int maxImgSize;

  static bool showCollectionTip;
  static bool showCryptoWarning;

  static DefaultView defaultView;

  static Map availableLanguages = {
    StringConst.en_US: StringConst.english.tr,
    StringConst.tr_TR: StringConst.turkish.tr,
  };

  static List defaultGenres = [
    Genre(title: StringConst.adventure.tr),
    Genre(title: StringConst.biography.tr),
    Genre(title: StringConst.children.tr),
    Genre(title: StringConst.classics.tr),
    Genre(title: StringConst.contemporary.tr),
    Genre(title: StringConst.dystopian.tr),
    Genre(title: StringConst.fantasy.tr),
    Genre(title: StringConst.fiction.tr),
    Genre(title: StringConst.history.tr),
    Genre(title: StringConst.horror.tr),
    Genre(title: StringConst.memoir.tr),
    Genre(title: StringConst.mystery.tr),
    Genre(title: StringConst.nonFiction.tr),
    Genre(title: StringConst.paranormal.tr),
    Genre(title: StringConst.romance.tr),
    Genre(title: StringConst.sciFi.tr),
    Genre(title: StringConst.selfHelp.tr),
    Genre(title: StringConst.thriller.tr),
    Genre(title: StringConst.travel.tr),
    Genre(title: StringConst.youngAdult.tr),
    Genre(title: StringConst.otherGenre.tr),
  ];

  static Map repetitionOptionsMap = {
    Repetition.Once: StringConst.once.tr,
    Repetition.Daily: StringConst.daily.tr,
    Repetition.MonToFri: StringConst.monToFri.tr,
    Repetition.Weekends: StringConst.weekends.tr,
    Repetition.Custom: StringConst.custom.tr,
  };

  static Map<int, String> numToDayMap = {
    1: StringConst.monday.tr,
    2: StringConst.tuesday.tr,
    3: StringConst.wednesday.tr,
    4: StringConst.thursday.tr,
    5: StringConst.friday.tr,
    6: StringConst.saturday.tr,
    7: StringConst.sunday.tr,
  };

  static Map<String, int> dayToNumMap = {
    StringConst.monday.tr: 1,
    StringConst.tuesday.tr: 2,
    StringConst.wednesday.tr: 3,
    StringConst.thursday.tr: 4,
    StringConst.friday.tr: 5,
    StringConst.saturday.tr: 6,
    StringConst.sunday.tr: 7,
  };

  static Map<int, String> numToShortDayMap = {
    1: StringConst.mon.tr,
    2: StringConst.tue.tr,
    3: StringConst.wed.tr,
    4: StringConst.thu.tr,
    5: StringConst.fri.tr,
    6: StringConst.sat.tr,
    7: StringConst.sun.tr,
  };

  static Map<String, bool> sort = {
    'name-a-to-z': false,
    'name-z-to-a': false,
    'pages-read': false,
    'page-count': false,
    'date-started': false,
    'date-finished': false,
    'number-of-highlights': false,
    'date-added-to-library-latest-to-first': false,
    'date-added-to-library-first-to-latest': false,
  };

  static Map<String, dynamic> filter = {
    'title': '',
    'author': '',
    'state': BookState.All,
    'genre': '',
    'has-notes': false,
    'has-highlits': false,
    'rating': 0.0,
    'page-count': 0,
    'show-lower': false,
    'show-higher': false,
  };

  static AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    'scheduled',
    'Scheduled notifications',
    'Scheduled notification channel',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );

  static tz.TZDateTime nextInstanceOfHour({int hour, int minute}) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static tz.TZDateTime nextInstanceOfDayWithHour({int day, int hour, int minute}) {
    tz.TZDateTime scheduledDate = nextInstanceOfHour(hour: hour, minute: minute);
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await platform.invokeMethod('getTimeZoneName');
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  static void showWhatsNew(context, {String version}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          title: Center(
            child: Text(
              '${StringConst.version.tr} $version',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
          ),
          content: Container(
            height: 250,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  whatsNewTile(StringConst.nowOpenSource.tr),
                  whatsNewTile(StringConst.bugFixes.tr),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                StringConst.close.tr,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                ),
              ),
              onPressed: () async {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  static Widget sortTile({Color color, String title, String key, VoidCallback onSortSelect}) {
    return Container(
      color: sort[key] ? AppColors.nord1 : Colors.transparent,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontFamily: StringConst.trtRegular,
          ),
        ),
        trailing: sort[key]
            ? Icon(
                Icons.check,
                color: color,
              )
            : Wrap(),
        onTap: onSortSelect,
      ),
    );
  }

  static void setALLSortValuesToFlase() {
    sort['name-a-to-z'] = false;
    sort['name-z-to-a'] = false;
    sort['pages-read'] = false;
    sort['page-count'] = false;
    sort['date-started'] = false;
    sort['date-finished'] = false;
    sort['number-of-highlights'] = false;
    sort['date-added-to-library-latest-to-first'] = false;
    sort['date-added-to-library-first-to-latest'] = false;
  }

  static void clearAllFilters(Map map) {
    map['title'] = '';
    map['author'] = '';
    map['state'] = BookState.All;
    map['genre'] = '';
    map['has-notes'] = false;
    map['has-highlits'] = false;
    map['rating'] = 0.0;
    map['page-count'] = 0;
    map['show-lower'] = false;
    map['show-higher'] = false;
  }

  static void showSortSetting(BuildContext context, {VoidCallback setState, VoidCallback onSortSelect}) async {
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SpaceH14(),
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          child: Text(
                            StringConst.sortBy.tr,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.nord1,
                              fontFamily: StringConst.trtRegular,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Positioned(
                        child: GestureDetector(
                          child: Icon(
                            Icons.refresh,
                            color: AppColors.nord1,
                          ),
                          onTap: () {
                            setALLSortValuesToFlase();
                            onSortSelect();
                            Get.back();
                          },
                        ),
                        right: 14,
                      ),
                    ],
                  ),
                  SpaceH14(),
                  Container(
                    height: 280,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          sortTile(
                            title: StringConst.nameAtoZ.tr,
                            color: sort['name-a-to-z'] ? Colors.white : AppColors.nord1,
                            key: 'name-a-to-z',
                            onSortSelect: () {
                              setALLSortValuesToFlase();
                              sort['name-a-to-z'] = true;
                              onSortSelect();
                              Get.back();
                            },
                          ),
                          sortTile(
                            title: StringConst.nameZtoA.tr,
                            color: sort['name-z-to-a'] ? Colors.white : AppColors.nord1,
                            key: 'name-z-to-a',
                            onSortSelect: () {
                              setALLSortValuesToFlase();
                              sort['name-z-to-a'] = true;
                              onSortSelect();
                              Get.back();
                            },
                          ),
                          sortTile(
                            title: StringConst.pagesRead.tr,
                            color: sort['pages-read'] ? Colors.white : AppColors.nord1,
                            key: 'pages-read',
                            onSortSelect: () {
                              setALLSortValuesToFlase();
                              sort['pages-read'] = true;
                              onSortSelect();
                              Get.back();
                            },
                          ),
                          sortTile(
                            title: StringConst.pageCount.tr,
                            color: sort['page-count'] ? Colors.white : AppColors.nord1,
                            key: 'page-count',
                            onSortSelect: () {
                              setALLSortValuesToFlase();
                              sort['page-count'] = true;
                              onSortSelect();
                              Get.back();
                            },
                          ),
                          sortTile(
                            title: StringConst.dateStarted.tr,
                            color: sort['date-started'] ? Colors.white : AppColors.nord1,
                            key: 'date-started',
                            onSortSelect: () {
                              setALLSortValuesToFlase();
                              sort['date-started'] = true;
                              onSortSelect();
                              Get.back();
                            },
                          ),
                          sortTile(
                            title: StringConst.dateFinished.tr,
                            color: sort['date-finished'] ? Colors.white : AppColors.nord1,
                            key: 'date-finished',
                            onSortSelect: () {
                              setALLSortValuesToFlase();
                              sort['date-finished'] = true;
                              onSortSelect();
                              Get.back();
                            },
                          ),
                          sortTile(
                            title: StringConst.numberOfHighlights.tr,
                            color: sort['number-of-highlights'] ? Colors.white : AppColors.nord1,
                            key: 'number-of-highlights',
                            onSortSelect: () {
                              setALLSortValuesToFlase();
                              sort['number-of-highlights'] = true;
                              onSortSelect();
                              Get.back();
                            },
                          ),
                          sortTile(
                            title: StringConst.dateAddedFirstToLatest.tr,
                            color: sort['date-added-to-library-first-to-latest'] ? Colors.white : AppColors.nord1,
                            key: 'date-added-to-library-first-to-latest',
                            onSortSelect: () {
                              setALLSortValuesToFlase();
                              sort['date-added-to-library-first-to-latest'] = true;
                              onSortSelect();
                              Get.back();
                            },
                          ),
                          sortTile(
                            title: StringConst.dateAddedLatestToFirst.tr,
                            color: sort['date-added-to-library-latest-to-first'] ? Colors.white : AppColors.nord1,
                            key: 'date-added-to-library-latest-to-first',
                            onSortSelect: () {
                              setALLSortValuesToFlase();
                              sort['date-added-to-library-latest-to-first'] = true;
                              onSortSelect();
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SpaceH14(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget whatsNewTile(title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.check,
            color: Colors.green,
          ),
          SpaceW20(),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: StringConst.trtRegular,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        ],
      ),
    );
  }

  static Future<void> initHive() async {
    Directory dir = await getExternalStorageDirectory();
    Hive.init(dir.path);
  }

  static String numbersToDays(List<int> days) {
    String dayStr = '';

    days.forEach((day) {
      dayStr += numToShortDayMap[day] + ' ';
    });

    return dayStr;
  }

  static void showFlushInfo(BuildContext context, String message) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      boxShadows: const [
        const BoxShadow(
          color: AppColors.nord3,
          offset: const Offset(0.0, 3.0),
          blurRadius: 2.0,
        ),
      ],
      backgroundGradient: const LinearGradient(
        colors: const [
          Colors.blueGrey,
          Colors.black,
        ],
      ),
      isDismissible: true,
      duration: const Duration(seconds: 3),
      progressIndicatorBackgroundColor: AppColors.nord1,
      titleText: Text(
        StringConst.appName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  static void showFlushSuccess(BuildContext context, String message) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      boxShadows: const [
        const BoxShadow(
          color: AppColors.nord3,
          offset: const Offset(0.0, 3.0),
          blurRadius: 2.0,
        ),
      ],
      backgroundGradient: const LinearGradient(
        colors: const [
          Colors.blueGrey,
          Colors.black,
        ],
      ),
      isDismissible: true,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.check,
        color: Colors.greenAccent,
      ),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: AppColors.nord1,
      titleText: Text(
        StringConst.appName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  static void showFlushError(BuildContext context, String message) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      boxShadows: const [
        const BoxShadow(
          color: AppColors.nord3,
          offset: const Offset(0.0, 3.0),
          blurRadius: 2.0,
        ),
      ],
      backgroundGradient: const LinearGradient(
        colors: const [
          Colors.blueGrey,
          Colors.black,
        ],
      ),
      isDismissible: true,
      shouldIconPulse: false,
      borderColor: Colors.redAccent,
      borderWidth: 0.2,
      duration: const Duration(seconds: 3),
      icon: Icon(
        Icons.error,
        color: Colors.red,
        size: 26,
      ),
      progressIndicatorBackgroundColor: AppColors.nord1,
      titleText: Text(
        StringConst.appName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  static void showCustomInfoToast(BuildContext context, String message, {bool showIcon = true}) {
    FToast fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: AppColors.nord2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          showIcon
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                )
              : Container(),
          SpaceW12(),
          Flexible(
            child: Container(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: StringConst.trtRegular,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  static void showCustomErrorToast(BuildContext context, String message) {
    FToast fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.redAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error,
            color: Colors.white,
          ),
          SpaceW12(),
          Text(
            message,
            style: const TextStyle(
              fontFamily: StringConst.trtRegular,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  static void setLimits(bool isPremium) {
    if (isPremium) {
      maxBookCapacity = IntegerConst.maxBookCapacityPro;
      maxGenreCapacity = IntegerConst.maxGenreCapacityPro;
      maxHighlightCapacity = IntegerConst.maxHighlightCapacityPro;
      maxCollectionCapacity = IntegerConst.maxCollectionCapacityPro;
      maxImgSize = IntegerConst.maxImgImgSizePro;
    } else {
      maxBookCapacity = IntegerConst.maxBookCapacity;
      maxGenreCapacity = IntegerConst.maxGenreCapacity;
      maxHighlightCapacity = IntegerConst.maxHighlightCapacity;
      maxCollectionCapacity = IntegerConst.maxCollectionCapacity;
      maxImgSize = IntegerConst.maxImgImgSize;
    }
  }

  static String timeAgo(DateTime time) {
    if (Utils.currentLocale.languageCode == StringConst.tr) {
      timeago.setLocaleMessages(StringConst.tr, timeago.TrMessages());
    }
    return timeago.format(time, locale: Utils.currentLocale.languageCode);
  }

  static List<Book> getBooks(List<QueryDocumentSnapshot> json) {
    List<Book> bookList = [];
    json.forEach((bookData) {
      bookList.add(Book.fromJson(id: bookData.id, json: bookData.data()));
    });
    return bookList;
  }

  static List<Genre> getGenres(List<QueryDocumentSnapshot> json) {
    List<Genre> genreList = [];
    json.forEach((genreData) {
      genreList.add(Genre.fromJson(id: genreData.id, json: genreData.data()));
    });
    return genreList;
  }

  static List<Highlight> getHighlights(List<dynamic> json) {
    List<Highlight> highlightList = [];
    json.asMap().forEach((index, value) {
      highlightList.add(Highlight.fromJson(json: json[index]));
    });
    return highlightList;
  }

  static List<Collection> getCollections(List<QueryDocumentSnapshot> json) {
    List<Collection> collectionList = [];
    json.forEach((collectionData) {
      collectionList.add(Collection.fromJson(id: collectionData.id, json: collectionData.data()));
    });
    return collectionList;
  }

  static List getGraphData(List<dynamic> json) {
    json.forEach((data) {
      data['date'] = (data['date'] as Timestamp).toDate();
    });
    return json;
  }

  static Widget getAvatarImage(String avatar, Color color) {
    Widget image;
    if (avatar == "" || avatar == null) {
      image = Image.asset(
        StringConst.defaultPersonIcon,
        color: color,
      );
    } else {
      image = CustomCachedNetworkImage(
        url: avatar,
      );
    }
    return image;
  }

  static Widget getBookCover(String url) {
    Widget image;
    if (url == "" || url == null) {
      image = Image.asset(StringConst.defaultPersonIcon);
    } else {
      image = CustomCachedNetworkImage(
        url: url,
      );
    }
    return image;
  }

  static Future<ModalOption> showBottomSheet(BuildContext context) async {
    ModalOption option;
    var prefs = await SharedPreferences.getInstance();

    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      backgroundColor: AppColors.grey2,
      context: context,
      builder: (BuildContext bc) {
        GlobalKey _one = GlobalKey();
        return ShowCaseWidget(
          onComplete: (index, key) async {
            await prefs.setBool('showLanguageHelper', false);
          },
          autoPlay: false,
          autoPlayDelay: Duration(seconds: 3),
          autoPlayLockEnable: false,
          builder: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                var result = prefs.getBool('showLanguageHelper');
                if (result == null) {
                  ShowCaseWidget.of(context).startShowCase([_one]);
                }
              });

              return Container(
                child: Wrap(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SpaceH14(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  StringConst.bookCover.tr,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                child: Container(
                                  width: 120,
                                  height: 30,
                                  child: Showcase(
                                    key: _one,
                                    description: StringConst.tapToSetSearchLanguage.tr,
                                    child: Row(
                                      children: [
                                        SpaceW8(),
                                        Text(
                                          StringConst.settings.tr,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        SpaceW10(),
                                        const Icon(
                                          Icons.settings,
                                          color: Colors.white,
                                        ),
                                        SpaceW4(),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  var prefs = await SharedPreferences.getInstance();
                                  String value = prefs.getString('searchEngine');
                                  OnlineSearchOption initialOption;

                                  if (value != null) {
                                    initialOption = getSearchOptionAsEnum(value);
                                  } else {
                                    initialOption = OnlineSearchOption.Bookdepository;
                                  }

                                  var result = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) => CustomOnlineSearchOptionPickerDialog(
                                      initialOption: initialOption,
                                    ),
                                  );
                                  if (result != null) {
                                    prefs.setString('searchEngine', getSearchOptionAsString(result));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SpaceH14(),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 70,
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Get.back();
                                        option = ModalOption.SearchOnline;
                                      },
                                    ),
                                    Text(
                                      StringConst.searchOnline.tr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 10, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 70,
                                child: Column(
                                  children: <Widget>[
                                    Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        IconButton(
                                          icon: const Icon(
                                            FontAwesomeIcons.windowMaximize,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            Get.back();
                                            option = ModalOption.ManualUrl;
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: const Text(
                                            StringConst.www,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 6, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      StringConst.enterUrl.tr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 10, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 70,
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: const Icon(
                                        Icons.photo_size_select_actual,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Get.back();
                                        option = ModalOption.Gallery;
                                      },
                                    ),
                                    Text(
                                      StringConst.takePhotoFromGallery.tr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 10, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 70,
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: const Icon(
                                        Icons.camera,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Get.back();
                                        option = ModalOption.Camera;
                                      },
                                    ),
                                    Text(
                                      StringConst.takePhoto.tr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 10, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 70,
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Get.back();
                                        option = ModalOption.Delete;
                                      },
                                    ),
                                    Text(
                                      StringConst.deleteCover.tr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 10, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SpaceH14(),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    return option;
  }

  static String getBookState(BookState bookState) {
    String state;
    switch (bookState) {
      case BookState.All:
        state = '';
        break;
      case BookState.ToRead:
        state = StringConst.toRead.tr;
        break;
      case BookState.Reading:
        state = StringConst.reading.tr;
        break;
      case BookState.Finished:
        state = StringConst.finished.tr;
        break;
      case BookState.Dropped:
        state = StringConst.dropped.tr;
        break;
      default:
    }
    return state;
  }

  static OnlineSearchOption getSearchOptionAsEnum(String value) {
    OnlineSearchOption option;
    if (value == 'Bookdepository') {
      option = OnlineSearchOption.Bookdepository;
    } else if (value == 'DR') {
      option = OnlineSearchOption.DR;
    }
    return option;
  }

  static String getSearchOptionAsString(OnlineSearchOption value) {
    String option;
    switch (value) {
      case OnlineSearchOption.Bookdepository:
        option = 'Bookdepository';
        break;
      case OnlineSearchOption.DR:
        option = 'DR';
        break;
      default:
    }
    return option;
  }

  static String dateFormatterServer(DateTime dateTime) {
    return formatter.format(dateTime);
  }

  static Future getCoversOnline({String title, String author, OnlineSearchOption option}) async {
    var dio = Dio();

    var imgLinks = [];

    dio.options.headers['user-agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36';

    title = title.isNotEmpty ? title.replaceAll(' ', '%20') : '';
    author = author.isNotEmpty ? author.replaceAll(' ', '%20') : '';

    if (option == OnlineSearchOption.DR) {
      try {
        var url = 'https://www.dr.com.tr/search?Page=1&Q=$title&redirect=search&Person[0]=$author';
        var res = await dio.get(url);

        String bodyString = res.data;

        var soup = Beautifulsoup(bodyString);

        imgLinks = soup.find_all('img').map((e) {
          try {
            var img = (soup.attr(e, "data-src").replaceAll('154x170', '600x600').replaceAll('/300/300/False/', '/400/300/False/'));
            if (img.contains('https://i.dr.com.tr/cache/600x600-0/originals/')) {
              return img;
            }
            return '';
          } catch (e) {
            return '';
          }
        }).toList();
        imgLinks = imgLinks.toSet().toList();
        imgLinks.removeWhere((element) => element == '');
      } catch (e) {
        return StringConst.anErrorOccured.tr;
      }

      return imgLinks;
    } else if (option == OnlineSearchOption.Bookdepository) {
      try {
        var response = await dio.get("https://suggestions.bookdepository.com/suggestions?searchTerm=$title+$author");

        var data = response.data;
        var id;

        title = data['content']['suggestBooks'][0]['title'];
        id = data['content']['suggestBooks'][0]['books'][0]['isbn13'];

        var response2 = await dio.get("https://bookdepository.com/$title/$id");

        var documentF = parse(response2.data);
        var imgFirst = documentF.querySelector('div.item-img-content img').attributes['src'];
        imgLinks.add(imgFirst);
      } catch (e) {}

      try {
        var res = await dio.get("https://www.bookdepository.com/search?searchTerm=$title&search=Find+book");

        var document = parse(res.data);
        var content = document.querySelectorAll('.item-img img');

        for (var i = 0; i < content.length; i++) {
          try {
            imgLinks.add(content[i].attributes['data-lazy'].replaceAll('mid', 'lrg').replaceAll('sml', 'lrg').toString());
          } catch (e) {}
        }

        imgLinks = imgLinks.toSet().toList();
      } catch (e) {
        return StringConst.anErrorOccured.tr;
      }
    }

    return imgLinks;
  }

  static String capitalizeString({String string}) {
    String capitalizedString = '';
    List<String> stringList = string.split(' ');
    for (var i = 0; i < stringList.length; i++) {
      if (stringList[i] == '') {
        continue;
      }
      stringList[i] = stringList[i].replaceAll(' ', '');
      stringList[i] = stringList[i].capitalize;
      capitalizedString += '${stringList[i]} ';
    }
    capitalizedString = capitalizedString.substring(0, capitalizedString.length - 1).trim();
    return capitalizedString;
  }

  static Future captureImage(ImageSource captureMode) async {
    final _picker = ImagePicker();

    try {
      var imageFile = await _picker.getImage(source: captureMode);
      var file = File(imageFile.path);
      return file;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> showAlertDialog(BuildContext context, {String description}) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(StringConst.accessBlocked.tr),
          content: Text(description),
          actions: <Widget>[
            TextButton(
              child: Text(StringConst.close.tr),
              onPressed: () {
                Get.back(result: false);
              },
            ),
            TextButton(
              child: Text(StringConst.appSettings.tr),
              onPressed: () {
                Get.back(result: true);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> showInfoDialog(BuildContext context, {String message}) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            StringConst.success.tr,
          ),
          content: Text(
            message,
            style: TextStyle(
              fontFamily: StringConst.trtRegular,
              fontSize: 14,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(StringConst.close.tr),
              onPressed: () {
                Get.back(result: false);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<File> urlToFile({String imageUrl, String id = ''}) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File('$tempPath$id.png');
    http.Response response = await http.get(imageUrl);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  static Future<void> saveFileToGalery({String path, String coinName}) async {
    var bytes = await rootBundle.load(path);
    await ImageGallerySaver.saveImage(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      name: '${coinName}Qr',
    );
  }

  static Future<Map> checkIfImage(String imageUrl) async {
    bool isImage;
    double size = 0;

    try {
      http.Response response = await http.get(imageUrl);
      if (response.statusCode == 200) {
        String contentType = response.headers['content-type'];
        if (contentType.contains('html') || contentType.contains('text')) {
          isImage = false;
        } else if (contentType.contains('image')) {
          isImage = true;
          size = (response.body.length / 100000);
        } else {
          isImage = false;
        }
      } else {
        isImage = false;
      }
    } catch (e) {
      isImage = false;
    }

    return {
      'isImage': isImage,
      'size': size,
    };
  }

  static void unFocus() {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  }

  static DateFormat getCustomDateFormatter() {
    DateFormat dateFormatter = DateFormat(
      'dd MMMM yyyy',
      selectedLocale != '' && selectedLocale != null ? selectedLocale.split('_')[0] : defaultLocale.split('_')[0],
    );
    return dateFormatter;
  }

  static DateFormat getGoalDateFormatter() {
    DateFormat dateFormatter = DateFormat(
      'MMMM',
      selectedLocale != '' && selectedLocale != null ? selectedLocale.split('_')[0] : defaultLocale.split('_')[0],
    );
    return dateFormatter;
  }

  static DateFormat getGoalViewDateFormatter() {
    DateFormat dateFormatter = DateFormat(
      'MMMM y',
      selectedLocale != '' && selectedLocale != null ? selectedLocale.split('_')[0] : defaultLocale.split('_')[0],
    );
    return dateFormatter;
  }

  static Future<Map> getAppPrefs() async {
    var prefs = await SharedPreferences.getInstance();

    final String value = prefs.getString('localeData');
    final String searchEngine = prefs.getString('searchEngine');
    final bool showSliders = prefs.getBool('showSliders');
    final bool showCollectionTip = prefs.getBool('showCollectionTip');
    final bool showCryptoWarning = prefs.getBool('showCryptoWarning');

    Utils.showCollectionTip = showCollectionTip;
    Utils.showCryptoWarning = showCryptoWarning;
    Utils.defaultView = prefs.getString('defaultView') == 'LIST' ? DefaultView.LIST : DefaultView.GRID;

    if (value == '' || value == null) {
      defaultLocale = Platform.localeName;
      languageCode = defaultLocale.split('_')[0];
      countryCode = defaultLocale.split('_')[1];
      selectedLocale = '';

      await prefs.setString(
        'localeData',
        jsonEncode(
          {
            'defaultLocale': defaultLocale,
            'languageCode': languageCode,
            'countryCode': countryCode,
            'selectedLocale': selectedLocale,
          },
        ),
      );
      await initializeDateFormatting(defaultLocale, null);
    } else {
      var jsonData = json.decode(value);
      languageCode = jsonData['languageCode'];
      countryCode = jsonData['countryCode'];
      defaultLocale = jsonData['defaultLocale'];
      selectedLocale = jsonData['selectedLocale'];

      await initializeDateFormatting(selectedLocale != '' ? selectedLocale : defaultLocale, null);
    }

    if (searchEngine == null) {
      if (languageCode == 'tr') {
        await prefs.setString('searchEngine', 'DR');
      } else {
        await prefs.setString('searchEngine', 'Bookdepository');
      }
    }

    Utils.currentLocale = Utils.selectedLocale != '' && Utils.selectedLocale != null ? Locale(Utils.selectedLocale.split('_')[0], Utils.selectedLocale.split('_')[1]) : Locale(Utils.languageCode, Utils.countryCode);

    Map map = {
      'defaultLocale': defaultLocale,
      'languageCode': languageCode,
      'countryCode': countryCode,
      'selectedLocale': selectedLocale,
      'showSliders': showSliders,
    };

    return map;
  }

  static Future<bool> isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    return true;
  }

  static Future<void> createPdf({String fileName, String markdown}) async {
    var html = mk.markdownToHtml(
      markdown,
    );

    html += """
    <style>
      pre {
        border-radius: 5px; 
        -moz-border-radius: 5px; 
        -webkit-border-radius: 5px;
        border: 1px solid #BCBEC0;
        background: #F1F3F5;
        padding-left: 10px;
        padding-top: 5px;
        padding-bottom: 5px;
        font:12px Monaco,Consolas,"Andale  Mono","DejaVu Sans Mono",monospace
      }

      code {
        border-radius: 5px; 
        -moz-border-radius: 5px; 
        -webkit-border-radius: 5px; 
        border: 1px solid #BCBEC0;
        padding: 2px;
        font:12px Monaco,Consolas,"Andale  Mono","DejaVu Sans Mono",monospace
      }

      pre code {
        border-radius: 0px; 
        -moz-border-radius: 0px; 
        -webkit-border-radius: 0px; 
        border: 0px;
        padding: 2px;
        font:12px Monaco,Consolas,"Andale  Mono","DejaVu Sans Mono",monospace
      }

      p {
        font-size: 14px;
      }

      span {
        font-size: 12px;
        color: grey;
      }
    </style>
    """;

    var data = await Printing.convertHtml(html: html);

    Printing.sharePdf(bytes: data, filename: '$fileName.pdf');
  }
}
